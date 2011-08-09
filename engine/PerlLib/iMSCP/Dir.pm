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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# @category		i-MSCP
# @copyright	2010 - 2011 by i-MSCP | http://i-mscp.net
# @author		Daniel Andreca <sci2tech@gmail.com>
# @version		SVN: $Id$
# @link			http://i-mscp.net i-MSCP Home Site
# @license		http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package iMSCP::Dir;

use FindBin;
use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin/../PerlLib";
use lib "$FindBin::Bin/../PerlVendor";

use strict;
use warnings;
use iMSCP::Debug;

use vars qw/@ISA $AUTOLOAD/;

@ISA = ('Common::SimpleClass');
use Common::SimpleClass;


sub _init{
	my $self = shift;
	debug('Starting...');
	for my $conf (keys %{$self->{args}}){
		$self->{$conf} = $self->{args}->{$conf};
	}
	debug('Ending...');
}

sub getFiles{
	my $self = shift;
	debug('Starting...');
	if(! $self->{files}) {
		$self->{files} = ();
		$self->get();
		$self->{fileType} = '' unless $self->{fileType};
		foreach (@{$self->{dirContent}}){
			push(
				@{$self->{files}},
				$_
			) if( -f "$self->{dirname}/$_" && $_ =~ m!$self->{fileType}$!);
		}
	}
	debug('Ending...');
	my @files = ($self->{files} ? @{$self->{files}} : ());
	return (wantarray ? @files : join(' ', @files));
}


sub getDirs{
	my $self = shift;
	debug('Starting...');
	if(! $self->{dirs}) {
		$self->{dirs} = ();
		$self->get();
		foreach (@{$self->{dirContent}}){
			next if($_ eq '.' || $_ eq '..');
			push(@{$self->{dirs}}, $_) if( -d "$self->{dirname}/$_");
		}
	}
	debug('Ending...');
	return (wantarray ? @{$self->{dirs}} : join(' ', @{$self->{dirs}}));
}

sub get{

	my $self = shift;

	debug('Starting...');

	if(! $self->{dirContent}) {
		debug("open directory $self->{dirname}");
		$self->{dirContent} = ();
		unless (opendir(DIRH, $self->{dirname})){
			error("Cannot open directory $self->{dirname}");
			return 1;
		}
		@{$self->{dirContent}} = readdir(DIRH);
		closedir(DIRH);
	}

	debug('Ending...');

	return (wantarray ? $self->{dirContent} : join(" ", @{$self->{dirContent}}));
}

sub mode{

	my $self	= shift;
	my $mode	= shift;
	my $dir		= shift;

	debug('Starting...');

	debug( sprintf ": Change mode mode: %o for '".( $dir || $self->{dirname}) ."'", $mode);
	unless (chmod($mode, $dir || $self->{dirname})){
		error("Cannot change permissions of file '".( $dir || $self->{dirname}) ."': $!");
		return 1;
	}

	debug('Ending...');
	0;
}

sub owner{

	my $self	= shift;
	my $owner	= shift;
	my $group	= shift;
	my $dir	= shift;

	debug('Starting...');

	my $uid = ($owner =~ /^\d+$/) ? $owner : getpwnam($owner);
	$uid = -1 unless (defined $uid);

	my $gid = ($group =~ /^\d+$/) ? $group : getgrnam($group);
	$gid = -1 unless (defined $gid);

	debug("Change owner uid:$uid, gid:$gid for '".( $dir || $self->{dirname}) ."'");

	unless (chown($uid, $gid,  $dir || $self->{dirname})){
		error("Cannot change owner of file '".( $dir || $self->{dirname}) ."': $!");
		return 1;
	}

	debug('Ending...');
	0;
}

sub make{

	my $self	= shift;
	my $option	= shift || {};

	$option = {} if (ref $option ne 'HASH');

	debug('Starting...');

	if (-e  $self->{dirname} && ! -d  $self->{dirname}) {
		warning("' $self->{dirname}' exists as file ! removing file first...");
		if(! unlink  $self->{dirname}){
			error("Could not unlink $self->{dirname}: $!");
			return 1;
		 }
	}

	if (!(-e  $self->{dirname} && -d  $self->{dirname})) {
		debug("'$self->{dirname}' doesn't exists as directory! creating...");
		my $err;

		use File::Path;
		my @lines =  mkpath( $self->{dirname}, {error => \$err});

		if (@$err) {
			for my $diag (@$err) {
				my ($dir, $message) = %$diag;
				if ($dir eq '') {
					error("General error: $message");
				}
				else {
					error("Problem creating $dir: $message");
				}
			}
			return 1;
		}

		foreach (@lines){
			if($option->{mode}){
				return 1 if $self->mode($option->{mode}, $_);
			}
			if($option->{user} || $option->{group}){
				return 1 if $self->owner(
					$option->{user} || -1,
					$option->{group} || -1,
					$_
				);
			}
		}

	} else {
		debug("'$self->{dirname}' exists ! Setting its permissions...");

		if($option->{mode}){
			return 1 if $self->mode( $option->{mode}, $self->{dirname});
		}
		if(defined $option->{user} || defined $option->{group}){
			return 1 if $self->owner(
				defined $option->{user} ? $option->{user} : -1,
				defined $option->{group} ? $option->{group} : -1,
				$self->{dirname}
			);
		}

	}

	debug('Ending...');

	0;
}

sub remove{

	my $self	= shift;
	my $err;

	debug('Starting...');

	debug("$self->{dirname}");

	use File::Path 'remove_tree';

	if ( -d  $self->{dirname}) {

		use File::Path;
		remove_tree( $self->{dirname}, {error => \$err});

		if (@$err) {
			for my $diag (@$err) {
				my ($dir, $message) = %$diag;
				if ($dir eq '') {
					error("General error: $message");
				}
				else {
					error("Problem deleting $dir: $message");
				}
			}
			return 1;
		}

	}

	debug('Ending...');

	0;
}

sub rcopy{
	my $self	= shift;
	my $destDir	= shift;
	my $option	= shift;

	$option = {} if(ref $option ne 'HASH');

	debug('Starting...');
	use iMSCP::File;

	my $dh;

	unless(opendir $dh, $self->{dirname}){
		error("Could not open dir '$self->{dirname}': $!");
		return 1;
	}

	for my $entry (readdir $dh) {
		next if($entry eq '.' or $entry eq '..');
		my $source = "$self->{dirname}/$entry";
		my $destination = "$destDir/$entry";
		if (-d $source) {
			next if($option->{excludeDir} && $source =~ /$option->{excludeDir}/);
			my $opts = {};
			if(!$option->{preserve} || (lc($option->{preserve}) ne 'no')){
				my $mode	= (stat($source))[2] & 00777;
				my $user	= (stat($source))[4];
				my $group	= (stat($source))[5];
				$opts	= {user =>$user, mode =>$mode, group =>$group}
			}
			debug("Copy directory $source to $destination");
			my $dir=iMSCP::Dir->new();
			$dir->{dirname} = $destination;
			$dir->make($opts) and return 1;
			$dir->{dirname} = $source;
			$dir->rcopy($destination, $option) and return 1;
		} else {
			if($option->{excludeFile}){error"$option->{excludeFile}";}
			next if($option->{excludeFile} && ($source =~ /$option->{excludeFile}/));
			debug("Copy file $self->{dirname}/$entry to $destDir/$entry");
			my $file=iMSCP::File->new();
			$file->{filename} = $source;
			$file->copyFile($destination, $option) and return 1;
		}
	}
	closedir $dh;

	debug('Ending...');
	0;
}
1;

__END__
