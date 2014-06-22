#!/usr/bin/perl
use v5.14;
use warnings;
use AnyEvent;
use UAV::Pilot::ARDrone::Driver;
use UAV::Pilot::ARDrone::Control::Event;
use UAV::Pilot::EasyEvent;

my $HOST = '192.168.1.1';
my $cv = AnyEvent->condvar;

my $driver = UAV::Pilot::ARDrone::Driver->new({
    host => $HOST,
});
$driver->connect;

my $event = UAV::Pilot::EasyEvent->new({
    condvar => $cv,
});

my $control = UAV::Pilot::ARDrone::Control::Event->new({
    driver => $driver,
});
$control->init_event_loop( $cv, $event );

$event->add_timer({
    duration       => 10,
    duration_units => $event->UNITS_MILLISECOND,
    cb             => sub { $control->takeoff },
})->add_timer({
    duration       => 10000,
    duration_units => $event->UNITS_MILLISECOND,
    cb             => sub {
        $control->land;
        $cv->send;
    },
});
$event->init_event_loop;
$cv->recv;
