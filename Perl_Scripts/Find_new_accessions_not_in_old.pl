use strict;

## Takes comma-delimited accession files with all accessions on one line as input

my $NewIDs = $ARGV[0];

open(NEW, $NewIDs) || die "Can't find comma-delim Accession output file, $NewIDs $!";

my @NewAcc = ();

while(<NEW>)
 {
    push @NewAcc, split(/,/, $_);
 }

close NEW;

my $OldIDs = $ARGV[1];

open(OLD, $OldIDs) || die "Can't find comma-delim Accession output file, $OldIDs $!";

my @OldAcc = ();

while(<OLD>)
 {
    push @OldAcc, split(/,/, $_);
 }

close OLD;


my @Novel_New = ();

my $i = 0;

foreach(@NewAcc)
{
    chomp $NewAcc[$i];
#    print $NewAcc[$i], "\n";
   
    my $j = 0;
    my $found = 0;  

  foreach(@OldAcc)
   {
      # print $OldAcc[$j];
      chomp $OldAcc[$j];
           
      if($OldAcc[$j] eq $NewAcc[$i])
        {
	  $found = 1;
        }
      $j++;
   } 
   
   if($found == 0)
    {
	push @Novel_New, $NewAcc[$i];
    }
   
    $i++; 
}

$i = 0;

 foreach(@Novel_New)
  {
      print $Novel_New[$i], ",";
      $i++;
  }

exit;
