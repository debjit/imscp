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
 * The Original Code is i-MSCP - Multi Server Control Panel.
 *
 * The Initial Developer of the Original Code is i-MSCP Team.
 * Portions created by Initial Developer are Copyright (C) 2010
 * i-MSCP - internet Multi Server Control Panel. All Rights Reserved.
 *
 * @category i-MSCP
 * @copyright 2010 by ispCP | http://i-mscp.net
 * @author Sacha Bay <sascha.bay@i-mscp.net>
 * @version SVN: $Id$
 * @link http://i-mscp.net i-MSCP Home Site
 * @license http://www.mozilla.org/MPL/ MPL 1.1
 */

require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onAdminScriptStart);

check_login(__FILE__);

/**
 * @var $cfg iMSCP_Config_Handler_File
 */
$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic('page', $cfg->ADMIN_TEMPLATE_PATH . '/software_options.tpl');
$tpl->define_dynamic('page_message', 'page');


$tpl->assign(
	array(
		'TR_PAGE_TITLE' => tr('i-MSCP - Application management options'),
		'THEME_COLOR_PATH'				=> "../themes/{$cfg->USER_INITIAL_THEME}",
		'THEME_CHARSET'					=> tr('encoding'),
		'ISP_LOGO'						=> layout_getUserLogo()
		)
);

if(isset($_POST['uaction']) && $_POST['uaction'] == "apply") {

    $error = "";

    $webdepot_xml_url = encode_idna(strtolower(clean_input($_POST['webdepot_xml_url'])));
    (strlen($webdepot_xml_url) > 0) ? $use_webdepot = $_POST['use_webdepot'] : $use_webdepot = '0';

    if(strlen($webdepot_xml_url) > 0 && $use_webdepot === "1") {
        $xml_file = @file_get_contents($webdepot_xml_url);
        if (!strpos($xml_file, 'i-MSCP websoftware depot list')) {
            set_page_message(tr("Unable to read xml file for web softwares."), 'error');
            $error = 1;
        }
    }
    if(!$error){
        $query = "
            UPDATE
                `web_software_options`
            SET
                `use_webdepot` = '".$use_webdepot."',
                `webdepot_xml_url` = '".$webdepot_xml_url."'
        ";
        execute_query($query);
        set_page_message(tr("Main application installer options updated."), 'info');
    }
}

$query = "SELECT * FROM `web_software_options`";
$rs = execute_query($query);

$tpl->assign(
	array(
		'TR_OPTIONS_SOFTWARE'           => tr('Application management options'),
        'TR_MAIN_OPTIONS'               => tr('Main application installer options'),
        'TR_USE_WEBDEPOT'               => tr('Using i-MSCP application installer Web software repository'),
        'TR_WEBDEPOT_XML_URL'           => tr('XML file URL for the i-MSCP Web software repository'),
        'TR_WEBDEPOT_LAST_UPDATE'       => tr('Last Web software repository update'),
        'USE_WEBDEPOT_SELECTED_OFF'     => (($rs->fields['use_webdepot'] == "0") ? $cfg->HTML_SELECTED : ''),
        'USE_WEBDEPOT_SELECTED_ON'      => (($rs->fields['use_webdepot'] == "1") ? $cfg->HTML_SELECTED : ''),
        'WEBDEPOT_XML_URL_VALUE'        => $rs->fields['webdepot_xml_url'],
        'WEBDEPOT_LAST_UPDATE_VALUE'    => ($rs->fields['webdepot_last_update'] == "0000-00-00 00:00:00") ? tr('not available') : $rs->fields['webdepot_last_update'],
        'TR_APPLY_CHANGES'              => tr('Apply changes'),
        'TR_ENABLED'                    => tr('Enabled'),
		'TR_DISABLED'                   => tr('Disabled'),
	)
);

gen_admin_mainmenu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/main_menu_settings.tpl');
gen_admin_menu($tpl, $cfg->ADMIN_TEMPLATE_PATH . '/menu_settings.tpl');

generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(
    iMSCP_Events::onAdminScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();

unsetMessages();
