#!/usr/bin/perl

use scannerDB;

# Test script to check the writedllconf funktion.
# Klaas Freitag <freitag@suse.de>, 2004
# 

my $prefix = $ENV{PREFIX_DIR};

die ("You should better call this with PREFIX_DIR set!\n") unless exists $ENV{PREFIX_DIR};

print "Using prefix $prefix\n";

my @enabledBackends = ("umax", "hp", "foo");

print "Enabling backends: " . join (" + ", @$be_ref) . "\n";

writeDllconf( \@enabledBackends );


# Show the changed file
my $cfg_file = "$prefix/etc/sane.d/dll.conf";

if( open( F, "$cfg_file")) 
{
    my @cfg = <F>;
    close F;

    print @cfg;
}



print "\n#\nThats it.\n";

