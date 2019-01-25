# mlc_stdlib.pm
#   Description

package mlc_stdlib;

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak carp};
use Data::Dumper;

our $VERSION = 0.001000;

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(
    read_files
    write_to_files

    match_test
    element_eq
);

################################################################
## FileOps

sub read_files {
    my (@files) = @_;

    sub read_from_file {
        my ($path) = @_;
        my @result;
        open( my $fh, '<:encoding(UTF-8)', "$path" )
            or croak("Could not open file '$path' $!");
        while ( my $line = <$fh> ) {
            chomp $line;
            push @result, "$line";
        }
        return join "\n", @result;
    }    ##    read_from_file

    my @result_array;
    foreach my $some_file (@files) {
        push @result_array, read_from_file($some_file);
    }
    return join "\n\n", @result_array;
}    ##    read_files

sub write_to_files {
    my ( $buffer, @list_of_paths ) = @_;
    foreach my $file_path (@list_of_paths) {
        open( my $FILE_HANDLE, ">", $file_path )
            or croak("Cannot open $file_path : $!\n");
        print $FILE_HANDLE "$buffer" or croak("Cannot write $file_path : $!\n");
    }
    return 1;    ## success
}    ##    write_to_files

################################################################
## assorted

################################################################
## Test Functions

sub match_test {
    my ( $x, $y ) = @_;

    if ( $x && $y ) { return $x =~ m/$y/i; }
    return 0;
}

sub element_eq {
    my ( $x, $y ) = @_;
    if ( ref($x) eq "ARRAY" && ref($y) eq "ARRAY" ) {
        if ( scalar @{$x} == scalar @{$y} ) {
            for ( my $index = 0; $index < scalar @{$x}; $index++ ) {
                if ( $x->[$index] ne $y->[$index] ) { return 0 }
            }
            return 1;
        }
    }
    elsif ( ref($x) eq "HASH" && ref($y) eq "HASH" ) {
        if ( element_eq( [ keys %{$x} ], [ keys %{$y} ] ) ) {
            foreach my $index ( keys %{$x} ) {
                if ( $x->{$index} ne $y->{$index} ) { return 0 }
            }
            return 1;
        }
    }
    else {
        return $x eq $y ? 1 : 0;
    }
    return 0;
}    ##    equals_test

################################################################

1;
