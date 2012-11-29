use strict;
use warnings;
use Test::More tests => 14;

use_ok 'PlugAuth';
use_ok 'PlugAuth::Routes';
use_ok 'PlugAuth::Plugin::FlatAuth';
use_ok 'PlugAuth::Plugin::FlatAuthz';
use_ok 'PlugAuth::Plugin::FlatUserList';

use_ok 'PlugAuth::Role::Auth';
use_ok 'PlugAuth::Role::Authz';
use_ok 'PlugAuth::Role::Plugin';
use_ok 'PlugAuth::Role::Refresh';
use_ok 'PlugAuth::Role::Flat';

use_ok 'Test::PlugAuth::Plugin::Auth';
use_ok 'Test::PlugAuth::Plugin::Authz';
use_ok 'Test::PlugAuth::Plugin::Refresh';

pass '14th test';