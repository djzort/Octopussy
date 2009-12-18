# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::SMTP - AAT SMTP module

=cut

package AAT::SMTP;

use strict;
use warnings;

use Mail::Sender;
use Net::Telnet;

my %conf_file = ();

=head1 FUNCTIONS

=head2 Configuration($appli)

Returns SMTP configuration

=cut

sub Configuration
{
  my $appli = shift;

  $conf_file{$appli} ||= AAT::Application::File($appli, 'smtp');
  my $conf = AAT::XML::Read($conf_file{$appli}, 1);

  return ($conf->{smtp});
}

=head2 Connection_Test($appli)

Checks the SMTP connection

=cut

sub Connection_Test
{
  my $appli  = shift;
  my $status = 0;
  my $conf   = Configuration($appli);
  if ( AAT::NOT_NULL($conf->{server})
    && AAT::NOT_NULL($conf->{sender}))
  {
    my $con = new Net::Telnet(
      Host    => $conf->{server},
      Port    => 25,
      Errmode => 'return',
      Timeout => 3
    );
    my $sender = (
      AAT::NOT_NULL($conf->{auth_type})
      ? new Mail::Sender {
        smtp    => $conf->{server},
        from    => $conf->{sender},
        auth    => $conf->{auth_type},
        authid  => $conf->{auth_login},
        authpwd => $conf->{auth_password}
        }
      : new Mail::Sender {smtp => $conf->{server}, from => $conf->{sender}}
    );

    if ((defined $con) && (defined $sender) && (ref $sender))
    {
      $status = 1;
      $con->close();
    }
  }

  return ($status);
}

=head2 Send_Message($appli, $subject, $body, @dests)

Send message to @dests

=cut

sub Send_Message
{
  my ($appli, $subject, $body, @dests) = @_;

  my $conf = Configuration($appli);
  if (AAT::NOT_NULL($conf->{server}) && AAT::NOT_NULL($conf->{sender}))
  {
    my $sender = (
      AAT::NOT_NULL($conf->{auth_type})
      ? new Mail::Sender {
        smtp    => $conf->{server},
        from    => $conf->{sender},
        auth    => $conf->{auth_type},
        authid  => $conf->{auth_login},
        authpwd => $conf->{auth_password}
        }
      : new Mail::Sender {smtp => $conf->{server}, from => $conf->{sender}}
    );
    if ((defined $sender) && (ref $sender))
    {
      foreach my $dest (@dests)
      {
        $sender->MailMsg({to => $dest, subject => $subject, msg => $body});
      }
      $sender->Close();

      return (1);
    }
  }
  else
  {
    AAT::Syslog('AAT::SMTP', 'SMTP_INVALID_CONFIG');
  }

  return (0);
}

=head2 Send_Message_With_File($appli, $subject, $body, $file, @dests)

Send message with file to @dests

=cut

sub Send_Message_With_File
{
  my ($appli, $subject, $body, $file, @dests) = @_;

  my $conf = Configuration($appli);
  if (AAT::NOT_NULL($conf->{server}) && AAT::NOT_NULL($conf->{sender}))
  {
    my $sender = (
      AAT::NOT_NULL($conf->{auth_type})
      ? new Mail::Sender {
        smtp    => $conf->{server},
        from    => $conf->{sender},
        auth    => $conf->{auth_type},
        authid  => $conf->{auth_login},
        authpwd => $conf->{auth_password}
        }
      : new Mail::Sender {smtp => $conf->{server}, from => $conf->{sender}}
    );
    if ((defined $sender) && (ref $sender))
    {
      foreach my $dest (@dests)
      {
        $sender->MailFile(
          {
            to      => $dest,
            subject => $subject,
            msg     => $body,
            file    => $file
          }
        );
      }
      $sender->Close();

      return (1);
    }
  }
  else
  {
    AAT::Syslog('AAT::SMTP', 'SMTP_INVALID_CONFIG');
  }

  return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
