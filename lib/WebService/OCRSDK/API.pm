package WebService::OCRSDK::API;

use Modern::Perl;
use Moose;
use LWP::UserAgent;
use URI::Escape;
use Data::OpenStruct::Deep;
use XML::Simple;
use MooseX::Privacy;
our $VERSION = '0.01';


has app_id    => (is => 'rw', isa => 'Str', required => 1);
has password  => (is => 'rw', isa => 'Str', required => 1);
has error_str => (is => 'rw', writer => 'set_error');
has content   => (is => 'rw', writer => 'set_content');

has ua => (
  isa => 'Object',
  is => 'rw',
  default => sub { LWP::UserAgent->new },
  handles => { post => 'post', get => 'get' },
);

around 'get' => sub {
  my $original_method = shift;
  my $self = shift;
  my $res = $self->$original_method(@_);
  
  unless ($res->is_success) {
    $self->set_error($res->status_line);
    return undef;
  }

  $self->set_content($res->content);

  return 1
};


sub get_task_status {
  my ($self, $param) = @_;

  unless ($param) {
    $self->set_error("please provide the task ID");
    return undef;
  }

  $self->get($self->_private_host . "/getTaskStatus?taskid=$param");

  $self->error_str ? undef : $self->_os_struct ;
}


sub process_mrz {
  my ($self, $param) = @_;
  
  unless($param) {
    #set error
    $self->set_error("please provide the path of image you want to upload");
    return undef;
  }

  unless(-e $param) {
   $self->set_error("$param is not exists or not accessible");
   return undef;
  }

  my $res = $self->post(
    $self->_private_host ."/processMRZ",
    Content_Type => 'form-data',
    Content => ['upload[file]' => [$param]],
  );

  unless ($res->is_success) {
    $self->set_error($res->status_line);
    return undef;
  }

  $self->set_content($res->content);

  $self->_os_struct;
}


private_method _os_struct => sub {
  my $self = shift;

  my $res_hash = XMLin($self->content, ForceArray => 1, KeepRoot => 1);

  my $task_id = (keys %{$res_hash->{response}[0]{task}})[0];
  my $data    = delete $res_hash->{response}[0]{task}{$task_id};
  $data->{id} = $task_id if $task_id;

  Data::OpenStruct::Deep->new(%$data);
};



private_method _private_host => sub {
  my $self = shift;
  
  my $app_id   = uri_escape($self->app_id);
  my $password = uri_escape($self->password);

  "http://$app_id:$password\@cloud.ocrsdk.com";  
};



=head1 NAME

WebService::OCRSDK::API - Perl interface to the ABBYY Cloud OCR SDK


=head1 VERSION

Version 0.01

=cut


=head1 SYNOPSIS

See http://ocrsdk.com/documentation/apireference/

    use Modern::Perl;

    use WebService::OCRSDK::API;
    use Data::Dumper;

    my $ocrsdk = WebService::OCRSDK::API->new(
      app_id   => "my_app_id",
      password => "my_password",
    );

    my $res = $ocrsdk->process_mrz("Passport.jpg") or die $ocrsdk->error_str;

    say $res->id; 
    say $res->credits;
    say $res->statusChangeTime;
    say $res->filesCount;
    say $res->registrationTime;
    say $res->estimatedProcessingTime;
    say $res->status;


=head1 SUBROUTINES/METHODS

=head2 get_task_status

Returns the current status of the task and the URL of the result of processing 
for completed tasks. The hyperlink has limited lifetime. If you want to 
download the result after the time has passed

see http://ocrsdk.com/documentation/apireference/getTaskStatus/

  my $res = $ocrsdk->get_task_status("task_id");
  say $res->status;
  say $res->resultUrl; 
  say $res->credits;

=cut

=head2 process_mrz

finds a machine-readable zone on the image and extracts data from it.
Machine-readable zone (MRZ) is typically found on official travel or identity 
documents of many countries. It can have 2 lines or 3 lines of machine-readable data.

See http://ocrsdk.com/documentation/apireference/processMRZ/

=cut

=head1 PRIVATE SUBS

=head2 _os_struct

=cut

=head2 private_host

=cut


=head1 AUTHOR

Zakarias Santanu, C<< <zaksantanu at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::OCRSDK::API


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Zakarias Santanu.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WebService::OCRSDK::API
