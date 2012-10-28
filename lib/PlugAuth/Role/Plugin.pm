package PlugAuth::Role::Plugin;

use strict;
use warnings;
use v5.10;
use Role::Tiny;

# ABSTRACT: Role for PlugAuth plugins
# VERSION

=head1 DESCRIPTION

Use this role when writing PlugAuth plugins.

=head1 METHODS

=head2 $plugin-E<gt>global_config

Get the global PlugAuth configuration (an instance of
L<Clustericious::Config>).

=cut

my $config;

sub global_config
{
  $config;
}

=head2 $plugin-E<gt>plugin_config

Get the plugin specific configuration.  This
method may be called as either an instance or
class method.

=cut

sub plugin_config
{
  shift->{plugin_config};
}

=head2 $plugin-E<gt>app

Returns the L<PlugAuth> instance for the running PlugAuth server.

=cut

my $app;

sub app
{
  $app;
}

sub new
{
  my($class, $global_config, $plugin_config, $theapp) = @_;
  $app = $theapp;
  $config = $global_config;
  bless {
    plugin_config => $plugin_config,
  }, $class;
}

1;
