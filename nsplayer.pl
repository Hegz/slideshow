#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: nsplayer.pl
#
#        USAGE: ./nsplayer.pl  
#
#  DESCRIPTION: Perl Wrapper to autostart the novisign web player
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Adam Fairbrother (Hegz), afairbrother@sd73.bc.ca
# ORGANIZATION: School District No. 73
#      VERSION: 1.0
#      CREATED: 14-02-13 04:32:49 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use X11::GUITest qw/
	StartApp
	WaitWindowViewable
	GetWindowPos
	GetScreenRes
	ResizeWindow
	ClickWindow
	MoveMouseAbs
	/;

my $application = "/usr/bin/firefox http://app.novisign.com/Player/NPlayer.html?screenkey=03eaefa2-64dc-41e0-86e6-f3255c4aa270";
my $app_title = "Novisign - Mozilla Firefox";

StartApp( $application );

my ($WindowID) = WaitWindowViewable($app_title);
if (!$WindowID) {
	die ("Couldn't find $app_title in time!");
}

my ($x, $y, $width, $height) = GetWindowPos($WindowID);

my ($screen_x, $screen_y) = GetScreenRes();

#Resize and centre the window
ResizeWindow ($WindowID, 705,342);
sleep 5;
ClickWindow($WindowID, 540, 300);
MoveMouseAbs($screen_x, $screen_y);
