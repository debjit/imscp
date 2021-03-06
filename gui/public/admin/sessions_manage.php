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
 * Script functions
 */

/**
 * Kill user session.
 *
 * @return void
 */
function kill_session()
{
	if (isset($_GET['kill']) && $_GET['kill'] !== ''
		&& isset($_GET['username']) &&  $_GET['username'] == $_SESSION['user_logged']
	) {
		$username = clean_input($_GET['username']);
		$sessionId = clean_input($_GET['kill']);

		$query = 'DELETE FROM `login` WHERE `session_id` = ?';
		$stmt = exec_query($query, $sessionId);

		if($stmt->rowCount()) { // A row was deleted ?
			set_page_message(tr('User session was killed.'), 'success');
			write_log($_SESSION['user_logged'] . ": killed $username session", E_USER_NOTICE);
		} else {
			set_page_message(tr('Session not found in login table.'), 'warning');
		}
	} elseif(isset($_GET['own'])) {
		set_page_message(tr("You can't remove your own session."), 'warning');
	}
}

/**
 * Generates users sessoion list.
 *
 * @param iMSCP_pTemplate $tpl Template engine
 * @return void
 */
function gen_user_sessions($tpl)
{
	$currentUserSessionId = session_id();

	$query = "SELECT `session_id`, `user_name`, `lastaccess` FROM `login`";
	$stmt = exec_query($query);

	while (!$stmt->EOF) {
		$username = tohtml($stmt->fields['user_name']);
		$sessionId = $stmt->fields['session_id'];

		if ($username === null) {
			$tpl->assign(array(
							  'ADMIN_USERNAME' => tr('Unknown'),
							  'LOGIN_TIME' => date('G:i:s', $stmt->fields['lastaccess'])));
		} else {
			$tpl->assign(array(
							  'ADMIN_USERNAME' =>
									$username . (($username == $_SESSION['user_logged'] &&
												  $currentUserSessionId !== $sessionId)
										? ' ('. tr('from other browser') . ')' : ''),
							  'LOGIN_TIME' => date('G:i:s', $stmt->fields['lastaccess'])));
		}

		if ($currentUserSessionId === $sessionId) { // Deletion of our own session is not allowed
			$tpl->assign('KILL_LINK', 'sessions_manage.php?own=1');
		} else {
			$tpl->assign('KILL_LINK', "sessions_manage.php?kill={$stmt->fields['session_id']}&username={$username}");
		}

		$tpl->parse('USER_SESSION', '.user_session');
		$stmt->moveNext();
	}
}

/************************************************************************************
 * Main script
 */

require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onAdminScriptStart);

check_login(__FILE__);

/** @var $cfg iMSCP_Config_Handler_File */
$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic(array(
						  'page' => $cfg->ADMIN_TEMPLATE_PATH . '/sessions_manage.tpl',
						  'page_message' => 'page',
						  'hosting_plans' => 'page',
						  'user_session' => 'page'));

$tpl->assign(array(
				  'TR_PAGE_TITLE' => tr('i-MSCP - Admin/Manage Sessions'),
				  'THEME_COLOR_PATH' => "../themes/{$cfg->USER_INITIAL_THEME}",
				  'THEME_CHARSET' => tr('encoding'),
				  'ISP_LOGO' => layout_getUserLogo(),
				  'TR_MANAGE_USER_SESSIONS' => tr('Manage user sessions'),
				  'TR_USERNAME' => tr('Username'),
				  'TR_USERTYPE' => tr('User type'),
				  'TR_LOGIN_ON' => tr('Last access'),
				  'TR_OPTIONS' => tr('Options'),
				  'TR_DELETE' => tr('Kill session')));


gen_admin_mainmenu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/main_menu_users_manage.tpl');
gen_admin_menu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/menu_users_manage.tpl');

kill_session();

gen_user_sessions($tpl);
generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(
    iMSCP_Events::onAdminScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();

unsetMessages();
