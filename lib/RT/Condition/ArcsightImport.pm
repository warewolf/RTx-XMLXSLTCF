package RT::Condition::ArcsightImport;
use base 'RT::Condition';
use strict;


sub Describe {
  return("Check if a new ticket is from ArcSight");
}

sub IsApplicable {
  my ($self) = shift;

  # Is this transaction a Create ticket transaction?
  my $txn_type = $self->TransactionObj->Type;
  if ($txn_type ne 'Create') {
    # Only on Create
    return 0;
  }

  # Does this transaction have an attachment with an
  # application/arcsight-external-event-tracking-data content type?
  my ($attachments) = $self->TransactionObj->Attachments();
  while (my $attachment_obj = $attachments->Next()) {
    next unless ($attachment_obj->ContentType() eq "application/arcsight-external-event-tracking-data");
    return 1;
  }
  return 0;
}

1;

