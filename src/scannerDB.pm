#
# scannerDB
# This script is part of the YaST2 Scanner installation module
#
# This module contains the scanner database - here is the decision which
# scanner does the work for which scanner.
# 
# Copyright SuSE Gmbh - 2001
# 
# Author: Klaas Freitag <freitag@suse.de>
#         Gabi Strattner <gs@suse.de>
#
# $Id$
#
package scannerDB;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);
use Exporter;
use File::Copy;
use ycp;
use English;

@ISA            = qw(Exporter);
@EXPORT         = qw( getModel 
		      getVendorList
		      findInHash
		      trim
		      readNetconf
		      writeNetConf
		      readDllconf
		      writeDllconf
		      writeIndividualConf
		      acquireTestImage 
		      performScanimage 
		      getNetInfo 
		      revertAll
		      enableNetScan 
		      disableNetScan );

use vars qw ( %knownIFaces %confChanges %driver %scanner_driver $prefix @devicesToReset @all_drivers);

#
# confChanges: 
# changse to the config files that come with the original SANE package are described here. 
# Changes mean that YaST reads the original config file and performs changes on it if 
# there are changes for the vendor dependend file described here.
# There are three kinds of changes defined yet: replace, comment and append
#   replace: Replaces the string action_what with the action_to string.
#   comment: comment the line (UNTESTED)
#   append:  append the line to the config file (UNTESTED)
#
#
$confChanges{abaton} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{agfafocus} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];

$confChanges{apple} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{artec} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
# no changes for artec_eplus48u
$confChanges{artec} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{bh} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{canon} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
# no changes for canon630u
$confChanges{coolscan} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
# no changes for coolscan2
# no changes for the dc2*, dmc
# no changes for epson
# no changes for fujitsu
# no changes for gphoto2
# no changes for gt68xx
$confChanges{hp} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
# no changes for hp5400
$confChanges{ibm} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{leo} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
# no changes for ma1509
$confChanges{matsushita} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{microtek} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
# no changes for microtek2
$confChanges{mustek} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
# no changes for mustek_pp
# no changes for mustek_pp_ccd
# no changes for mustek_usb
$confChanges{nec} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{pie} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
# no changes for plustek
# no changes for qcam
$confChanges{ricoh} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{s9036} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{sceptre} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{sharp} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
# no changes for snapscan
# no changes for sp15c
# no changes for st400
$confChanges{tamarack} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{teco1} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{teco2} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{teco3} = [{ action => "replace", action_what => "/dev/scanner", action_to => "YAST2_DEVICE" }];
$confChanges{umax} = [{ action => "replace", action_what => "/dev/sg0", action_to => "YAST2_DEVICE" }];
# no changes for umax1220u
# no changes for umax_pp
# no changes for v4l

# End of confChanges.

sub storeBackend($)
{
    my ($backend) = @_;
    # printf ( "## Backend: %s\n", $backend->{name} );
    push @all_drivers, lc $backend->{name};
}

sub storeEntry( $$$$ )
{
    my ($interface, $mfg, $model, $backend) = @_;
    my $manu = lc $mfg;
    $mfg = ucfirst $manu;

    $knownIFaces{$interface} = 1 unless exists $knownIFaces{$interface};

    $driver{$interface}{$mfg}{$model}=$backend;

    # Print Output for debug.
    # printf "\$driver{\"%s\"}", $interface;
    # printf "{\"%s\"}",         $mfg;
    # printf "{\"%s\"} =",       $model;
    # print '"' .                $backend;
    # print '"' . "\n";
}


sub storeDevice($$)
{
    my ($backend, $device) = @_;

    my $stat = $device->{status};
    $stat = $backend->{status} unless( defined $stat );

    if( $stat ne "unsupported" )
    {
	my $interface = $device->{interface};

	#
	# At the moment we are only interested in SCSI, USB
	# and PTAL devices. No need to care for the others.
	#

	# Make sure only scanner will come.
	if( $device->{devicetype} eq "scanner" ) 
	{
	    if ( $interface =~ /USB/ )
	    {
		storeEntry( "USB", $device->{mfg},
			    $device->{model},
			    $backend->{name} );
	    }

	    if ( $interface =~ /SCSI/ )
	    {
		storeEntry( "SCSI", $device->{mfg},
			    $device->{model},
			    $backend->{name} );
	    }
	    # HP all-in-one devices: 
	    if ( $interface =~ /Parport\(ECP\) USB JetDirect/ )
	    {
		storeEntry( "PTAL", $device->{mfg},
			    $device->{model},
			    $backend->{name} );	
	    }

	    # Count the models for the driver.
	    my $cnt = $scanner_driver{lc $backend->{name}} || 0;
	    $cnt++;
	    $scanner_driver{lc $backend->{name}} = $cnt; 

	    # storeEntry( $interface, 
	    # 	    $device->{mfg},
	    # 	    $device->{model},
	    # 	    $backend->{name} );
	}
    }
    else
    {
	y2debug( "Reading sane-descs: Rejecting status: <$stat>" );
    }

    # printf( "        %s| %s on %s: %s\n", $device->{mfg},
    # $device->{model},
    # $device->{interface}, $stat );

}


#
# This sub parses the conf files of the SANE package to get rid of the
# static list this file used before. See description.txt in the SANE
# document dir for further information of the format of the conf files
#
sub populateDriverInfo( $ )
{
    my ($baseDir) = @_;

    y2error( "no such dir: $baseDir" ) unless ( -d $baseDir );

    my @conf = glob( $baseDir . "*.desc" );

    foreach my $confFile( @conf )
    {
	my $currBackend;
	my $devType;

	open FILE, "$confFile" || y2error( "Failed to open $confFile" );
	my @tfile = <FILE>;
	close FILE;
	chomp @tfile;

	my @file;
	foreach my $line( @tfile )
	{

	    $line =~ s/;.*$//;  # Comments
	    next if ( $line =~ /^\s*$/ );

	    push @file, $line;
	}
	my %backend;
	my %device;

	my $line;
	foreach $line ( @file )
	{
	    my ($tag, $val);

	    if( $line =~ /:(.+?)\s+"(.+)"/ )
	    {
		$tag = $1;
		$val = $2;
	    }
	    elsif( $line =~ /:(.+?)\s+:?(\S+)/ )
	    {
		$tag = $1;
		$val = $2;
	    }
	    else
	    {
		print "Spurious: <$line>\n";
		next;
	    }

	    #
	    # Backend related data
	    #
	    if( $tag eq "backend" )
	    {
		# First line of a file. Delete the backend info
		storeDevice( \%backend, \%device ) if( exists $device{model} );
		$backend{name} = $val;
		storeBackend( \%backend );

		%device  = ();
	    }
	    elsif( $tag eq "status" )
	    {
		if( exists $device{model} )
		{
		    $device{status} = $val;
		}
		else
		{
		    $backend{status} = $val;
		}
	    }
	    elsif( $tag eq "version" || $tag eq "new" || $tag eq "manpage" )
	    {
		$backend{$tag} = $val;
	    }

	    #
	    # Device related data
	    #
	    elsif( $tag eq "devicetype" )
	    {
		%device = ();
		$device{devicetype} = $val;
	    }
	    elsif( $tag eq "mfg" )
	    {
		storeDevice( \%backend, \%device ) if( exists $device{model});
                delete  $device{model};
                delete  $device{interface};
                delete  $device{status};
                delete  $device{desc};

		$device{mfg} = $val;
	    }

	    #
	    # Model related stuff
	    #
	    elsif( $tag eq "model" )
	    {
		# Model is the start tag. Store the backend and 
		# clear the model desc.
		storeDevice( \%backend, \%device ) if( exists $device{model});
		# %device = ();    # Clear the model datastructure
		delete  $device{model};
		delete  $device{interface};
		delete  $device{status};
		delete  $device{desc};

		$device{model} = $val;
	    }
	    elsif( $tag eq "interface" ||
		   $tag eq "desc"      ||
		   $tag eq "comment"   ||
		   $tag eq "status"     )     # Status is already handled above
	    {
		$device{ $tag } = $val;
	    }
	}
        storeDevice( \%backend, \%device ) if( exists $device{model});
    }

    my @v = values %driver;
    my $cntV = scalar @v;
    y2debug( "Reading scanner database: Know $cntV different scanner models" );
    

    my @drivers = sort keys %scanner_driver;
    foreach my $driver ( @drivers )
    {
	y2debug( "Know this backends: $driver supporting " . $scanner_driver{$driver} . " models" );
	# print STDERR "driver $driver supports " . $scanner_driver{$driver} . " models\n";
	# print STDERR "WRN: No config for driver <$driver>\n" unless( exists $config{$driver} );
    }
}




################################################################################
# case INsensitive search function in a hash
#
#

=head1 NAME

findInHash - case insensitive hash search

=head1 SYNOPSIS

    my $value = findInHash( 'goofy', \%bighash );

=head1 DESCRIPTION

findInHash searches the keys of a given hash for the 
given searchkey parameter caseinsensitive and returns the
entry, if it finds one.

That means, that the string 'goofy' would be found even if
it is stored with the key 'GOOFY' in the hash.

=head1 PRARMETER

The first parameter is the string which is searched for the 
hash keys.

The second parameter is a reference to a hash.

=head1 RETURN VALUE

The value of the found key if it exists, an empty string else.

=cut

sub findInHash( $$ )
{
    my ( $searchkey, $hashref ) = @_;

    my @hkeys = keys %$hashref;
    my $regExpKey = quotemeta( $searchkey );

    # y2debug( "findInHash: Keys: " . join( "-", @hkeys ));

    my $entry = "";
    my ($hkey) = grep( /^$regExpKey$/i, @hkeys ); # key must fit exactly (exception: ignore case)

    if( defined $hkey )
    {
	$entry = $$hashref{ $hkey };
	# y2debug( "Found key <$searchkey> entry <$entry>" );
    }
    else
    {
	y2debug("Could not find entry for key <$searchkey>" );
    }

    return( $entry );
}

sub readConfig($)
{
    my ($confFile) = @_;
    my @reply;

    if ( -e $confFile )
    {
	if( open FILE, "$confFile" ) 
	{
	    @reply = <FILE>;
	    close FILE;
	}
	else
	{
	    y2error("Could not open conffile for reading: $!");
	}
    }
    else 
    {
	y2error("No conffile found at <$confFile>");
    }
    return @reply;
}


sub createBackup( $ )
{
    my( $file ) = @_;

    if( !defined( $file ) || $file eq "" )
    {
	y2debug( "WRN: Can not backup empty file" );
	return "";
    }

    unless( -e $file )
    {
	y2debug("File <$file> does not exists, but who cares, creating it !" ) ;
	unless( open (FILE, $file) )
	{
	    y2debug( "Could not create file <$file>" );
	    return "";
	}
	print FILE "";
	close FILE;
    }

    my $backupfile = $file . ".yast2-$PID";

    if( -e $backupfile )
    {
	y2debug( "backupfile for PID $PID already exists. Not overwriting" );
    }
    else
    {
	y2debug( "Copying to Backupfile: <$backupfile>" );
	copy( $file, $backupfile );
    }
    return( $backupfile );
}


#
# modifies /var/lib/sane/devices, which holds a list of devices read by
# rcsane. If the device is not known, its added.
#
sub modify_rc_cmdfile( $ )
{
    my ($dev) = @_;
    my @lines;

    if( open( FILE, "$prefix/var/lib/sane/devices" ) )
    {
	@lines = <FILE>;
	close FILE;
    }

    my $oriline = shift @lines;
    $oriline = "" unless( defined $oriline );
 
    y2debug( "Found in /var/lib/sane/devices: <$oriline>" );
    
    my @devs = split( /\s+/, $oriline );

    my $line = "";
    my $already_known = 0;

    foreach my $known_dev ( @devs ){
	if( -e $known_dev ) {
	    $line .= " $dev";
	    $already_known = 1 if( $known_dev =~ /^$dev$/ );
	}
	else
	{
	    y2debug("WRN: Have a nonexisting devicefile in devicelist" );
	}
    }
    $line .= " $dev" if( ! $already_known );

    # Check if directory exists and create if neccessary.
    unless( -e "$prefix/var/lib/sane" )
    {
	system( "/bin/mkdir -p $prefix/var/lib/sane" );
    }

    if( open( FILE, ">$prefix/var/lib/sane/devices" ))
    {
	print FILE "$line\n";
	close FILE;
    }
    else
    {
	y2debug("ERR: Directory <$prefix/var/lib/sane/devices> does not exist and could not be created !" );
    }
}



=head1 NAME

getModel - find a hash of scanner - drivers

=head1 SYNOPSIS

    my %modelsnDrivers = getModel( 'SCSI', 'Umax' );

=head1 DESCRIPTION

getModel is a specialised utility function that returns a hash
containing scanner driver data related to scanner models.

The hash is taken from the scanner driver 'database'.

The function is case insensitive, you do not have to care
about.

=head1 PRARMETER

The first parameter is the name of the bus, e.g. "SCSI" or "USB"
The second parameter is the vendor string.

=head1 RETURN VALUE

a hash that contains the name of the driver to use for all models
at the given bus of the given vendor.

=cut


sub getModel( $$ )
{
    my ( $bus, $vendor ) = @_;

    my %foundscanner = ();

    y2debug("getModel called with <$bus> <$vendor>" );

    if( !defined $vendor || $vendor =~ /^\s*$/ ) {
	y2debug( "getModel: Vendor is empty - can not find model!" );
    }
    else
    {
	if( $bus !~ /net/i )
	{
	    my $bus_scanners = findInHash( $bus, \%driver ); # { uc $bus };
	    if( ref( $bus_scanners ) eq "HASH" )
	    {
		my $mfg_scanner_ref = findInHash( $vendor, $bus_scanners ); # ->{ uc $vendor};

		if( ref($mfg_scanner_ref)  eq "HASH" ) # defined $mfg_scanner_ref )
		{
		    %foundscanner = %$mfg_scanner_ref;
		}
		else
		{
		    if( $vendor =~ /generic/i )
		    {
			# In case of generic all entries are required with
                        # all the same items as driver entry ;)
			foreach my $d ( sort @all_drivers )
			{
			    $foundscanner{ $d } = $d;
			}
		    }
		    else
		    {
			y2debug( "Can not find scanner for Vendor " . uc $vendor );
		    }
		}
	    }
	    else
	    {
		y2debug( "Can not find scanner for bus " . uc $bus );
	    }
	}
	else
	{
	    y2debug(" No models available for Network scanner !" );
	}
    }
    return %foundscanner;
}


=head1 NAME

getVendorList - return a list of scanner vendors

=head1 SYNOPSIS

    my @vendors = getVendorList( 'SCSI' );

=head1 DESCRIPTION

returns a list of the vendors for which sane provides a driver for
the specific bus.

=head1 PRARMETER

the string naming the bus, eg. SCSI or USB

=head1 RETURN VALUE

a list of strings

=cut

sub getVendorList( $ )
{
    my ($bus) = @_;
    
    y2debug( "Searching vendors providing for <$bus>" );
    
    my $bus_scanners = findInHash( $bus, \%driver ); #$driver{ uc $bus };

    my @vendorlist = ();

    if( ref( $bus_scanners ) eq "HASH" )
    {
	@vendorlist = keys %$bus_scanners;
	unshift @vendorlist, 'Generic';
    }
    else
    {
	y2debug( "Could not find scanners for bus <$bus>" );
    }

    return @vendorlist;

}


=head1 NAME

trim - cut off whitespaces from a string

=head1 SYNOPSIS

    my $trimmedstring = trim( '    untrimmed    ' );

=head1 DESCRIPTION

trim takes a string and returns it after having cut off all whitespace
in front and at the end.

=head1 PRARMETER

the string to trim

=head1 RETURN VALUE

the trimmed string

=cut

sub trim( $ )
{
    my ($str) = @_;
    $str =~ s/\"//g;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    y2debug("Trim: Trimmed string to <$str>");
    return( $str );
}


#
=head1 NAME

writeNetConf - writes SANEs net.conf file

=head1 SYNOPSIS

    if( writeNetConf( \@hosts ) ) ...

=head1 DESCRIPTION

takes a reference of a list of host names which are written
to /etc/sane.d/net.cof. Mind that /etc/sane.d/net.conf is 
completely rewritten, thus L<readNetConf> needs to be called
first to get the existing net stations.

=head1 PRARMETER

a reference to a list of stations.

=head1 RETURN VALUE

a bool inicating success.

=head1 SEE ALSO

readNetConf

=cut

sub writeNetConf( $ )
{
    my ($net_stations) = @_;
    my $res = 0;

    my $fi = "$prefix/etc/sane.d/net.conf";
    createBackup( $fi );
    
    y2debug( "Try to open <$fi>" );

    if( open( F, "> $fi" ) )
    {
	my $t = localtime;
	print F "#
#
# SANE net config
# written by YaST2, $t
#
";
	my $nstats = join( "\n", @$net_stations );
	y2debug("Writing net stations: $nstats" );
	print F $nstats;
	$res = close F;
    }
    else
    {
	y2debug( "Open of /etc/sane.d/net.conf failed: $!" );
	$res = 0;
    }
    
    return $res;
    
}

=head1 NAME

readNetConf - read SANEs net.conf file

=head1 SYNOPSIS

    my @netConf = readNetConf();

=head1 DESCRIPTION

reads SANEs net configuration file /etc/sane.d/net.conf and
returns a list of all net stations configured there.

=head1 RETURN VALUE

a list of all stations.

=head1 SEE ALSO

writeNetConf

=cut

sub readNetConf
{
    my @res;

    if( open( F, "$prefix/etc/sane.d/net.conf" ))
    {
	foreach my $l ( <F> )
	{
	    next if( $l =~ /\s*\#/ );
	    next if( $l =~ /^\s*$/ );

	    push @res, trim($l);
	}
	close F;
    }
    else
    {
	y2debug( "Could not open file $prefix/etc/sane.d/net.conf: $!" );
    }
    return( @res );
}


=head1 NAME

writeDllconf - 

=head1 SYNOPSIS

    my @conf = ( "umax", "agfa" );
    writeDllconf( \@conf );

=head1 DESCRIPTION

writes a complete configuration file for SANEs dynamic backend
loading. The resulting file contains all backends as in the original
one, but the ones given in the parameter list are uncommented.

=head1 RETURN VALUE

a bool indicating success.

=head1 SEE ALSO

writeNetConf

=cut

sub writeDllconf( $ )
{
    my ($be_ref) = @_;
    my $res = 0;

    my $fi = "$prefix/etc/sane.d/dll.conf";
    my @dll = readConfig( $fi );

    createBackup( $fi );

    y2debug( "Try to open <$fi>" );
 
    if( open( F, "> $fi" ) )
    {
	my $t = localtime;
	print F "#
# SANE Dynamic library loader config
# written by YaST2, $t
#
";

	foreach my $dllLine ( @dll ) 
	{
	    next if( $dllLine =~ /SANE Dynamic library loader config/ );
	    next if( $dllLine =~ /written by YaST/ );
	    next if( $dllLine =~ /^\s*#\s*$/ );
	    next if( $dllLine =~ /^\s*$/ );

	    next if( $dllLine =~ /EOF/ );

	    my $driver = $dllLine;

	    $driver =~ s/[\s#]//g; # wipe out all whitespaces and #
	    # print STDERR "Driver: $driver\n";
	    if( grep( /$driver/i, @$be_ref  ) )
	    {
		print F "$driver\n";
	    }
	    else
	    {
		# do not touch the line
		# print F $dllLine;
		# disable the line
		print F "# $driver\n";
	    }
	}

	print F "\n# EOF\n";
	$res = close F;

    }
    else
    {
	y2debug( "Open of /etc/sane.d/dll.conf failed: $!" );
	$res = 0;
    }
    
    return $res;
}




=head1 NAME

writeIndividualConf - write config for on scanner

=head1 SYNOPSIS

    writeIndividualConf( "SCSI", "umax", "/dev/sg0");

=head1 DESCRIPTION

writes a configuration file for one scanner. 

=head1 RETURN VALUE

Param. 1 is the bus (SCSI or USB), param. 2 the vendor.
Param. 3 is the device file to use.

=head1 SEE ALSO

writeNetConf, readNetConf

=cut

sub writeIndividualConf( $$$ )
{
    my ( $bus, $vendor, $device ) = @_;
    my $res = 0;

    $vendor = lc $vendor;

    unless( exists( $confChanges{ $vendor } ) )
    {
	y2debug( "WARN: Can not find a config for <$vendor>" );
	return 1;  # No problem if no config file
    }

    my $actionsRef = $confChanges{$vendor};  # reference on list of actions
    my @actions = @$actionsRef;
    my $actCnt = @actions;
    y2debug("Action for <$vendor>: $actCnt");

    if( scalar @actions > 0 )   # if there are entries
    {
	# Only do the whole stuff if there are config changes
	my $cfg_file = "$prefix/etc/sane.d/$vendor.conf";
	y2debug( "Writing $cfg_file" );

	my @cfg = readConfig($cfg_file);

	createBackup( $cfg_file );
	my @newFileContent;
	my $toAppend="";

	if( open( F, ">$cfg_file" ) )
	{
	    foreach my $line ( @cfg )
	    {
		# loop over all actions
		foreach my $actDescRef ( @actions )
		{
		    my $action  = $actDescRef->{action};
		    my $actWhat = $actDescRef->{action_what};
		    my $actTo   = $actDescRef->{action_to};


		    if ( $action eq "replace" )
		    {
			# replace action_what with action_to
			$line =~ s/$actWhat/$actTo/g; # '
			y2debug("Replaced line <$line>");
		    }
		    elsif ( $action eq "comment" )
		    {
			# comment line starting with action_what
			if( $line =~ /^\s*$actWhat/ ) 
			{
			    $line = "# " . $line;
			}
		    }
		    elsif ( $action eq "append" )
		    {
			$toAppend .= $line . "\n";
			# append field action_what to end of file
		    }
		}
		$line =~ s/YAST2_DEVICE/$device/im;
		push @newFileContent, $line;
	    }
	    if( $toAppend ne "" ) 
	    {
		push @newFileContent, $toAppend;
	    }

	    print F @newFileContent;
	    close F;
	}
	else 
	{
	    $res = 0;
	}
    }
    else
    {
	y2debug("No changes for config file $vendor required");
    }

    if( $res )
    {
	# Change the device permission to 666, remember the device.
	if( $bus =~ /scsi/i )
	{
	    if( defined( $device ) && -c $device )
	    {
		y2debug("Setting permissions of device <$device> to 666");
		push @devicesToReset, $device;
		my $mode = 0666;
		chmod $mode, $device;

		# In case it is an scsi device, add it to /var/lib/sane/devices.
		modify_rc_cmdfile( $device );
	    }
	    else
	    {
		y2debug("ERR <$device> is not a character device !" );
	    }
	}
    }
    return $res;
}
# ################################################################################

=head1 NAME

readDllconf - read the list of backends

=head1 SYNOPSIS

    my @dlls = readDllconf();

=head1 DESCRIPTION

read the list of enabled backends to read dynamically.

=head1 RETURN VALUE

a list of loadable backends 

=head1 SEE ALSO

writeNetConf, readNetConf

=cut

# ################################################################################
sub readDllconf()
{
    my $f = "$prefix/etc/sane.d/dll.conf";
    my @res = ();

    if( open( F, $f )  )
    {
	while( <F> )
	{
	    chomp;
	    next if( /^\s*\#/ );
	    next if( /^\s*$/ );
	    s/\#.*$//g;
	    my $be = trim($_);
	    y2debug("pushing <$be> to existing Backend list");
	    push @res, $be;
	}
        close F;
    }
    else
    {
	y2debug( "$f not existing" );
    }
    return @res;
    
}

# ################################################################################

=head1 NAME

acquireTestImage - scan a test image.

=head1 SYNOPSIS

    my $file = aquireTestImage( "umax:/dev/sg0", "/tmp" );

=head1 DESCRIPTION

tries to scan a test image from a scanner pointed to by the first parameter string.
Mind that the string must be compatible to pass it to scanimage directly.

=head1 PARAMETERS

The first parameter is a device specification string, the second parameter gives
a temp directory where the image can be stored.

=head1 RETURN VALUE

The full filename of the image.

=cut

# ################################################################################


sub acquireTestImage( $$ )
{
    my ($usedev, $tmpdir) = @_;

    y2debug( "Scanning test image from <$usedev>" );

    my $tmpfile = "$prefix" . "$tmpdir/y2testimage_$PID.pnm";

    my $cmd = sprintf( "/usr/bin/scanimage -d %s > %s", $usedev, $tmpfile );

    y2debug( "Scanning test image with command <$cmd>" );
 
    system( $cmd );
    return( $tmpfile );

}

#
# enable one single station to be scanned from
#
sub enableNetScan( $ )
{
    my ($host) = @_;

    my $ok = 1;

    my @already_conf = readNetConf();

    unless( grep( /$host/i, @already_conf ))
    {
	push @already_conf, $host;
	$ok = writeNetConf( \@already_conf );
    }
	    
    # Add net to dll.conf
    my @cfg_backends = readDllconf( );

    unless( grep ( /net/i, @cfg_backends ))
    {
	push @cfg_backends, "net";
	$ok = writeDllconf( \@cfg_backends );
    }
    return( $ok );
}


sub disableNetScan( $ )
{
    my ($host) = @_;

    my $ok = 1;

    my @already_conf = readNetConf();

    # Take all _but_ host from the list
    @already_conf = grep ( !/$host/i, @already_conf );

    $ok = writeNetConf( \@already_conf );

    return( $ok );
    
}


sub getNetInfo( $ )
{
    my ($host) = @_;

    y2debug( "Querying host <$host>" );

    # first, add the host to net.conf and enable net-scanning.

    my @origNetStations = readNetConf();

    y2debug("Enabling net scanner for <$host>" );
    if( enableNetScan( $host ) )
    {
	# now the net station should be enalbed.
	y2debug("Netscanning for <$host> enabled successfully");
    }
    
    unless( grep ( /$host/i, @origNetStations ))
    {
	# if not yet in the host list, add and write config.
	my @stations = @origNetStations;
	push @stations, $host;
	writeNetConf( \@stations );
    }
    
    # Now the net configuration should be fine.
    my @scanners = performScanimage( 1 );  # Net only.
    
    my @hostscanners;
    
    # Sort out which scanners are connected to the required station
    foreach my $scanref ( @scanners )
    {
	my $referto = $$scanref{host};

	y2debug( "Found scanner on host <$referto>" );

	if ( $referto =~ /^$host$/i )
	{
	    y2debug( "adding network-scanner <$referto>" );
	    push @hostscanners, $scanref;
	}
    }
    
    # copy the original files back to dll.conf and net.conf
    if( -e "$prefix/etc/sane.d/dll.conf.yast2-$PID" )
    {
	y2debug( "Reverting to original dll.conf" );
	move( "$prefix/etc/sane.d/dll.conf.yast2-$PID",
	      "$prefix/etc/sane.d/dll.conf" );
    }

    if( -e "$prefix/etc/sane.d/net.conf.yast2-$PID" )
    {
	y2debug( "Reverting to original net.conf" );
	move( "$prefix/etc/sane.d/net.conf.yast2-$PID",
	      "$prefix/etc/sane.d/net.conf" ) ;
    }

    return( @hostscanners );
}

# ################################################################################

=head1 NAME

revertAll - revert all configuration files.

=head1 SYNOPSIS

    revertAll();

=head1 DESCRIPTION

this function reverts all configuration changes. It copies the backup files
back.

=cut

# ################################################################################

sub revertAll
{
    # reverting: search for all files ending on yast2-$PID
    # and remove them to their old name 
 
    my $path = "$prefix/etc/sane.d/*.yast2-$PID";
    y2debug( "Globbing for <$path>" );

    my @files = glob($path);
    my $countfiles = @files;

    foreach my $bfile ( @files )
    {
	my $origfile = $bfile;
	$origfile =~ s/\.yast2-$PID$//;
	y2debug( "Reverting file <$bfile> to <$origfile>" );

	move ( $bfile, $origfile );
    }
    y2debug( "Reverted $countfiles configuration-files" );
    
    # look in /var/lib/sane for to restore things
    $path = "$prefix/var/lib/sane/devices.yast2-$PID";
    if( -e $path )
    {
	y2debug("Restoring devices-file in <$path>");
	move ( $path, "$prefix/var/lib/sane/devices" );
    }
    

    # Now check for changed permissions on scsi-files
    while( my $file = shift @devicesToReset )
    {
	if( -c $file )
	{
	    y2debug("Resetting device <$file> to 640" );
	    chmod 0640, $file;
	    
	}
    }
}


# ################################################################################

=head1 NAME

performScanimage - invoke scanimage from SANE for information

=head1 SYNOPSIS

    my @scanners = performScanimage();

=head1 DESCRIPTION

This is one of the most important functions. It invokes SANEs command scanimage
to get a list of the scanners known by sane. It fills a hash for every scanner
and pushes the reference to the hash to an array. 

=head1 PARAMETERS

The first optional parameter indicates if only net scanners should be returned.
If no parameter is there, all known scanners are returned.

=head1 RETURN VALUE

an array with references to hashes.

=cut

# ################################################################################

sub performScanimage( ;$ )
{
    my ($netOnly) = @_;

    y2debug( "Searching for configured scanners!" );
    my $cmd = '/usr/bin/scanimage -f $\'"%d" "%v" "%m" "%t"\n\''; # '
    y2debug( "Using command <$cmd>!" );

    my @scanners = ();

    if( open( CMD, "$cmd |" ) )
    {
	my $cnt = 0;
	while( <CMD> )
	{
 	    next if( /^\s*$/ );
	    chomp;
	    my ($name, $vendor, $model, $class ) = split( /"\s+"/ );
	    $name =~ s/\"//g;
	    $name =~ s/^\s+|\s+$//g;
	    my ($driver, $devfile);
            # bus defaults to SCSI, switched later
	    my $bus = "SCSI";
	    my $host = uc "localhost";
	    
	    if( $name =~ /(\S+):(\S+):(\S+):(\S+)/ )
	    {
		if ( $1 eq "net" )
		{
		    # A Network scanner was found with a name like 
		    # net:d213.suse.de:umax:/dev/sg0
		    $bus = "Net";
		    $host =  $2;
		    $driver =  $3;
		    $devfile =  $4;
		    y2debug( "Found new network scanner: $bus:$host:$driver:$devfile" );
	        } elsif ( $2 eq "libusb" ) { 
		    # A libusb devive found
		    # epson:libusb:001:003
		    $bus = "USB";
		    $driver = $1;
		    $devfile = $1.":".$2.":".$3.":".$4;
		} elsif ( $2 eq "mlc" ) {
		    # A PTAL device found, e.g.
		    # hpoj:mlc:usb:PSC_2200_Series
		    $bus = "PTAL";
		    $driver = $1;
		    $devfile = $2.":".$3.":".$4;
		}
	    }
	    else
	    {
                # split up a name-string like umax:/dev/scanner to driver and device
		($driver, $devfile) = split( /:/, $name );
	    }
	    
	    if( $bus ne "Net" && $devfile =~ /dev.+usb/i )
	    {
		$bus = "USB";
	    }
	    y2debug( "Found scanner $vendor $model on $devfile" );
            
            # Push anonym hashes to the array. The array contains references to
            # the hashes then.
	    if( $bus ne "Net" && defined( $netOnly ) && $netOnly )
	    {
		y2debug("Found non-net-scanner, but netOnly required -> skip" );
		next ;
	    }

	    push ( @scanners , 
	    { bus => $bus, 
		  class_id => "",
		  device => trim($model),
		  device_id => "",
		  resource =>"",
		  rev => "",
		  sub_class_id => "",
		  sub_device => trim($model),
		  sub_vendor => trim($vendor),
		  unique_key => "",
		  vendor => trim($vendor),
		  vendor_id => "",
		  dev_name => trim($devfile),
		  class => trim($class),
		  scanner_driver => trim($driver),
		  host => $host 
		  } );
	    $cnt++;
	}
	close CMD;
	y2debug( "found $cnt configured scanners !" );
    }
    else
    {
	y2debug( "ERROR: Could not open scanimage!" );
	@scanners = ();
    }
    return( @scanners );
}


#
#
# This enables debug. Just set the environment PREFIX_DIR to any
# directory which acts as prefix to /etc/sane.d
$prefix = "";
$prefix = $ENV{PREFIX_DIR} if( exists $ENV{PREFIX_DIR} );
@devicesToReset = ();

#
# Online parsing of the original sane desc files:
# ==============================================
#
# From sane 1.0.10 the sane backend description files are parsed
# on the fly by the YaST2 scanner installation module instead of
# using a static list.
# Parse the sane config files, give path that ends with a /
# where the desc files reside. They must be part of the sane
# package.
# example: /usr/share/sane/descriptions/fujitsu.desc

undef @all_drivers;
undef %driver;
populateDriverInfo( "/usr/share/sane/descriptions/" );
populateDriverInfo( "/usr/share/sane/descriptions-external/" );

# print "\nKnown Interfaces:\n";
# foreach my $k ( keys %knownIFaces )
# {
#     print "$k\n";
# }
# 
# print "\nKnown drivers:\n";
# foreach my $k ( sort @all_drivers )
# {
#     print "$k\n";
# }



1;

# EOF
