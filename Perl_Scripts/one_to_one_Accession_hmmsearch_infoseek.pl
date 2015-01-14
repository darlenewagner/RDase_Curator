use strict;

my $HMMsearch = $ARGV[0];

open(HMM, $HMMsearch) || die "Can't find HMMer output file, $HMMsearch $!";

my $accessions = $ARGV[1];

## assume $accessions were parsed and written in the same order as HMMsearch rankings

open(ACC, $accessions) || die "Can't find comma-delim accession IDs file, $accessions $!";

my @accessions = <ACC>;

## print $accessions[0];

my @IDs = ();

my $a = 0;

     @IDs = split(',', $accessions[0]);

my @HMMfile = <HMM>;

my %Score_Data = ();

foreach(@HMMfile)
 {
  if($HMMfile[$a] =~ /^>>/)
   {
      last;
   }
  elsif($HMMfile[$a] =~ /^\s+[0-9].+gi\|.+/)
  {
    my @Hits = split(/gi\|/, $HMMfile[$a]);
    
    my @Bits = split(/\s+/, $Hits[0]);
   
    my $i1 = 1;

    foreach(@Hits)
    {
	my @Accession = split(/\|/, $Hits[$i1]);

        my @Annot = split(/\[/, $Accession[3]);

      if($Accession[2] ne '')
       {        
          #print $Accession[2], ",";
	  $Annot[0] =~ s/^\s+//g;
          $Annot[1] = substr($Annot[1], 0, length($Annot[1]) - 1);
          $Annot[1] =~ s/\]//g;
	  $Score_Data{$Accession[2]} = $Bits[1]."\t".$Bits[2]."\t".$Accession[0]."|".$Accession[2]."\t".$Annot[0]."\t".$Annot[1];
       }

	$i1++;
    }
  }
    
    $a++;
 
} 
   
   ## print $Bits[1], "\t", $Bits[2], "\n";
   # for(my $i = 0; $i < scalar @Hits; $i++)
   #  {
   #	 my $ii = 0;
   #     foreach(@IDs)
   #	  {
   #         if(($Hits[$i] =~ m/$IDs[$ii]/) && ($IDs[$ii] ne ''))
   #       {   
   #              $Hits[$i] =~ s/\.[1-9]\|\s/\t/g;
   #              $Hits[$i] =~ s/_[0-9]\s/\t/g;
   #              $Hits[$i] =~ s/\[/\t/g;
   #              chomp $Hits[$i];
   #               my $temp_info = substr($Hits[$i], 0, length($Hits[$i]) - 1);
   #               $temp_info =~ s/\]//g;
   # 	  print $Bits[1], "\t", $Bits[2], "\t", $temp_info, "\n";
   #         }
   #	     $ii++;
   #	  }
   #   }  
   

    my $i2 = 0;
    
   foreach(@IDs)
   {
      # print $IDs[$i2], "\n";
       print $Score_Data{$IDs[$i2]}, "\n";
       $i2++;
   }


    print "\n";



exit;
