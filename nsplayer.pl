#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: nsplayer.pl
#
#        USAGE: ./nsplayer.pl  
#
#  DESCRIPTION: Perl Wrapper to autostart the novisign web player
#
#      OPTIONS: -k Novisign Screen Key
# REQUIREMENTS: requires package libx11-guitest-perl
#       AUTHOR: Adam Fairbrother, afairbrother@sd73.bc.ca
# ORGANIZATION: School District No. 73
#      VERSION: 1.0
#      CREATED: 14-02-13 04:32:49 PM
#===============================================================================

use strict;
use warnings;
use utf8;
use Getopt::Std;
use X11::GUITest qw/
	StartApp
	WaitWindowViewable
	GetScreenRes
	ResizeWindow
	ClickWindow
	MoveMouseAbs
	MoveWindow
	/;

my $FF_height = 705;
my $FF_width = 342;

my $button_x = 540;
my $button_y = 300;

# Screen Key
our $opt_k;
getopts( 'k:' );

my $application = "/usr/bin/firefox http://app.novisign.com/Player/NPlayer.html?screenkey=$opt_k";
my $app_title = "Novisign - Mozilla Firefox";

# Clear Out firefox cache / settings
my $profiledir;
my $ffdir = $ENV{"HOME"} . "/.mozilla/firefox";

open my $ffProfile, '<', "$ffdir/profiles.ini" || die "$!";
while (<$ffProfile>) {
	chomp;
	if (m/Path=/) {
		$profiledir = $_;
		$profiledir =~ s/Path=//;
		last;
	}
}
close $ffProfile;

opendir my $dir, "$ffdir/$profiledir/" || die "$!";
my @sqlites = grep { /sqlite/ && -f "$ffdir/$profiledir/$_" } readdir($dir);
close $dir;

foreach (@sqlites) {
	unlink "$ffdir/$profiledir/$_" or warn "$_:$!";
}
unlink glob "$ffdir/$profiledir/sessionstore.*";

# Start and wait for ready
StartApp( $application );

my ($WindowID) = WaitWindowViewable($app_title,undef,30);
if (!$WindowID) {
	die ("Couldn't find $app_title in time!");
}

my ($screen_x, $screen_y) = GetScreenRes();

#Resize and centre the window
ResizeWindow ($WindowID, $FF_height,$FF_width);
MoveWindow( $WindowID, ($screen_x - $FF_height)/2, ($screen_y - $FF_width)/2);

sleep 1;

#Click the 'Lets Roll' button, and move the mouse off screen
ClickWindow($WindowID, $button_x, $button_y);
MoveMouseAbs($screen_x, $screen_y);
