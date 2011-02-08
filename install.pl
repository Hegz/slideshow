#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  install.pl
#
#        USAGE:  ./install.pl  
#
#  DESCRIPTION:  Perform the nessiary steps to setup the slideshow system
#
# REQUIREMENTS:  Run from the same folder as the contents of the archive with 
#                Root permissions (sudo).
#
#       AUTHOR:  Adam Fairbrother (AF), afairbrother@sd73.bc.ca
#      COMPANY:  School District No. 73
#      VERSION:  1.0
#      CREATED:  11-01-31 11:24:55 AM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use File::Copy;
use File::Path;
use Cwd;
use options;
use Getopt::Long;

#Setup Command line flags
my $install = 0;
my $update = 0;
my $uninstall = 0;
GetOptions ( 'install'   => \$install,
		'update'    => \$update,
		'uninstall' => \$uninstall);

unless ($install || $update || $uninstall){
	# Display Usage information
	print "No flags detected\n";
	exit;
}

if (($install + $update + $uninstall) > 1 ){
	# Display usage information
	print "Multiple flags detected\n";
	exit;
}

if ($install) {
	# Verify the config file.
	unless ($install) {
		print "Please edit the config file options.pm to ensure that eveything is setup correctly.\n";
		print "Install Aborting, Unsuccessful\n";
		exit;
	}
	unless ($machine) {
		print "You will need to set the machine dns name for the slideshow to run.\n";
		print "Install Aborting, Unsuccessful\n";
		exit;
	}
	# make sure we're running as root, or with sudo
	unless ($ENV{'USER'} eq 'root'){
		print "This script requires root privilages.  Please run with sudo.\n";
		print "Install Aborting, Unsuccessful\n";
		exit;
	}
	# Check to see that $showuser isn't already on the system
	open my $passwdfile, '<', '/etc/passwd' or die("error opening passwd file $!\n");
	while (<$passwdfile>) {
		if (m/$showuser/){
			print "the user account $showuser is already active on the system.  Is the slideshow account already setup?\n";
			print "Install Aborting, Unsuccessful\n";
			exit;
		}
	}

	# check for the source files in the current dir.
	my $currentdir = getcwd;
	opendir my $source, "$currentdir" or die("Error opening current directory $!\n");
	my @localfiles = readdir($source);
	my $correctfolder = 0;
	foreach (@localfiles) {
		if (m/install.pl/){
			$correctfolder = 1;
		}
	}
	close $source;
	unless ($correctfolder) {
		print "This script must be run from within extracted file directory.\n";
		print "Please change to the directoy where you extracted the files and try again\n";
		print "Install Aborting, Unsuccessful\n";
		exit;
	}


	# begin the installation steps here, 
	my $autologinfile = '/var/lib/vservers/vs1/etc/gdm/autologin';
	my $autologin;
	open $autologin, '<', $autologinfile or die("Error opening autologin file for read ($autologinfile):$!\n");
	while (<$autologin>){
		if (m/(.*)\:$showuser/){
			print "Account $showuser is already set to atologin on machine $1\n";
			print "Install Aborting, Unsuccessful\n";
			exit;
		}
	}
	close $autologin;

	open $autologin, '>>', $autologinfile or die("Error opening autologin file for write ($autologinfile):$!\nInstall Aborting, Unsuccessful\n");

	# **** Anything that can fail during install should do so before this point ****

	# Add the user to the system
	`useradd -d $userhomedir -m -s /bin/bash -g teachers -c 'Automatic slideshow computer account' $showuser `;

	# Copy the files from the current dir to the users folder.
	`cp $currentdir/* -r $userhomedir`;
	`cp $currentdir/.??* -r $userhomedir`;

	# create the log file folder
	mkpath($logdir);

	# Set correct ownership/permissions on the new files
	`chown $showuser\\: ~$showuser -R`;

	# Set the machine to login automatically.
	print $autologin "$machine:$showuser\n";
	close $autologin;

	# Create the slideshow folder, and hidden folder 
	mkpath($showdir,$convertdir);

	symlink $showdir, "$convertdir/showdir";
	# Set permisions on the slideshow folder and the hidden folder
	`chown $showuser\\: $showdir -R`;
	`chmod 770 $showdir -R`;

	# Update the cron scripts for the correct paths
	{
		local $^I = '.bak';
		local @ARGV = ("$userhomedir/.kde/Autostart/cron-15m.sh", "$userhomedir/.kde/Autostart/cron-1m.sh");
		while (<>){
			s/PATH/$userhomedir/;
			s/LOG/$logdir/;
			print
		}
		unlink ("$userhomedir/.kde/Autostart/cron-15m.sh.bak", "$userhomedir/.kde/Autostart/cron-1m.sh.bak");
	}

	# Update the .xscreensaver file with the correct slideshow path
	{
		local $^I = '.bak';
		local @ARGV = ("$userhomedir/.xscreensaver");
		while (<>){
			s/PATH/$convertdir/;
			print;
		}
		unlink ("$userhomedir/.xscreensaver.bak");
	}

	# Run the mkdoc script to write a quick users guide to the slideshow folder
	eval {require "mkdoc.pl"};

	print "Install Successful\n";
	print "Please restart the slideshow machine ($machine) to complete the installation\n";
	exit;
}
elsif ($uninstall) {
	# run install from $showuser $HOME
	my $currentdir = getcwd;
	if ($currentdir ne $userhomedir){
		print "Please run the uninstall script from the Slidshow users home folder\n";
		print "Uninstall Aborting, Unsuccessful\n";
		exit;
	}
	# Make sure we're running with root privalages, or sudo
	unless ($ENV{'USER'} eq 'root'){
		print "This script requires root privilages.  Please run with sudo.\n";
		print "Unnstall Aborting, Unsuccessful\n";
		exit;
	}
	# Remove $convertdir
	remove_tree($convertdir);

	# remove README
	unlink ("$showdir/README.txt");
	# Remove Autologin
	{
		local $^I = '.bak';
		local @ARGV = ('/var/lib/vservers/vs1/etc/gdm/autologin');
		while (<>){
			s/$machine:$showuser//;
			print;
		}
		unlink ('/var/lib/vservers/vs1/etc/gdm/autologin.bak');
	}
	# remove user & $userhome from the system
	`userdel -r -f $showuser`;

	print "Uninstall Successful\n";
	print "Please restart the slideshow machine ($machine) to complete the Uninstallation\n";
	`cd`;
	exit;
}
elsif ($update) {
	print "Feature not yet implemented\n";

}
