<?xml version="1.0" encoding="{THEME_CHARSET}" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset={THEME_CHARSET}" />
        <meta http-equiv="X-UA-Compatible" content="IE=8" />
        <title>{TR_ADMIN_ADMIN_LOG_PAGE_TITLE}</title>
        <meta name="robots" content="nofollow, noindex" />
        <link href="{THEME_COLOR_PATH}/css/imscp.css" rel="stylesheet" type="text/css" />
        <!--[if IE 6]>
        <script type="text/javascript" src="{THEME_COLOR_PATH}/js/DD_belatedPNG_0.0.8a-min.js"></script>
        <script type="text/javascript">
            DD_belatedPNG.fix('*');
        </script>
        <![endif]-->
    </head>

    <body>

        <div class="header">
            {MAIN_MENU}

            <div class="logo">
                <img src="{THEME_COLOR_PATH}/images/imscp_logo.png" alt="i-MSCP logo" />
                <img src="{THEME_COLOR_PATH}/images/imscp_webhosting.png" alt="i-MSCP" />
            </div>
        </div>

        <div class="location">
            <div class="location-area icons-left">
                <h1 class="general">{TR_MENU_GENERAL_INFORMATION}</h1>
            </div>
            <ul class="location-menu">
                <!-- <li><a class="help" href="#">Help</a></li> -->
                <li><a class="logout" href="../index.php?logout">{TR_MENU_LOGOUT}</a></li>
            </ul>
            <ul class="path">
                <li><a href="index.php">{TR_MENU_GENERAL_INFORMATION}</a></li>
                <li><a href="admin_log.php">{TR_ADMIN_LOG}</a></li>
            </ul>
        </div>

        <div class="left_menu">
            {MENU}
        </div>


        <div class="body">

            <h2 class="admin_lod"><span>{TR_ADMIN_LOG}</span></h2>
            <form name="admin_lod" method="post" action="admin_log.php">
                <!-- BDP: clear_log -->
                <label for="uaction_clear">{TR_CLEAR_LOG_MESSAGE}</label>
                <select name="uaction_clear" id="uaction_clear">
                    <option value="0" selected="selected">{TR_CLEAR_LOG_EVERYTHING}</option>
                    <option value="2">{TR_CLEAR_LOG_LAST2}</option>
                    <option value="4">{TR_CLEAR_LOG_LAST4}</option>
                    <option value="12">{TR_CLEAR_LOG_LAST12}</option>
                    <option value="26">{TR_CLEAR_LOG_LAST26}</option>
                    <option value="52">{TR_CLEAR_LOG_LAST52}</option>
                </select>
                <!-- EDP: clear_log -->
                <input name="Submit" type="submit" class="button" value="{TR_CLEAR_LOG}" />
                <input type="hidden" name="uaction" value="clear_log" />
            </form>

            <table>
                <tr>
                    <th>{TR_DATE}</th>
                    <th>{TR_MESSAGE}</th>
                </tr>
                <!-- BDP: log_row -->
                <tr>
                    <td class="{ROW_CLASS}">{DATE}</td>
                    <td class="{ROW_CLASS}">{MESSAGE}</td>
                </tr>
                <!-- EDP: log_row -->
            </table>
            <div class="paginator">
                <!-- BDP: scroll_next_gray -->
                    <a class="icon i_next_gray" href="#">&nbsp;</a>
                <!-- EDP: scroll_next_gray -->
                <!-- BDP: scroll_next -->
                    <a class="icon i_next" href="admin_log.php?psi={NEXT_PSI}" title="next">next</a>
                <!-- EDP: scroll_next -->
                <!-- BDP: scroll_prev -->
                    <a class="icon i_prev" href="admin_log.php?psi={PREV_PSI}" title="previous">previous</a>
                <!-- EDP: scroll_prev -->
                <!-- BDP: scroll_prev_gray -->
                    <a class="icon i_prev_gray" href="#">&nbsp;</a>
                <!-- EDP: scroll_prev_gray -->
            </div>


        </div>
        <div class="footer">
            i-MSCP {VERSION}<br />build: {BUILDDATE}<br />Codename: {CODENAME}
        </div>
</body>
</html>
