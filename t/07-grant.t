use strict;
use warnings;
use FindBin ();
BEGIN { require "$FindBin::Bin/etc/setup.pl" }
use Test::More tests => 40;
use Test::Mojo;
use Mojo::JSON;

my $t = Test::Mojo->new('PlugAuth');

$t->get_ok('/'); # creates $t->ua

my $port = $t->ua->app_url->port;

$t->app->config->simple_auth->{url} = "http://localhost:$port";

sub json($) {
    ( { 'Content-Type' => 'application/json' }, Mojo::JSON->new->encode(shift) );
}

# grant an action on a resource to a group
$t->get_ok("http://localhost:$port/authz/user/optimus/open/matrix")
    ->status_is(403)
    ->content_is("unauthorized : optimus cannot open /matrix", "denied optimus");

$t->get_ok("http://localhost:$port/authz/user/rodimus/open/matrix")
    ->status_is(403)
    ->content_is("unauthorized : rodimus cannot open /matrix", "denied rodimus");

$t->post_ok("http://primus:snoopy\@localhost:$port/grant/group1/open/matrix")
    ->status_is(200)
    ->content_is("ok");

$t->get_ok("http://localhost:$port/authz/user/optimus/open/matrix")
    ->status_is(200)
    ->content_is("ok", "ok optimus");

$t->get_ok("http://localhost:$port/authz/user/rodimus/open/matrix")
    ->status_is(200)
    ->content_is("ok", "ok rodimus");

# grant an action on a resource to a user
$t->get_ok("http://localhost:$port/authz/user/starscream/thwart/megatron")
    ->status_is(403)
    ->content_is("unauthorized : starscream cannot thwart /megatron", "denied megatron");

$t->post_ok("http://primus:snoopy\@localhost:$port/grant/starscream/thwart/megatron")
    ->status_is(200)
    ->content_is('ok');

$t->get_ok("http://localhost:$port/authz/user/starscream/thwart/megatron")
    ->status_is(200)
    ->content_is("ok", "ok megatron");

# grant an action on a resource to a non existent group/user
$t->get_ok("http://localhost:$port/authz/user/unicron/fear/matrix")
    ->status_is(403)
    ->content_is("unauthorized : unicron cannot fear /matrix", "denied unicron");

$t->post_ok("http://primus:snoopy\@localhost:$port/grant/unicron/fear/matrix")
    ->status_is(404)
    ->content_is("not ok", "stuff");

$t->get_ok("http://localhost:$port/authz/user/unicron/fear/matrix")
    ->status_is(403)
    ->content_is("unauthorized : unicron cannot fear /matrix", "denied unicron");

# attempt to grant with bogus credentials
$t->post_ok("http://primus:badpass\@localhost:$port/grant/group1/transform/cog")
    ->status_is(401)
    ->content_is("authentication failure", "denied primus");

# grant to a group with an @ in the name (since groups can be users)
$t->post_ok("http://primus:snoopy\@localhost:$port/grant/prime\@autobot.mil/leadership/matrix")
    ->status_is(200)
    ->content_is('ok', 'ok prime@autobot.mil');

1;