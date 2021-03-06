{* 
TestLink Open Source Project - http://testlink.sourceforge.net/
@filesource	tcView.tpl

Purpose: smarty template - view test case in test specification

@internal revisions
*}

{config_load file="input_dimensions.conf"}
{lang_get var='labels' 
          s='no_records_found,other_versions,show_hide_reorder,version,title_test_case,match_count'}

{include file="inc_head.tpl" openHead='yes'}
<script language="JavaScript" src="gui/javascript/expandAndCollapseFunctions.js" type="text/javascript"></script>
{include file="inc_action_onclick.tpl"}

<script type="text/javascript">
/* All this stuff is needed for logic contained in inc_del_onclick.tpl */
var target_action=fRoot+'{$gui->deleteStepAction}';
</script>

{include file="inc_ext_js.tpl" css_only=1}

{* need by refresh on upload logic used when this template is called while executing *}
{if $gui->bodyOnLoad != ''}
  <script language="JavaScript">
  var {$gui->dialogName} = new std_dialog('&refreshTree');
  </script>  
{/if}


<script language="JavaScript">
function validateStepsReorder(formOID)
{
  // var formObj=document.getElementById(formOID);
	// var all_inputs = formObj.getElementsByTagName('input');
	// var input_element;
	// var check_id='';
	// var apieces='';
	// var combo_id_suffix='';
	// var cb_id= new Array();
	// var jdx=0;
	// var idx=0;
	// var step_set = new Array();	
  // 
	// // Build an array with the html select ids
	// alert('formsQty:' + document.forms.length);
  // 
  // alert(document.forms[0].name);
  // alert(document.forms[1].name);
  // alert(document.forms[2].name);
  // alert(document.forms[2].id);
  // f=document.getElementById(document.forms[1].id);
	// all_inputs = formObj.getElementsByTagName('input');
  // 
	// alert('validateStepsReorder');
	// alert(formOID);
	// alert(formObj);
	// alert(all_inputs);
	// alert(all_inputs.length);
	// alert(formOID + '::' + formObj.getElementsByTagName('input').length);
	// 
	// for(idx = 0; idx < all_inputs.length; idx++)
	// {
	//   input_element=all_inputs[idx];		
	//   alert(input_element.type + ':' + input_element.name);
	// 	if(input_element.type == "text")
	// 	{
  //     step_set[jdx]=input_element.value;
  //     jdx++;
	// 	}	
	// }
	// alert(step_set);
  return true;
}	


// var sorted_arr = arr.sort(); // You can define the comparing function here. JS default uses a crappy string compare.
// var results = [];
// for (var i = 0; i < arr.length - 1; i += 1) {
//         if (sorted_arr[i + 1] == sorted_arr[i]) {
//                 results.push(sorted_arr[i]);
//         }
// }
</script>  

</head>

{$my_style = ""}
{if $gui->hilite_testcase_name}
  {$my_style = "background:#059; color:white; margin:0px 0px 4px 0px;padding:3px;"}
{/if}

<body onLoad="viewElement(document.getElementById('other_versions'),false);{$gui->bodyOnLoad}" onUnload="{$gui->bodyOnUnload}">
<h1 class="title">{$gui->pageTitle|escape}</h1>

{include file="inc_update.tpl" user_feedback=$gui->user_feedback refresh=$gui->refreshTree}
<div class="workBack">

{if $gui->tc_current_version}
{section name=idx loop=$gui->tc_current_version}

		{$tcID = $gui->tc_current_version[idx][0].testcase_id}

    {* Current active version *}
    {if $gui->testcase_other_versions[idx] neq null}
        {$my_delete_version = "yes"}
    {else}
        {$my_delete_version = "no"}
    {/if}
  
    <h2 style="{$my_style}">
	  {$tlImages.toggle_direct_link} &nbsp;
	  {if $gui->display_testcase_path}
	      {foreach from=$gui->path_info[$tcID] item=path_part}
	          {$path_part|escape} /
	      {/foreach}
	  {/if}
    {if $gui->show_title == 'no'}
	    {$gui->tc_current_version[idx][0].tc_external_id|escape}:{$gui->tc_current_version[idx][0].name|escape}</h2>
    {/if}
    <div class="direct_link" style='display:none'><a href="{$gui->direct_link}" target="_blank">{$gui->direct_link}</a></div>
		{include file="testcases/tcView_viewer.tpl" 
		         args_testcase = $gui->tc_current_version[idx][0]
		         args_keywords_map = $gui->keywords_map[idx] 
		         args_reqs = $gui->arrReqs[idx] 
		         args_status_quo = $gui->status_quo[idx]
		         args_can_do = $gui->can_do
		         args_can_move_copy="yes"
		         args_can_delete_testcase="yes" 
		         args_can_delete_version=$my_delete_version

		         args_show_version="yes" 
		         args_show_title=$gui->show_title
		         args_activate_deactivate_name='activate'
		         args_activate_deactivate='bnt_activate'
		         args_cf = $gui->cf_current_version[idx] 
		         args_tcase_cfg = $gui->tcase_cfg
		         args_users = $gui->users
		         args_tproject_name = $gui->tprojectName
		         args_tsuite_name = $gui->parentTestSuiteName
		         args_linked_versions = $gui->linked_versions[idx]
		         args_has_testplans = $gui->has_testplans}
		
		
    {include file="inc_attachments.tpl" attach=$gui->attach[$tcID]}
		
		
		
		         
	{* Other Versions *}
    {if $gui->testcase_other_versions[idx] neq null}
        {$vid = $gui->tc_current_version[idx][0].id}
        {$div_id = "vers_$vid"}
        {$memstatus_id = "mem_$div_id"}
        <br />
        {include file="inc_show_hide_mgmt.tpl" 
                 show_hide_container_title=$labels.other_versions
                 show_hide_container_id=$div_id
                 show_hide_container_draw=false
                 show_hide_container_class='exec_additional_info'
                 show_hide_container_view_status_id=$memstatus_id}
               
        <div id="vers_{$vid}" class="workBack">
        
  	    {foreach from=$gui->testcase_other_versions[idx] item=my_testcase key=tdx}

            {$version_num = $my_testcase.version}
            {$title = $labels.version}
            {$title = "$title $version_num"}
            
            {$sep="_"}
            {$div_id="v_$vid"}
            {$div_id="$div_id$sep$version_num"}
            {$memstatus_id="mem_$div_id"}
            {include file="inc_show_hide_mgmt.tpl" 
                     show_hide_container_title=$title
                     show_hide_container_id=$div_id
                     show_hide_container_draw=false
                     show_hide_container_class='exec_additional_info'
                     show_hide_container_view_status_id=$memstatus_id}
                     
  	          <div id="{$div_id}" class="workBack">
				      {*
				      BE CAREFUL
				          args_cf=$gui->cf_other_versions[idx][tdx]  - KO
           			  args_cf=$gui->cf_other_versions[$idx][$tdx]  - KO
           			  args_cf=$gui->cf_other_versions[$idx][tdx]  - KO
           			  args_cf=$gui->cf_other_versions[idx][$tdx] - OK 
           			   - do not know if there is info on smarty manuals
				      *}
				      {include file="testcases/tcView_viewer.tpl" 
                       args_testcase=$my_testcase 
                       args_keywords_map=$gui->keywords_map[idx] 
                       args_reqs=$gui->arrReqs[idx]
                       args_status_quo=$gui->status_quo[idx]
                       args_can_do=$gui->can_do
         		           args_can_move_copy="no" 
                       args_can_delete_testcase='no'
                       args_can_delete_version="yes"
                       
                       args_show_version="no" 
                       args_show_title="no"
                       args_users=$gui->users
                       args_cf=$gui->cf_other_versions[idx][$tdx]
           		         args_linked_versions=null
	         		         args_has_testplans=$gui->has_testplans}
  	         </div>
  	         <br />
  	         
		    {/foreach}
		    </div>
  
      	{* Force the div of every old version to show closed as first state *}
      	<script type="text/javascript">
 	  	  viewElement(document.getElementById('vers_{$vid}'),false);
    	  {foreach item=my_testcase from=$gui->testcase_other_versions[idx]}
  	  	  viewElement(document.getElementById('v_{$vid}_{$my_testcase.version}'),false);
			  {/foreach}
      	</script>
    {/if}
    <br>
{/section}
{else}
  {if isset($gui->warning_msg)}
	  {$gui->warning_msg}
	{else}
	  {$labels.no_records_found}
	{/if}
{/if}
</div>
{if $gui->refreshTree} {$tlRefreshTreeJS} {/if}
</body>
</html>