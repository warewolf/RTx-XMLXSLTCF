use inc::Module::Install;
RTx('RTx-XMLXSLTCF');
license('GPL Version 2');
author('Richard G Harman Jr <richard+RTx-XMLXSLTCF@richardharman.com>');
version_from('lib/RTx/XMLXSLTCF.pm');

{ # check RT version
    my @v = split /\./, "$RT::VERSION";
    unless ($v[0]>=3 && $v[1]>=8 && ($v[2]>=1 || $v[2]eq'HEAD')) {
        die "XML-XSLT-CF 1.0 and newer needs RT 3.8.1 at least, you have $RT::VERSION";
    }
}

# XXX: This should be reported by M::I::RTx
my ($lib_path) = $INC{'RT.pm'} =~ /^(.*)[\\\/]/;
my $local_lib_path = "$RT::LocalPath/lib";
unshift @INC, $local_lib_path, $lib_path;

requires('XML::LibXML');
requires('XML::LibXSLT');
requires('HTML::TreeBuilder');
requires('HTML::FormatText');
requires('URI::Escape');
requires('MIME::Entity');

auto_install();

#substitute( {
#        RT_LIB_PATH => join( ' ', $local_lib_path, $lib_path ),
#    },
#    't/rtir-test.pl',
#    'etc/upgrade/upgrade.pl',
#    'etc/add_constituency',
#);

#tests("t/*.t t/*/*.t");

WriteAll();
