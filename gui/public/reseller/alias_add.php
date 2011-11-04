<?php
/**
 * i-MSCP - internet Multi Server Control Panel
 *
 * @copyright   2001-2006 by moleSoftware GmbH
 * @copyright   2006-2010 by ispCP | http://isp-control.net
 * @copyright   2010-2011 by i-msCP | http://i-mscp.net
 * @version     SVN: $Id$
 * @link        http://i-mscp.net
 * @author      ispCP Team
 * @author      i-MSCP Team
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
 * Initialize data.
 *
 * @return void
 */
function init_empty_data()
{
    global $cr_user_id, $alias_name, $domain_ip, $forward, $mount_point;
    $cr_user_id = $alias_name = $domain_ip = $forward = $mount_point = '';
}

/**
 * Generates page.
 *
 * @param iMSCP_pTemplate $tpl Template engine
 * @param $reseller_id Reseller unique identifier
 * @return void
 */
function gen_al_page($tpl, $reseller_id)
{
    global $alias_name, $forward, $forward_prefix, $mount_point;

    $cfg = iMSCP_Registry::get('config');

    list(, , , , , , $uals_current) = generate_reseller_user_props($reseller_id);

    list(, , , , , $rals_max) = get_reseller_default_props($reseller_id);

    if ($uals_current >= $rals_max && $rals_max != "0") {
        $_SESSION['almax'] = '_yes_';
        redirectTo('alias.php');
    }

    if (isset($_POST['status']) && $_POST['status'] == 1) {
        $forward_prefix = clean_input($_POST['forward_prefix']);
        if ($_POST['status'] == 1) {
            $check_en = $cfg->HTML_CHECKED;
            $check_dis = '';
            $forward = encode_idna(strtolower(clean_input($_POST['forward'])));
            $tpl->assign(array(
                              'READONLY_FORWARD' => '',
                              'DISABLE_FORWARD' => ''));
        } else {
            $check_en = '';
            $check_dis = $cfg->HTML_CHECKED;
            $forward = '';
            $tpl->assign(array(
                              'READONLY_FORWARD' => $cfg->HTML_READONLY,
                              'DISABLE_FORWARD' => $cfg->HTML_DISABLED));
        }

        $tpl->assign(array(
                          'HTTP_YES' => ($forward_prefix === 'http://')
                              ? $cfg->HTML_SELECTED : '',
                          'HTTPS_YES' => ($forward_prefix === 'https://')
                              ? $cfg->HTML_SELECTED : '',
                          'FTP_YES' => ($forward_prefix === 'ftp://')
                              ? $cfg->HTML_SELECTED : ''));
    } else {
        $check_en = '';
        $check_dis = $cfg->HTML_CHECKED;
        $forward = '';
        $tpl->assign(array(
                          'READONLY_FORWARD' => $cfg->HTML_READONLY,
                          'DISABLE_FORWARD' => $cfg->HTML_DISABLED,
                          'HTTP_YES' => '',
                          'HTTPS_YES' => '',
                          'FTP_YES' => ''));
    }

    $tpl->assign(array(
                      'DOMAIN' => tohtml(decode_idna($alias_name)),
                      'MP' => tohtml($mount_point),
                      'FORWARD' => tohtml(encode_idna($forward)),
                      'CHECK_EN' => $check_en,
                      'CHECK_DIS' => $check_dis));

    generate_ip_list($tpl, $reseller_id);
    gen_users_list($tpl, $reseller_id);
}

/**
 * Adds domain alias.
 *
 * @return void
 */
function add_domain_alias()
{
    global $cr_user_id, $alias_name, $domain_ip, $forward, $forward_prefix,
        $mount_point, $validation_err_msg;

    /** @var $cfg iMSCP_Config_Handler_File */
    $cfg = iMSCP_Registry::get('config');

    $cr_user_id = $_POST['usraccounts'];

    $alias_name = strtolower($_POST['ndomain_name']);
    $mount_point = array_encode_idna(strtolower($_POST['ndomain_mpoint']), true);

    if ($_POST['status'] == 1) {
        $forward = encode_idna(strtolower(clean_input($_POST['forward'])));
        $forward_prefix = clean_input($_POST['forward_prefix']);
    } else {
        $forward = 'no';
        $forward_prefix = '';
    }

    $query = "SELECT `domain_ip_id` FROM `domain` WHERE `domain_id` = ?";
    $rs = exec_query($query, $cr_user_id);

    $domain_ip = $rs->fields['domain_ip_id'];

    // First check if input string is a valid domain names
    if (!validates_dname($alias_name)) {
        set_page_message($validation_err_msg, 'error');
        return;
    }

    // Should be perfomed after domain names syntax validation now
    $alias_name = encode_idna($alias_name);

    if (imscp_domain_exists($alias_name, $_SESSION['user_id'])) {
        set_page_message(tr('Domain with that name already exists on the system.'), 'error');
    } elseif (!validates_mpoint($mount_point) && $mount_point != '/') {
       set_page_message(tr('Incorrect mount point syntax.'), 'error');
    } elseif ($alias_name == $cfg->BASE_SERVER_VHOST) {
        set_page_message(tr('Master domain cannot be used.'), 'error');
    } elseif ($_POST['status'] == 1) {
        $aurl = @parse_url($forward_prefix . decode_idna($forward));

        if ($aurl === false) {
            set_page_message(tr('Wrong address in forward URL.'), 'error');
        } else {
            $domain = $aurl['host'];

            if (substr_count($domain, '.') <= 2) {
                $ret = validates_dname($domain);
            } else {
                $ret = validates_dname($domain, true);
            }

            $domain = encode_idna($aurl['host']);

            if (!$ret) {
                set_page_message(tr('Wrong domain part in forward URL.', 'error'));
            } else {
                $domain = encode_idna($aurl['host']);
                $forward = $aurl['scheme'] . '://';

                if (isset($aurl['user'])) {
                    $forward .= $aurl['user'] . (isset($aurl['pass'])
                        ? ':' . $aurl['pass'] : '') . '@';
                }

                $forward .= $domain;

                if (isset($aurl['port'])) {
                    $forward .= ':' . $aurl['port'];
                }

                if (isset($aurl['path'])) {
                    $forward .= $aurl['path'];
                } else {
                    $forward .= '/';
                }

                if (isset($aurl['query'])) {
                    $forward .= '?' . $aurl['query'];
                }

                if (isset($aurl['fragment'])) {
                    $forward .= '#' . $aurl['fragment'];
                }
            }
        }
    } else {
        $query = "SELECT  `domain_id` FROM `domain_aliasses` WHERE `alias_name` = ?";
        $res = exec_query($query, $alias_name);

        $query = "SELECT `domain_id` FROM `domain` WHERE `domain_name` = ?";
        $res2 = exec_query($query, $alias_name);

        if ($res->rowCount() > 0 || $res2->rowCount() > 0) {
            // we already have domain with this name
            set_page_message(tr('Domain already registered on the system.'), 'error');
        }

        $query = "
			SELECT
				COUNT(`subdomain_id`) AS cnt
			FROM
				`subdomain`
			WHERE
				`domain_id` = ?
			AND
				`subdomain_mount` = ?
		";
        $subdomres = exec_query($query, array($cr_user_id, $mount_point));
        $subdomdata = $subdomres->fetchRow();

        $query = "
			SELECT
				COUNT(`subdomain_alias_id`) AS alscnt
			FROM
				`subdomain_alias`
			WHERE
				`alias_id`
			IN
				(SELECT `alias_id` FROM `domain_aliasses` WHERE `domain_id` = ?)
			AND
				`subdomain_alias_mount` = ?
		";
        $alssubdomres = exec_query($query, array($cr_user_id, $mount_point));

        $alssubdomdata = $alssubdomres->fetchRow();

        if ($subdomdata['cnt'] > 0 || $alssubdomdata['alscnt'] > 0) {
            set_page_message(tr('There is a subdomain with the same mount point.'), 'error');
        }
    }

    if($_SESSION['user_page_message']) {
        return;
    }

    // Begin add new alias domain
    $alias_name = htmlspecialchars($alias_name, ENT_QUOTES, 'UTF-8');

    $query = "
		INSERT INTO
			`domain_aliasses` (
			    `domain_id`, `alias_name`, `alias_mount`, `alias_status`,
			    `alias_ip_id`, `url_forward`
			) VALUES (
			    ?, ?, ?, ?, ?, ?
			)
	";
    exec_query($query, array($cr_user_id, $alias_name, $mount_point, $cfg->ITEM_ADD_STATUS, $domain_ip, $forward));

    /** @var $db iMSCP_Database */
    $db = iMSCP_Registry::get('db');
    $als_id = $db->insertId();

    update_reseller_c_props(get_reseller_id($cr_user_id));

    $query = "SELECT `email` FROM `admin` WHERE `admin_id` = ? LIMIT 1";
    $rs = exec_query($query, who_owns_this($cr_user_id, 'dmn_id'));
    $user_email = $rs->fields['email'];

    // Create the 3 default addresses if wanted
    if ($cfg->CREATE_DEFAULT_EMAIL_ADDRESSES) {
        client_mail_add_default_accounts($cr_user_id, $user_email, $alias_name, 'alias', $als_id);
    }

    send_request();
    $admin_login = $_SESSION['user_logged'];
    write_log("$admin_login: add domain alias: $alias_name", E_USER_NOTICE);

    $_SESSION['aladd'] = '_yes_';
    redirectTo('alias.php');
}

/**
 * Generate users list.
 *
 * @param iMSCP_pTemplate $tpl Template engine
 * @param $reseller_id Reseller unique identifier
 * @return bool
 */
function gen_users_list($tpl, $reseller_id)
{
    global $cr_user_id;

    /** @var $cfg iMSCP_Config_Handler_File */
    $cfg = iMSCP_Registry::get('config');

    $query = "
		SELECT
			`admin_id`
		FROM
			`admin`
		WHERE
			`admin_type` = 'user'
		AND
			`created_by` = ?
		ORDER BY
			`admin_name`
	";
    $ar = exec_query($query, $reseller_id);

    if ($ar->rowCount() == 0) {
        set_page_message(tr('There is no user records for this reseller to add an alias for.'));
        redirectTo('alias.php');
    }

    $i = 1;

    while ($ad = $ar->fetchRow()) { // Process all founded users
        $admin_id = $ad['admin_id'];
        $selected = '';

        // Get domain data
        $query = "
			SELECT
				`domain_id`,
				IFNULL(`domain_name`, '') AS domain_name
			FROM
				`domain`
			WHERE
				`domain_admin_id` = ?
		";

        $dr = exec_query($query, $admin_id);
        $dd = $dr->fetchRow();

        $domain_id = $dd['domain_id'];
        $domain_name = $dd['domain_name'];

        if (('' == $cr_user_id && $i == 1) || ($cr_user_id == $domain_id)) {
            $selected = $cfg->HTML_SELECTED;
        }

        $domain_name = decode_idna($domain_name);

        $tpl->assign(array(
                          'USER' => $domain_id,
                          'USER_DOMAIN_ACCOUNT' => tohtml($domain_name),
                          'SELECTED' => $selected));
        $i++;
        $tpl->parse('USER_ENTRY', '.user_entry');
    }

    return true;
}

/************************************************************************************
 * Main script
 */

// Include core library
require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onResellerScriptStart);

check_login(__FILE__);

/** @var $cfg iMSCP_Config_Handler_File */
$cfg = iMSCP_Registry::get('config');

// Avoid useless work during Ajax request
if (!is_xhr()) {
    $tpl = new iMSCP_pTemplate();
    $tpl->define_dynamic('page', $cfg->RESELLER_TEMPLATE_PATH . '/alias_add.tpl');
    $tpl->define_dynamic('page_message', 'page');
    $tpl->define_dynamic('logged_from', 'page');
    $tpl->define_dynamic('user_entry', 'page');

    $tpl->assign(array(
             'THEME_COLOR_PATH' => "../themes/{$cfg->USER_INITIAL_THEME}",
             'THEME_CHARSET' => tr('encoding'),
             'ISP_LOGO' => layout_getUserLogo()));

    $reseller_id = $_SESSION['user_id'];

    gen_reseller_mainmenu($tpl, $cfg->RESELLER_TEMPLATE_PATH . '/main_menu_users_manage.tpl');
    gen_reseller_menu($tpl, $cfg->RESELLER_TEMPLATE_PATH . '/menu_users_manage.tpl');
    gen_logged_from($tpl);

    $tpl->assign(array(
                      'TR_PAGE_TITLE' => tr('i-MSCP Reseller/Add Alias'),
                      'TR_MANAGE_DOMAIN_ALIAS' => tr('Manage domain alias'),
                      'TR_ADD_ALIAS' => tr('Add domain alias'),
                      'TR_DOMAIN_NAME' => tr('Domain name'),
                      'TR_DOMAIN_ACCOUNT' => tr('User account'),
                      'TR_MOUNT_POINT' => tr('Directory mount point'),
                      'TR_DOMAIN_IP' => tr('Domain IP'),
                      'TR_FORWARD' => tr('Forward to URL'),
                      'TR_ADD' => tr('Add alias'),
                      'TR_DMN_HELP' => tr("You do not need 'www.' i-MSCP will add it on its own."),
                      'TR_JS_EMPTYDATA' => tr("Empty data or wrong field!"),
                      'TR_JS_WDNAME' => tr("Wrong domain name!"),
                      'TR_JS_MPOINTERROR' => tr("Please write mount point!"),
                      'TR_ENABLE_FWD' => tr("Enable Forward"),
                      'TR_ENABLE' => tr("Enable"),
                      'TR_DISABLE' => tr("Disable"),
                      'TR_PREFIX_HTTP' => 'http://',
                      'TR_PREFIX_HTTPS' => 'https://',
                      'TR_PREFIX_FTP' => 'ftp://'));

    list(
        $rdmn_current, $rdmn_max, $rsub_current, $rsub_max, $rals_current, $rals_max,
        $rmail_current, $rmail_max, $rftp_current, $rftp_max, $rsql_db_current, $rsql_db_max,
        $rsql_user_current, $rsql_user_max, $rtraff_current, $rtraff_max, $rdisk_current, $rdisk_max
        ) = get_reseller_default_props($_SESSION['user_id']);

    if ($rals_max != 0 && $rals_current >= $rals_max) {
        $_SESSION['almax'] = '_yes_';
    }

    if (!check_reseller_permissions($reseller_id, 'alias') ||
        isset($_SESSION['almax'])
    ) {
        redirectTo('alias.php');
    }
}

/**
 * Dispatches the request
 */
if (isset($_POST['uaction'])) {
    if ($_POST['uaction'] == 'toASCII') { // Ajax request
        header('Content-Type: text/plain; charset=utf-8');
        header('Cache-Control: no-cache, private');
        // backward compatibility for HTTP/1.0
        header('Pragma: no-cache');
        header("HTTP/1.0 200 Ok");

        // Todo check return value here before echo...

        $asciiString = encode_idna(strtolower($_POST['domain']));
        echo !empty($asciiString) ? '/'. $asciiString : '';
        exit;
    } elseif ($_POST['uaction'] == 'add_alias') {
        add_domain_alias();
    } else {
        throw new iMSCP_Exception(tr("Unknown action: %s", $_POST['uaction']));
    }
} else { // Default view
    init_empty_data();
}

gen_al_page($tpl, $_SESSION['user_id']);
generatePageMessage($tpl);

$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(
    iMSCP_Events::onResellerScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();
