Auto Slidshow Readme

This script will setup display of an open office impress slideshow, a movie 
file, or a mixed document slideshow.

Installation
------------

Extract the archive to anywhere. This will bejust the temporary install folder,
and can be deleted once the install process is complete.

tar -xzf slideshow-<release>.tar.gz

Change Directories to the slideshow folder

cd slideshow/

Edit the config file (options.pm), and set at least the station dns name to 
display on.  Other options should be fine as defaults, but can be changed if
necessary.  Change the install ready value to 1 to indicate that the config
file is ready to go.

nano options.pm

Run the install command with root privileges (sudo) on the server.

./install.pl --install

Reboot the display machine.

The display machine will start displaying the content of the $showdir 
(Default: /home/public/TV/) when it boots up.

A short readme file is written to the $showdir with a brief set of usage 
instructions.

Removal
-------------

On the server, change directories to the $showuser  home folder, (default: 
/home/h/hallmon) and a with root privileges (sudo) run the command

./install --uninstall

Reboot the display machine. It will boot up to the normal login screen.
