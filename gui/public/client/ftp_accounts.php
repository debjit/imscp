<?php
/**
 * i-MSCP - internet Multi Server Control Panel
 *
 * @copyright	2001-2006 by moleSoftware GmbH
 * @copyright	2006-2010 by ispCP | http://isp-control.net
 * @copyright	2010-2011 by i-MSCP | http://i-mscp.net
 * @version		SVN: $Id$
 * @link		http://i-mscp.net
 * @author		ispCP Team
 * @author		i-MSCP Team
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
 * Generates FTP accounts list.
 *
 * @param iMSCP_pTemplate $tpl
 * @return void
 */
function gen_page_ftp_list($tpl)
{
	list(,$dmn_name) = get_domain_default_props($_SESSION['user_id']);

	$query = "
		SELECT
			`gid`, `members`
		FROM
			`ftp_group`
		WHERE
			`groupname` = ?
	";
	$stmt = exec_query($query, $dmn_name);

	if ($stmt->rowCount() == 0) {
		set_page_message(tr('You do not have FTP users.'), 'info');
		$tpl->assign('FTP_ACCOUNTS', '');
	} else {
		$ftp_accs = explode(',', $stmt->fields['members']);
		sort($ftp_accs);
		reset($ftp_accs);

		for ($i = 0, $cnt_ftp_accs = count($ftp_accs); $i < $cnt_ftp_accs; $i++) {
			$ftp_accs_encode[$i] = decode_idna($ftp_accs[$i]);

			$tpl->assign(array(
							  'FTP_ACCOUNT' => tohtml($ftp_accs_encode[$i]),
							  'UID' => urlencode($ftp_accs[$i])));

			$tpl->parse('FTP_ITEM', '.ftp_item');
		}

		$tpl->assign('TOTAL_FTP_ACCOUNTS', count($ftp_accs));
	}
}

/************************************************************************************
 * Main script
 */

// Include core library
require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onClientScriptStart);

check_login(__FILE__);

// If the feature is disabled, redirects the client in silent way
$domainProperties = get_domain_default_props($_SESSION['user_id'], true);
if ($domainProperties['domain_ftpacc_limit'] == '-1') {
	redirectTo('index.php');
}

/** @var $cfg iMSCP_Config_Handler_File */
$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic(array(
						  'page' => $cfg->CLIENT_TEMPLATE_PATH . '/ftp_accounts.tpl',
						  'logged_from' => 'page',
						  'page_message' => 'page',
						  'ftp_message' => 'page',
						  'ftp_accounts' => 'page',
						  'ftp_item' => 'ftp_accounts'));
$tpl->assign(array(
				  'TR_PAGE_TITLE' => tr('i-MSCP - Client/Manage Users'),
				  'THEME_COLOR_PATH' => "../themes/{$cfg->USER_INITIAL_THEME}",
				  'THEME_CHARSET' => tr('encoding'),
				  'ISP_LOGO' => layout_getUserLogo(),
				  'TR_TOTAL_FTP_ACCOUNTS' => tr('FTPs total'),
				  'TR_FTP_USERS' => tr('FTP Users'),
				  'TR_FTP_ACCOUNT' => tr('FTP account'),
				  'TR_FTP_ACTION' => tr('Actions'),
				  'TR_LOGINAS' => tr('Login As'),
				  'TR_EDIT' => tr('Edit'),
				  'TR_DELETE' => tr('Delete'),
				  'TR_MESSAGE_DELETE' => tr('Are you sure you want to delete the %s FTP user?', true, '%s'),
				  'FILEMANAFER_TARGET' => $cfg->FILEMANAGER_TARGET,
			 ));

gen_client_mainmenu($tpl, $cfg->CLIENT_TEMPLATE_PATH . '/main_menu_ftp_accounts.tpl');
gen_client_menu($tpl, $cfg->CLIENT_TEMPLATE_PATH . '/menu_ftp_accounts.tpl');
gen_logged_from($tpl);
gen_page_ftp_list($tpl);
check_permissions($tpl);

generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onClientScriptEnd,
											  new iMSCP_Events_Response($tpl));

$tpl->prnt();

unsetMessages();
