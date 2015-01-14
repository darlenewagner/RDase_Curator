use strict;
use LWP::Simple;

# Input: One-line list of protein accession IDs separated by comma from file
# Method: Required LWP::Perl and NCBI command 'fetch.cgi'
# Output: GenPept record

my $url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=';

## EXAMPLE: http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=AFM24124&rettype=fasta&retmode=text

my $IDs = $ARGV[0];

open(IDs, $IDs) || die "Can't find accession ID file, $IDs $!";

my $i = 0;

#my @GenPept = ();

foreach(<IDs>)
{
    my @accession = split(",", $_);
    
    my $id = 0;
    
    foreach(@accession)
    {
       my $GenPept = get $url.$accession[$id]."&rettype=fasta&retmode=text";
       # show_accession($GenPept);
       print $GenPept, "\n";
       $id++; 
    }
    
    $i++;

   if($i > 0)
   {
       last;
   }
}

sub show_accession {

    ## $GP should be in genpept or genbank format
 
    my $GP = shift(@_);

    my @line = split(/\n/, $GP);
    my @first_line = split(/\s+/,$line[0]);
    print $first_line[1], "\n";

}

