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

  if ($value && $pattern && ref $pattern eq 'Regexp') {
      return 1 if $value =~ $pattern;
  }

  if ($value && defined $pattern) {
      if ($pattern eq $value) {
          return 1;
      }
      else {
          return undef;
      }
  }

  return undef;
}

sub _params {
  my ($r, $c, $captures, $params) = @_;

  unless ($params && (ref $params eq 'ARRAY' || ref $params eq 'HASH')) {
    return;
  }

  # All parameters need to exist
  my $p = $c->req->params;

  if (ref $params eq 'ARRAY') {
    foreach my $name (@{ $params }) {
      return unless _check(scalar $p->param($name), undef);
    }
  }
  elsif (ref $params eq 'HASH') {
    keys %$params;
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

  # Does a paramter "productIdx" exist (i.e. ?productIdx=)?
  get '/' => (params => [qw(productIdx)]) => sub {...};

  # Does a paramter "productIdx" match a word?
  get '/' => (params => {productIdx => "oranges"}) => sub {...};

  # Does a paramter "productIdx" match a regular expression?
  get '/' => (params => {productIdx => qr/\w/}) => sub {

  # Does a paramter username exist and does paramter fruit match a word?
  get '/' => (params => ["username"]) => (params => {fruit => "oranges"}) => sub {

=head1 DESCRIPTION

L<Mojolicious::Plugin::ParamCondition> is a routes condition based 
on the presence and value of request parameters.

=head2 Dispatching

Given the following code:

    get '/' => (params => ["username"]) => (params => {mode => "bread"}) => sub {
        my $self = shift;

        $self->render_text("Buy some bread!.");
    };

    get '/' => (params => ["username"]) => (params => {mode => "login"}) => sub {
        my $self = shift;

        $self->render_text("Thank you: logging in.");
    };

    get '/' => (params => ["username"]) => sub {
        my $self = shift;

        $self->render_text("Please enter a password");
    };

    get '/' => sub {
        my $self = shift;

        $self->render_text("Good morning.");
    };

The following GET request will match:

    /                             -> $self->render(text => "Good morning");
    /?username=                   -> $self->render(text => "Please enter a password");
    /?username=Baerbel            -> $self->render(text => "Please enter a password");
    /?username=Baerbel&mode=login -> $self->render(text => "Thank you: logging in.");
    /?username=Baerbel&mode=bread -> $self->render(text => "Buy some bread!.");

=head1 METHODS

L<Mojolicious::Plugin::ParamCondition> inherits all methods from
L<Mojolicious::Plugin>.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
