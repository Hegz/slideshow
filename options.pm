#===============================================================================
#
#         FILE:  options.pm
#
#  DESCRIPTION:  This file contains the options for the slideshow.pl file
#
#        NOTES:  The Case of the values will matter for all values defined in
#                this file.  Please take that into concideration when editing.
#
#       AUTHOR:  Adam Fairbrother (AF), afairbrother@sd74.bc.ca
#      COMPANY:  School District No. 73
#      VERSION:  1.0
#      CREATED:  11-01-26 01:53:34 PM
#===============================================================================

use strict;
use warnings;
use POSIX qw(strftime);

package options;
use Exporter;
our @ISA = qw(Exporter);

#### General Options ####

# Machine dns name to run the script on
our $machine = '';

# User account to run the slideshow
our $showuser = 'hallmon';

# Set this variable to 1 to state that the software is ready to be installed.
our $installrdy = 0;

#### Automatic Play Options ####

# The name of the odp file to play exclusively if it exists.
our $magicodp = 'Automatic.odp';

# The name of the video file to play exclusively if it exists.
# use EXT as a placeholder file extention.
our $magicvideo = 'Automatic.EXT';

# Valid video file extentions. default is Just a small smattering
# expand as needed based off what Mplayer can play.
our @videoextentions = qw(avi mpg wmv asf mov mp4);

our $magicnovisign = 'Novisign.key';

#### Directory Locations ####

# slide show user home folder
our $userhomedir = '/home/' . substr( $showuser, 0, 1 ) . "/$showuser";

# where the raw files are stored by the steno
our $showdir = '/home/public/TV';

# location of the x screen saver image cache file
our $xscreencache = "$userhomedir/.xscreensaver-getimage.cache";

# where the converted slides are to be stored
our $convertdir = "$showdir/.ConvertedSlides";

#### Program Locations ####

# location of the open office bin file for converts
our $sofficebin = '/usr/lib/libreoffice/program/soffice.bin';

# Location of the open office wrapper executable for the slideshow
our $sofficeslides = '/usr/bin/soffice';

# location of the Imagemagick convert program
our $convertbin = '/usr/bin/convert';

# location of the mplayer program
our $mplaybin = '/usr/bin/mplayer';

#### Logging Options ####

# current date string YYYY-MM-DD
my $today = POSIX::strftime "%Y-%b-%e", localtime;

# The location to store log files.
our $logdir = "$userhomedir/log";

# Log file name for slideshow converts/updates/deletes
our $showlogfile = "$logdir/$today-Slideshow.log";

#Variables exported by this config file, No need to edit.
our @EXPORT = qw($machine $showuser $installrdy
	$userhomedir $showdir $xscreencache $convertdir
	$sofficebin $sofficeslides $convertbin $mplaybin
	$logdir $showlogfile
	$magicodp $magicvideo @videoextentions $magicnovisign);
