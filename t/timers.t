#!/usr/bin/env perl

use Mojo::Base -strict;

use Test::More;

use Mojo::Reactor::UV::FFI;
use Mojo::IOLoop;

isa_ok( Mojo::IOLoop->singleton->reactor, 'Mojo::Reactor::UV::FFI', 'Detect Mojo::Reactor::UV::FFI');

subtest 'Timer' => sub {
  my $fired = 0;
  my ($t, $id) = Mojo::IOLoop->timer( 0.25 => sub { $fired++ });
  Mojo::IOLoop->start;
  ok $fired, 'timer fired';
};

subtest 'Recurring' => sub {
  my $fired = 0;
  my ($t, $id)   = Mojo::IOLoop->recurring( 0.25 => sub { $fired++ });
  my ($t2, $id2) = Mojo::IOLoop->timer( 1 => sub { Mojo::IOLoop->remove($id) });
  Mojo::IOLoop->start;
  ok $fired > 1, 'recurring fired repeatedly';
};

subtest 'is_running' => sub {
  my $running = Mojo::IOLoop->is_running;
  ok ! $running, 'false before starting';

  my ($t, $id) = Mojo::IOLoop->timer(
      0.25 => sub { $running = Mojo::IOLoop->is_running }
  );

  Mojo::IOLoop->start;
  ok $running, 'true while running';
  ok ! Mojo::IOLoop->is_running, 'false after stopping';
};

done_testing;

