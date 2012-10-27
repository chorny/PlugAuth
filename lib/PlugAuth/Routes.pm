package PlugAuth::Routes;

# ABSTRACT: routes for plugauth
# VERSION

=head1 DESCRIPTION

This module defins the routes provided by L<PlugAuth>.

=head1 SEE ALSO

L<PlugAuth>

=cut

# There may be external authentication for these routes, i.e. using
# this CI to determine who can check/update other's access.

use strict;
use warnings;
use Log::Log4perl qw/:easy/;
use Mojo::ByteStream qw/b/;
use IO::File;
use List::MoreUtils qw/mesh/;
use Clustericious::RouteBuilder;
use Clustericious::Config;

get '/' => sub { shift->render_text("welcome to plug auth") } => "index" ;

ladder sub { shift->data->refresh };

# Check authentication for a user (http basic auth protocol).
get '/auth' => sub {
    my $self = shift;
    my $auth = $self->req->headers->authorization or do {
        $self->res->headers->www_authenticate('Basic "ACPS"');
        $self->res->code(401);
        $self->render(text => "please authenticate");
        return;
    };
    my ($method,$str) = split / /,$auth;
    my ($user,$pw) = split /:/, b($str)->b64_decode;

    my $ok = $self->data->check_credentials($user,$pw);
    DEBUG "Authentication succeeded for user $user" if $ok;
    return $self->render_text("ok") if $ok;
    DEBUG "Authentication failed for user $user";
    $self->res->code(403);
    $self->render_text("not ok");
};

# Check authorization for a user to perform $action on $resource.
get '/authz/user/#user/#action/(*resource)' => sub {
    my $c = shift;
    # Ok iff the user is in a group for which $action on $resource is allowed.
    my ($user,$resource,$action) = map $c->stash($_), qw/user resource action/;
    $resource = "/$resource";
    TRACE "Checking authorization for $user to perform $action on $resource...";
    my $found = $c->data->can_user_action_resource($user,$action,$resource);
    if ($found) {
        TRACE "Authorization succeeded ($found)";
        return $c->render(text => 'ok', status => 200);
    }
    TRACE "Authorization failed";
    $c->render(text => "unauthorized : $user cannot $action $resource", status => 403);
};

# Given a user, an action and a regex, return a list of resources
# on which $user can do $action, where each resource matches that regex.
get '/authz/resources/#user/#action/(*resourceregex)' => sub  {
    my $c = shift;
    my ($user,$action,$resourceregex) = map $c->stash($_), qw/user action resourceregex/;
    TRACE "Checking $user, $action, $resourceregex";
    $resourceregex = qr[$resourceregex];
    my @resources;
    for my $resource ($c->data->match_resources($resourceregex)) {
        TRACE "Checking resource $resource";
        push @resources, $resource if $c->data->can_user_action_resource($user,$action,$resource);
    }
    $c->render_json([sort @resources]);
};

# Return a list of all defined actions
get '/actions' => sub {
    my($self) = @_;
    $self->render_json([ $self->data->actions ]);
};

# All the groups for a user :
get '/groups/#user' => sub {
    my $c = shift;
    $c->render_json([ $c->data->groups($c->stash('user')) ]);
};

# Given a host and a tag (e.g. "trusted") return true if that host has
# that tag.
get '/host/#host/:tag' => sub {
    my $c = shift;
    my ($host,$tag) = map $c->stash($_), qw/host tag/;
    if ($c->data->host_has_tag($host,$tag)) {
        TRACE "Host $host has tag $tag";
        return $c->render(text => "ok", status => 200);
    }
    TRACE "Host $host does not have tag $tag";
    return $c->render(text => "not ok", status => 403);
};

get '/user' => sub {
    my $c = shift;
    $c->render_json([ $c->data->all_users ]);
};

get '/group' => sub {
    my $c = shift;
    $c->render_json([ $c->data->all_groups ]);
};

get '/users/:group' => sub {
    my $c = shift;
    $c->render_json([ $c->data->users($c->stash('group')) ]);
};

authenticate;
authorize 'accounts';

post '/user' => sub {
    my $c = shift;
    my $user = $c->req->json->{user};
    my $password = $c->req->json->{password} || '';
    $c->data->create_user($user, $password)
    ? $c->render(text => 'ok', status => 200)
    : $c->render(text => "not ok", status => 403);
};

del '/user/#user' => sub {
    my $c = shift;
    $c->data->delete_user($c->param('user') )
    ? $c->render(text => 'ok', status => 200)
    : $c->render(text => 'not ok', status => 404);
};

post '/group' => sub {
    my $c = shift;
    my $group = $c->req->json->{group};
    my $users = $c->req->json->{users};
    $c->data->create_group($group, $users)
    ? $c->render(text => 'ok', status => 200)
    : $c->render(text => "not ok", status => 403);
};

del '/group/:group' => sub {
    my $c = shift;
    $c->data->delete_group($c->param('group') )
    ? $c->render(text => 'ok', status => 200)
    : $c->render(text => 'not ok', status => 404);
};

post '/group/:group' => sub {
    my $c = shift;
    my $users = $c->req->json->{users};
    $c->data->update_group($c->param('group'), $users)
    ? $c->render(text => 'ok', status => 200)
    : $c->render(text => 'not ok', status => 404);
};

post '/grant/#group/:action1/(*resource)' => sub {
    my $c = shift;
    my($group, $action, $resource) = map { $c->stash($_) } qw( group action1 resource );
    $c->data->grant($group, $action, $resource)
    ? $c->render(text => 'ok', status => 200)
    : $c->render(text => 'not ok', status => 404);
};

authenticate;
authorize 'change_password';

post '/user/#user' => sub {
    my($c) = @_;
    my $user = $c->param('user');
    my $password = eval { $c->req->json->{password} } || '';
    $c->data->change_password($user, $password)
    ? $c->render(text => 'ok', status => 200)
    : $c->render(text => 'not ok', status => 403);
};

1;