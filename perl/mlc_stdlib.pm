# mlc_stdlib.pm
#   Description

package mlc_stdlib;

use feature ':5.16';

use strict;
use warnings;

our $VERSION = 0.001000;

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(
    match_test
    element_eq
);




################################################################
## FileOps

sub read_from_file {
    my ($path) = @_;
    my @result;
    open( my $fh, '<:encoding(UTF-8)', "$path" )
      or croak "Could not open file '$path' $!";
    while ( my $line = <$fh> ) {
        chomp $line;
        push @result, "$line";
    }
    return join "\n", @result;
}    ##    read_from_file

sub read_files {
    my (@files) = @_;
    my @result_array;
    foreach my $some_file (@files) {
        push @result_array, read_from_file($some_file);
    }
    return join "\n\n", @result_array;
}    ##    read_files

sub write_to_files {
    my ( $filename, $buffer ) = @_;

    sub write_to_one_file {
        my ( $filename, $buffer ) = @_;
        open( my $FILE_HANDLE, ">", $filename )
          or croak "Cannot open $filename : $!\n";
        print $FILE_HANDLE $buffer or croak "Cannot write $filename : $!\n";
        return 1;    ## success
    }    ##    write_to_one_file
    if ( ref($filename) =~ m/^ARRAY.*/ ) {
        foreach my $file_path ( @{$filename} ) {
            write_to_one_file( $file_path, $buffer );
        }
    }
    else {
        write_to_one_file( $filename, $buffer );
    }
    return 1;    ## success
}    ##    write_to_files


################################################################
## Test Functions

sub match_test {
    my ( $x, $y ) = @_;
    
    if( $x && $y)
    {return $x =~ m/$y/i;}
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
