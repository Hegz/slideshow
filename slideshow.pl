#!/usr/bin/perl
##===============================================================================
#
#         FILE:  slideshow.pl
#
#        USAGE:  Don't run this file directly.  It is run from a user level cron 
#                script  
#
#  DESCRIPTION: This script will handle the display of files as part of a hallway
#               slideshow/video presentation.
#
#               This script handels display and updates to the files.
#               Supported File types
#                    Open Office Impress
#                    Adobe pdf
#                    Movie files ( avi, mpeg, etc...)
#
#       AUTHOR:  Adam Fairbrother (AF), afairbrother@sd73.bc.ca
#      COMPANY:  School District No. 73
#      VERSION:  1.0
#      CREATED:  10-03-27 
#      UPDATED:  11-02-08 11:49:57 AM
#===============================================================================

use warnings;
use strict;
use File::Copy;
use options;

$ENV{'DISPLAY'} = ':0';# needed for open office headless

open my $log, '>>', "$showlogfile" or die("Cannot open log file ($showlogfile). $!");
opendir my $show, $showdir or die("Cannot Open Slide show Directory ($showdir). $!");
my $mytime = gettime();
{
# Strip the .EXT from the magic video filename
	local $magicvideo = $magicvideo;
	$magicvideo =~ s/\..*$//;

	foreach (readdir ($show)) {
		if (m/$magicodp/){
			if (`ps -a u -u hallmon | grep -v grep | grep -c $magicodp ` != 0) {
				if ((stat("$showdir/$magicodp"))[9] != (stat("$convertdir/$magicodp"))[9]) {
					start_show($magicodp);
					print $log "[I] $mytime Updated $magicodp Impress slideshow.\n";
					exec("$sofficeslides -norestore -view -show $convertdir/$magicodp");
					exit 0;
				}
				else{
					exit 0;
				}
			}
			else {
				start_show($magicodp);
				print $log "[I] $mytime Started $magicodp Impress slideshow.\n";
				system("$sofficeslides -norestore -view -show $convertdir/$magicodp");
				exit 0;
			}  
		}
		elsif (m/$magicvideo/){
			for my $ext (@videoextentions){
				if (m/$magicvideo\.$ext/){
					$magicvideo = $_;
					if (`ps -a u -u hallmon | grep -v grep | grep -c $magicvideo ` != 0) {
						if ((stat("$showdir/$magicvideo"))[9] != (stat("$convertdir/$magicvideo"))[9]) {
							start_show($magicvideo);
							print $log "[M] $mytime Updated $magicvideo mplayer video file.\n";
							unless(fork()){
								exec "$mplaybin -fs -quiet $convertdir/$magicvideo -loop 0 &> /dev/null";
							}
							exit 0;
						}
						else {
							exit 0;
						}
					}
					else {
						start_show($magicvideo);
						print $log "[M] $mytime Started $magicvideo mplayer video file.\n";
						unless(fork()){
							exec "$mplaybin -fs -quiet $convertdir/$magicvideo -loop 0 &> /dev/null";
						}
						exit 0;
					}
				}
			}
		}
	}
}
# No magic has been found in the presentation folder, kill any soffice or mplayer processes
`killall soffice.bin`;
`killall mplayer`;

# Enable the screen saver
`dcop kdesktop KScreensaverIface enable 1`;

rewinddir $show;

my %existdocs;

foreach (readdir($show)){
	if (lc($_) =~ m/\.odp$/) { 
#Process ODP files
		my $slidesdir = "$convertdir/$_/";
		my $cmd = "$sofficebin -headless \"macro:///Standard.ConvertImpresstoPNG.Main($showdir/$_,$slidesdir)\"";
		print $log &processfile($_, $slidesdir, $cmd)
	}
	elsif (lc($_) =~ m/\.pdf/) {
# Process PDF files
		my $slidesdir = "$convertdir/$_/";
		my $cmd = "$convertbin \"$showdir/$_\" \"$slidesdir/$_.png\"";
		print $log &processfile($_, $slidesdir, $cmd);
	}
#setup more file type handeling here
}
closedir $show;

# clean up old slide sets.
opendir my $convert, "$convertdir";
foreach (readdir($convert)) {
	my $dir = "$convertdir/$_";
	next if (($_ eq ".") || ($_ eq "..") || (-l $dir));
	next if (exists($existdocs{$_}));
	print $log &rmdircontent($dir);
	rmdir $dir;	
}
closedir($convert);
# close $log;

#update the cache
eval {require "updatecache.pl"};


# Check for changes to the options file, and update the quick users guide
if (((stat("$userhomedir/options.pm"))[9]) != ((stat("$showdir/README.txt"))[9])) {
	eval {require "mkdoc.pl"};
}

# Start the screensaver and exit the script.
unless(fork()){
	exec('/usr/bin/kdesktop_lock');
}

sub start_show {
# Re/start the show with the new source file from the $convertdir
# file mtime is used to see if files differ.
	my ($file) = @_;
# Kill everything
	system 'killall soffice';
	sleep 5;
	system 'killall mplayer';
	sleep 5;
	system 'killall kdesktop_lock';
	system 'dcop kdesktop KScreensaverIface enable 0';
	if ( -e "$convertdir/$file") {
		unlink "$convertdir/$magicodp";
	}
	copy( "$showdir/$file","$convertdir/$file" );
	utime(time, ((stat("$showdir/$file"))[9]), "$convertdir/$file");
}

sub rmdircontent {
# empty the contents of a directory
	my ($dir) = @_;
	my $mytime = &gettime;
	if ( -d $dir) {
		opendir my $todelete, "$dir";
		my @del = grep { !/^\./ && -f "$dir/$_"} readdir($todelete); 
		foreach (@del){
			unlink "$dir/$_";
		}
		close($todelete);
		return "[D] $mytime $dir\n";
	}
	return "[W] $mytime Directory $dir dosn't exist\n";
}

sub processfile {
	my ($file, $slidesdir, $cmd) = @_;
	# Create/update child image files for a given file
	# 1: Source file to process
	# 3: desitination directory
	# 3: command of the file to process
	$existdocs{$_} = 1;
	my $logmsg = "";
	my $docmtime = (stat("$showdir/$file"))[9];
	if ( (-e $slidesdir) && ( -d $slidesdir) && ($docmtime != (stat($slidesdir))[9])){
	# Dir exists and have differerent mtimes, remove old slides and recreate
		&rmdircontent($slidesdir);
		system $cmd;
		print "$cmd\n";
		utime(time, $docmtime, $slidesdir);
		my $mytime = &gettime;
		$logmsg = "[U] $mytime \"$file\" As: $slidesdir\n";
	}
	elsif ( (! -e $slidesdir) && ( ! -d "$showdir/$file") && ( -e "$showdir/$file")) {
	# convert slides and set the mtime of the directory
		mkdir($slidesdir);
		system $cmd;
		print "$cmd\n";
		utime(time, $docmtime, $slidesdir);
		my $mytime = &gettime;
		$logmsg = "[C] $mytime \"$file\" As: $slidesdir\n";
	}
	return $logmsg;
}

sub gettime {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $time = sprintf("%02d:%02d:%02d",$hour,$min,$sec);
	return $time;
}
