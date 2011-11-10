<?php
/**
 * i-MSCP - internet Multi Server Control Panel
 *
 * @copyright 	2001-2006 by moleSoftware GmbH
 * @copyright 	2006-2010 by ispCP | http://isp-control.net
 * @copyright 	2010-2011 by i-MSCP | http://i-mscp.net
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
 * Portions created by the i-MSCP Team are Copyright (C) 2010-2011 by
 * i-MSCP a internet Multi Server Control Panel. All Rights Reserved.
 */

/************************************************************************************
 * Main script
 */

// Include core library
require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onAdminScriptStart);

check_login(__FILE__);

/** @var $cfg iMSCP_Config_Handler_File */
$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic(array('page' => $cfg->ADMIN_TEMPLATE_PATH . '/manage_users.tpl',
                          'page_message' => 'page',

                          'admin_message' => 'page',

                          'admin_list' => 'page',
                          'admin_item' => 'admin_list',
                          'admin_delete_show' => 'admin_item',
                          'admin_delete_link' => 'admin_item',

                          'rsl_message' => 'page',
                          'rsl_list' => 'page',
                          'rsl_item' => 'rsl_list',
                          'rsl_delete_show' => 'rsl_item',
                          'rsl_delete_link' => 'rsl_item',

                          'usr_message' => 'page',
                          'usr_list' => 'page',
                          'usr_item' => 'usr_list',
                          'user_details' => 'usr_list',

                          'usr_status_reload_true' => 'usr_item',
                          'usr_status_reload_false' => 'usr_item',
                          'usr_delete_show' => 'usr_item',
                          'usr_delete_link' => 'usr_item',
                          'icon' => 'usr_item',

                          'scroll_prev_gray' => 'page',
                          'scroll_prev' => 'page',
                          'scroll_next_gray' => 'page',
                          'scroll_next' => 'page'));

$tpl->assign(array(
                  'TR_PAGE_TITLE' => tr('i-MSCP - Admin/Manage Users'),
                  'THEME_COLOR_PATH' => "../themes/{$cfg->USER_INITIAL_THEME}",
                  'THEME_CHARSET' => tr('encoding'),
                  'ISP_LOGO' => layout_getUserLogo()));

if (isset($_POST['details']) && !empty($_POST['details'])) {
	$_SESSION['details'] = $_POST['details'];
} else {
	if (!isset($_SESSION['details'])) {
		$_SESSION['details'] = "hide";
	}
}

if (isset($_SESSION['user_added'])) {
	unset($_SESSION['user_added']);
	set_page_message(tr('Customer scheduled for addition.'), 'success');
} elseif (isset($_SESSION['reseller_added'])) {
	unset($_SESSION['reseller_added']);
	set_page_message(tr('Reseller successfully added.'), 'success');
} elseif (isset($_SESSION['user_updated'])) {
	unset($_SESSION['user_updated']);
	set_page_message(tr('Customer account successfully updated.'), 'success');
} elseif (isset($_SESSION['user_deleted'])) {
	unset($_SESSION['user_deleted']);
	set_page_message(tr('Customer scheduled for deletion.'), 'success');
} elseif (isset($_SESSION['email_updated'])) {
	unset($_SESSION['email_updated']);
	set_page_message(tr('Email Updated.'), 'success');
} elseif (isset($_SESSION['hdomain'])) {
	unset($_SESSION['hdomain']);
	set_page_message(tr('This reseller has one or more customers accounts.<br /> To remove this reseller, please first remove these customers accounts.'), 'error');
} elseif (isset($_SESSION['user_disabled'])) {
	unset($_SESSION['user_disabled']);
	set_page_message(tr('Customer account scheduled for deactivation.'), 'success');
}

if (!$cfg->exists('HOSTING_PLANS_LEVEL') ||
    strtolower($cfg->HOSTING_PLANS_LEVEL) !== 'admin'
) {
	$tpl->assign('EDIT_OPTION', '');
}

gen_admin_mainmenu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/main_menu_users_manage.tpl');
gen_admin_menu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/menu_users_manage.tpl');
get_admin_manage_users($tpl);
generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(
    iMSCP_Events::onAdminScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();

unsetMessages();
