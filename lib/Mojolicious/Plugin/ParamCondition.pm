package Mojolicious::Plugin::ParamCondition;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;

  $app->routes->add_condition(params => \&_params);
}

sub _check {
  my ($value, $pattern) = @_;

  if (!defined $pattern) {
      return defined $value ? 1 : undef;
  }

  return 1
    if $value && $pattern && ref $pattern eq 'Regexp' && $value =~ $pattern;
  return $value && defined $pattern && $pattern eq $value ? 1 : undef;
}

sub _params {
  my ($r, $c, $captures, $params) = @_;

  unless($params && (ref $params eq 'ARRAY' || ref $params eq 'HASH')) {
    return;
  }

  # All parameters need to exist
  my $p = $c->req->params;

  if (ref $params eq 'ARRAY') {
    foreach my $name (@{ $params }) {
      return unless _check(scalar $p->param($name));
    }
  }
  elsif (ref $params eq 'HASH') {
    while (my ($name, $pattern) = each %$params) {
      return unless _check(scalar $p->param($name), $pattern);
    }
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

  # The user selected a product with an index is digits and there is a username.
  get '/' => (params => ["username"]) => (params => {"productIdx" => qr/^\d+$/}) => sub {...};

=head1 DESCRIPTION

L<Mojolicious::Plugin::ParamCondition> is a routes condition for parameter
based routes.

=head1 METHODS

L<Mojolicious::Plugin::ParamCondition> inherits all methods from
L<Mojolicious::Plugin>.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
