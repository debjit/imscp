<?xml version="1.0" encoding="{THEME_CHARSET}" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset={THEME_CHARSET}" />
        <meta http-equiv="X-UA-Compatible" content="IE=8" />
        <title>{TR_ADMIN_SOFTWARE_PAGE_TITLE}</title>
        <meta name="robots" content="nofollow, noindex" />
        <link href="{THEME_COLOR_PATH}/css/imscp.css" rel="stylesheet" type="text/css" />
        <script type="text/javascript" src="{THEME_COLOR_PATH}/js/imscp.js"></script>
        <script type="text/javascript" src="{THEME_COLOR_PATH}/js/jquery.js"></script>
		<script type="text/javascript" src="{THEME_COLOR_PATH}/js/jquery.imscpTooltips.js"></script>
        <!--[if IE 6]>
        <script type="text/javascript" src="{THEME_COLOR_PATH}/js/DD_belatedPNG_0.0.8a-min.js"></script>
        <script type="text/javascript">
            DD_belatedPNG.fix('*');
        </script>
         <![endif]-->
        <script language="JavaScript" type="text/JavaScript">
        /*<![CDATA[*/
			$(document).ready(function(){
				// Tooltips - begin
				$('span.i_app_installer').sw_iMSCPtooltips('span.title');
				// Tooltips - end
			});
			$(document).ready(function(){
				// Tooltips - begin
				$('span.i_help').iMSCPtooltips('span.title');
				// Tooltips - end
			});
		/*]]>*/
		</script>
	</head>

    <body>

        <div class="header">
            {MAIN_MENU}

            <div class="logo">
                <img src="{THEME_COLOR_PATH}/images/imscp_logo.png" alt="i-MSCP logo" />
            </div>
        </div>

        <div class="location">
            <div class="location-area icons-left">
			<h1 class="manage_users">{TR_MENU_MANAGE_USERS}</h1>
		</div>
		<ul class="location-menu">
                <!-- <li><a class="help" href="#">Help</a></li> -->
                <li><a class="logout" href="../index.php?logout">{TR_MENU_LOGOUT}</a></li>
            </ul>
            <ul class="path">
                <li><a href="software_manage.php">{TR_MENU_MANAGE_SOFTWARE}</a></li>
                <li><a href="software_reseller.php?id={RESELLER_ID}">{TR_SOFTWARE_DEPOT}</a></li>
            </ul>
        </div>

        <div class="left_menu">
            {MENU}
        </div>

        <div class="body">
        
        	<!-- BDP: page_message -->
            <div class="{MESSAGE_CLS}">{MESSAGE}</div>
            <!-- EDP: page_message -->
            
            <h2 class="apps_installer"><span>{TR_SOFTWARE_DEPOT}</span></h2>
            <table>
            	<tr>
					<th>{TR_SOFTWARE_NAME}</th>
					<th width="90">{TR_SOFTWARE_INSTALLED}</th>
					<th width="90">{TR_SOFTWARE_VERSION}</th>
					<th width="90">{TR_SOFTWARE_LANGUAGE}</th>
					<th width="90">{TR_SOFTWARE_TYPE}</th>
				</tr>
				<!-- BDP: no_softwaredepot_list -->
				<tr>
					<td colspan="5"><div class="warning">{NO_SOFTWAREDEPOT}</div></td>
				</tr>
				<!-- EDP: no_softwaredepot_list -->
				<!-- BDP: list_softwaredepot -->
				<tr>
					<td><span class="icon i_app_installer" title="{TR_TOOLTIP}">{TR_NAME}</span></td>
					<td align="center"><span class="icon i_help" id="tld_help" title="{SW_INSTALLED}">help</span></td>
					<td>{TR_VERSION}</td>
					<td>{TR_LANGUAGE}</td>
					<td>{TR_TYPE}</td>
				</tr>
				<!-- EDP: list_softwaredepot -->
				<tr>
					<th colspan="5">{TR_SOFTWAREDEPOT_COUNT}:&nbsp;{TR_SOFTWAREDEPOT_NUM}</th>
				</tr>
            </table>
            <br />
            <h2 class="apps_installer"><span>{TR_ACTIVATED_SOFTWARE}</span></h2>
            <table>
            	<tr>
					<th>{TR_RESELLER_NAME}</th>
					<th align="center" width="150">{TR_RESELLER_COUNT_SWDEPOT}</th>
					<th align="center" width="150">{TR_RESELLER_COUNT_WAITING}</th>
					<th align="center" width="150">{TR_RESELLER_COUNT_ACTIVATED}</th>
					<th align="center" width="150">{TR_RESELLER_SOFTWARE_IN_USE}</th>
				</tr>
				<!-- BDP: no_reseller_list -->
				<tr>
					<td colspan="5"><div class="warning">{NO_RESELLER}</div></td>
				</tr>
				<!-- EDP: no_reseller_list -->
				<!-- BDP: list_reseller -->
				<tr>
					<td>{RESELLER_NAME}</td>
					<td align="center">{RESELLER_COUNT_SWDEPOT}</td>
					<td align="center">{RESELLER_COUNT_WAITING}</td>
					<td align="center">{RESELLER_COUNT_ACTIVATED}</td>
					<td align="center"><a href="software_reseller.php?id={RESELLER_ID}">{RESELLER_SOFTWARE_IN_USE}</a></td>
				</tr>
				<!-- EDP: list_reseller -->
				<tr>
					<th colspan="5">{TR_RESELLER_ACT_COUNT}:&nbsp;{TR_RESELLER_ACT_NUM}</th>
				</tr>
            </table>
            <div class="paginator">
                
            </div>

        </div>

    </body>
</html>