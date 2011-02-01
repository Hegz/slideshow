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
use options;

print "$magicodp\n";
# Verify the config file.
unless ($install) {
	print "Please edit the config file options.pm to ensure that eveything is setup correctly.\n";
	exit;
}
unless ($machine) {
	print "You will need to set the machine dns name for the slideshow to run.\n";
	exit;
}
# make sure we're running as root.
unless ($ENV{'USER'} eq 'root'){
	print "This script requires root privilages.  Please run with sudo.\n";
	exit;
}
# Check to see that $showuser isn't already on the system
open my $passwdfile, '<', '/etc/passwd';
while (<$passwdfile>) {
	if (m/$showuser/){
		print "the user account $showuser is already active on the system.  Is the slideshow account already setup?\n";
		exit;
	}
}

# check for the source files in the current dir.
opendir my $source, "$ENV{'PWD'}";
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
	exit;
}

# Add the user to the system
`useradd -d $userhomedir -m -s /bin/bash -g teachers -c 'Account for the automatic slideshow computer' $showuser `;

# Copy the files from the current dir to the users folder.
opendir $source, "$ENV{'PWD'}";
my @files = readdir($source);
foreach (@files){
	copy($_, $userhomedir);
}

# Set correct ownership/permissions on the new files
`chown $showuser\\: ~$showuser -R`;

# Set the machine to login automatically.
open my $autologin, '>>', '/var/lib/vservers/vs1/etc/gdm/autologin/';
print $autologin "$machine:$showuser\n";
close $autologin;

# Create the slideshow folder
# Create the hidden slideshow folder
mkpath($showdir,$convertdir);

# Set permisions on the slideshow folder
# Set permissions on the hidden folder
`chown $showuser\\: $showdir -R`;
`chmod 770 $showdir -R`;

# Run the mkdoc script to write a quick users guide to the slideshow folder

eval {require "mkdoc.pl"};
