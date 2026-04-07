# lumpers-vs-splitters
Complete processing from all avilable sequences to species hypotesis

Using a mPTP approach to identify species from soil and sporome sequences found in several databases. 
mPTP needs a rooted binary tree to start, so we first need to clean and align the sequences to call IQ3. IQ3 output is going to be used by mPTP. 

#### What is in here 

### Sequences cleaning
1. Script01 - Creates a list of IDs from a metadata table and extracts its fasta sequences from a database
2. Script02 - Concatenates different .fasta documents from a folder into a single .fasta
3. Script03 - Identify duplicated sequences in a .fasta and removes them
4. Script04 - Check if MAFFT and IQ3 are installed an wich version

### Prepare the alignment
1. Script05 - Call Mafft for alignment
2. Script06 - Call IQtree to create a ML tree based on the last alignment
