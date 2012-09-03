use Mojo::IOLoop;
use Test::More;
use Test::Mojo;

# Make sure sockets are working
plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop->new->generate_port;    # Test server
plan tests => 54;

# Lite app
use Mojolicious::Lite;

# Silence
app->log->level('error');

plugin 'ParamCondition';

get '/' => (params => {username => qr/\w/, fruit => "apples"}) => sub {
    my $self = shift;

    $self->render_text("with apples");
};

get '/' => (params => {username => qr/\w/, fruit => "oranges"}) => sub {
    my $self = shift;

    $self->render_text("with oranges");
};

get '/' => (params => ["username"]) => (params => {fruit => "oranges"}) => sub {
    my $self = shift;

    $self->render_text("with 'blank' username and oranges");
};

get '/' => (params => ["username"]) => sub {
    my $self = shift;

    $self->render_text("with username");
};

get '/' => sub {
    my $self = shift;

    $self->render_text("default");
};

post '/' => (params => {username => qr/\w/, fruit => "apples"}) => sub {
    my $self = shift;

    $self->render_text("post with apples");
};

post '/' => (params => {username => qr/\w/, fruit => "oranges"}) => sub {
    my $self = shift;

    $self->render_text("post with oranges");
};

post '/' => (params => ["username"]) => (params => {fruit => "oranges"}) => sub {
    my $self = shift;

    $self->render_text("post with 'blank' username and oranges");
};

post '/' => (params => ["username"]) => sub {
    my $self = shift;

    $self->render_text("post with username");
};

post '/' => sub {
    my $self = shift;

    $self->render_text("post default");
};

# Tests
my $t = Test::Mojo->new;

# Username, password
diag '/';

$t->get_ok('/')->status_is(200)
  ->content_is('default');

$t->get_ok('/?username=')->status_is(200)
  ->content_is('with username');

$t->get_ok('/?username=fred')->status_is(200)
  ->content_is('with username');

$t->get_ok('/?username=fred&fruit=oranges')->status_is(200)
  ->content_is('with oranges');

$t->get_ok('/?username=fred&fruit=apples')->status_is(200)
  ->content_is('with apples');

$t->get_ok('/?username=&fruit=oranges')->status_is(200)
  ->content_is("with 'blank' username and oranges");

$t->get_ok('/?fruit=oranges')->status_is(200)
  ->content_is('default');

$t->get_ok('/?fruit=pears')->status_is(200)
  ->content_is('default');

$t->get_ok('/?username=brian&fruit=pears')->status_is(200)
  ->content_is('with username');


$t->post_ok('/')->status_is(200)
  ->content_is('post default');

$t->post_ok('/?username=fred')->status_is(200)
  ->content_is('post with username');

$t->post_ok('/?username=')->status_is(200)
  ->content_is('post with username');

$t->post_ok('/?username=fred&fruit=oranges')->status_is(200)
  ->content_is('post with oranges');

$t->post_ok('/?username=fred&fruit=apples')->status_is(200)
  ->content_is('post with apples');

$t->post_ok('/?username=&fruit=oranges')->status_is(200)
  ->content_is("post with 'blank' username and oranges");

$t->post_ok('/?fruit=oranges')->status_is(200)
  ->content_is('post default');

$t->post_ok('/?fruit=pears')->status_is(200)
  ->content_is('post default');

$t->post_ok('/?username=brian&fruit=pears')->status_is(200)
  ->content_is('post with username');
