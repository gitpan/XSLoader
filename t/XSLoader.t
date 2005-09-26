#!/usr/bin/perl -w

BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = '../lib';
    }
}

use strict;
use Config;
use Test;
my %modules;
BEGIN {
    %modules = (
      # ModuleName  => q|code to check that it was loaded|, 
       'Cwd'        => q| ::ok( ref Cwd->can('fastcwd'),'CODE' ) |,         # 5.7 ?
       'File::Glob' => q| ::ok( ref File::Glob->can('doglob'),'CODE' ) |,   # 5.6
       'SDBM_File'  => q| ::ok( ref SDBM_File->can('TIEHASH'), 'CODE' ) |,  # 5.0
       'Socket'     => q| ::ok( ref Socket->can('inet_aton'),'CODE' ) |,    # 5.0
       'Time::HiRes'=> q| ::ok( ref Time::HiRes->can('usleep'),'CODE' ) |,  # 5.7.3
    );
    plan tests => keys(%modules) + 3
}

BEGIN {
    print "# - use XSLoader:\n";
    eval 'use XSLoader';
    if($@) {
        ok($@, '');
        exit 1;
    }
    ok(1);
}

print "# - XSLoader->can('load'):\n";
ok( ref XSLoader->can('load') );

# Check error messages
print "# - calling XSLoader::load() with no argument:\n";
eval { XSLoader::load(); };
ok( $@ =~ /^XSLoader::load\('Your::Module', \$Your::Module::VERSION\)/ );

# Now try to load well known XS modules
my $extensions = $Config{'extensions'};
$extensions =~ s|/|::|g;

for my $module (sort keys %modules) {
    if($extensions !~ /\b$module\b/) {
        skip("$module not available", 1);
        next
    }
    print "# - trying to load $module\:\n";
    my $chkcode = qq| package $module; XSLoader::load('$module'); | . $modules{$module};
    eval $chkcode;
    ok(0) if $@;
}

