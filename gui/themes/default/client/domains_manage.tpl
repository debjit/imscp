<!-- INCLUDE "../shared/layout/header.tpl" -->
<body>
	<script type="text/javascript">
	/* <![CDATA[ */


		//$(	document).ready(function(){
		//	$('.tablesorter').tablesorter({cssHeader: 'tablesorter'});
		//});


		function action_delete(url, subject) {
			if (!confirm(sprintf("{TR_MESSAGE_DELETE}", subject))) {
				return false;
			}

			location = url;
		}
	/* ]]> */
	</script>

	<div class="header">
		{MAIN_MENU}
		<div class="logo">
			<img src="{ISP_LOGO}" alt="i-MSCP logo"/>
		</div>
	</div>
	<div class="location">
		<div class="location-area">
			<h1 class="domains">{TR_MENU_MANAGE_DOMAINS}</h1>
		</div>
		<ul class="location-menu">
			<!-- BDP: logged_from -->
			<li><a class="backadmin" href="change_user_interface.php?action=go_back">{YOU_ARE_LOGGED_AS}</a></li>
			<!-- EDP: logged_from -->
			<li><a class="logout" href="../index.php?logout">{TR_MENU_LOGOUT}</a></li>
		</ul>
		<ul class="path">
			<li><a href="domains_manage.php">{TR_MENU_MANAGE_DOMAINS}</a></li>
			<li><a href="#" onclick="return false;">{TR_LMENU_OVERVIEW}</a></li>
		</ul>
	</div>
	<div class="left_menu">{MENU}</div>
	<div class="body">
		<h2 class="domains"><span>{TR_MENU_MANAGE_DOMAINS}</span></h2>

		<!-- BDP: page_message -->
		<div class="{MESSAGE_CLS}">{MESSAGE}</div>
		<!-- EDP: page_message -->

		<h3 class="domains"><span>{TR_DOMAINS}</span></h3>

		<!-- BDP: domain_list -->
		<table class="tablesorter">
			<tr>
				<th>{TR_NAME}</th>
				<th>{TR_CREATE_DATE}</th>
				<th>{TR_EXPIRE_DATE}</th>
				<th>{TR_STATUS}</th>
			</tr>
			<!-- BDP: domain_item -->
			<tr>
				<!-- BDP: domain_status_reload_true -->
				<td style="width: 300px">
					<a href="http://{DOMAIN_NAME}/" class="icon i_domain_icon" title="{DOMAIN_NAME}">{DOMAIN_NAME}</a>
				</td>
				<!-- EDP: domain_status_reload_true -->
				<!-- BDP: domain_status_reload_false -->
				<td style="width: 300px">
					<span class="icon i_domain_icon" title="{DOMAIN_NAME}">{DOMAIN_NAME}</span>
				</td>
				<!-- EDP: domain_status_reload_false -->
				<td>{DOMAIN_CREATE_DATE}</td>
				<td>{DOMAIN_EXPIRE_DATE}</td>
				<td>{DOMAIN_STATUS}</td>
			</tr>
			<!-- EDP: domain_item -->
		</table>
		<!-- EDP: domains_list -->

		<!-- BDP: domain_aliases_block -->
		<h3 class="domains"><span>{TR_DOMAIN_ALIASES}</span></h3>

		<!-- BDP: als_message -->
		<div class="info">{ALS_MSG}</div>
		<!-- EDP: als_message -->

		<!-- BDP: als_list -->
		<table class="tablesorter">
			<tr>
				<th>{TR_NAME}</th>
				<th>{TR_MOUNT}</th>
				<th>{TR_REDIRECT}</th>
				<th>{TR_STATUS}</th>
				<th>{TR_ACTIONS}</th>
			</tr>
			<!-- BDP: als_item -->
			<tr>
				<!-- BDP: als_status_reload_true -->
				<td style="width: 300px">
					<a href="http://{ALS_NAME}/" class="icon i_domain_icon" title="{ALS_NAME}">{ALS_NAME}</a>
				</td>
				<!-- EDP: als_status_reload_true -->
				<!-- BDP: als_status_reload_false -->
				<td style="width: 300px">
					<span class="icon i_domain_icon" title="{ALS_NAME}">{ALS_NAME}</span>
				</td>
				<!-- EDP: als_status_reload_false -->
				<td>{ALS_MOUNT}</td>
				<td>{ALS_REDIRECT}</td>
				<td>{ALS_STATUS}</td>
				<td>
					<a class="icon i_edit" href="{ALS_EDIT_LINK}" title="{ALS_EDIT}">{ALS_EDIT}</a>
					<a class="icon i_delete" href="#" onclick="action_delete('{ALS_ACTION_SCRIPT}', '{ALS_NAME}'); return false;" title="{ALS_ACTION}">{ALS_ACTION}</a>
				</td>
			</tr>
			<!-- EDP: als_item -->
		</table>
		<!-- EDP: als_list -->

		<!-- EDP: domain_aliases_block -->
		<!-- BDP: subdomains_block -->
		<h3 class="domains"><span>{TR_SUBDOMAINS}</span></h3>

		<!-- BDP: sub_message -->
		<div class="info">{SUB_MSG}</div>
		<!-- EDP: sub_message -->

		<!-- BDP: sub_list -->
		<table class="tablesorter">
			<tr>
				<th>{TR_NAME}</th>
				<th>{TR_MOUNT}</th>
				<th>{TR_REDIRECT}</th>
				<th>{TR_STATUS}</th>
				<th>{TR_ACTIONS}</th>
			</tr>
			<!-- BDP: sub_item -->
			<tr>
				<!-- BDP: sub_status_reload_true -->
				<td style="width: 300px">
					<a href="http://{SUB_NAME}.{SUB_ALIAS_NAME}/" class="icon i_domain_icon" title="{SUB_NAME}.{SUB_ALIAS_NAME}">{SUB_NAME}.{SUB_ALIAS_NAME}</a>
				</td>
				<!-- EDP: sub_status_reload_true -->
				<!-- BDP: sub_status_reload_false -->
				<td style="width: 300px">
					<span class="icon i_domain_icon" title="{SUB_NAME}.{SUB_ALIAS_NAME}">{SUB_NAME}.{SUB_ALIAS_NAME}</span>
				</td>
				<!-- EDP: sub_status_reload_false -->
				<td>{SUB_MOUNT}</td>
				<td>{SUB_REDIRECT}</td>
				<td>{SUB_STATUS}</td>
				<td>
					<a class="icon i_edit" href="{SUB_EDIT_LINK}" title="{SUB_EDIT}">{SUB_EDIT}</a>
					<a class="icon i_delete" href="#"  onclick="action_delete('{SUB_ACTION_SCRIPT}', '{SUB_NAME}.{SUB_ALIAS_NAME}'); return false;">{SUB_ACTION}</a>
				</td>
			</tr>
			<!-- EDP: sub_item -->
		</table>
		<!-- EDP: sub_list -->

		<!-- EDP: subdomains_block -->
		<!-- BDP: custom_dns_records_block -->
		<h3 class="domains"><span>{TR_DNS}</span></h3>

		<!-- BDP: dns_message -->
		<div class="info">{DNS_MSG}</div>
		<!-- EDP: dns_message -->

		<!-- BDP: dns_list -->
		<table class="tablesorter">
			<tr>
				<th>{TR_DOMAIN_NAME}</th>
				<th>{TR_DNS_NAME}</th>
				<th>{TR_DNS_CLASS}</th>
				<th>{TR_DNS_TYPE}</th>
				<th>{TR_DNS_DATA}</th>
				<th>{TR_DNS_ACTION}</th>
			</tr>
			<!-- BDP: dns_item -->
			<tr>
				<td style="width: 300px"><span class="icon i_domain_icon">{DNS_DOMAIN}</span></td>
				<td>{DNS_NAME}</td>
				<td>{DNS_CLASS}</td>
				<td>{DNS_TYPE}</td>
				<td>{DNS_DATA}</td>
				<td>
					<a class="icon i_edit" href="{DNS_ACTION_SCRIPT_EDIT}" title="{DNS_ACTION_EDIT}">{DNS_ACTION_EDIT}</a>
					<a href="#" class="icon i_delete" onclick="action_delete('{DNS_ACTION_SCRIPT_DELETE}', '{DNS_TYPE_RECORD}'); return false;" title="{DNS_ACTION_DELETE}">{DNS_ACTION_DELETE}</a>
				</td>
			</tr>
			<!-- EDP: dns_item -->
		</table>
		<!-- EDP: dns_list -->
		<!-- EDP: custom_dns_records_block -->
	</div>
<!-- INCLUDE "../shared/layout/footer.tpl" -->
