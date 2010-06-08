require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Chef::Knife::Configure do
  before do
    @knife = Chef::Knife::Configure.new
    @rest_client = mock("null rest client", :post_rest => { :result => :true })
    @knife.stub!(:rest).and_return(@rest_client)

    @out = StringIO.new
    @knife.stub!(:stdout).and_return(@out)
    @knife.config[:config_file] = '/home/you/.chef/knife.rb'

    @in = StringIO.new("\n" * 7)
    @knife.stub!(:stdin).and_return(@in)
  end

  it "asks the user for the URL of the chef server" do
    @knife.ask_user_for_config
    @out.string.should match(Regexp.escape('Your chef server URL? [http://localhost:4000]'))
    @knife.chef_server.should == 'http://localhost:4000'
  end

  it "asks the user for the user name they want for the new client" do
    @knife.ask_user_for_config
    @out.string.should match(Regexp.escape("Select a user name for your new client: [#{Etc.getlogin}]"))
    @knife.new_client_name.should == Etc.getlogin
  end
  
  it "asks the user for the existing admin client's name if -i is specified" do
    @knife.config[:initial] = true
    @knife.ask_user_for_config
    @out.string.should match(Regexp.escape("Your existing admin client user name? [chef-webui]"))
    @knife.admin_client_name.should == 'chef-webui'
  end
  
  it "should not ask the user for the existing admin client's name if -i is not specified" do
    @knife.ask_user_for_config
    @out.string.should_not match(Regexp.escape("Your existing admin client user name? [chef-webui]"))
    @knife.admin_client_name.should_not == 'chef-webui'
  end
  
  it "asks the user for the location of the existing admin key if -i is specified" do
    @knife.config[:initial] = true
    @knife.ask_user_for_config
    @out.string.should match(Regexp.escape("The location of your existing admin key? [/etc/chef/webui.pem]"))
    @knife.admin_client_key.should == '/etc/chef/webui.pem'
  end
  
  it "should not ask the user for the location of the existing admin key if -i is not specified" do
    @knife.ask_user_for_config
    @out.string.should_not match(Regexp.escape("The location of your existing admin key? [/etc/chef/webui.pem]"))
    @knife.admin_client_key.should_not == '/etc/chef/webui.pem'
  end
  
  it "asks the user for the location of a chef repo" do
    @knife.ask_user_for_config
    @out.string.should match(Regexp.escape("Path to a chef repository (or leave blank)?"))
    @knife.chef_repo.should == ''
  end
  
  it "asks the users for the name of the validation client" do
    @knife.ask_user_for_config
    @out.string.should match(Regexp.escape("Your validation client user name? [chef-validator]"))
    @knife.validation_client_name.should == 'chef-validator'
  end
  
  it "asks the users for the location of the validation key" do
    @knife.ask_user_for_config
    @out.string.should match(Regexp.escape("The location of your validation key? [/etc/chef/validation.pem]"))
    @knife.validation_key.should == '/etc/chef/validation.pem'
  end
  
  it "writes the new data to a config file" do
    FileUtils.should_receive(:mkdir_p).with("/home/you/.chef")
    config_file = StringIO.new
    ::File.should_receive(:open).with("/home/you/.chef/knife.rb", "w").and_yield config_file
    @knife.config[:repository] = '/home/you/chef-repo'
    @knife.run
    config_file.string.should match(/^node_name[\s]+'#{Etc.getlogin}'$/)
    config_file.string.should match(%r{^client_key[\s]+'/home/you/.chef/#{Etc.getlogin}.pem'$})
    config_file.string.should match(/^validation_client_name\s+'chef-validator'$/)
    config_file.string.should match(%r{^validation_key\s+'/etc/chef/validation.pem'$})
    config_file.string.should match(%r{^chef_server_url\s+'http://localhost:4000'$})
    config_file.string.should match(%r{cookbook_path\s+\[ '/home/you/chef-repo/cookbooks', '/home/you/chef-repo/site-cookbooks' \]})
  end
  
  it "creates a new client when given the --initial option" do
    client_command = Chef::Knife::ClientCreate.new
    client_command.should_receive(:run)
    
    Chef::Knife::ClientCreate.stub!(:new).and_return(client_command)
    FileUtils.should_receive(:mkdir_p).with("/home/you/.chef")
    ::File.should_receive(:open).with("/home/you/.chef/knife.rb", "w")
    @knife.config[:initial] = true
    @knife.run
    client_command.name_args.should == Array(Etc.getlogin)
    client_command.config[:admin].should be_true
    client_command.config[:file].should == "/home/you/.chef/#{Etc.getlogin}.pem"
    client_command.config[:yes].should be_true
    client_command.config[:no_editor].should be_true
  end
end
