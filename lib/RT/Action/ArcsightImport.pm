package RT::Action::ArcsightImport;
# vim: foldmethod=marker filetype=perl

use strict;
use warnings;
use base qw(RT::Action);

sub Prepare {
    my ($self) = shift;
    my ($xml);

    # Go no further if this isn't a brand spanking new ticket
    return undef if ( $self->TicketObj->Status ne "new" );

    # Grab attachment(s) for this transaction, so we can hunt for XML data.
    my $attachments = $self->TransactionObj->Attachments();

    while ( my $attachment = $attachments->Next() ) {
        next unless ( $attachment->ContentType() eq "application/arcsight-external-event-tracking-data" );
        # set $xml to our XML (text) document.
        $xml = $attachment->Content() || $attachment->LargeContent();
        last;
    }

    # stash in $self a copy of the text XML document for inserting later
    $self->{_xml_txt} = $xml;

    if ($xml) {
      return 1;
    } else {
      return undef; 
    }
}

sub Commit {
    my $self = shift;

    my $ticket = $self->TicketObj;

    my $cf_obj = RT::CustomField->new($RT::SystemUser);
    $cf_obj->LoadByName( Name => "ArcsightXML" );

    my @return = $self->TransactionObj->AddCustomFieldValue(
        Field             => $cf_obj,
        Value             => $self->{_xml_txt},
        RecordTransaction => 1,
    );
    return @return;
}

1;
