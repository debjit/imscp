<!-- INCLUDE "../shared/layout/header.tpl" -->
	<body>
		<div class="header">
			{MAIN_MENU}

			<div class="logo">
				<img src="{ISP_LOGO}" alt="i-MSCP logo" />
			</div>
		</div>

		<div class="location">
			<div class="location-area">
				<h1 class="general">{TR_MENU_GENERAL_INFORMATION}</h1>
			</div>
			<ul class="location-menu">
				<!-- <li><a class="help" href="#">Help</a></li> -->
				<!-- BDP: logged_from -->
				<li><a class="logout" href="change_user_interface.php?action=go_back">{YOU_ARE_LOGGED_AS}</a></li>
				<!-- EDP: logged_from -->
				<li><a class="logout" href="../index.php?logout">{TR_MENU_LOGOUT}</a></li>
			</ul>
			<ul class="path">
				<li><a href="index.php">{TR_MENU_GENERAL_INFORMATION}</a></li>
				<li><a href="#" onclick="return false;">{TR_LMENU_CHANGE_PERSONAL_DATA}</a></li>
			</ul>
		</div>

		<div class="left_menu">
			{MENU}
		</div>

		<div class="body">
			<h2 class="settings"><span>{TR_TITLE_CHANGE_PERSONAL_DATA}</span></h2>

			<!-- BDP: page_message -->
			<div class="{MESSAGE_CLS}">{MESSAGE}</div>
			<!-- EDP: page_message -->

			<form name="client_personal_change_frm" method="post" action="personal_change.php">
				<table>
					<tr>
						<th colspan="2">{TR_PERSONAL_DATA}</th>
					</tr>
					<tr>
						<td style="width:300px;"><label for="fname">{TR_FIRST_NAME}</label></td>
						<td><input id="fname" name="fname" type="text" value="{FIRST_NAME}"/></td>
					</tr><tr>
						<td><label for="lname">{TR_LAST_NAME}</label></td>
						<td><input name="lname" id="lname" type="text" value="{LAST_NAME}"/></td>
					</tr><tr>
						<td><label for="gender">{TR_GENDER}</label></td>
						<td><select name="gender" id="gender" size="1">
								<option value="M" {VL_MALE}>{TR_MALE}</option>
								<option value="F" {VL_FEMALE}>{TR_FEMALE}</option>
								<option value="U" {VL_UNKNOWN}>{TR_UNKNOWN}</option>
						</select></td>
					</tr>
					<tr>
						<td><label for="firm">{TR_COMPANY}</label></td>
						<td><input type="text" name="firm" id="firm" value="{FIRM}"/></td>
					</tr>
					<tr>
						<td><label for="street1">{TR_STREET_1}</label></td>
						<td><input type="text" name="street1" id="street1" value="{STREET_1}"/></td>
					</tr>
					<tr>
						<td><label for="street2">{TR_STREET_2}</label></td>
						<td><input type="text" name="street2" id="street2" value="{STREET_2}"/></td>
					</tr>
					<tr>
						<td><label for="zip">{TR_ZIP_POSTAL_CODE}</label></td>
						<td><input type="text" name="zip" id="zip" value="{ZIP}"/></td>
					</tr>
					<tr>
						<td><label for="city">{TR_CITY}</label></td>
						<td><input type="text" name="city" id="city" value="{CITY}"/></td>
					</tr>
					<tr>
						<td><label for="city">{TR_STATE}</label></td>
						<td><input type="text" name="state" id="state" value="{STATE}"/></td>
					</tr>
					<tr>
						<td><label for="country">{TR_COUNTRY}</label></td>
						<td><input type="text" name="country" id="country" value="{COUNTRY}"/></td>
					</tr>
					<tr>
						<td><label for="email1">{TR_EMAIL}</label></td>
						<td><input type="text" name="email" id="email1" value="{EMAIL}"/></td>
					</tr>
					<tr>
						<td><label for="phone">{TR_PHONE}</label></td>
						<td><input type="text" name="phone" id="phone" value="{PHONE}"/></td>
					</tr>
					<tr>
						<td><label for="fax">{TR_FAX}</label></td>
						<td><input type="text" name="fax" id="fax" value="{FAX}"/></td>
					</tr>
				</table>

				<div class="buttons">
					<input type="submit" name="Submit" value="{TR_UPDATE_DATA}" />
					<input type="hidden" name="uaction" value="updt_data" />
				</div>

			</form>
		</div>
<!-- INCLUDE "../shared/layout/footer.tpl" -->
