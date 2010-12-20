#
# Author:: Stephen Delano (<stephen@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/environment'

class Environments < Application

  provides :html
  before :login_required
  before :require_admin, :only => [:create, :update, :destroy]

  # GET /environments
  def index
    @environment_list = begin
                          Chef::Environment.list
                        rescue => e
                          Chef::Log.error("#{e}\n#{e.backtrace.join("\n")}")
                          @_message = "Could not list environments"
                          {}
                        end
    render
  end

  # GET /environments/:id
  def show
    load_environment
    render
  end

  # GET /environemnts/new
  def new
    @environment = Chef::Environment.new
    load_cookbooks
    render
  end

  # POST /environments
  def create
    begin
      @environment = Chef::Environment.new
      @environment.name(params[:name])
      @environment.description(params[:description]) if params[:description] != ''
      @environment.attributes(JSON.parse(params[:attributes])) if params[:attributes] != ''
      @environment.cookbook_versions(search_params_for_cookbook_versions)
      @environment.create
      redirect(url(:environments), :message => { :notice => "Created Environment #{@environment.name}" })
    rescue Chef::Exceptions::ValidationFailed => e
      Chef::Log.debug("Got 400 bad request creating environment #{params[:name]}\n#{format_exception(e)}")
      redirect(url(:new_environment), :message => { :error => "The new environment is not formed correctly. Check for illegal characters in the environment's name or body, and check that the body is formed correctly."})
    rescue Net::HTTPServerException => e
      if bad_request?(e)
        Chef::Log.debug("Got 400 bad request creating environment #{params[:name]}\n#{format_exception(e)}")
        redirect(url(:new_environment), :message => { :error => "The new environment is not formed correctly. Check for illegal characters in the environment's name or body, and check that the body is formed correctly."})
      elsif conflict?(e)
        Chef::Log.debug("Got 409 conflict creating environment #{params[:name]}\n#{format_exception(e)}")
        redirect(url(:new_environment), :message => { :error => "An environment with that name already exists"})
      elsif forbidden?(e)
        # Currently it's not possible to get 403 here. I leave the code here for completeness and may be useful in the future.[nuo]
        Chef::Log.debug("Got 403 forbidden creating environment #{params[:name]}\n#{format_exception(e)}")
        redirect(url(:new_environment), :message => { :error => "Permission Denied. You do not have permission to create an environment."})
      else
        Chef::Log.error("Error communicating with the API server\n#{format_exception(e)}")
        raise
      end
    end
  end

  # GET /environments/:id/edit
  def edit
    load_environment
    load_cookbooks
    render
  end

  # PUT /environments/:id
  def update
    begin
      @environment = Chef::Environment.load(params[:id])
      @environment.description(params[:description]) if params[:description] != ''
      @environment.attributes(JSON.parse(params[:attributes])) if params[:attributes] != ''
      @environment.cookbook_versions(@environment.cookbook_versions.merge!(search_params_for_cookbook_versions))
      @environment.save
      redirect(url(:environment, :id=> params[:id]), :message => { :notice => "Updated Environment #{@environment.name}" })
    rescue => e
      if not_found?(e)
        # Currently it's not possible to get 403 here. I leave the code here for completeness and may be useful in the future.[nuo]
        Chef::Log.debug("Got 404 Not Found updating environment #{params[:id]}\n#{format_exception(e)}")
        redirect(url(:edit_environment, :id=>params[:id]), :message => { :error => "Environment #{params[:id]} not found."})
      elsif forbidden?(e)
        # Currently it's not possible to get 403 here. I leave the code here for completeness and may be useful in the future.[nuo]
        Chef::Log.debug("Got 403 forbidden updating environment #{params[:id]}\n#{format_exception(e)}")
        redirect(url(:edit_environment, :id=>params[:id]), :message => { :error => "Permission Denied. You do not have permission to edit an environment."})
      else
        Chef::Log.error("Error communicating with the API server\n#{format_exception(e)}")
        redirect(url(:edit_environment, :id => params[:id]), :message => { :error => "Error communicating with the API server. Could not update the environment."})
      end
    end
  end

  # DELETE /environments/:id
  def destroy
    begin
      @environment = Chef::Environment.load(params[:id])
      @environment.destroy
      redirect(absolute_url(:environments), :message => { :notice => "Environment #{@environment.name} deleted successfully." }, :permanent => true)
    rescue => e
      Chef::Log.error("#{e}\n#{e.backtrace.join("\n")}")
      @environment_list = Chef::Environment.list()
      @_message = {:error => "Could not delete environment #{params[:id]}: #{e.message}"}
      render :index
    end
  end

  # GET /environments/:environment_id/cookbooks
  def list_cookbooks
    # TODO: rescue loading the environment
    @environment = Chef::Environment.load(params[:environment_id])
    @cookbooks = begin
                   r = Chef::REST.new(Chef::Config[:chef_server_url])
                   r.get_rest("/environments/#{params[:environment_id]}/cookbooks").inject({}) do |res, (cookbook, url)|
                     # we just want the cookbook name and the version
                     res[cookbook] = url.split('/').last
                     res
                   end
                 rescue => e
                   Chef::Log.error("#{e}\n#{e.backtrace.join("\n")}")
                   @_message = "Could not load cookbooks for environment #{params[:environment_id]}"
                   {}
                 end
    render
  end

  # GET /environments/:environment_id/nodes
  def list_nodes
    # TODO: rescue loading the environment
    @environment = Chef::Environment.load(params[:environment_id])
    @nodes = begin
               r = Chef::REST.new(Chef::Config[:chef_server_url])
               r.get_rest("/environments/#{params[:environment_id]}/nodes").keys.sort
             rescue => e
               Chef::Log.error("#{e}\n#{e.backtrace.join("\n")}")
               @_message = "Could not load nodes for environment #{params[:environment_id]}"
               []
             end
    render
  end

  # GET /environments/:environment_id/set
  def select_environment
    name = params[:environment_id]
    referer = request.referer || "/nodes"
    if name == '_none'
      session[:environment] = nil
    else
      # TODO: check if environment exists
      session[:environment] = name
    end
    redirect referer
  end

  private

  def load_environment
    begin
      @environment = Chef::Environment.load(params[:id])
    rescue Net::HTTPServerException => e
      if not_found?(e)
        Chef::Log.debug("API server returned 404 when requesting environment #{params[:id]}\n#{format_exception(e)}")
        redirect(url(:environments), :message => {:error => "Environment #{params[:id]} not found."})
      elsif forbidden?(e)
        # Currently, 403 may not be returned but leave this case here for completeness
        Chef::Log.debug("API server returned 403 when requesting environment #{params[:id]}\n#{format_exception(e)}")
        redirect(url(:environments), :message => {:error => "Permission denied. You do not have permission to view the environment."})
      else
        Chef::Log.error(format_exception(e))
        redirect(url(:environments), :message => {:error => "Could not load environment #{params[:id]}"})
      end
    end
  end

  def load_cookbooks
    begin
      # @cookbooks is a hash, keys are cookbook names, values are their URIs.
      @cookbooks = Chef::REST.new(Chef::Config[:chef_server_url]).get_rest("cookbooks").keys
    rescue Net::HTTPServerException => e
      Chef::Log.error(format_exception(e))
      redirect(url(:new_environment), :message => { :error => "Could not load the list of available cookbooks."})
    end
  end

  def search_params_for_cookbook_versions
    cookbooks = {}
    params.each do |k,v|
      combobox_id = k[/cookbooks_box_(\d+)/, 1]
      unless combobox_id.nil?
        cookbooks[v] = params["conditions_box_#{combobox_id}"]
      end
    end
    cookbooks
  end

end