=head1 NAME

Octopussy::Web

=cut

package Octopussy::Web;

use Dancer ':syntax';

use Web::Core::JSON;

use Octopussy::Web::Device;
use Octopussy::Web::User;

our $VERSION = '1.2';

prefix undef;

=head1 HOOKS

=head2 HOOK 'before'

Redirect to User Login page if no 'octopussy_user' in Session

=cut

hook 'before' => sub 
{
	if (! session('octopussy_user') && request->path_info !~ m{^/user/login}) 
	{
		var requested_path => request->path_info;
		request->path_info('/user/login');
    }
};

=head1 ROUTES

=head2 GET '/'

=cut

get '/' => sub 
{
	template 'home';
};

1;

=head1 AUTHOR

Sebastien Thebert <support@octopussy.pm>

=cut
