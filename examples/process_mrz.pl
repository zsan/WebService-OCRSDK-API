#!/usr/bin/env perl
use Modern::Perl;

use lib "../lib";
use WebService::OCRSDK::API;
use Data::Dumper;

my $ocrsdk = WebService::OCRSDK::API->new(
  app_id   => "_your_application_id_",
  password => "_your_application_password_",
);

my $res = $ocrsdk->process_mrz("/path/to/image_file") or die $ocrsdk->error_str;

say $res->id; 
say $res->credits;
say $res->statusChangeTime;
say $res->filesCount;
say $res->registrationTime;
say $res->estimatedProcessingTime;
say $res->status;



my $status_res = $ocrsdk->get_task_status($res->id) or die $ocrsdk->error_str;

say $status_res->resultUrl; 
say $status_res->credits;
say $status_res->statusChangeTime;
say $status_res->filesCount;
say $status_res->registrationTime;
# say $res->estimatedProcessingTime;
say $status_res->status;

# if you want
# say Dumper $res;
# say Dumper $status_res

