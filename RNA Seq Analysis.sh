
mkdir -p ~/data/RNAseq
cd ~/data/RNAseq
pwd

## creating a symbolic link via -sf
ln -sf /mnt/nfs/data/RNA-seq/GSE47042/*.fastq ~/data/RNAseq/
ls -l

## fastqc is sequence quality control analysis. -o means outdir which is current directory here
## to check the quality control report check the test_fastqc html file in a web browser
/usr/local/bin/FastQC/fastqc -o . test.fastq

ls -l

# You don't need to run this, but this is a trick to load genome into memory, 
# so if we all run STAR we can the genome will not be loaded X times and overload
# the server:
## --genomeLoad LoadAndExit : load genome in shared memory and exit kepping it in memory for future runs
## --genomeDir : path to where the genome file is present
STAR --genomeLoad LoadAndExit --genomeDir /mnt/nfs/mfiers/STAR/hg19_star_db 

## --readFilesIn : path to the files which contain input read one. MAPPING fastq TO GENOME
## STAR takes fastq and gives a SAM file
STAR --genomeDir /mnt/nfs/mfiers/STAR/hg19_star_db \
     --genomeLoad LoadAndKeep \
     --runThreadN 2 \
     --readFilesIn test.fastq \
     --outFileNamePrefix test.

ls -l test.*

## checking how the sam file looks like
head -40 test.Aligned.out.sam | grep '^@'

head -34 test.Aligned.out.sam | grep -v '^@'

## samfile needs to be converted to bam file for subsequent analysis and this is done by samtools
samtools sort -o test.bam test.Aligned.out.sam

ls -l test*[bs]am

## Index a coordinate-sorted BAM or CRAM file for fast random access
samtools index test.bam

## testing using regular expression if sam,bam,index file is created or not
ls -l test*[bs]a[mi]

ln -sf /mnt/nfs/data/RNA-seq/GSE47042/[NS]*.ba[mi] ~/data/RNAseq/

ls -l *.ba[mi]

## print alignment in SAM format
samtools view NS1.bam | head -3

##Retrieve and print stats in the index file corresponding to the input file. chromosome, nmapped unmapped
samtools idxstats test.bam


##Does a full pass through the input file to calculate and print statistics to stdout. overall statistics. not chromosome based.
samtools flagstat test.bam

## copying gtf fron source to current dir
ln -sf /mnt/nfs/data/RNA-seq/GSE47042/*.gtf ~/data/RNAseq/
ls -l *gtf

head -3 gencode.v19.nopseudo.plus.sort.chr21.gtf

## featureCounts is a highly efficient general-purpose read summarization program that counts mapped reads 
##for genomic features
## Takes as input SAM/BAM files and an annotation file including chromosomal coordinates of features. 
## outputs numbers of reads assigned to features 
## -Q is minimum mapping quality score
## gene_name was an actual attribute in the gtf file
## gene level read aggregation
featureCounts -Q 10 -g gene_name -a gencode.v19.nopseudo.plus.sort.chr21.gtf -o S1-chr21.counts S1-chr21.bam

ls -l *.counts*

ln -sf /mnt/nfs/data/RNA-seq/GSE47042/all.count* ~/data/RNAseq/
ls -l *count*

## counts per gene per sample
head -5 all.counts | column -t ## count results per gene
head -20 all.counts.summary | column -t ## results per sample

## counts by gene and then by sample
head all.counts

## the 6th columns has all the counts
cut -f-6 all.counts > all.genedata.tsv

head all.genedata.tsv

## grep -v is exclude
cut -f1,7- all.counts | grep -v '^#' > all.gene.counts

head all.gene.counts


## to pull out records of as particular gene 
grep BRCA2 all.gene.counts


### after running r script for significant genes use webgestalt or human mine
