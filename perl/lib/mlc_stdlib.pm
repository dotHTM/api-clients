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
    write_file

    match_test
    element_eq
);

################################################################
## FileOps

sub read_files {
    my (@path_list) = @_;
    if ( ref( $path_list[0] ) =~ m/^ARRAY.*/ ) {
        @path_list = @{ $path_list[0] };
    }
    my @result_array;
    foreach my $path (@path_list) {
        my @result;
        open( my $FILE_HANDLE, '<:encoding(UTF-8)', "$path" )
            or croak "Could not open file '$path' $!";
        while ( my $line = <$FILE_HANDLE> ) {
            chomp $line;
            push @result, "$line";
        }
        push @result_array, ( join "\n", @result );
    }
    return join "\n", @result_array;
}    ##    read_files

sub write_file {
    my ( $filename, $buffer ) = @_;
    open( my $FILE_HANDLE, ">", $filename )
        or croak "Cannot open $filename : $!\n";
    print $FILE_HANDLE $buffer or croak "Cannot write $filename : $!\n";
    return 1;    ## success
}    ##    write_to_one_file

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
