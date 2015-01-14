use strict;

my $Domain = $ARGV[0];

open(HMM, $Domain) || die "Can't find HMMer output file, $Domain $!";

my $cut = index($Domain, '.');

$Domain = "pfam13486";
#substr($Domain, 0, $cut);

my $acc = $ARGV[1];

## assume $accessions were parsed and written in the same order as HMMsearch rankings

open(ACC, $acc) || die "Can't find comma-delim accession file, $acc $!";

my @accessions = <ACC>;

## print $accessions[0];

my @IDs = ();

my $a = 0;

#foreach(@accessions)
# {
     @IDs = split(',', $accessions[0]);
#     $a++;
# }

# print $IDs[0], " ", $IDs[1], " ", $IDs[2], "\n";
 
while(<HMM>)
 {
  if($_ =~ /^>>/)
   {
      last;
   }
  elsif($_ =~ /^\s+[0-9].+gi.+/)
  {
    my @Hits = split(/gi(_|\|)/, $_);
    
    my @Bits = split(/\s+/, $Hits[0]);
    
   # print $Bits[1], "\t", $Bits[2], "\n";

    for(my $i = 1; $i < scalar @Hits; $i++)
     {
	 my $ii = 0;
         
         foreach(@IDs)
	  {
            ## accessions of sequences with a match will be modified
            if(($Hits[$i] =~ m/$IDs[$ii]/) && ($IDs[$ii] ne ''))
	      {   
                 # $Hits[$i] =~ s/\.\|\s/\t/g;
                 # $Hits[$i] =~ s/_[0-9]\s/\t/g;
                 # $Hits[$i] =~ s/\[/\t/g;
                 # my $temp_info = substr($Hits[$i], 0, length($Hits[$i]) - 2);

                  $IDs[$ii] = $IDs[$ii]."\t".$Bits[1]."\t".$Bits[2]."\tfound ".$Domain;
	      }
 	     $ii++;
	  }
         
      }  
   
  }
  
 }


## print all accessions, including those without matches

 my $p = 0;
 
 foreach(@IDs)
   {
      if($IDs[$p] =~ /\t/)
        {
         print $IDs[$p], "\n";
        }
      else
       {
	 print $IDs[$p], "\t-\t-\tnot found\n";
       }
     $p++;
   }


exit;
