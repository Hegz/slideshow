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
my $machine          ='t101-1';

# User account to run the slideshow
my $showuser         ='hallmon';


#### Directory Locations ####

# slide show user home folder
my $userhomedir      ='/home/h/hallmon';

# where the raw files are stored by the steno
my $showdir          ='/home/public/TV';                

# location of the x screen saver image cache file
my $xscreencache     ="$userhomedir/.xscreensaver-getimage.cache";

# where the converted slides are to be stored
my $convertdir       ="$showdir/.ConvertedSlides";


#### Program Locations ####

# location of the open office bin file
my $sofficebin       ='/usr/lib/openoffice/program/soffice.bin';

# location of the Imagemagick convert program
my $convertbin       ='/usr/bin/convert';

# location of the mplayer program
my $mplaybin         ='/usr/bin/mplayer';


#### Logging Options ####

# current date string YYYY-MM-DD
my $today            =POSIX::strftime "%Y-%b-%e", localtime;

# The location to store log files.
my $logdir           ="$userhomedir/log";

# Log file name for slideshow converts/updates/deletes
my $showlogfile      ="$logdir/$today-Slideshow.log";


#### Automatic Play Options ####

# The name of the odp file to play exclusively if it exists.
my $magicodp         ="Automatic.odp";

# The name of the video file to play exclusively if it exists.
# use EXT as a placeholder file extention.
my $magicvideo       ="Automatic.EXT";

# Valid video file extentions. default is Just a small smattering 
# expand as needed based off what Mplayer can play.
my @videoextentions  =qw(avi mpg wmv asf mov mp4);


#Variables exported by this config file, No need to edit.
our @EXPORT = qw($machine $showuser 
		$userhomedir $showdir $xscreencache $convertdir 
		$sofficebin $convertbin $mplaybin 
		$logdir $showlogfile  
		$magicodp $magicvideo @videoextentions );
