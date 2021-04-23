#!/usr/bin/env perl
#
#   Web server for STSI's Variant Browser
#   Based on Mojolicius Perl Web Framework
#
#   Last Modified; May/20/2016
#
#   Version 0.4.0
#
#   Copyright (C) 2016 Manuel Rueda (mrueda@scripps.edu)
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#   If this program helps you in your research, please cite.

use Mojolicious::Lite;

#use Mojo::Server::Hypnotoad;
use autodie;
use FindBin qw($Bin);
use lib $Bin;
use BROWSER::HTML;
use BROWSER::DB;

# Naming convention: snake_case
# Mojolicius stuff
#app->secret('no-secret-warnings off');
app->mode('development');    # stop debug pages

# Route #1 -> Rendering Home Page HTML
get '/' => sub {
    my $self     = shift;
    my $html     = HTML->new();
    my $html_str = $html->front_page();
    $self->render( data => $html_str );
};

# Route #2 -> Rendering HTML results via GET or POST
# This route avoids proxy redirecting via POST form '/' to genomics.scripps.edu
any [ 'GET', 'POST' ] => '/results' => sub {
    my $self     = shift;
    my $query    = $self->param('query');
    my $html     = HTML->new( { query => $query } );
    my $html_str = $html->submission();
    $self->render( data => $html_str );
};

# Route #3 -> Web Services results via GET or POST with placeholders
any [ 'GET', 'POST' ] => '/:query/:cohort/:filetype' =>
  [ cohort => [qw(cg illumina molau)], filetype => [qw(vcf json)] ] => sub { # /:format 'format' did not work
    my $self   = shift;
    my $query  = $self->param('query');
    my $cohort = lc( $self->param('cohort') );
    my $format = lc( $self->param('filetype') );
    my $html =
      HTML->new( { query => $query, cohort => $cohort, format => $format } );
    my $str = $html->web_services();
    $self->render( data => $str );
  };

# Route #4 -> Rendering Beacon Page HTML
get '/ga4gh' => sub {
    my $self     = shift;
    my $html     = HTML->new();
    my $html_str = $html->beacon_page();
    $self->render( data => $html_str );
};

# Route #5 -> Rendering HTML-based Beacon results
post '/ga4gh' => sub {
    my $self   = shift;
    my $beacon = uc( $self->param('beacon') );
    my $ref    = uc( $self->param('ref') );
    my $chr    = $self->param('chr');
    my $pos    = $self->param('pos');
    $pos++;    # From 0-based to 1-based
    my $alt      = uc( $self->param('alt') );                       # Any allele
    my $query    = $chr . ':' . $pos . '-' . $pos;
    my $html     = HTML->new( { query => $query, allele => $alt } );
    my $html_str = $html->submission();
    $self->render( data => $html_str );
};

app->start();

exit;
