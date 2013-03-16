#!/usr/bin/perl

use warnings;
use strict;

use Image::Magick;

# emits bar codes for the Lego Code Pilot
# or the Lego Micro Scout

# based on information from
# http://www.elecbrick.com/lego/

# (c) 2013 by Matthias Wenzel
#          lego bei mazzoo de
#
#     licensed under GPLv3

my $start_bit = "1";
my $stop_bit  = "0111";

my $zero = "001";
my $one  = "011";

sub calc_crc($)
{
  my $n   = shift;
  my $crc = 7-(($n+($n>>2)+($n>>4))&7);
  return $crc;
}

sub int_to_bar($$)
{
  my $n      = shift;
  my $n_bits = shift;

  my $bar    = "";

  for ( 1..$n_bits )
  {
    if ( $n & 1 )
    {
      $bar = $one  . $bar;
    }else{
      $bar = $zero . $bar;
    }
    $n >>= 1;
  }
  return $bar;
}

sub write_barcode($$)
{
  my ($barcode, $code) = @_;

  my $image = Image::Magick->new(
      size  => '400x100',
      type  => 'Greyscale',
      depth => 16,
      );
  $image->Read('xc:white');

  for my $bar (0..34)
  {
    my @col;
    @col = [0,0,0];
    @col = [0xff,0xff,0xff] if ( substr($barcode, $bar, 1) == "0" );

    for my $x (25 + $bar * 10 .. 35 + $bar * 10)
    {
      for my $y (0..100)
      {
        $image->SetPixel(
            x => $x,
            y => $y,
            color => @col,
            );
      }
    }

  }
  $image->Write( filename => "code$code.png");
}

sub main()
{
  my $code = $ARGV[0];
  $code = 0 unless $code; # default : motor forward


  my $barcode;

  $barcode = $start_bit;
  $barcode .= int_to_bar(calc_crc($code), 3);
  $barcode .= int_to_bar($code, 7);
  $barcode .= $stop_bit;

  write_barcode($barcode, $code);
}

main();
0;
