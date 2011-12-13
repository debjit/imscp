<?php
/**
 * i-MSCP a internet Multi Server Control Panel
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
 *
 * by moleSoftware GmbH. All Rights Reserved.
 * Portions created by the ispCP Team are Copyright (C) 2006-2010 by
 * isp Control Panel. All Rights Reserved.
 *
 * Portions created by the i-MSCP Team are Copyright (C) 2010-2011 by
 * i-MSCP a internet Multi Server Control Panel. All Rights Reserved.
 *
 * @category	iMSCP
 * @package		iMSCP_Core
 * @copyright	2001-2006 by moleSoftware GmbH
 * @copyright	2006-2010 by ispCP | http://isp-control.net
 * @copyright	2010-2011 by i-MSCP | http://i-mscp.net
 * @link		http://i-mscp.net
 * @author		ispCP Team
 * @author		i-MSCP Team
 */

// Include core library
require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onLostPasswordScriptStart);

/** @var $cfg iMSCP_Config_Handler_File */
$cfg = iMSCP_Registry::get('config');

// Lost password feature is disabled ?
if (!$cfg->LOSTPASSWORD) {
	redirectTo('/index.php');
}

// Check for gd library availability
if (!check_gd()) {
	throw new iMSCP_Exception(tr("PHP GD extension not loaded."));
}

// Check for font files availability
if (!captcha_fontfile_exists()) {
	throw new iMSCP_Exception(tr('Captcha fontfile not found.'));
}

// Remove old unique keys
removeOldKeys($cfg->LOSTPASSWORD_TIMEOUT);

isset($_SESSION['user_theme']) ? $theme_color = $_SESSION['user_theme']
	: $theme_color = $cfg->USER_INITIAL_THEME;

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic('page', $cfg->LOGIN_TEMPLATE_PATH . '/lostpassword.tpl');
$tpl->define_dynamic('page_message', 'page');

$tpl->assign(
	array(
		'TR_MAIN_INDEX_PAGE_TITLE' => tr('i-MSCP - Multi Server Control Panel - Lost password'),
		'THEME_COLOR_PATH' => $cfg->LOGIN_TEMPLATE_PATH,
		'THEME_CHARSET' => tr('encoding'),
		'productLongName' => tr('internet Multi Server Control Panel'),
		'productLink' => 'http://www.i-mscp.net',
		'productCopyright' => tr('© 2010 - 2011 i-MSCP Team<br/>All Rights Reserved'),
		'TR_CAPCODE' => tr('Security code'),
		'TR_IMGCAPCODE' => '<img id="captcha" src="imagecode.php" width="' .
			$cfg->LOSTPASSWORD_CAPTCHA_WIDTH . '" height="' .
			$cfg->LOSTPASSWORD_CAPTCHA_HEIGHT .
			' alt="captcha image" />',
		'TR_USERNAME' => tr('Username'),
		'TR_SEND' => tr('Send'),
		'TR_CANCEL' => tr('Cancel')
	)
);

// A request for new password was validated (User clicked on the link he has received by mail)
if (isset($_GET['key']) && $_GET['key'] != '') {
	// Check key
	check_input($_GET['key']);

	// Sending new password
	if (sendPassword($_GET['key'])) {
		set_page_message(tr('Your new password has been sent. Check your mail.'), 'success');
	} else {
		set_page_message(tr('New password has not been sent. Ask your administrator.'), 'error');
	}
} elseif (isset($_POST['uname'])) { // Request for new password

	// Check if we are not blocked (brute force feature)
	check_ipaddr(getipaddr(), 'captcha');

	if ($_POST['uname'] != '' && isset($_SESSION['image']) && isset($_POST['capcode'])) {
		check_input(trim($_POST['uname']));
		check_input($_POST['capcode']);

		if ($_SESSION['image'] != $_POST['capcode']) {
			set_page_message(tr('Wrong security code'), 'error');
		} elseif (!requestPassword($_POST['uname'])) {
			set_page_message(tr('Wrong username'), 'error');
		} else {
			set_page_message(tr('Your request for new password was registered. You will receive an email with instructions to complete the process.'), 'success');
		}
	} else {
		set_page_message(tr('All fields are required.'), 'error');
	}

} else { // Lost password form (Default)
	unblock($cfg->BRUTEFORCE_BLOCK_TIME, 'captcha');
	is_ipaddr_blocked(null, 'captcha', true);
}

// Generate page messages
generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onLostPasswordScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();
