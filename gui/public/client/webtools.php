<?php
/**
 * i-MSCP - internet Multi Server Control Panel
 *
 * @copyright	2001-2006 by moleSoftware GmbH
 * @copyright	2006-2010 by ispCP | http://isp-control.net
 * @copyright	2010-2011 by i-MSCP | http://i-mscp.net
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
 * Main script
 */

// Include core library
require_once 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onClientScriptStart);

check_login(__FILE__);

/** @var $cfg iMSCP_Config_Handler_File */
$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic(
	array(
		 'page' => $cfg->CLIENT_TEMPLATE_PATH . '/webtools.tpl',
		 'page_message' => 'page',
		 'logged_from' => 'page'
	)
);

$tpl->assign(
	array(
		 'TR_PAGE_TITLE' => tr('i-MSCP - Client/Webtools'),
		 'THEME_COLOR_PATH' => "../themes/{$cfg->USER_INITIAL_THEME}",
		 'THEME_CHARSET' => tr('encoding'),
		 'ISP_LOGO' => layout_getUserLogo(),

		 'TR_TITLE_WEBTOOLS' => tr('Webtools'),

		 'TR_HTACCESS' => tr('Protected areas'),
		 'TR_HTACCESS_TXT' => tr('Manage your protected areas, users and groups.'),

		 'TR_ERROR_PAGES' => tr('Error pages'),
		 'TR_ERROR_PAGES_TXT' => tr('Customize error pages for your domain.'),

		 'TR_BACKUP' => tr('Backup'),
		 'TR_BACKUP_TXT' => tr('Backup and restore settings.'),

		 'TR_WEBMAIL' => tr('Webmail'),
		 'TR_WEBMAIL_TXT' => tr('Access your mail through the web interface.'),

		 'TR_FILEMANAGER' => tr('Filemanager'),
		 'TR_FILEMANAGER_TXT' => tr('Access your files through the web interface.'),

		 'TR_AWSTATS' => tr('Awstats'),
		 'TR_AWSTATS_TXT' => tr('Access your domain statistics through the Awstats Web interface.'),

		 'TR_APP_INSTALLER' => 'Application installer',
		 'TR_APP_INSTALLER_TXT' => tr('Install various Web applications with a few clicks.')
	)
);

gen_client_mainmenu($tpl, $cfg->CLIENT_TEMPLATE_PATH . '/main_menu_webtools.tpl');
gen_client_menu($tpl, $cfg->CLIENT_TEMPLATE_PATH . '/menu_webtools.tpl');
gen_logged_from($tpl);
generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onClientScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();

unsetMessages();
