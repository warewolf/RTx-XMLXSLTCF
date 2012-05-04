package RTx::XMLXSLTCF;
our $VERSION ="0.0.1";

1;

=pod

=head1 NAME

RTx::XMLXSLTCF - An XML->XSL transform custom field, and Arcsight event data extraction from XML.

=head1 INTENDED USE AND RECOMMENDED DOSAGE

This extension should help in automated reception, processing, and presentation of Arcsight SEIM Event data within Request Tracker.  This extension includes a custom field for ticket transactions to display the XML data, one new Scrip Condition, and two new Scrip Actions.  It's designed to insert new tickets into the RTIR 'Incident Reports' queue.

In case of XML or XPath overdose, contact your local poison center.

=head1 REQUIRED CUSTOMIZATION

=head2 SHELL SCRIPTS

This extension comes with a pair of scripts in the sbin folder:

=over 8

=item rt-pull-arcsight-exports.sh

This script is used to retrieve XML event data from the Arcsight SEIM.  You will need to have access via SSH and RSync to the SEIM's arcsight account.  Check out the comments at the beginning of the script on methods of how to do this in a secure manner.  The RSync command used within the script will try to remove the XML files from the Arcsight SEIM after they have been copied, to prevent the same file being downloaded and imported twice.

You will need to change the SSH_KEY, ARCSIGHT, and XML_PATH variables to suite your local environment.

=item rt-import-arcsight-xml.pl

=back

=head2 XSL STYLESHEET

This extension comes with an example XSL style sheet for presentation of the Arcsight XML event data within ticket history.  It's etc/arcsight_event.xsl.

You're going to need to copy and paste the contents of that XSL stylesheet into the XSL value for the ArcsightXML custom field in the Custom Field admin interface in Request Tracker, because I havn't quite figured out how to do it automatically from etc/initialdata.

=head1 SCRIPS

The meat of this extension are two Scrips that tie everything together.  They should be automatically created for you:

=over 8

=item 010 Import Arcsight Event Data on new Arcsight event

=item 020 Extract Arcsight Event Data on new Arcsight event

These Scrips try to execute early, since Request Tracker executes scrips in asciibetical order.

=back

=head2 SCRIP CONDITIONS

=over 8

=item RT::Condition::ArcsightImport

RT::Condition::ArcsightImport detects a new Arcsight event based on the presense of an XML attachment with a specific MIME content type.  These XML attachments are exported from an Arcsight SEIM with the "Export to External Tracking System" capability.

=back

=head2 SCRIP ACTIONS

=over 8

=item RT::Action::ArcsightImport

RT::Action::ArcsightImport takes the Arcsight XML event data, and adds it to the ArcsightXML custom field.  This is then used for presentation of the event data in ticket history.  It's also used by RT::Action::ArcsightExtract for extracting individual elements of the XML data, and inserting those into fields in a ticket.

=item RT::Action::ArcsightExtract

RT::Action::ArcsightExtract uses XML XPath select expressions to locate an XML element, and do something with it.  Out of the box it takes a <SecurityEvent> element name attribute, and the <fileName> child element text vaule, and uses those values to automatically modify the ticket subject.

To add new functionality, you will need to adjust the $mapping hash reference in ArcsightExtract.pm.  It's a field -> subref dispatch table.  The subroutine reference is passed two values - an XML object, and the Scrip $self object.

The XML object is an XML node element of the first <SecurityEvent> element that has a <type> value of Correlated.

=back

=head1 BUGS

=over 8

=item New Ticket notifications go out prior to actions performed by RT::Action::ArcsightExtract

The impact of this is that the rt-import-arcsight-xml.pl had to be customized to emulate one of the features of RT::Action::ArcsightExtract, namely the ticket Subject line processing.

=back

=head1 AUTHOR

Richard Harman C<< <richard+RTx-XMLXSLTCF@richardharman.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011, Richard Harman, All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the terms of version 2 of the GNU General Public License.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

