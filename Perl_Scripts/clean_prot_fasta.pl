use strict;

## removes newline from amino acid sequence data, 
## facilitates analysis of length and conserved motifs, 
## example: 

while(<STDIN>)
{
   $_ =~ s/\\//g;

  if($_ =~ /^(A|[C-Y])/)
   {
       chomp;
       print;
   }
 elsif($_ =~ /^>/)
   {
     print "\n";
     print $_;
   }
 elsif($_ =~ /^\s+$/)
   {
      chomp;
   }
  
   
}

print "\n";

exit;
