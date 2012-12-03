package PlugAuth::Role::Authz;

use strict;
use warnings;
use Role::Tiny;

# ABSTRACT: Role for PlugAuth authorization plugins
# VERSION

=head1 SYNOPSIS

 package PlugAuth::Plugin::MyAuthz;
 
 use Role::Tiny::With;
 
 with 'PlugAuth::Role::Plugin';
 with 'PlugAuth::Role::Authz';

 # implement at least: can_user_action_resource, match_resources, 
 # host_has_tag, actions, groups_for_user, all_groups 
 # and users_in_group 
 
 # optionall implement: create_group, delete_group, update_group
 # and delete_group
 
 1;

=head1 DESCRIPTION

Use this role when writing PlugAuth plugins that manage
authorization (ie. determine what the user has authorization
to actually do).

=cut

requires qw( 
  can_user_action_resource
  match_resources
  host_has_tag
  actions
  groups_for_user
  all_groups
  users_in_group
);

=head1 REQUIRED ABSTRACT METHODS

=head2 $plugin-E<gt>can_user_action_resource( $user, $action, $resource )

If $user can perform $action on $resource, return a string containing the 
group and resource that permits this. Otherwise, return false.

=head2 $plugin-E<gt>match_resources( $regex )

Given a regex, return all resources that match that regex.

=head2 $plugin-E<gt>host_has_tag( $host, $tag )

Returns true if the given host has the given tag.

=head2 $plugin-E<gt>actions

Returns a list of actions.

=head2 $plugin-E<gt>groups_for_user( $user )

Returns the groups the given user belongs to.

=head2 $plugin-E<gt>all_groups

Returns a list of all groups.

=head2 $plugin-E<gt>users_in_group( $group )

Return the list of users (as an array ref) that belong to the given group.
Each user belongs to a special group that is the same as their user name
and just contains themselves, and this will be included in the list.

Returns undef if there is no such group.

=head1 OPTIONAL ABSTRACT METHODS

These methods may be implemented by your class.

=head2 $plugin-E<gt>create_group( $group, $users )

Create a new group with the given users.  $users is a
comma separated list of user names.

=cut

sub create_group { 0 }

=head2 $plugin-E<gt>delete_group( $group )

Delete the given group.

=cut

sub delete_group { 0 }

=head2 $plugin-E<gt>grant( $group, $action, $resource )

Grant the given group or user ($group) the authorization to perform the given
action ($action) on the given resource ($resource).

=cut

sub grant { 0 }

=head2 $plugin-E<gt>revoke( $group, $action, $resource )

Revoke the given group or user ($group) the authorization to performa
the given action ($action) on the given resource ($resource)

=cut

sub revoke { 0 }

=head2 $plugin-E<gt>granted

Returns a list of granted permissions

=cut

sub granted { [] }

=head2 $plugin-E<gt>update_group( $group, $users )

Update the given group, setting the set of users that belong to that
group.  The existing group membership will be replaced with the new one.
$users is a comma separated list of user names.

=cut

sub update_group { 0 }

1;

=head1 SEE ALSO

L<PlugAuth>,
L<PlugAuth::Guide::Plugin>

=cut
