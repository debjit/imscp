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
 *
 * @category	iMSCP
 * @package		iMSCP_Core
 * @subpackage	Client
 * @copyright 	2001-2006 by moleSoftware GmbH
 * @copyright 	2006-2010 by ispCP | http://isp-control.net
 * @copyright 	2010-2011 by i-MSCP | http://i-mscp.net
 * @link 		http://i-mscp.net
 * @author 		ispCP Team
 * @author 		i-MSCP Team
 */

// Include core library
require_once 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onClientScriptStart);

check_login(__FILE__);

// If the feature is disabled, redirects in silent way
if (!customerHasFeature('protected_areas')) {
    redirectTo('index.php');
}

/** @var $cfg iMSCP_Config_Handler_File */
$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic('page', $cfg->CLIENT_TEMPLATE_PATH . '/puser_uadd.tpl');
$tpl->define_dynamic('page_message', 'page');
$tpl->define_dynamic('usr_msg', 'page');
$tpl->define_dynamic('grp_msg', 'page');
$tpl->define_dynamic('logged_from', 'page');
$tpl->define_dynamic('pusres', 'page');
$tpl->define_dynamic('pgroups', 'page');

$tpl->assign(
	array(
		 'TR_PAGE_TITLE' => tr('i-MSCP - Client / Webtools / Protected areas / Add user'),
		 'THEME_COLOR_PATH' => "../themes/{$cfg->USER_INITIAL_THEME}",
		 'THEME_CHARSET' => tr('encoding'),
		 'ISP_LOGO' => layout_getUserLogo()
	)
);

/**
 * @param $tpl
 * @param $dmn_id
 * @return
 */
function padd_user($tpl, $dmn_id) {

	/** @var $cfg iMSCP_Config_Handler_File */
	$cfg = iMSCP_Registry::get('config');

	if (isset($_POST['uaction']) && $_POST['uaction'] == 'add_user') {
		// we have to add the user
		if (isset($_POST['username']) && isset($_POST['pass']) && isset($_POST['pass_rep'])) {
			if (!validates_username($_POST['username'])) {
				set_page_message(tr('Wrong username!'), 'error');
				return;
			}
			if (!chk_password($_POST['pass'])) {
				if ($cfg->PASSWD_STRONG) {
					set_page_message(sprintf(tr('The password must be at least %s long and contain letters and numbers to be valid.'), $cfg->PASSWD_CHARS), 'error');
				} else {
					set_page_message(sprintf(tr('Password data is shorter than %s signs or includes not permitted signs!'), $cfg->PASSWD_CHARS), 'error');
				}
				return;
			}
			if ($_POST['pass'] !== $_POST['pass_rep']) {
				set_page_message(tr('Passwords do not match.'), 'error');
				return;
			}
			$status = $cfg->ITEM_ADD_STATUS;

			$uname = clean_input($_POST['username']);

			$upass = crypt_user_pass_with_salt($_POST['pass']);

			$query = "
				SELECT
					`id`
				FROM
					`htaccess_users`
				WHERE
					`uname` = ?
				AND
					`dmn_id` = ?
			";
			$rs = exec_query($query, array($uname, $dmn_id));

			if ($rs->recordCount() == 0) {

				$query = "
					INSERT INTO `htaccess_users` (
					    `dmn_id`, `uname`, `upass`, `status`
					) VALUES (
					    ?, ?, ?, ?
					)
				";
				exec_query($query, array($dmn_id, $uname, $upass, $status));

				send_request();

				set_page_message(tr('User scheduled for addition.'), 'success');

				$admin_login = $_SESSION['user_logged'];
				write_log("$admin_login: add user (protected areas): $uname", E_USER_NOTICE);
				redirectTo('protected_user_manage.php');
			} else {
				set_page_message(tr('User already exist !'), 'error');
				return;
			}
		}
	} else {
		return;
	}
}

gen_client_mainmenu($tpl, $cfg->CLIENT_TEMPLATE_PATH . '/main_menu_webtools.tpl');
gen_client_menu($tpl, $cfg->CLIENT_TEMPLATE_PATH . '/menu_webtools.tpl');
gen_logged_from($tpl);
padd_user($tpl, get_user_domain_id($_SESSION['user_id']));

$tpl->assign(
	array(
		'TR_HTACCESS'			=> tr('Protected areas'),
		'TR_ACTION'				=> tr('Action'),
		'TR_USER_MANAGE'		=> tr('Manage user'),
		'TR_USERS'				=> tr('User'),
		'TR_USERNAME'			=> tr('Username'),
		'TR_ADD_USER'			=> tr('Add user'),
		'TR_GROUPNAME'			=> tr('Group name'),
		'TR_GROUP_MEMBERS'		=> tr('Group members'),
		'TR_ADD_GROUP'			=> tr('Add group'),
		'TR_EDIT'				=> tr('Edit'),
		'TR_GROUP'				=> tr('Group'),
		'TR_DELETE'				=> tr('Delete'),
		'TR_GROUPS'				=> tr('Groups'),
		'TR_PASSWORD'			=> tr('Password'),
		'TR_PASSWORD_REPEAT'	=> tr('Repeat password'),
		'TR_CANCEL'				=> tr('Cancel'),
		'TR_HTACCESS_USER' => tr('Manage users and groups')
	)
);

generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onClientScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();

unsetMessages();
