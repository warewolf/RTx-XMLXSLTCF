package RT::CustomField;
use strict;
no warnings qw(redefine);
use vars qw(%FieldTypes);

$FieldTypes{XSL} = [
  'Enter multiple XML documents for XSLT transform',
  'Enter one XML document for XSLT transform',
  'Enter up to [_1] XML documents for XSLT transform',
];

sub TypeComposites {
    my $self = shift;
    return grep !/(?:[Tt]ext|Combobox|XSL)-0/, map { ("$_-1", "$_-0") } $self->Types;
}


sub IsXSLType {
  my $self = shift;
  my $type = @_? shift : $self->Type;
  return undef unless $type;
  $type =~ m/(?:XSL)/;
}

sub XSL {
  my $self = shift;
  
  return '' unless $self->IsXSLType;
  my $xsl = $self->FirstAttribute('XSL');
  $xsl = $xsl->Content() if $xsl;
  return $xsl || undef;
}

sub SetXSL {
  my $self = shift;
  my $xsl  = shift;
  my ($status, $msg) = $self->SetAttribute( Name => "XSL", Content => $xsl );
  return ($status, $msg);
}

1;
