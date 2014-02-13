#!/usr/bin/perl
use warnings;
use strict;

use options;

open my $cache, '>', $xscreencache
        or die("Cannont open cache file($xscreencache): $!");
print $cache "$convertdir\n";
&listfiles( "$convertdir", "", $cache );
close $cache;

sub listfiles {

        #Output a file list in the format that xscreensaver expects it
        my ( $dir, $disp, $FH ) = @_;
        opendir my $show, "$dir";
        my @dircontent = grep { !/^\./ } readdir($show);
        closedir($show);
        foreach (@dircontent) {
                if ( -d "$dir/$_" ) {
                        &listfiles( "$dir/$_", "$dir/$_", $FH );
                }
                elsif ( lc($_) =~ /\.png$/ ) {
                        print $FH "$disp/$_\n";
                }
                elsif ( lc($_) =~ /\.gif/ ) {
                        print $FH "$disp/$_\n";
                }
                elsif ( lc($_) =~ m/\.jpg/ ) {
                        print $FH "$disp/$_\n";
                }
        }
}
