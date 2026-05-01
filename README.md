# lumpers-vs-splitters
Complete processing from all avilable sequences extracted from several databases to species hypotesis infered by mPTP.

Using a mPTP approach to identify species from soil and sporome sequences found in several public databases. 
First of all, some of the sequences needs renaming and extraction from the source downloads, so the first steps are preparing the data. Then we gather the sequences together for the analysis and remove duplicated information (some sequences are exactly the same but each database assign a diferent code). After that, we need to make sure the required programs exist in the enviroment for the next steps to work. mPTP needs a rooted binary tree to start, so we first need to align the sequences to call IQ3. IQ3 output is going to be used by mPTP. mPTP outputs a .txt with the infromation abouth the species and a .tree with the topology and support values of the trees. Support values indicate the fraction of sampled delimitations in which a node was part of the speciation process, where values closest to 1 belongs to the between-species splitting process.

### Software requirements 
- MAFFT 7 
  https://mafft.cbrc.jp/alignment/software/source.html
- IQTree2
  https://iqtree.github.io/doc/Quickstart
- mPTP
  https://github.com/Pas-Kapli/mptp/wiki
- Bash

##### Imput organization

```
lumpers-vs-splitters
|
├── BDD
│   ├── Unite_database
|   │   ├── Unite_metadata.csv
│   |   └── Unite.fasta
│   └── NCBI_database
│       └── *.fasta
├── scripts
│   └── Script*.sh
├── Results
```

### Script description
#### Preparing the data
1. Script_01 - Creates a list of IDs from a metadata table and extracts its fasta sequences from a database
2. Script_02 - Concatenates different .fasta documents from a folder into a single .fasta
3. Script_03 - Identify duplicated sequences in a .fasta and removes them
4. Script_04 - Check if MAFFT and IQtree are installed an wich version

#### Proccess the data
1. Script_05 - Call Mafft for alignment
2. Script_06 - Call IQtree to create a ML tree based on the last alignment
3. Script_07 - Call mPTP for the species inference

### Expected output
```
Results
|
├── Concatenated
│   ├── duplicated
│   |   └── *_duplicated.fasta
│   ├── *_concatenated.fasta
│   └── *_unique.fasta
├── alignments
│   ├── *_partitions.nex
│   └──*_align.fasta
├── iqtree
│   └── *_tree.contree
└── mPTP
    ├── *.svg
    ├── *.tree
    └──*.txt

```
### For the chismosos
I am adding an R script to plot the mPTP tree with the PP and the Bootsrap values obtained from IQTree. You can also visualice the correlation between them.


### Additional info
This proyect was executed in a potatoe connected with an aaa battery
- Personal Laptop
- Linux Mint 21.1
- CPU: Intel Core i3-1005G1
    2 nucleous 4 threads
- RAM: 4GB



