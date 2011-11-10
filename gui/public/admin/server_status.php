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
 *
 * Portions created by the ispCP Team are Copyright (C) 2006-2010 by
 * isp Control Panel. All Rights Reserved.
 * 
 * Portions created by the i-MSCP Team are Copyright (C) 2010 by
 * i-MSCP a internet Multi Server Control Panel. All Rights Reserved.
 */

// Include needed libraries
require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onAdminScriptStart);

// Check for login
check_login(__FILE__);

/**
 * @var $cfg iMSCP_Config_Handler_File
 */
$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic('page', $cfg->ADMIN_TEMPLATE_PATH . '/server_status.tpl');
$tpl->define_dynamic('page_message', 'page');
$tpl->define_dynamic('service_status', 'page');

$tpl->assign(
	array(
		'TR_PAGE_TITLE' => tr('i-MSCP Admin / General Information / Server Status'),
		'THEME_COLOR_PATH' => "../themes/{$cfg->USER_INITIAL_THEME}",
		'THEME_CHARSET' => tr('encoding'),
		'ISP_LOGO' => layout_getUserLogo()
	)
);

gen_admin_mainmenu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/main_menu_general_information.tpl');
gen_admin_menu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/menu_general_information.tpl');

$tpl->assign(
	array(
		'TR_HOST' => tr('Host'),
		'TR_SERVICE' => tr('Service'),
		'TR_STATUS' => tr('Status'),
		'TR_SERVER_STATUS' => tr('Server status'),
	)
);

// Services status string
$running = tr('UP');
$down = tr('DOWN');

$services = new iMSCP_Services();

foreach($services as $service) {

	$services->setService($services->key($services), false);

	if($services->isVisible()) {

		$serviceState = $services->isRunning();

		$tpl->assign(
			array(
				'HOST' =>  $services->getIp(),
				'PORT' => $services->getPort(),
				'SERVICE' => $services->getName(),
				'STATUS' => $serviceState ? "<b>$running</b>" : $down,
				'CLASS' => $serviceState ? 'up' : 'down'
			)
		);

		$tpl->parse('SERVICE_STATUS', '.service_status');
	}
}

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(
    iMSCP_Events::onAdminScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();
