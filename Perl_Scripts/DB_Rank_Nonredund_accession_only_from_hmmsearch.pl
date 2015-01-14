use strict;

my $HMMsearch = $ARGV[0];

open(HMM, $HMMsearch) || die "Can't find HMMer output file, $HMMsearch $!";

my @Hit_IDs = ();

my $primary = 'gb';  ## GenBank accessions when available

my $rank = 0;  

  my %DB_hash = ();     ## helps select GenBank ID when RefSeq, 
                        ## EMBL, and/or DBJ refer to same sequence from same genome

  my %rank_hash = (); ## tracks rank of sequence among HMM search hits  
  
  my %GI_hash = ();

  my %source_hash = (); ## helps track redundant sequences from same genome
  
my $total_hits = 0;
  
while(<HMM>)
 {

  if($_ =~ />>/)
  {
      my $temp_line = $_;
      
      $rank++;
      
      $temp_line =~ s/\[4Fe-4S\]/FeS/g;
     
      my @line = split(/(\]|;)/, $temp_line);
     
    my $i = 0;
     
      foreach(@line)
       {   
        my @record = split(/\|/, $line[$i]);

        if($record[2] =~ /(gb|ref|emb|dbj|pdb|sp)/)
         {      
            $DB_hash{$record[3]} = $record[2];
            $rank_hash{$record[3]} = $rank; 
          #  print $record[3], ", ";       
         }

        my @strain_data = split(/\[\[?/, $line[$i]);
        my $species = '';

        if($strain_data[1] =~ /(^[A-Z]|^[0-9])/i)
	 {
           $species = $strain_data[1];
         }
        if($record[2] =~ /sp/)
 	 {
            $species = "Not Annotated";
         }
       
        $source_hash{$record[3]} = $species;

        $i++;
       }

    
     # print "\n";
     
  }
  
 }

 $total_hits = $rank;

my %Source_1_to_1 = (); ## use one accession to access gene in organism only once

## following line sorts accessions according to their rank in HMM hits:

my @rank_keys = sort { $rank_hash{$a} <=> $rank_hash{$b} } keys %rank_hash;

## parse hashes according to rank == r

for(my $r = 1; $r < $total_hits; $r++)
{
   my %strain_accession = ();
   my @accession = ();
   my @strain = ();
   my @DB = ();

   my $k = 0;

   my $found_gb = 0;
   
   ## inner loop iterates through list of sequences having $current_rank
   
   my @taxon = ();
   push @taxon, "?";
    
   my $non_specific_str = 0;

   foreach(@rank_keys)
    {

    # collect db|accession and species/strain    
    if($r == $rank_hash{$rank_keys[$k]})
      {       
          ## hash of hashes, %strain_accession = (
          ##                                $source_hash{$rank_keys[$k]} => {
          ##                                                           $DB_hash{$rank_keys[$k]} => 'accession'     
          ##                                                                }
          ##                                      )
          
          if($source_hash{$rank_keys[$k]} =~ /uncultured/)
	  {
            $source_hash{$rank_keys[$k]} = $source_hash{$rank_keys[$k]}."-".$non_specific_str;
            $non_specific_str++;
	  }
          
          $strain_accession{$source_hash{$rank_keys[$k]}}{$DB_hash{$rank_keys[$k]}} = $rank_keys[$k];
           
          push @strain, $source_hash{$rank_keys[$k]};

      }
     
      $k++;
    }

   my $a = 0;

   my $record_count = keys %strain_accession;

   foreach my $species (reverse sort keys %strain_accession)
    {
      ## Nested loop for debugging hash of hashes
        #  print $species, ": {\n";
        #   foreach my $db ( sort keys %{ $strain_accession{ $species } } )
        #      {
        #          print $db, " => ", $strain_accession{$species}{$db}, "\n";
        #      }
       #	print "}\n";

      #determine number of databases in which a gene occurs
	my $accession_count = keys %{ $strain_accession{ $species } };
            
      foreach my $db ( sort keys %{ $strain_accession{ $species } } )
        {
           if($db =~ /(^emb|^sp|^gb)/)
	   {
               @taxon = split(/\s+/, $species);
               # print " - ", $taxon[0];
                $found_gb = 1;
               # print $species, ", ", $strain_accession{$species}{$db}, "\t";
               print $strain_accession{$species}{$db}, "\n";
           }
          elsif(($db =~ /^ref/) && ($found_gb == 0) && ($strain_accession{$species}{$db} !~ /WP_/ ))
	  {
               @taxon = split(/\s+/, $species);
               # print " - ", $taxon[0];
               # $found_gb = 1;
               # print $species, ", ", $strain_accession{$species}{$db}, "\t";
               print $strain_accession{$species}{$db}, "\n";
          }
          elsif(($db =~ /^dbj/) && ($strain_accession{$species}{$db} !~ /WP_/ ) && ($accession_count == 1))
           { 
               @taxon = split(/\s+/, $species);
               # print " - ", $taxon[0];
               #  print $species, ", ", $strain_accession{$species}{$db}, "\t";
               print $strain_accession{$species}{$db}, "\n"; 
           }
          elsif(($db =~ /^ref/) && ($strain_accession{$species}{$db} =~ /WP_/ ) && ($record_count == 1))
	      {  
                 my $collision = 0;
                 my $ii = 0;
                 
	         my @line = split(/\s+/, $species);
                 
                if($taxon[0] ne $line[0])
	       	   {
                     # print $species, ", ", $strain_accession{$species}{$db}, "\t";
                     print $strain_accession{$species}{$db}, "\n"; 
                   }
              }
        }


    }



  
}

  print "\n";
 
exit;

