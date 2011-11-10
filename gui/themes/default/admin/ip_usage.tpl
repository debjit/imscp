<!-- INCLUDE "../shared/layout/header.tpl" -->
    <body>
        <div class="header">
            {MAIN_MENU}
            <div class="logo">
                <img src="{ISP_LOGO}" alt="i-MSCP logo" />
            </div>
        </div>
        <div class="location">
            <div class="location-area">
                <h1 class="statistics">{TR_MENU_IP_USAGE}</h1>
            </div>
            <ul class="location-menu">
                <!-- <li><a class="help" href="#">Help</a></li> -->
                <li><a class="logout" href="../index.php?logout">{TR_MENU_LOGOUT}</a>
                </li>
            </ul>
            <ul class="path">
                <li><a href="server_statistic.php">{TR_MENU_STATISTICS}</a></li>
                <li><a href="ip_usage.php">{TR_IP_ADMIN_USAGE_STATISTICS}</a></li>
            </ul>
        </div>
        <div class="left_menu">
            {MENU}
        </div>
        <div class="body">
            <h2 class="general"><span>{TR_IP_ADMIN_USAGE_STATISTICS}</span></h2>

            <!-- BDP: page_message -->
            <div class="{MESSAGE_CLS}">{MESSAGE}</div>
            <!-- EDP: page_message -->

            <!-- BDP: statistics -->
            <table>
                <!-- BDP: ip_row -->
                <thead>
                    <tr>
                        <th colspan="5">{IP}</th>
                    </tr>
                </thead>
                <tr>
                    <td>&nbsp;</td>
                    <td style="width:300px;"><b>{TR_DOMAIN_NAME}</b></td>
                    <td><b>{TR_RESELLER_NAME}</b></td>
                </tr>
                <!-- BDP: domain_row -->
                <tr>
                    <td width="25">&nbsp;</td>
                    <td>{DOMAIN_NAME}</td>
                    <td>{RESELLER_NAME}</td>
                </tr>
                <!-- EDP: domain_row -->
                <tr>
                    <td>&nbsp;</td>
                    <td colspan="5"><b>{RECORD_COUNT}</b></td>
                </tr>
                <!-- EDP: ip_row -->
            </table>
            <!-- EDP: statistics -->
        </div>
<!-- INCLUDE "../shared/layout/footer.tpl" -->
