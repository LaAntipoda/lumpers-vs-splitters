# lumpers-vs-splitters
Complete processing from all avilable sequences to species hypotesis

Using a mPTP approach to identify species from soil and sporome sequences found in several databases. 
mPTP needs a rooted binary tree to start, so we first need to clean and align the sequences to call IQ3. IQ3 output is going to be used by mPTP. 

#### What is in here 

### Sequences cleaning
1. Script01 - Creates a list of IDs from a metadata table and extracts its fasta sequences from a database
2. Script02 - Concatenates different .fasta documents from a folder into a single .fasta
3. Script03 - Identify duplicated sequences in a .fasta and removes them
4. Script04 - Searches for genes names in NCBI sequences IDs and split the fasta by gene name

### Prepare the alignment
1. Script05 - Validates Mafft existance and version
2. Script06 - Call Mafft for alignment
