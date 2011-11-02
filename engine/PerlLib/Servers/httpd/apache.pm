#!/usr/bin/perl

# i-MSCP - internet Multi Server Control Panel
# Copyright (C) 2010 - 2011 by internet Multi Server Control Panel
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# @category		i-MSCP
# @copyright	2010 - 2011 by i-MSCP | http://i-mscp.net
# @author		Daniel Andreca <sci2tech@gmail.com>
# @version		SVN: $Id$
# @link			http://i-mscp.net i-MSCP Home Site
# @license		http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package Servers::httpd::apache;

use strict;
use warnings;
use iMSCP::Debug;
use Data::Dumper;

use vars qw/@ISA/;

@ISA = ('Common::SingletonClass');
use Common::SingletonClass;

sub _init{

	my $self				= shift;

	$self->{masterConf}		= '00_master.conf';
	$self->{masterSSLConf}	= '00_master_ssl.conf';

	$self->{cfgDir}	= "$main::imscpConfig{'CONF_DIR'}/apache";
	$self->{bkpDir}	= "$self->{cfgDir}/backup";
	$self->{wrkDir}	= "$self->{cfgDir}/working";
	$self->{tplDir}	= "$self->{cfgDir}/parts";

	my $conf		= "$self->{cfgDir}/apache.data";
	tie %self::apacheConfig, 'iMSCP::Config','fileName' => $conf;

	$self->{tplValues}->{$_} = $self::apacheConfig{$_} foreach(keys %self::apacheConfig);

	0;
}

sub install{

	use Servers::httpd::apache::installer;

	my $self	= shift;
	my $rs		= 0;
	$rs |= Servers::httpd::apache::installer->new()->install();

	$rs;
}

sub postinstall{

	my $self	= shift;
	$self->{restart} = 'yes';

	0;
}

sub setGuiPermissions{

	use Servers::httpd::apache::installer;

	my $self	= shift;
	my $rs = Servers::httpd::apache::installer->new()->setGuiPermissions();

	$rs;
}

sub registerPreHook{

	my $self		= shift;
	my $fname		= shift;
	my $callback	= shift;

	my $installer	= Servers::httpd::apache::installer->new();

	debug("Register pre hook to $fname on installer")
		if (ref $callback eq 'CODE' && $installer->can($fname));
	push (@{$installer->{preCalls}->{$fname}}, $callback)
		if (ref $callback eq 'CODE' && $installer->can($fname));

	debug("Register pre hook to $fname")
		if (ref $callback eq 'CODE' && $self->can($fname));
	push (@{$self->{preCalls}->{$fname}}, $callback)
		if (ref $callback eq 'CODE' && $self->can($fname));

	0;
}

sub registerPostHook{

	my $self		= shift;
	my $fname		= shift;
	my $callback	= shift;

	debug("Attaching to $fname... $callback");

	my $installer	= Servers::httpd::apache::installer->new();

	debug("Register post hook to $fname on installer")
		if (ref $callback eq 'CODE' && $installer->can($fname));
	push (@{$installer->{postCalls}->{$fname}}, $callback)
		if (ref $callback eq 'CODE' && $installer->can($fname));

	debug("Register post hook to $fname")
		if (ref $callback eq 'CODE' && $self->can($fname));
	push (@{$self->{postCalls}->{$fname}}, $callback)
		if (ref $callback eq 'CODE' && $self->can($fname));

	0;
}

sub enableSite{

	use iMSCP::Execute;

	my $self	= shift;
	my $site	= shift;
	my ($rs, $stdout, $stderr);

	$rs = execute("a2ensite $site", \$stdout, \$stderr);
	debug("$stdout") if($stdout);
	error("$stderr") if($stderr);
	return $rs if $rs;

	0;
}

sub disableSite{

	use iMSCP::Execute;

	my $self	= shift;
	my $site	= shift;
	my ($rs, $stdout, $stderr);

	$rs = execute("a2dissite $site", \$stdout, \$stderr);
	debug("stdout $stdout") if($stdout);
	error("stderr $stderr") if($stderr);
	return $rs if $rs;

	0;
}

sub enableMod{

	use iMSCP::Execute;

	my $self	= shift;
	my $mod		= shift;
	my ($rs, $stdout, $stderr);

	$rs = execute("a2enmod $mod", \$stdout, \$stderr);
	debug("$stdout") if($stdout);
	error("$stderr") if($stderr);
	return $rs if $rs;

	0;
}

sub disableMod{

	use iMSCP::Execute;

	my $self	= shift;
	my $mod		= shift;
	my ($rs, $stdout, $stderr);

	$rs = execute("a2dismod $mod", \$stdout, \$stderr);
	debug("$stdout") if($stdout);
	error("$stderr") if($stderr);
	return $rs if $rs;

	0;
}

sub forceRestart{

	my $self				= shift;
	$self->{forceRestart}	= 'yes';

	0;
}

sub restart{

	my $self			= shift;
	my ($rs, $stdout, $stderr);

	use iMSCP::Execute;

	# Reload apache config
	$rs = execute("$self->{tplValues}->{CMD_HTTPD} ".($self->{forceRestart} ? 'restart' : 'reload'), \$stdout, \$stderr);
	debug("$stdout") if $stdout;
	warning("$stderr") if $stderr && !$rs;
	error("$stderr") if $stderr && $rs;
	error("Error while restating") if $rs && !$stderr;
	return $rs if $rs;

	0;
}

sub buildConf($ $ $){

	use iMSCP::Templator;

	my $self		= shift;
	my $cfgTpl		= shift;
	my $filename	= shift || '';

	error('Empty config template...') unless $cfgTpl;
	return undef unless $cfgTpl;

	$self->{tplValues}->{$_} = $self->{data}->{$_} foreach(keys %{$self->{data}});
	warning('Nothing to do...') unless keys %{$self->{tplValues}} > 0;

	my @calls = exists $self->{preCalls}->{buildConf}
				?
				(@{$self->{preCalls}->{buildConf}})
				:
				()
	; # is a reason for this!!! Simplify code and you have infinite loop

	# avoid running same hook again if is not self register again
	delete $self->{preCalls}->{buildConf};

	foreach(@calls){
		eval {$cfgTpl = &$_($cfgTpl, $filename);};
		error("$@") if ($@);
		return undef if $@;
	};

	$cfgTpl = process($self->{tplValues}, $cfgTpl);
	return undef if (!$cfgTpl);

	# avoid running same hook again if is not self register again
	@calls = exists $self->{postCalls}->{buildConf}
				?
				(@{$self->{postCalls}->{buildConf}})
				:
				()
	; # is a reason for this!!! Simplify code and you have infinite loop

	# avoid running same hook again if is not self register again
	delete $self->{postCalls}->{buildConf};

	foreach(@calls){
		eval {$cfgTpl = &$_($cfgTpl, $filename);};
		error("$@") if ($@);
		return undef if $@;
	};

	$cfgTpl;
}

sub buildConfFile{

	use File::Basename;
	use iMSCP::File;

	my $self	= shift;
	my $file	= shift;
	my $option	= shift;

	$option = {} if ref $option ne 'HASH';

	my ($filename, $directories, $suffix) = fileparse($file);

	$file = "$self->{cfgDir}/$file" unless -d $directories && $directories ne './';

	my $fileH = iMSCP::File->new(filename => $file);
	my $cfgTpl = $fileH->get();
	error("Empty config template $file...") unless $cfgTpl;
	return 1 unless $cfgTpl;

	my @calls = exists $self->{preCalls}->{buildConfFile}
				?
				(@{$self->{preCalls}->{buildConfFile}})
				:
				()
	; # is a reason for this!!! Simplify code and you have infinite loop

	# avoid running same hook again if is not self register again
	delete $self->{preCalls}->{buildConfFile};

	foreach(@calls){
		eval {$cfgTpl = &$_($cfgTpl, "$filename$suffix");};
		error("$@") if ($@);
		return undef if $@;
	}

	$cfgTpl = $self->buildConf($cfgTpl, "$filename$suffix");
	return 1 if (!$cfgTpl);

	@calls = exists $self->{postCalls}->{buildConfFile}
				?
				(@{$self->{postCalls}->{buildConfFile}})
				:
				()
	; # is a reason for this!!! Simplify code and you have infinite loop

	# avoid running same hook again if is not self register again
	delete $self->{postCalls}->{buildConfFile};

	foreach(@calls){
		eval {$cfgTpl = &$_($cfgTpl, "$filename$suffix");};
		error("$@") if ($@);
		return undef if $@;
	}

	$fileH = iMSCP::File->new(
				filename => ($option->{destination}
				?
				$option->{destination} :
				"$self->{wrkDir}/$filename$suffix")
	);
	$fileH->set($cfgTpl) and return 1;
	$fileH->save() and return 1;
	$fileH->mode($option->{mode} ? $option->{mode} : 0644) and return 1;
	$fileH->owner(
			$option->{user}		? $option->{user}	: $main::imscpConfig{'ROOT_USER'},
			$option->{group}	? $option->{group}	: $main::imscpConfig{'ROOT_GROUP'}
	) and return 1;

	0;
}

sub installConfFile{

	use File::Basename;
	use iMSCP::File;

	my $self	= shift;
	my $file	= shift;
	my $option	= shift;

	$option = {} if ref $option ne 'HASH';

	my ($filename, $directories, $suffix) = fileparse($file);

	$file = "$self->{wrkDir}/$file" unless -d $directories && $directories ne './';

	my $fileH = iMSCP::File->new(filename => $file);

	$fileH->mode($option->{mode} ? $option->{mode} : 0644) and return 1;
	$fileH->owner(
			$option->{user}		? $option->{user}	: $main::imscpConfig{'ROOT_USER'},
			$option->{group}	? $option->{group}	: $main::imscpConfig{'ROOT_GROUP'}
	) and return 1;

	$fileH->copyFile(
					$option->{destination}
					?
					$option->{destination} :
					"$self::apacheConfig{APACHE_SITES_DIR}/$filename$suffix"
	);

	0;
}

sub setData{

	my $self	= shift;
	my $data	= shift;

	$data = {} if ref $data ne 'HASH';
	$self->{data} = $data;

	0;
}

sub getRunningUser{
	return $self::apacheConfig{APACHE_USER};
}

sub getRunningGroup{
	return $self::apacheConfig{APACHE_GROUP};
}

sub removeSection{

	use iMSCP::Templator;

	my $self	= shift;
	my $section	= shift;
	my $data	= shift;
	my $bTag = "# SECTION $section BEGIN.\n";
	my $eTag = "# SECTION $section END.\n";
	debug("$section...");

	$data = replaceBloc($bTag, $eTag, '', $data, undef);

	$data;
}

sub buildPHPini{

	use iMSCP::Rights;

	my $self		= shift;
	my $data		= shift;
	my $rs			= 0;
	my $php5Dir		= "$self::apacheConfig{PHP_STARTER_DIR}/$data->{DMN_NAME}";
	my $fileSource	= "$main::imscpConfig{CONF_DIR}/fcgi/parts/php5-fcgi-starter.tpl";
	my $destFile	= "$php5Dir/php5-fcgi-starter";

	$rs |= $self->buildConfFile($fileSource, {destination => $destFile});
	$rs |= setRights($destFile,
		{
			user	=> $data->{USER},
			group	=> $data->{GROUP},
			mode	=> '0550',
		}
	);

	$fileSource	= "$main::imscpConfig{CONF_DIR}/fcgi/parts/php5/php.ini";
	$destFile	= "$php5Dir/php5/php.ini";

	$rs |= $self->buildConfFile($fileSource, {destination => $destFile});
	$rs |= setRights($destFile,
		{
			user	=> $data->{USER},
			group	=> $data->{GROUP},
			mode	=> '0440',
		}
	);

	$rs;
}

#####################################################################################
##			DOMAIN LEVEL
sub addUser{

	use iMSCP::File;
	use iMSCP::Templator;

	my $self		= shift;
	my $data		= shift;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $hDir		= $data->{HOME_DIR};
	my $rootUser	= $main::imscpConfig{ROOT_USER};
	my $rootGroup	= $main::imscpConfig{ROOT_GROUP};
	my $apacheGroup	= $self::apacheConfig{APACHE_GROUP};
	my $php5Dir		= "$self::apacheConfig{PHP_STARTER_DIR}/$data->{DMN_NAME}";
	my ($rs, $stdout, $stderr);

	my $errmsg = {
		'USER'		=> 'You must supply user name!',
		'BWLIMIT'	=> 'You must supply a bandwidth limit!'
	};

	foreach(keys %{$errmsg}){
		error("$errmsg->{$_}") unless exists $data->{$_};
		return 1 unless exists $data->{$_};
	}

	$self->{data} = $data;

	########################## START MOD CBAND SECTION ##############################
	$rs |= iMSCP::File->new(
			filename => "$self->{cfgDir}/00_modcband.conf"
	)->copyFile(
		"$self->{bkpDir}/00_modcband.conf.". time
	) if (-f "$self->{cfgDir}/00_modcband.conf");

	my $filename = (
		-f "$self->{wrkDir}/00_modcband.conf"
		?
		"$self->{wrkDir}/00_modcband.conf"
		:
		"$self->{cfgDir}/00_modcband.conf"
	);

	my $file	= iMSCP::File->new(filename => $filename);
	my $content	= $file->get();

	unless($content){
		error("Can not read $filename");
		$rs = 1;
	} else {
		my $bTag	= "## SECTION {USER} BEGIN.\n";
		my $eTag	= "## SECTION {USER} END.\n";
		my $bUTag	= "## SECTION $data->{USER} BEGIN.\n";
		my $eUTag	= "## SECTION $data->{USER} END.\n";

		my $entry	= getBloc($bTag, $eTag, $content);
		chomp($entry);
		$entry		=~ s/#//g;

		$content	= replaceBloc($bUTag, $eUTag, '', $content, undef);
		chomp($content);

		$self->{data}->{BWLIMIT_DISABLED} = ($data->{BWLIMIT} ? '' : '#');

		$entry		= $self->buildConf($bTag.$entry.$eTag);
		$content	= replaceBloc($bTag, $eTag, $entry, $content, 'yes');

		$file = iMSCP::File->new(filename => "$self->{wrkDir}/00_modcband.conf");
		$file->set($content);
		$rs = 1 if $file->save();

		$rs |= $self->installConfFile("00_modcband.conf");

		$rs |= $self->enableSite("00_modcband.conf");

		unless( -f "$self::apacheConfig{SCOREBOARDS_DIR}/$data->{USER}"){
			$rs	|=	iMSCP::File->new(
						filename => "$self::apacheConfig{SCOREBOARDS_DIR}/$data->{USER}"
					)->save();
		}
	}
	########################### END MOD CBAND SECTION ###############################

	########################## START PHP.INI for user ###############################
	if($self::apacheConfig{INI_LEVEL} =~ /^user$/i){
		for (
			["$php5Dir",		$data->{USER},	$data->{GROUP},	0555],
			["$php5Dir/php5",	$data->{USER},	$data->{GROUP},	0550]
		){
			$rs |= iMSCP::Dir->new( dirname => $_->[0])->make({
				user	=> $_->[1],
				group	=> $_->[2],
				mode	=> $_->[3]
			});
		}
		$rs |= $self->buildPHPini($data);
	}
	########################### END PHP.INI for user ################################

	##################### START COMMON FILES IN USER FOLDER #########################

	#ERROR DOCS
	$rs |= execute("cp -vnRT $main::imscpConfig{GUI_ROOT_DIR}/public/errordocs $hDir/errors", \$stdout, \$stderr);
	debug("$stdout") if $stdout;
	error("$stderr") if $stderr;

	$rs |= setRights(
		"$hDir/errors",
		{
			user		=> $data->{USER},
			group		=> $apacheGroup,
			filemode	=> '0640',
			dirmode		=> '0755',
			recursive	=> 'yes'
		}
	);

	for(
		"$hDir/$self::apacheConfig{HTACCESS_USERS_FILE_NAME}",
		"$hDir/$self::apacheConfig{HTACCESS_GROUPS_FILE_NAME}"
	){
		my $fileH	=	iMSCP::File->new(filename => $_);
		$rs		|=	$fileH->save() unless( -f $_);
		$rs		|=	$fileH->mode(0644);
	}

	###################### END COMMON FILES IN USER FOLDER ##########################

	$self->{restart} = 'yes';

	$rs;
}

sub delUser{

	use iMSCP::File;
	use iMSCP::Dir;
	use iMSCP::Templator;

	my $self		= shift;
	my $data		= shift;
	my $hDir		= $data->{HOME_DIR};
	my $rs			= 0;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $errmsg = {
		'USER'	=> 'You must supply user name!'
	};

	foreach(keys %{$errmsg}){
		error("$errmsg->{$_}") unless exists $data->{$_};
		return 1 unless exists $data->{$_};
	}

	$self->{data} = $data;

	########################## START MOD CBAND SECTION ##############################
	$rs |= iMSCP::File->new(
			filename => "$self->{cfgDir}/00_modcband.conf"
	)->copyFile(
		"$self->{bkpDir}/00_modcband.conf.". time
	) if (-f "$self->{cfgDir}/00_modcband.conf");

	my $filename = (
		-f "$self->{wrkDir}/00_modcband.conf"
		?
		"$self->{wrkDir}/00_modcband.conf"
		:
		"$self->{cfgDir}/00_modcband.conf"
	);

	my $file	= iMSCP::File->new(filename => $filename);
	my $content	= $file->get();
	unless($content){
		error("Can not read $filename");
		$rs = 1;
	} else {
		my $bUTag	= "## SECTION $data->{USER} BEGIN.\n";
		my $eUTag	= "## SECTION $data->{USER} END.\n";

		$content	= replaceBloc($bUTag, $eUTag, '', $content, undef);

		$file = iMSCP::File->new(filename => "$self->{wrkDir}/00_modcband.conf");
		$file->set($content);
		$rs |= $file->save();

		$rs |= $self->installConfFile("00_modcband.conf");

		$rs |= $self->enableSite("00_modcband.conf");

		if( -f "$self::apacheConfig{SCOREBOARDS_DIR}/$data->{USER}"){
			$rs |= iMSCP::File->new(
				filename => "$self::apacheConfig{SCOREBOARDS_DIR}/$data->{USER}"
			)->delFile();
		}
	}
	########################### END MOD CBAND SECTION ###############################

	for(
		"$self::apacheConfig{PHP_STARTER_DIR}/$data->{DMN_NAME}",
		$hDir,
	){
		$rs |= iMSCP::Dir->new(dirname => $_)->remove() if -d $_;
	}

	$self->{restart} = 'yes';

	$rs;
}

sub addDmn{

	my $self = shift;
	my $data = shift;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	$self->{mode} = 'dmn';

	my $errmsg = {
		'DMN_NAME'	=> 'You must supply domain name!',
		'DMN_IP'	=> 'You must supply ip for domain!'
	};

	foreach(keys %{$errmsg}){
		error("$errmsg->{$_}") unless $data->{$_};
		return 1 unless $data->{$_};
	}

	$self->{data} = $data;

	my $rs	= $self->addCfg($data);
	$rs		|= $self->addFiles($data) unless $data->{FORWARD} && $data->{FORWARD} =~ m~(http|htpps|ftp)://~i;

	$self->{restart}	= 'yes';
	delete $self->{data};

	$rs;
}

sub addCfg{

	use iMSCP::File;

	my $self = shift;
	my $data = shift;
	my $rs = 0;

	$self->{data} = $data;

	unless($data->{FORWARD} && $data->{FORWARD} =~ m~(http|htpps|ftp)://~i){
		$self->registerPostHook(
			'buildConf', sub { return $self->removeSection('cgi support', @_); }
		) unless ($data->{have_cgi} && $data->{have_cgi} eq 'yes');

		$self->registerPostHook(
			'buildConf', sub { return $self->removeSection('php enabled', @_); }
		) unless ($data->{have_php} && $data->{have_php} eq 'yes');

		$self->registerPostHook(
			'buildConf', sub { return $self->removeSection('php disabled', @_); }
		) if ($data->{have_php} && $data->{have_php} eq 'yes');
	}

	############################ START CONFIG SECTION ###############################
	$self->{data}->{FCGID_NAME} = $data->{ROOT_DMN_NAME}	if($self::apacheConfig{INI_LEVEL} =~ /^user$/i);
	$self->{data}->{FCGID_NAME} = $data->{PARENT_DMN_NAME} 	if($self::apacheConfig{INI_LEVEL} =~ /^domain$/i);
	$self->{data}->{FCGID_NAME} = $data->{DMN_NAME}			if($self::apacheConfig{INI_LEVEL} =~ /^subdomain$/i);


	$rs |= iMSCP::File->new(
		filename => "$self->{cfgDir}/$data->{DMN_NAME}.conf"
	)->copyFile(
		"$self->{bkpDir}/$data->{DMN_NAME}.conf.". time
	) if (-f "$self->{cfgDir}/$data->{DMN_NAME}.conf");

	$rs |= $self->buildConfFile(
		($data->{FORWARD} && $data->{FORWARD} =~ m~(http|htpps|ftp):\/\/~i ? "$self->{tplDir}/domain_redirect.tpl" : "$self->{tplDir}/domain.tpl"),
		{destination => "$self->{wrkDir}/$data->{DMN_NAME}.conf"}
	);
	$rs |= $self->installConfFile("$data->{DMN_NAME}.conf");
	############################ END CONFIG SECTION ###############################

	$rs |=	$self->buildConfFile(
				"$self->{tplDir}/custom.conf.tpl",
				{destination => "$self::apacheConfig{APACHE_CUSTOM_SITES_CONFIG_DIR}/$data->{DMN_NAME}.conf"}
			) unless (-f "$self::apacheConfig{APACHE_CUSTOM_SITES_CONFIG_DIR}/$data->{DMN_NAME}.conf");

	$rs |= $self->enableSite("$data->{DMN_NAME}.conf");

	$rs;
}

sub dmnFolders{

	my $self		= shift;
	my $data		= shift;
	my $hDir		= $data->{HOME_DIR};
	my $rootUser	= $main::imscpConfig{ROOT_USER};
	my $rootGroup	= $main::imscpConfig{ROOT_GROUP};
	my $apacheGroup	= $self::apacheConfig{APACHE_GROUP};
	my $newHtdocs	= -d "$hDir/htdocs";
	my $php5Dir	= "$self::apacheConfig{PHP_STARTER_DIR}/$data->{DMN_NAME}";
	my ($rs, $stdout, $stderr);

	my @folders = (
		["$hDir",			$data->{USER},	$apacheGroup,	0750],
		["$hDir/htdocs",	$data->{USER},	$data->{GROUP},	0755],
		["$hDir/cgi-bin",	$data->{USER},	$data->{GROUP},	0755],
		["$hDir/phptmp",	$data->{USER},	$apacheGroup,	0770]
	);

	push(@folders, ["$hDir/errors",		$data->{USER},	$data->{GROUP},	0755])
		if $self->{mode} eq 'dmn';
	push(@folders, ["$php5Dir",			$data->{USER},	$data->{GROUP},	0555])
		if
			$self->{mode} eq 'dmn' &&
			$self::apacheConfig{INI_LEVEL} =~ /^domain$/i ||
			$self::apacheConfig{INI_LEVEL} =~ /^subdomain$/i;
	push(@folders, ["$php5Dir/php5",	$data->{USER},	$data->{GROUP},	0550])
		if
			$self->{mode} eq 'dmn' &&
			$self::apacheConfig{INI_LEVEL} =~ /^domain$/i ||
			$self::apacheConfig{INI_LEVEL} =~ /^subdomain$/i;

	@folders;
}

sub addFiles{

	use iMSCP::Dir;
	use iMSCP::Rights;

	my $self		= shift;
	my $data		= shift;
	my $hDir		= $data->{HOME_DIR};
	my $rootUser	= $main::imscpConfig{ROOT_USER};
	my $rootGroup	= $main::imscpConfig{ROOT_GROUP};
	my $apacheGroup	= $self::apacheConfig{APACHE_GROUP};
	my $newHtdocs	= -d "$hDir/htdocs";
	my ($rs, $stdout, $stderr);

	for ($self->dmnFolders($data)){
		$rs |= iMSCP::Dir->new( dirname => $_->[0])->make({
			user	=> $_->[1],
			group	=> $_->[2],
			mode	=> $_->[3]
		});
	}

	unless ($newHtdocs){
		my $sourceDir	= "$main::imscpConfig{GUI_ROOT_DIR}/data/domain_default_page";
		my $dstDir		= "$hDir/htdocs/";
		my $fileSource =
		my $destFile	= "$hDir/htdocs/index.html";

		$rs |= execute("cp -vnRT $sourceDir $dstDir", \$stdout, \$stderr);
		debug("$stdout") if $stdout;
		error("$stderr") if $stderr;

		$rs |= $self->buildConfFile($fileSource, {destination => $destFile});

		$rs |= setRights(
			$dstDir,
			{
				user		=> $data->{USER},
				group		=> $apacheGroup,
				filemode	=> '0640',
				dirmode		=> '0755',
				recursive	=> 'yes'
			}
		);
	}

	my $sourceDir	= "$main::imscpConfig{GUI_ROOT_DIR}/data/domain_disable_page";
	my $dstDir		= "$hDir/domain_disable_page";
	my $fileSource =
	my $destFile	= "$hDir/domain_disable_page/index.html";

	$rs = execute("cp -vnRT $sourceDir $dstDir", \$stdout, \$stderr);
	debug("$stdout") if $stdout;
	error("$stderr") if $stderr;

	$rs = $self->buildConfFile($fileSource, {destination => $destFile});

	$rs = setRights(
		"$hDir/domain_disable_page",
		{
			user		=> $rootUser,
			group		=> $apacheGroup,
			filemode	=> '0640',
			dirmode		=> '0750',
			recursive	=> 'yes'
		}
	);

	$rs |= $self->buildPHPini($data)
		if(
			$self::apacheConfig{INI_LEVEL} =~ /^domain$/i &&
			$self->{mode} eq"dmn" ||
			$self::apacheConfig{INI_LEVEL} =~ /^subdomain$/i
		);

	$rs;
}

sub delDmn{

	my $self	= shift;
	my $data	= shift;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	error('You must supply domain name!') unless $data->{DMN_NAME};
	return 1 unless $data->{DMN_NAME};

	my $rs = 0;

	$rs |= $self->disableSite("$data->{DMN_NAME}.conf");

	for(
		"$self::apacheConfig{APACHE_SITES_DIR}/$data->{DMN_NAME}.conf",
		"$self::apacheConfig{APACHE_CUSTOM_SITES_CONFIG_DIR}/$data->{DMN_NAME}.conf",
		"$self->{wrkDir}/$data->{DMN_NAME}.conf",
	){
		$rs |= iMSCP::File->new(filename => $_)->delFile() if -f $_;
	}

	my $hDir		= $data->{HOME_DIR};

	for(
		"$self::apacheConfig{PHP_STARTER_DIR}/$data->{DMN_NAME}",
		"$hDir",
	){
		$rs |= iMSCP::Dir->new(dirname => $_)->remove() if -d $_;
	}

	$self->{restart}	= 'yes';
	delete $self->{data};

	$rs;
}

sub disableDmn{

	use iMSCP::File;

	my $self = shift;
	my $data = shift;
	my $rs = 0;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $errmsg = {
		'DMN_NAME'	=> 'You must supply domain name!',
		'DMN_IP'	=> 'You must supply ip for domain!'
	};
	foreach(keys %{$errmsg}){
		error("$errmsg->{$_}") unless $data->{$_};
		return 1 unless $data->{$_};
	}

	$self->{data} = $data;

	iMSCP::File->new(
		filename => "$self->{cfgDir}/$data->{DMN_NAME}.conf"
	)->copyFile(
		"$self->{bkpDir}/$data->{DMN_NAME}.conf". time
	) if (-f "$self->{cfgDir}/$data->{DMN_NAME}.conf");

	$rs |= $self->buildConfFile(
		"$self->{tplDir}/domain_disabled.tpl",
		{destination => "$self->{wrkDir}/$data->{DMN_NAME}.conf"}
	);

	$rs |= $self->installConfFile("$data->{DMN_NAME}.conf");

	$rs |= $self->enableSite("$data->{DMN_NAME}.conf");
	return $rs if $rs;

	$self->{restart}	= 'yes';
	delete $self->{data};

	0;
}

sub addSub{
	my $self = shift;
	my $data = shift;
	$self->{mode}	= 'sub';

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $errmsg = {
		'DMN_NAME'	=> 'You must supply subdomain name!',
		'DMN_IP'	=> 'You must supply ip for subdomain!'
	};
	foreach(keys %{$errmsg}){
		error("$errmsg->{$_}") unless $data->{$_};
		return 1 unless $data->{$_};
	}

	$self->{data} = $data;

	my $rs	= $self->addCfg($data);
	$rs		|= $self->addFiles($data);

	$self->{restart}	= 'yes';
	delete $self->{data};

	$rs;
}

sub delSub{
	my $self	= shift;
	$self->delDmn(@_);
}

sub disableSub{
	my $self	= shift;
	$self->disableDmn(@_);
}

sub addHtuser{

	use iMSCP::File;

	my $self	= shift;
	my $data	= shift;
	my $rs		= 0;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $fileName	= $self::apacheConfig{HTACCESS_USERS_FILE_NAME};
	my $filePath	= "$main::imscpConfig{USER_HOME_DIR}/$data->{HTUSER_DMN}/$fileName";
	my $fileH		= iMSCP::File->new(filename => $filePath);
	my $fileContent	= $fileH->get() if -f $filePath;
	$fileContent	= '' if !$fileContent;

	$fileContent	=~ s/^$data->{HTUSER_NAME}:[^\n]*\n//img;
	$fileContent	.= "$data->{HTUSER_NAME}:$data->{HTUSER_PASS}\n";
	$rs |=	$fileH->set($fileContent);
	$rs |=	$fileH->save();
	$rs |=	$fileH->mode(0644);
	$rs |=	$fileH->owner(
				$main::imscpConfig{'ROOT_USER'},
				$main::imscpConfig{'ROOT_GROUP'}
			);

	$rs;
}

sub delHtuser{

	use iMSCP::File;

	my $self	= shift;
	my $data	= shift;
	my $rs		= 0;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $fileName	= $self::apacheConfig{HTACCESS_USERS_FILE_NAME};
	my $filePath	= "$main::imscpConfig{USER_HOME_DIR}/$data->{HTUSER_DMN}/$fileName";
	my $fileH		= iMSCP::File->new(filename => $filePath);
	my $fileContent	= $fileH->get() if -f $filePath;
	$fileContent	= '' if !$fileContent;

	$fileContent	=~ s/^$data->{HTUSER_NAME}:[^\n]*\n//img;
	$rs |=	$fileH->set($fileContent);
	$rs |=	$fileH->save();
	$rs |=	$fileH->mode(0644);
	$rs |=	$fileH->owner(
				$main::imscpConfig{'ROOT_USER'},
				$main::imscpConfig{'ROOT_GROUP'}
			);

	$rs;
}

sub addHtgroup{

	use iMSCP::File;

	my $self	= shift;
	my $data	= shift;
	my $rs		= 0;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $fileName	= $self::apacheConfig{HTACCESS_GROUPS_FILE_NAME};
	my $filePath	= "$main::imscpConfig{USER_HOME_DIR}/$data->{HTGROUP_DMN}/$fileName";
	my $fileH		= iMSCP::File->new(filename => $filePath);
	my $fileContent	= $fileH->get() if -f $filePath;
	$fileContent	= '' if !$fileContent;

	$fileContent	=~ s/^$data->{HTGROUP_NAME}:[^\n]*\n//img;
	$fileContent	.= "$data->{HTGROUP_NAME}:$data->{HTGROUP_USERS}\n";
	$rs |=	$fileH->set($fileContent);
	$rs |=	$fileH->save();
	$rs |=	$fileH->mode(0644);
	$rs |=	$fileH->owner(
				$main::imscpConfig{'ROOT_USER'},
				$main::imscpConfig{'ROOT_GROUP'}
			);

	$rs;
}

sub delHtgroup{

	use iMSCP::File;

	my $self	= shift;
	my $data	= shift;
	my $rs		= 0;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $fileName	= $self::apacheConfig{HTACCESS_GROUPS_FILE_NAME};
	my $filePath	= "$main::imscpConfig{USER_HOME_DIR}/$data->{HTGROUP_DMN}/$fileName";
	my $fileH		= iMSCP::File->new(filename => $filePath);
	my $fileContent	= $fileH->get() if -f $filePath;
	$fileContent	= '' if !$fileContent;

	$fileContent	=~ s/^$data->{HTGROUP_NAME}:[^\n]*\n//img;
	$rs |=	$fileH->set($fileContent);
	$rs |=	$fileH->save();
	$rs |=	$fileH->mode(0644);
	$rs |=	$fileH->owner(
				$main::imscpConfig{'ROOT_USER'},
				$main::imscpConfig{'ROOT_GROUP'}
			);

	$rs;
}

sub addHtaccess{

	use iMSCP::File;
	use iMSCP::Templator;

	my $self	= shift;
	my $data	= shift;
	my $rs		= 0;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $fileUser	= "$data->{HOME_PATH}/$self::apacheConfig{HTACCESS_USERS_FILE_NAME}";
	my $fileGroup	= "$data->{HOME_PATH}/$self::apacheConfig{HTACCESS_GROUPS_FILE_NAME}";
	my $filePath	= "$data->{AUTH_PATH}/.htaccess";
	my $fileH		= iMSCP::File->new(filename => $filePath);
	my $fileContent	= $fileH->get() if -f $filePath;
	$fileContent	= '' if !$fileContent;

	my $bTag	=	"\t\t### START i-MSCP PROTECTION ###\n";
	my $eTag	=	"\t\t### END i-MSCP PROTECTION ###\n";
	my $tag		=	"\t\tAuthType $data->{AUTH_TYPE}\n".
					"\t\tAuthName \"$data->{AUTH_NAME}\"\n".
					"\t\tAuthUserFile $fileUser\n";
	if($data->{HTUSERS} eq ''){
		$tag	.=	"\t\tAuthGroupFile $fileGroup\n".
					"\t\tRequire group $data->{HTGROUPS}\n";
	} else {
		$tag	.=	"\t\tRequire user $data->{HTUSERS}\n";
	}

	$fileContent = replaceBloc($bTag, $eTag, '', $fileContent, undef);
	$fileContent = $bTag.$tag.$eTag.$fileContent;

	$rs |=	$fileH->set($fileContent);
	$rs |=	$fileH->save();
	$rs |=	$fileH->mode(0644);
	$rs |=	$fileH->owner(
				$data->{USER},
				$data->{GROUP}
			);
	$rs;
}

sub delHtaccess{

	use iMSCP::File;
	use iMSCP::Templator;

	my $self	= shift;
	my $data	= shift;
	my $rs		= 0;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	my $fileUser	= "$data->{HOME_PATH}/$self::apacheConfig{HTACCESS_USERS_FILE_NAME}";
	my $fileGroup	= "$data->{HOME_PATH}/$self::apacheConfig{HTACCESS_GROUPS_FILE_NAME}";
	my $filePath	= "$data->{AUTH_PATH}/.htaccess";
	my $fileH		= iMSCP::File->new(filename => $filePath);
	my $fileContent	= $fileH->get() if -f $filePath;
	$fileContent	= '' if !$fileContent;

	my $bTag	=	"\t\t### START i-MSCP PROTECTION ###\n";
	my $eTag	=	"\t\t### END i-MSCP PROTECTION ###\n";

	$fileContent = replaceBloc($bTag, $eTag, '', $fileContent, undef);

	if($fileContent ne ''){
		$rs |=	$fileH->set($fileContent);
		$rs |=	$fileH->save();
		$rs |=	$fileH->mode(0644);
		$rs |=	$fileH->owner(
					$data->{USER},
					$data->{GROUP}
				);
	} else {
		$rs |= $fileH->delFile() if -f $filePath;
	}

	$rs;
}

sub addIps{

	use iMSCP::File;
	use iMSCP::Templator;

	my $self	= shift;
	my $data	= shift;
	my $rs		= 0;

	local $Data::Dumper::Terse = 1;
	debug("Data: ". (Dumper $data));

	unless ($data->{IPS} && ref $data->{IPS} eq 'ARRAY'){
		error("You must provide ip list");
		return 1;
	}

	$rs |= iMSCP::File->new(
		filename => "$self->{cfgDir}/00_nameserver.conf"
	)->copyFile(
		"$self->{bkpDir}/00_nameserver.conf.". time
	) if (-f "$self->{cfgDir}/00_nameserver.conf");

	my $filename = (
		-f "$self->{wrkDir}/00_nameserver.conf"
		?
		"$self->{wrkDir}/00_nameserver.conf"
		:
		"$self->{cfgDir}/00_nameserver.conf"
	);

	my $file = iMSCP::File->new(filename => $filename);
	my $content = $file->get();
	$content =~ s/NameVirtualHost[^\n]+\n//gi;

	foreach (@{$data->{IPS}}){
		$content.= "NameVirtualHost $_:80\n"
	}

	$file = iMSCP::File->new(filename => "$self->{wrkDir}/00_nameserver.conf");
	$file->set($content);
	$file->save() and return 1;

	$rs = $self->installConfFile("00_nameserver.conf");
	return $rs if $rs;

	$rs |= $self->enableSite("00_nameserver.conf");

	$self->{restart}	= 'yes';
	delete $self->{data};

	$rs;
}

sub getTraffic{

	use iMSCP::Execute;
	use iMSCP::Dir;

	my $self	= shift;
	my $who		= shift;
	my $traff	= 0;
	my $trfDir	= "$self::apacheConfig{APACHE_LOG_DIR}/traff";
	my ($rv, $rs, $stdout, $stderr);

	unless($self->{logDb}){
		$self->{logDb} = 1;

		$rs = execute("$main::imscpConfig{CMD_PS} -o pid,args -C 'imscp-apache-logger'", \$stdout, \$stderr);
		error($stderr) if $stderr;

		my $rv = iMSCP::Dir->new(dirname => $trfDir)->moveDir("$trfDir.old") if -d $trfDir;
		if($rv){
			delete $self->{logDb};
			return 0;
		}

		if($rs || !$stdout){
			error('imscp-apache-logger is not running') unless $stderr;
		} else {
			while($stdout =~ m/^\s{0,}(\d+)(?!.*error)/mg){
				$rs = execute("kill -s HUP $1", \$stdout, \$stderr);
				debug($stdout) if $stdout;
				error($stderr) if $stderr;
			}
		}
	}

	if(-d "$trfDir.old" && -f "$trfDir.old/$who-traf.log"){
		use iMSCP::File;
		my $content = iMSCP::File->new(filename => "$trfDir.old/$who-traf.log")->get();
		if($content){
			my @lines = split("\n", $content);
			$traff += $_ foreach @lines;
		} else {
			error("Can not read $trfDir.old/$who-traf.log");
		}
	}

	$traff;
}

END{

	use iMSCP::Dir;

	my $endCode	= $?;
	my $self	= Servers::httpd::apache->new();
	my $rs		= 0;
	my $trfDir	= "$self::apacheConfig{APACHE_LOG_DIR}/traff";

	$rs = $self->restart() if $self->{restart} && $self->{restart} eq 'yes';

	$rs |= iMSCP::Dir->new(dirname => "$trfDir.old")->remove() if -d "$trfDir.old";

	$? = $endCode || $rs;
}

1;
