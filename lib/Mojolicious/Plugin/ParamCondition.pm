package Mojolicious::Plugin::ParamCondition;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;

  $app->routes->add_condition(params => \&_params);
}

sub _check {
  my ($value) = @_;
  return defined $value ? 1 : undef;
}

sub _params {
  my ($r, $c, $captures, $names) = @_;
  return unless $names && ref $names eq 'ARRAY';

  # All parameters need to exist
  my $p = $c->req->params;
  foreach my $name (@{ $names }) {
    return unless _check(scalar $p->param($name));
  }
  return 1;
}

1;

=head1 NAME

Mojolicious::Plugin::ParamCondition - Request parameter condition plugin

=head1 SYNOPSIS

  # Mojolicious::Lite
  plugin 'ParamCondition';

  # The user selected a product with an index exists.
  get '/' => (params => [qw(productIdx)]) => sub {...};

=head1 DESCRIPTION

L<Mojolicious::Plugin::ParamCondition> is a routes condition for parameter
based routes.

=head1 METHODS

L<Mojolicious::Plugin::ParamCondition> inherits all methods from
L<Mojolicious::Plugin>.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
