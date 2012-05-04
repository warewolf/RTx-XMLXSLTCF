#!/usr/bin/perl
# vim: foldmethod=marker

use strict;
use warnings;
use URI::Escape;
use MIME::Entity;
use XML::LibXML;
use XML::LibXSLT;
use HTML::TreeBuilder;
use HTML::FormatText;


#### EMAIL PARAMETERS # 
# - change these to suite your environment
my $email_from   = 'arcsight@esm.arcsight.example.com';
my $email_to     = 'arcsight@rt.example.com';
my $ticket_queue = 'Incident Reports';
my $rt_url       = 'http://localhost/';
#### EMAIL PARAMETERS # 

#### XML and XSL Stylesheet # 
# Where to look for Arcsight XML Event data,
# and which XSL stylesheet to run the XML event data through for the ticket message body.
my $stylesheet_file = "/opt/rt3/var/arcsight/stylesheet.xsl";
my $exports_dir     = "/opt/rt3/var/arcsight/exports";
my %xslt_params	    = ( arcsightweb => "'https://esm.arcsight.example.com:9443'", );
#### XML Event Data location, and stylesheet for e-mail message body # 

sub xslt_uri_escape { # 
    my $uri = shift;
    return uri_escape($uri);
} # 

XML::LibXSLT->register_function( 'urn:uri', 'escape-uri', \&xslt_uri_escape );

my $parser = XML::LibXML->new( # 
    {
        no_network      => 1,
        load_ext_dtd    => 0,
        no_blanks       => 1,
        expand_entities => 0,
        expand_xinclude => 0,
        ext_ent_handler => sub {

            # my ($sys_id, $pub_id) = @_;
            # warn "Received external entity: $sys_id:$pub_id";
            "";
        },
    }
); # 

my $xslt = XML::LibXSLT->new();

# read in XSL stylesheet
open( XSL, "<", $stylesheet_file )
  or die "Couldn't open $stylesheet_file for reading! ($!)";
my $stylesheet_string;
{ local $/ = undef; $stylesheet_string = <XSL> }
close XSL;

# parse stylesheet XML
my $style_doc_xml = $parser->load_xml( string => $stylesheet_string );

# convert into XSLT translation object
my $stylesheet = $xslt->parse_stylesheet($style_doc_xml);

opendir( ARCSIGHT_XML, $exports_dir )
  or die "Couldn't open exports directory $exports_dir for reading ($!)";

my @xml_files =
  grep { -r $_ && -f && $_ =~ m/ExternalEventTrackingData/ && $_ !~ m/lock$/ }
  map { $exports_dir . "/$_" } readdir(ARCSIGHT_XML);

# iterate over XML files
foreach my $xmlfile (@xml_files) { # 

  # skip over locked files.
  next if ( -f "$xmlfile.lock" );

  # lock our file.
  open( LOCK, ">", "$xmlfile.lock" )
    or die "Couldn't open $xmlfile.lock for writing! ($!)";
  print LOCK "locked by $$\n";
  close LOCK;

  open( XML, "<", $xmlfile )
    or die "Couldn't open $xmlfile for reading! ($!)";
  my $xml_string;
  { local $/ = undef; $xml_string = <XML> };
  my $xml_doc = $parser->load_xml( string => $xml_string );

  # pull out the case IDs from the XML document
  my (@case_ids) = map { $_->to_literal() } $xml_doc->findnodes('/archive/ArchiveCreationParameters/include/list/ref/@id');

  # iterate over the case IDs
  foreach my $case_id (@case_ids) { # 

    # create a new XML document with only one case
    my $single_case_doc = only_case($xml_doc,$case_id);

    # grab the case node
    my ($case) = $single_case_doc->findnodes('/archive/Case');

    # pull out some useful text values
    my ($case_name) = $case->findvalue('./@name');
    my ($display_id) = $case->findvalue('./displayId');


    # transform the single case XML document with XSLT to make it pretty for an HTML message body
    # ... this is so that it looks mildly useful when RT sends this out via e-mail
    my $results_html = $stylesheet->transform($single_case_doc, %xslt_params);

    # convert the XSLT results into text (HTML)
    my $html_data = $stylesheet->output_as_bytes($results_html);

    my $formatter = HTML::FormatText->new();
    my $parsed_tree  = HTML::TreeBuilder->new->parse( $html_data );
    my $text_data = $formatter->format( $parsed_tree );


    # build a toplevel MIME entity
    my $top = MIME::Entity->build(#{{{
      From    => $email_from,
      To      => $email_to,
      Subject => $case_name,
      Type => 'multipart/alternative',
    );#}}}

    # build the first part (multipart/alternative) - it will be the container for the text/plain and HTML parts.
    $top->attach( Type => 'text/plain', Encoding=> 'quoted-printable', Data => $text_data );
    $top->attach( Type => 'text/html', Encoding=> 'quoted-printable', Data => $html_data );

    #  attach the alternative to the toplevel message (first outer part)
    $top->attach(#{{{
      Type => 'application/arcsight-external-event-tracking-data',
      Disposition => 'attachment',
      Encoding=> 'base64',
      Description => "ArcSight Event Data",
      Filename => "$display_id.xml",
      Data => $single_case_doc->toString(),
    );#}}}

    if (1) { # 
	open( MAILGATE, "|-", qw(/opt/rt3/bin/rt-mailgate --queue ),
	    $ticket_queue, qw( --action correspond --url), $rt_url )
	  or die "Couldn't open pipe to rt-mailgate ($!)";
	print MAILGATE $top->stringify;
	close MAILGATE;

	unlink($xmlfile);
	unlink( $xmlfile . ".lock" );
    } # 

  } # 

} # 

# restrict an XML document down to a single specific case
sub only_case { # 
  my ($source,$case_keep_id) = @_;

  # create a new document for us to stick our clone into
  my $new_doc = XML::LibXML::Document->new();

  # clone (deeply) the root document element
  my $clone = $source->documentElement()->cloneNode(1);

  # add the clone to the new document
  $new_doc->setDocumentElement($clone);

  # ok, now that we have a cloned document, we can start ripping out bits.

  # iterate over cases in this document, skipping the one we want.
  # run remove_case to remove all signs of that case in the document.
  my (@case_ids) = map { $_->to_literal() } $new_doc->findnodes('/archive/Case/@id');

  foreach my $case_id (@case_ids) {
    next if ($case_id eq $case_keep_id);
    remove_case($new_doc,$case_id);
  }

  return $new_doc;
} # 

# remove this case from the xml document
sub remove_case { # 
  my ($doc,$case_id) = @_;

  # find the case element in the XML document, by specific case ID
  my ($case_element) = $doc->findnodes('/archive/Case[@id="'.$case_id.'"]');

  # find this case's event IDs
  my (@case_event_ids) =  map { $_->to_literal() } $case_element->findnodes('./caseEvents/list/ref/@id');
  #print STDERR "Case event ids: ",join(", ",@case_event_ids),"\n";

  # find this case's note IDs
  my (@case_note_ids) =  map { $_->to_literal() } $case_element->findnodes('./hasNote/list/ref/@id');
  #print STDERR "Case note ids: ",join(", ",@case_note_ids),"\n";

  # find all the elements we want to lift out of this document, by specific element ID attribute
  my @to_remove_xpaths;

  push @to_remove_xpaths, map { '/archive/SecurityEvent[@id="'.$_.'"]' } @case_event_ids;
  push @to_remove_xpaths, map { '/archive/Note[@id="'.$_.'"]' } @case_note_ids;
  push @to_remove_xpaths, map { '/archive/Case[@id="'.$_.'"]' } $case_id;
  push @to_remove_xpaths, map { '/archive/ArchiveCreationParameters/include/list/ref[@id="'.$_.'"]' } $case_id;

  # unlink the nodes we don't want (they're still in RAM, but just not bound to this XML document any more)
  map { $_->unbindNode() } $doc->findnodes(join("|",@to_remove_xpaths));

} # 
