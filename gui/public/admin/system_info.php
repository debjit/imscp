<?php
/**
 * i-MSCP a internet Multi Server Control Panel
 *
 * @copyright 	2001-2006 by moleSoftware GmbH
 * @copyright 	2006-2010 by ispCP | http://isp-control.net
 * @copyright 	2010 by i-MSCP | http://i-mscp.net
 * @version 	SVN: $Id$
 * @link 		http://i-mscp.net
 * @author 		ispCP Team
 * @author 		i-MSCP Team
 *
 * @license
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is "VHCS - Virtual Hosting Control System".
 *
 * The Initial Developer of the Original Code is moleSoftware GmbH.
 * Portions created by Initial Developer are Copyright (C) 2001-2006
 * by moleSoftware GmbH. All Rights Reserved.
 * Portions created by the ispCP Team are Copyright (C) 2006-2010 by
 * isp Control Panel. All Rights Reserved.
 * Portions created by the i-MSCP Team are Copyright (C) 2010 by
 * i-MSCP a internet Multi Server Control Panel. All Rights Reserved.
 */

require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onAdminScriptStart);

check_login(__FILE__);

$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic('page', $cfg->ADMIN_TEMPLATE_PATH . '/system_info.tpl');
$tpl->define_dynamic('page_message', 'page');
$tpl->define_dynamic('hosting_plans', 'page');
$tpl->define_dynamic('disk_list', 'page');
$tpl->define_dynamic('disk_list_item', 'disk_list');

$sysinfo = new iMSCP_SystemInfo();

$tpl->assign(
	array(
		'CPU_MODEL'				=> tohtml($sysinfo->cpu['model']),
		'CPU_COUNT'				=> tohtml($sysinfo->cpu['cpus']),
		'CPU_MHZ'				=> tohtml($sysinfo->cpu['cpuspeed']),
		'CPU_CACHE'				=> tohtml($sysinfo->cpu['cache']),
		'CPU_BOGOMIPS'			=> tohtml($sysinfo->cpu['bogomips']),
		'UPTIME'				=> tohtml($sysinfo->uptime),
		'KERNEL'				=> tohtml($sysinfo->kernel),
		'LOAD'					=> $sysinfo->load[0] .' '.
									$sysinfo->load[1] .' '.
									$sysinfo->load[2],
		'RAM_TOTAL'				=> numberBytesHuman($sysinfo->ram['total'] * 1024),
		'RAM_USED'				=> numberBytesHuman($sysinfo->ram['used'] * 1024),
		'RAM_FREE'				=> numberBytesHuman($sysinfo->ram['free'] * 1024),
		'SWAP_TOTAL'			=> numberBytesHuman($sysinfo->swap['total'] * 1024),
		'SWAP_USED'				=> numberBytesHuman($sysinfo->swap['used'] * 1024),
		'SWAP_FREE'				=> numberBytesHuman($sysinfo->swap['free'] * 1024),
	)
);

$mount_points = $sysinfo->filesystem;

foreach ($mount_points as $mountpoint) {
		$tpl->assign(
			array(
				'MOUNT'		=> tohtml($mountpoint['mount']),
				'TYPE'		=> tohtml($mountpoint['fstype']),
				'PARTITION'	=> tohtml($mountpoint['disk']),
				'PERCENT'	=> $mountpoint['percent'],
				'FREE'		=> numberBytesHuman($mountpoint['free'] * 1024),
				'USED'		=> numberBytesHuman($mountpoint['used'] * 1024),
				'SIZE'		=> numberBytesHuman($mountpoint['size'] * 1024),
			)
		);

	$tpl->parse('DISK_LIST_ITEM', '.disk_list_item');
}

$tpl->parse('DISK_LIST', 'disk_list');

/**
 * static page messages.
 */
$tpl->assign(
	array(
		'TR_PAGE_TITLE' => tr('i-MSCP - Multi Server Control Panel'),
		'THEME_COLOR_PATH' => "../themes/{$cfg->USER_INITIAL_THEME}",
		'THEME_CHARSET' => tr('encoding'),
		'ISP_LOGO' => layout_getUserLogo()
	)
);

$tpl->assign(
	array(
		'TR_CPU_BOGOMIPS'		=> tr('CPU bogomips'),
		'TR_CPU_CACHE'			=> tr('CPU cache'),
		'TR_CPU_COUNT'			=> tr('Number of CPU Cores'),
		'TR_CPU_MHZ'			=> tr('CPU MHz'),
		'TR_CPU_MODEL'			=> tr('CPU model'),
		'TR_CPU_SYSTEM_INFO'	=> tr('CPU system Info'),
		'TR_FILE_SYSTEM_INFO'	=> tr('Filesystem system Info'),
		'TR_FREE'				=> tr('Free'),
		'TR_KERNEL'				=> tr('Kernel Version'),
		'TR_LOAD'				=> tr('Load (1 Min, 5 Min, 15 Min)'),
		'TR_MEMRY_SYSTEM_INFO'	=> tr('Memory system info'),
		'TR_MOUNT'				=> tr('Mount'),
		'TR_RAM'				=> tr('RAM'),
		'TR_PARTITION'			=> tr('Partition'),
		'TR_PERCENT'			=> tr('Percent'),
		'TR_SIZE'				=> tr('Size'),
		'TR_SWAP'				=> tr('Swap'),
		'TR_SYSTEM_INFO_TITLE'	=> tr('System info'),
		'TR_SYSTEM_INFO'		=> tr('Vital system info'),
		'TR_TOTAL'				=> tr('Total'),
		'TR_TYPE'				=> tr('Type'),
		'TR_UPTIME'				=> tr('Up time'),
		'TR_USED'				=> tr('Used'),
	)
);

gen_admin_mainmenu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/main_menu_system_tools.tpl');
gen_admin_menu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/menu_system_tools.tpl');
generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(
    iMSCP_Events::onAdminScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();

unsetMessages();
