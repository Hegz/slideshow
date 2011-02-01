#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  mkdoc.pl
#
#        USAGE:  ./mkdoc.pl  
#
#  DESCRIPTION:  Write out a quick readme docuemnt to the $showdir explaing how
#                the system works, and what the magic document names are.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Adam Fairbrother (AF), afairbrother@sd73.bc.ca
#      COMPANY:  School District No. 73
#      VERSION:  1.0
#      CREATED:  11-01-31 03:34:37 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use options;

open my $template, '<', 'doc/usage_Template.txt';
open my $readme, '>', "$showdir/README.txt";

print "$machine";

# Fill in the template file
while (<$template>){
	s/MAGICODP/$magicodp/g;
	s/MAGICVIDEO/$magicvideo/g;
	s/VIDEOEXTENTIONS/@videoextentions/g;
	print $readme $_;
}
close $template;
close $readme;

# Update the readme time to match the option file time.
utime(time, ((stat('options.pm'))[9]), "$convertdir/README.txt");
