<?php
/**
 * i-MSCP - internet Multi Server Control Panel
 *
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
 * The Original Code is i-MSCP - Multi Server Control Panel.
 *
 * The Initial Developer of the Original Code is i-MSCP Team.
 * Portions created by Initial Developer are Copyright (C) 2010 - 2011
 * i-MSCP - internet Multi Server Control Panel. All Rights Reserved.
 *
 * @category i-MSCP
 * @copyright 2010-2011 by ispCP | http://i-mscp.net
 * @author Sacha Bay <sascha.bay@i-mscp.net>
 * @version SVN: $Id$
 * @link http://i-mscp.net i-MSCP Home Site
 * @license http://www.mozilla.org/MPL/ MPL 1.1
 */

// Include core library
require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onAdminScriptStart);

check_login(__FILE__);

/** @var $cfg iMSCP_Config_Handler_File */
$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic('page', $cfg->ADMIN_TEMPLATE_PATH . '/software_reseller.tpl');
$tpl->define_dynamic('page_message', 'page');
$tpl->define_dynamic('list_software', 'page');
$tpl->define_dynamic('no_software_list', 'page');
$tpl->define_dynamic('list_softwaredepot', 'page');
$tpl->define_dynamic('no_softwaredepot_list', 'page');
$tpl->define_dynamic('no_reseller_list', 'page');
$tpl->define_dynamic('list_reseller', 'page');
$tpl->define_dynamic('software_is_in_softwaredepot', 'page');
$tpl->define_dynamic('software_is_not_in_softwaredepot', 'page');

if (isset($_GET['id'])){
	if (isset($_GET['id']) && is_numeric($_GET['id'])) {
		$reseller_id = $_GET['id'];
	} else {
		set_page_message(tr('Wrong reseller id.'), 'error');
		redirectTo('software_manage.php');
	}

} else {
	set_page_message(tr('Wrong reseller id.'), 'error');
	redirectTo('software_manage.php');
}

$tpl->assign(
		array(
			'TR_PAGE_TITLE' => tr('i-MSCP - Application Management'),
			'THEME_COLOR_PATH'				=> "../themes/{$cfg->USER_INITIAL_THEME}",
			'THEME_CHARSET'					=> tr('encoding'),
			'ISP_LOGO'						=> layout_getUserLogo()
			)
	);

$software_cnt = get_installed_res_software($tpl, $_GET['id']);
$res_cnt = get_reseller_software($tpl, $_GET['id']);

$tpl->assign(
		array(
			'RESELLER_ID'					=> $reseller_id,
			'TR_SOFTWARE_INSTALLED' 		=> tr('Installed on'),
			'TR_SOFTWARE_RIGHTS' 			=> tr('Permissions'),
			'TR_SOFTWAREDEPOT_COUNT' 		=> tr('Total Softwares'),
			'TR_SOFTWAREDEPOT_NUM' 			=> $software_cnt,
			'TR_AWAITING_ACTIVATION' 		=> tr('Awaiting activation'),
			'TR_ACTIVATED_SOFTWARE' 		=> tr('Reseller list'),
			'TR_SOFTWARE_NAME' 				=> tr('Software name'),
			'TR_SOFTWARE_VERSION' 			=> tr('Version'),
			'TR_SOFTWARE_LANGUAGE' 			=> tr('Language'),
			'TR_SOFTWARE_TYPE' 				=> tr('Type'),
			'TR_RESELLER_NAME' 				=> tr('Reseller'),
			'TR_RESELLER_ACT_COUNT' 		=> tr('Reseller total'),
			'TR_RESELLER_ACT_NUM' 			=> $res_cnt,
			'TR_RESELLER_COUNT_SWDEPOT' 	=> tr('Software repository'),
			'TR_RESELLER_COUNT_WAITING' 	=> tr('Awaiting activation'),
			'TR_RESELLER_COUNT_ACTIVATED' 	=> tr('Activated softwares'),
			'TR_RESELLER_SOFTWARE_IN_USE' 	=> tr('Total installations'),
			'TR_ADMIN_SOFTWARE_PAGE_TITLE' 	=> tr('i-MSCP - Software Installer Management')
			)
	);

gen_admin_mainmenu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/main_menu_users_manage.tpl');
gen_admin_menu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/menu_users_manage.tpl');

generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onAdminScriptEnd,
                                              new iMSCP_Events_Response($tpl));

$tpl->prnt();

unsetMessages();
