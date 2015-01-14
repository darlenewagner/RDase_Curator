use strict;

my $csv = $ARGV[0];

open(CSV, $csv) || die "Can't find HMMer output file, $csv $!";

my $fasta = $ARGV[1];

open(FASTA, $fasta) || die "Can't find fasta protein file, $fasta $!";

my @proteins = <FASTA>;

my $first_line = 0;

my $Folder_name = 'Protein_Partition';

my @FileNames = ();

my @Accessions = ();

my %Hash_of_Hash = ();  ## Stores bitscores referenced by Accession and HMM name

my @RDase_full = ();
my @RDase_PFAM = ();
my @Acetogen = ();
my @QueG = ();

while(<CSV>)
  {
      my @line = ();
    
   ## Read first line of file to allocate a filename for each HMM
    if(($_ =~ /(GenBank|RDase)/) && ($first_line == 0))
      { 
     	@line = split(/,/, $_);
        
        my $l = 0;
     
        foreach(@line)
	 {
           if($l > 0)
	   {
	      #my $idx = index($line[$l], ' ', 2);
              
              push @FileNames, $line[$l];   
	   }
	   $l++;
         }
        $first_line = 1;
      }
   elsif($_ =~ /[0-9]/) ## read data rows starting in NCBI Accession IDs
      {
    ## Use Accessions as outer Hash key          
       @line = split(/,/, $_);
       push @Accessions, $line[0];

         my $l = 0;         

          foreach(@line)
  	   {
         
            if($l > 0)
	     {
		 # print $FileNames[$l - 1], "\t";
                 chomp $line[$l];
                 $Hash_of_Hash{$line[0]}{$FileNames[$l - 1]} = $line[$l];
	     }
	   $l++;
         }

      ### print "\n";
   
      }
  }

### Open output file handles

# for(my $i = 1; $i < scalar @FileNames; $i++)
#  {
#  }

## loops for determining sort order 
 my $aa = 0; 
 my %column = ();

 foreach(@Accessions)
{
    $column{$Accessions[$aa]} = ++$aa;
}

  my @ACC = ();
 
 foreach my $ID (sort { $column{$a} <=> $column{$b} } keys %Hash_of_Hash ) 
  { 
      push @ACC, $ID;
   
    my @TEMP = ();
    my @MOD = ();  
  
    for my $model ( keys %{$Hash_of_Hash{$ID}} )
     {
       # print $Hash_of_Hash{$ID}{$model}, "\t";
      push @MOD, $model;  
      push @TEMP, $Hash_of_Hash{$ID}{$model};
     } 
   
    my $max = $TEMP[0]; ## Priming read
    my $mod = $MOD[0];
  
    # $max1 =~ s/\s+//g;
 
  for(my $i = 0; $i + 1 < scalar @TEMP; $i++)
    {
        
     if($max < $TEMP[$i + 1])
       {
          $mod = $MOD[$i + 1];
          $max = $TEMP[$i + 1];
       }  
    }
     
###    print $ID, "\t", $mod, "\t", $max, "\n";

      my $p = 0;
      my $in_record = 0;

 if($mod eq 'RDase_Superfamily')
  {
      push @RDase_full, $ID;
  }
elsif($mod eq 'PFAM_dehalogenase')
 {
      push @RDase_PFAM, $ID;
 }
elsif($mod eq 'Acetogen_Methanogen_Fe-S')
 {
      push @Acetogen, $ID;
 }
elsif($mod eq 'QueG_Corrin_Fe-S')
 {
      push @QueG, $ID;
 }

      
#  foreach(@proteins)
#   {
#    if(($proteins[$p] =~ /^>/) && ($in_record == 0))
#     {
#      if($proteins[$p] =~ m/$ID/)
#         {
#          $in_record = 1;       
#         }

#      if($in_record == 1)
#        {
#          open(OUT, ">>", $Folder_name."/".$mod.".txt");
#          print OUT $proteins[$p], "\n";
#          close OUT;
#          $in_record = 0;
#        }
#      }
#    $p++;
#    }

  }
 
  
  my $p = 0;


  foreach(@proteins)
   {
    if($proteins[$p] =~ /^>/)
     {
       my @line = split(/\|/, $proteins[$p]);

      # print $line[3], "\n";       
       my $r = 0;
       
       foreach(@RDase_full)
       {
         chomp $RDase_full[$r];
 
         if($RDase_full[$r] eq $line[3])
           {
               open(OUT, ">>", $Folder_name."/RDase_retreived_by_main_HMM.txt");
	       print OUT $proteins[$p], $proteins[$p + 1];
               close OUT;
           }          
           $r++;  
        }

       $r = 0;

       foreach(@RDase_PFAM)
       {
         chomp $RDase_PFAM[$r];
 
         if($RDase_PFAM[$r] eq $line[3])
           {
               open(OUT, ">>", $Folder_name."/RDase_retreived_by_PFAM.txt");
	       print OUT $proteins[$p], $proteins[$p + 1];
               close OUT;
           }          
           $r++;  
        }
         

       $r = 0;

       foreach(@Acetogen)
       {
         chomp $Acetogen[$r];
 
         if($Acetogen[$r] eq $line[3])
           {
               open(OUT, ">>", $Folder_name."/Acetogen_Methanogen_related_FeS.txt");
	       print OUT $proteins[$p], $proteins[$p + 1];
               close OUT;
           }          
           $r++;  
        }


       $r = 0;

       foreach(@QueG)
       {
         chomp $QueG[$r];
 
         if($QueG[$r] eq $line[3])
           {
               open(OUT, ">>", $Folder_name."/QueG_related.txt");
	       print OUT $proteins[$p], $proteins[$p + 1];
               close OUT;
           }          
           $r++;  
        }
         
     } 
    $p++;
    
   }
 

 


  
exit;
