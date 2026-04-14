# lumpers-vs-splitters
Complete processing from all avilable sequences extracted from several databases to species hypotesis infered by mPTP.

Using a mPTP approach to identify species from soil and sporome sequences found in several public databases. 
First of all, some of the sequences needs renaming and extraction from the source downloads, so the first steps are preparing the data. Then we gather the sequences together for the analysis and remove duplicated information (some sequences are exactly the same but each database assign a diferent code). After that, we need to make sure the required programs exist in the enviroment for the next steps to work. mPTP needs a rooted binary tree to start, so we first need to align the sequences to call IQ3. IQ3 output is going to be used by mPTP. 

#### Software requirements 
- MAFFT 7 
  https://mafft.cbrc.jp/alignment/software/source.html
- IQTree2
  https://iqtree.github.io/doc/Quickstart
- mPTP
- Bash

#### What is in here

lumpers-vs-splitters
|
├── BDD
│   ├── Unite_database
|   │   ├── Unite_metadata.csv
│   |   └── Unite_*.fasta
│   └── NCBI_database
│       └── *.fasta
├── scripts
│   └── Script*.sh
├── Results



### Preparing the data
1. Script01 - Creates a list of IDs from a metadata table and extracts its fasta sequences from a database
2. Script02 - Concatenates different .fasta documents from a folder into a single .fasta
3. Script03 - Identify duplicated sequences in a .fasta and removes them
4. Script04 - Check if MAFFT and IQtree are installed an wich version

### Prepare the alignment
1. Script05 - Call Mafft for alignment
2. Script06 - Call IQtree to create a ML tree based on the last alignment


### Additional info
This proyect was executed in a potatoe connected with a aaa battery
- Personal Laptop
- Linux mint
- CPU:
- RAM:
