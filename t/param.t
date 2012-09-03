use Mojo::IOLoop;
use Test::More;
use Test::Mojo;
use Mojo::ByteStream 'b';

# Make sure sockets are working
plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop->new->generate_port;    # Test server
plan tests => 18;

# Lite app
use Mojolicious::Lite;

# Silence
app->log->level('error');

plugin 'ParamCondition';

get '/' => (params => ["username"]) => (params => {"fruit" => qr/^oranges$/}) => sub {
    my $self = shift;

    $self->render_text("with oranges");
};

get '/' => (params => ["username"]) => sub {
    my $self = shift;

    $self->render_text("with username");
};

get '/' => sub {
    my $self = shift;

    $self->render_text("default");
};

# Tests
my $t = Test::Mojo->new;

# Username, password
diag '/';

$t->get_ok('/')->status_is(200)
  ->content_is('default');

$t->get_ok('/?username=fred')->status_is(200)
  ->content_is('with username');

$t->get_ok('/?username=fred&fruit=oranges')->status_is(200)
  ->content_is('with oranges');

$t->get_ok('/?fruit=oranges')->status_is(200)
  ->content_is('default');

$t->get_ok('/?fruit=pears')->status_is(200)
  ->content_is('default');

$t->get_ok('/?username=brian&fruit=pears')->status_is(200)
  ->content_is('with username');
