jQuery(document).ready(function($){

	//------------------------------------------------------
	//Basic
	//------------------------------------------------------
	$('#ac01_01').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id'
		}
	);
	$('#ac01_02').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'name_en',
			'per_page'    : 20,
			'navi_num'    : 10
		}
	);
	$('#ac01_03').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'name_en',
			'navi_num'    : 1,
			'navi_simple' : true
		}
	);
	//------------------------------------------------------
	//Sub-info
	//------------------------------------------------------
	$('#ac02_01').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'employee_en',
			'sub_info'    : true
		}
	);
	$('#ac02_02').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'employee_en',
			'sub_info'    : true,
			'sub_as'      : {
				'id'       : 'Employer ID',
				'post'     : 'Post',
				'position' : 'Position'
			}
		}
	);
	$('#ac02_03').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'employee_en',
			'sub_info'    : true,
			'sub_as'      : {
				'post'     : 'Post',
				'position' : 'Position'
			},
			'show_field'  : 'position,post'
		}
	);
	$('#ac02_04').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'employee_en',
			'sub_info'    : true,
			'sub_as'      : {
				'id'       : 'Employer ID'
			},
			'hide_field'  : 'position,post'
		}
	);
	//------------------------------------------------------
	//Select-only
	//------------------------------------------------------
	$('#ac03_01').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'employee_en',
			'sub_info'    : true,
			'select_only' : true
		}
	);
	$('#ac03_02').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id',
			'sub_info'    : true,
			'show_field'  : 'id',
			'select_only' : true,
			'primary_key' : 'name'
		}
	);
	//------------------------------------------------------
	//Mini-size
	//------------------------------------------------------
	$('#ac04_01').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id',
			'mini'        : true
		}
	);
	$('#ac04_02').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'employee_en',
			'mini'        : true,
			'sub_info'    : true,
			'sub_as'      : {
				'id'       : 'Employer ID',
				'post'     : 'Post',
				'position' : 'Position'
			}
		}
	);
	$('#ac04_03').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id',
			'mini'        : true,
			'select_only' : true
		}
	);
	//------------------------------------------------------
	//Package
	//------------------------------------------------------
	$('#ac05_01').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id',
			'package'     : true
		}
	);
	$('#ac05_02').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'employee_en',
			'package'     : true,
			'sub_info'    : true,
			'sub_as'      : {
				'id'       : 'Employer ID',
				'post'     : 'Post',
				'position' : 'Position'
			}
		}
	);
	$('#ac05_03').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id',
			'package'     : true,
			'select_only' : true
		}
	);
	$('#ac05_04').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id',
			'package'     : true,
			'mini'        : true
		}
	);
	//------------------------------------------------------
	//Initial Value
	//------------------------------------------------------
	$('#ac06_01').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id',
			'init_val'    : ['Japan']
		}
	);
	$('#ac06_02').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id',
			'init_val'    : [28],
			'select_only' : true,
			'primary_key' : 'id'
		}
	);
	$('#ac06_03').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'order_field' : 'id',
			'init_val'    : [28,29,30],
			'select_only' : true,
			'primary_key' : 'id',
			'package'     : true
		}
	);
	//------------------------------------------------------
	//for CakePHP
	//------------------------------------------------------
	$('#ac07_01').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'field'       : 'name',
			'order_field' : 'id',
			'cake_rule'   : true
		}
	);
	$('#ac07_02').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'field'       : 'name',
			'order_field' : 'id',
			'select_only' : true,
			'cake_rule'   : true,
			'cake_model'  : 'User',
			'cake_field'  : 'nation_id'
		}
	);
	$('#ac07_03').ajaxComboBox(
		'acbox/php/ajaxComboBox.php',
		{
			'lang'        : 'en',
			'db_table'    : 'nation',
			'field'       : 'name',
			'order_field' : 'id',
			'select_only' : true,
			'cake_rule'   : true,
			'cake_model'  : 'User',
			'cake_field'  : 'nation_id',
			'package'     : true
		}
	);
});

function displayResult(div_id){

	var result = {};
	$('#' + div_id + ' input').each(function(idx){
		result[$(this).attr('name')] = $(this).val();
	});

	var text = '';
	for(var key in result){
		if(result[key] == ''){
			result[key] = '(empty)';
		}
		//text += key + ' : ' + result[key] + '\n';
		text += result[key] + '\n';
	}
	alert(text);
}
