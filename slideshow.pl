#!/usr/bin/perl
# Adam Fairbrother afairbrother@sd73.bc.ca
# May 27, 2010
#
# Perl script to change document files into picures to be displayed on the TV
# Slide files are stored in directoies named after the files in a hidden directory of the base slideshow folder
# in the hidden folder should be simlink to ../
# the slideshow should be started from the hidden diretory
#
# Currently handles:
# 	Open Office Impress
# 	Adobe PDF files
use warnings;
use strict;
use File::Copy;
use options;

$ENV{'DISPLAY'} = ':0';# needed for open office headless

open my $log, '>>', "$showlogfile" || die("Cannot open log file ($showlogfile). $!");
opendir my $show, $showdir || die("Cannot Open Slide show Directory ($showdir). $!");

# Strip the EXT from the magic video filename
$magicvideo =~ s/\..*$/./;

foreach (readdir ($show)) {
# Check for magic files.  Only the first magic file found will play.
	if (m/$magicodp/){
		# Magic odp found
		if (`ps -a u -u hallmon | grep $magicodp -c`) {
			# Magic is running. Is it the current version?
			if ((stat("$showdir/$magicodp"))[9] != (stat("$convertdir/$magicodp"))[9]) {
				# modify time on the file is different!
				# Stop the running process
				`killall soffice.bin`;
				sleep 15;
				# Delete the old file
				unlink "$convertdir/$magicodp";
				# Copy the new file to dodge file locks.
				copy( "$showdir/$magicodp","$convertdir/$magicodp");
				# Keep the mtime of the old and new files in sync
				utime(time, ((stat("$showdir/$magicodp"))[9]), "$convertdir/$magicodp");
				# Restart the slideshow.
				exec("$sofficebin -norestore -view -show $convertdir/$magicodp");
				# Nothing left to do, Leave happy.
				exit 0;
			}
			else{
				# We are running and up to date, Nothing left to do.
				exit 0;
			}
		}
	}
	elsif (m/$magicvideo/){
		for my $ext (@videoextentions){
			# Unroll the file extentions list
			if (m/$_\.$ext/){
				# Magic video has been found.
				$magicvideo = $_;
				if (`ps -a u -u hallmon | grep $magicvideo -c`){
					# Magic video is running.
					if ((stat("$showdir/$magicvideo"))[9] != (stat("$convertdir/$magicvideo"))[9]) {
						# Magic video m time differs.
						# Stop the running process
						`killall mplayer`;
						sleep 15;
						# Delete the old files
						unlink "$convertdir/$magicvideo";
						# Copy the new one into place.
						copy( "$showdir/$magicvideo", "$convertdir/$magicvideo");
						# Keep the mtime of the old and new files in sync
						utime(time, ((stat("$showdir/$magicvideo"))[9]), "$convertdir/$magicvideo");
						# restart the new video
						exec("$mplaybin ");
						#leave
						exit 0;
					}
					else {
						# Magic is up to date.
						exit 0;
					}
				}
			}
		}


	}

		# Magic video has been found
}

# Check in the $showdir for a magic video file
# if it's not playing already, Disable the screensaver and play it.
# Stop the job and and restart it if the file mtime changes.
# Exit the script


# Check for and process non magic files as per usual.
# enable the screen saver.

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
close $log;

#update the cache
eval {require "updatecache.pl"};

sub rmdircontent {
	# empty the contents of a directory
	my ($dir) = @_;
	opendir my $todelete, "$dir";
	my @del = grep { !/^\./ && -f "$dir/$_"} readdir($todelete); 
	foreach (@del){
		unlink "$dir/$_";
	}
	close($todelete);
	my $mytime = &gettime;
	return "[D] $mytime $dir\n";
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
		utime(time, $docmtime, $slidesdir);
		my $mytime = &gettime;
		$logmsg = "[U] $mytime \"$file\" As: $slidesdir\n";
	}
	elsif ( (! -e $slidesdir) && ( ! -d "$showdir/$file") && ( -e "$showdir/$file")) {
		# convert slides and set the mtime of the directory
		mkdir($slidesdir);
		system $cmd;
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
