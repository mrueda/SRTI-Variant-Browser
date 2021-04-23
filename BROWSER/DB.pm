package DB;

use strict;
use warnings;
use DBI;
use autodie;

=head1 NAME

  BROWSER::DB - Package for DB connection 

=head1 SYNOPSIS

  use BROWSER::DB

=head1 DESCRIPTION


=head1 AUTHOR

Written by Manuel Rueda, PhD

=cut

=head1 METHODS

=cut

#my $data = '/media/mrueda/4TB/Databases/browser';
my $data = '/var/www/browser';
#############################################

=head2 new

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub new {
    my ( $class, $args_sub ) = @_;
    my $self = {
        chr    => $args_sub->{chr},
        query  => $args_sub->{query},
        type   => $args_sub->{type},
        allele => $args_sub->{allele} || 'off'
    };

    bless $self, $class;
    return $self;
}

#############################################

=head2 cohort

    About   : We need this method to expand object initialization
    Usage   : None             
    Args    : 

=cut

#############################################

sub cohort {
    my $self = shift;
    $self->{"cohort"} = shift;
    return $self->{"cohort"};
}

#############################################

=head2 get_query_TABIX

    About   : For consistency, we will be returning an array reference
    Usage   : None             
    Args    : 

=cut

#############################################

sub get_query_TABIX {

    my ($self) = @_;
    my $chr    = $self->{chr};
    my $query  = $self->{query};
    my $allele = $self->{allele};
    my $cohort = $self->{cohort};                      # New argument
    my $tabix  = '/pro/NGSutils/htslib-1.11//tabix';
    my $file2query =
      $cohort eq 'molau'
      ? "$data/files/molau/vcf/chr$chr.$cohort.vcf.gz"
      : "$data/files/wellderly/vcf/chr$chr.$cohort.vcf.gz";
    my $cmd =
      $allele ne 'off'
      ? "$tabix $file2query $query | LC_ALL=C grep -F -w $allele"
      : "$tabix $file2query $query";
    my $rows = [];
    @$rows = `$cmd`;

    if ( !@$rows ) {
        $rows = [];    # Empty result
    }
    else {
        chomp @$rows;
    }
    return $rows;      # w/o \n
}

#############################################

=head2 get_query_SQLite

    About   : For consistency, we will be returning an array reference
    Usage   : None             
    Args    : 

=cut

#############################################

sub get_query_SQLite {

    my ($self) = @_;
    my $query  = $self->{query};
    my $field  = $self->{type};
    my $cohort = $self->{cohort};    # New argument
    my $db = $cohort eq 'molau' ? 'molau' : "wellderly_$cohort";
    my $dbfile =
      $cohort eq 'molau'
      ? "$data/db/molau/$db.db"
      : "$data/db/wellderly/$db.db";
    my $user   = '';
    my $passwd = '';
    my $dsn    = "dbi:SQLite:dbname=$dbfile";
    my $dbh    = DBI->connect(
        $dsn, $user, $passwd,
        {
            PrintError       => 0,
            RaiseError       => 1,
            AutoCommit       => 1,
            FetchHashKeyName => 'NAME_lc',
        }
    );

    my %query = (
        gene => "select * from $db where gene = ?",
        rs   => "select * from $db where rs = ?",

        #       rs       => 'select * FROM ExAC WHERE rs =  ? COLLATE NOCASE',
        unknown => "select * from $db like ?"
    );

    my $sth = $dbh->prepare(<<SQL);
$query{$field}
SQL

    #$query{$field}
    #select * from $db where rs = ?

    # Excute query
    $sth->execute($query);

    # Result will be an array reference
    my $str  = '';
    my $rows = [];
    while ( my @columns = $sth->fetchrow_array() ) {

        #$str = join( "\t", @columns );
        $str = join( "\t", @columns[ 0 .. 7 ] );
        push @$rows, $str;
    }
    $sth->finish();
    $dbh->disconnect();

    $rows = () if !@$rows;    # Empty result
    return $rows;             # w/o \n
}

1;
