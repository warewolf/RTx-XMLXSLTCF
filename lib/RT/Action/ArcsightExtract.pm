package RT::Action::ArcsightExtract;
# vim: foldmethod=marker filetype=perl

use strict;
use warnings;
use base qw(RT::Action);
use XML::LibXML;
use List::Util qw(first);

my $mapping = { # {{{

  auto_set_subject => sub { my ($ScriptObj,$EventXML,$ExportXML) = @_;#{{{
      my $Ticket = $ScriptObj->TicketObj;
      my ($subject) = map { $_->to_literal } $ExportXML->findnodes('//Case/@name');

      return ($Ticket->SetSubject($subject));
    },#}}}

  auto_set_location => sub { my ($ScriptObj,$EventXML,$ExportXML) = @_;#{{{
    my $Ticket = $ScriptObj->TicketObj;
    my ($location) = map { $_->to_literal } $ExportXML->findnodes('//Case/attackAgent');

    my $cf = RT::CustomField->new( $ScriptObj->TransactionObj->CurrentUser );
    $cf->LoadByNameAndQueue( Queue => $Ticket->QueueObj->Id, Name => '_RTIR_Location' );

    unless ( $cf->Id ) {
        $RT::Logger->warning("Couldn't load '_RTIR_Location' CF for queue ". $Ticket->QueueObj->Name );
        return 1;
    }

    if ($ScriptObj->TransactionObj->Type eq 'CustomField' and $ScriptObj->TransactionObj->Field == $cf->id) {
        return 1;
    }

    my ($res, $msg) = $Ticket->AddCustomFieldValue(Field => $cf->id, Value => $location) if (length($location));

  },
  # }}}

  auto_set_owner => sub { my ($ScriptObj,$EventXML,$ExportXML) = @_;#{{{
    my $Ticket = $ScriptObj->TicketObj;

    my $arcsight_owner = $ExportXML->findvalue('//Case/ownedBy/list/ref/@externalID');
    unless (length $arcsight_owner) {
      ($arcsight_owner) = ($ExportXML->findvalue('//Case/childOf/list/ref/@uri') =~ m,/All Cases/All Cases/Personal/([^']+)'s Cases/,);
    }

    # create an empty owner object as the RT System user
    my $owner = RT::User->new($RT::SystemUser);

    # try to load up the username from arcsight
    $owner->Load($arcsight_owner);
    my $owner_name = ($owner ? $owner->Name : $arcsight_owner);
 
    return $Ticket->SetOwner($owner_name);
  } #}}}

}; 

#}}}

sub Prepare {#{{{
    my ($self) = shift;
    my $transaction = $self->TransactionObj;

    # we only want to work on a ticket if it is brand new.
    return undef if ( $self->TicketObj->Status ne "new" );

    $self->{_xml_parser} = XML::LibXML->new( {#{{{
      no_network => 1,
      load_ext_dtd => 0,
      expand_entities => 0,
      expand_xinclude => 0,
      ext_ent_handler => sub {
	  # my ($sys_id, $pub_id) = @_;
	  # warn "Received external entity: $sys_id:$pub_id";
	  "";
	},
      }
    );#}}}

    my $CustomFields = $transaction->CustomFields;
    while (my $CustomField = $CustomFields->Next() ) {#{{{
      next unless ($CustomField->Name() eq "ArcsightXML");
      my $Values = $CustomField->Values();
      $self->{_xml_txt} = $Values->First();
      return (0,"Unable to get value of ArcsightXML Custom Fieid") unless ($self->{_xml_txt});
      last;
    }#}}}

    # catch errors from trying to load the XML document into the parser
    eval {#{{{
      $self->{_xml_doc} = $self->{_xml_parser}->load_xml( string => $self->{_xml_txt} );
    };#}}}

    if ($@) {#{{{
      return (0, "Unable to load XML content: $@" );
    } else {
      return (1,"Loaded ArcsightXML Custom Field");
    }#}}}
}#}}}

sub Commit {#{{{
    my $self = shift;
    my $transaction = $self->TransactionObj;

    $self->{_xml_txt} = $transaction->FirstCustomFieldValue("ArcsightXML");
    eval { $self->{_xml_doc} = $self->{_xml_parser}->load_xml( string => $self->{_xml_txt} ); };


    # We only care about the first correlated event.
    my ($event) = $self->{_xml_doc}->findnodes('//SecurityEvent[type/text()="Correlation"][1]');

    while (my ($field,$dispatch) = each %$mapping) {#{{{
      my @return = $dispatch->($self,$event,$self->{_xml_doc});
      $RT::Logger->debug("ArcsightExtract dispatch for $field returned @return");
    }#}}}

    return 1;
}#}}}

1;
