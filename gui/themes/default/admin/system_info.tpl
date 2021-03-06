<!-- INCLUDE "../shared/layout/header.tpl" -->
        <div class="header">
            {MAIN_MENU}
            <div class="logo">
                <img src="{ISP_LOGO}" alt="i-MSCP logo" />
            </div>
        </div>

        <div class="location">
            <div class="location-area">
                <h1 class="webtools">{TR_MENU_SYSTEM_TOOLS}</h1>
            </div>
            <ul class="location-menu">
                <li><a class="logout" href="../index.php?logout">{TR_MENU_LOGOUT}</a></li>
            </ul>
            <ul class="path">
                <li><a href="system_info.php">{TR_MENU_SYSTEM_TOOLS}</a></li>
            </ul>
        </div>

        <div class="left_menu">
            {MENU}
        </div>

        <div class="body">
            <h2 class="tools"><span>{TR_SYSTEM_INFO}</span></h2>

			<!-- BDP: page_message -->
			<div class="{MESSAGE_CLS}">{MESSAGE}</div>
			<!-- EDP: page_message -->

            <!-- BDP: props_list -->
            <table>
                <tr>
                    <td>{TR_KERNEL}</td>
                    <td>{KERNEL}</td>
                </tr>
                <tr>
                    <td>{TR_UPTIME}</td>
                    <td>{UPTIME}</td>
                </tr>
                <tr>
                    <td>{TR_LOAD}</td>
                    <td>{LOAD}</td>
                </tr>
            </table>

            <!-- EDP: props_list -->
            <h2 class="tools"><span>{TR_CPU_SYSTEM_INFO}</span></h2>

            <table>
                <tr>
                    <td>{TR_CPU_MODEL}</td>
                    <td >{CPU_MODEL}</td>
                </tr>
                <tr>
                    <td>{TR_CPU_COUNT}</td>
                    <td>{CPU_COUNT}</td>
                </tr>
                <tr>
                    <td>{TR_CPU_MHZ}</td>
                    <td>{CPU_MHZ}</td>
                </tr>
                <tr>
                    <td>{TR_CPU_CACHE}</td>
                    <td>{CPU_CACHE}</td>
                </tr>
                <tr>
                    <td>{TR_CPU_BOGOMIPS}</td>
                    <td>{CPU_BOGOMIPS}</td>
                </tr>
            </table>

            <h2 class="tools"><span>{TR_MEMRY_SYSTEM_INFO}</span></h2>

			<table>
				<tr>
					<th>{TR_RAM}</th>
					<th>{TR_TOTAL}</th>
					<th>{TR_USED}</th>
					<th>{TR_FREE}</th>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td>{RAM_TOTAL}</td>
					<td>{RAM_USED}</td>
					<td>{RAM_FREE}</td>
				</tr>
			</table>

			<table>
				<tr>
					<th>{TR_SWAP}</th>
					<th>{TR_TOTAL}</th>
					<th>{TR_USED}</th>
					<th>{TR_FREE}</th>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td>{SWAP_TOTAL}</td>
					<td>{SWAP_USED}</td>
					<td>{SWAP_FREE}</td>
				</tr>
			</table>

            <h2 class="tools"><span>{TR_FILE_SYSTEM_INFO}</span></h2>

            <!-- BDP: disk_list -->
            <table>
                <tr>
                    <th>{TR_MOUNT}</th>
                    <th>{TR_TYPE}</th>
                    <th>{TR_PARTITION}</th>
                    <th>{TR_PERCENT}</th>
                    <th>{TR_FREE}</th>
                    <th>{TR_USED}</th>
                    <th>{TR_SIZE}</th>
                </tr>
                <!-- BDP: disk_list_item -->
                <tr>
                    <td>{MOUNT}</td>
                    <td>{TYPE}</td>
                    <td>{PARTITION}</td>
                    <td>{PERCENT}%</td>
                    <td>{FREE}</td>
                    <td>{USED}</td>
                    <td>{SIZE}</td>
                </tr>
                <!-- EDP: disk_list_item -->
            </table>
            <!-- EDP: disk_list -->
        </div>
<!-- INCLUDE "../shared/layout/footer.tpl" -->
