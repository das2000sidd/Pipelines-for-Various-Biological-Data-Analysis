
mkdir -p /mnt/nfs/$USER/jupyternotebooks/chip-seq/
cd /mnt/nfs/$USER/jupyternotebooks/chip-seq/
#ln -sf /mnt/nfs/data/chipseq/p53/*.fastq .
#ln -sf /mnt/nfs/data/chipseq/p53/ChIP_input_MCF7-chr19.bam .

ls

## -x is basename of the index for the reference genome
## -S File to write SAM alignments to
## gives how many reads aligned in total as well as ho wmany uniquely aligned and how many aligned more than once
bowtie2-align -x /mnt/nfs/data/resources/bowtie2/hg19 /mnt/nfs/data/chipseq/p53/ChIP_p53_chr19.fastq -S ChIP_p53.sam

head -500  ChIP_p53.sam | tail -5

## Ignored for compatibility with previous samtools versions. 
## -b for output in BAM forma
samtools view -S -b ChIP_p53.sam > ChIP_p53.bam

## sort - Sort alignments by leftmost coordinates
## -O format for final output
## -o output to file
samtools sort -O bam -o ChIP_p53.sorted.bam ChIP_p53.bam 

##Index a coordinate-sorted BAM or CRAM file for fast random access
samtools index ChIP_p53.sorted.bam 

ls

## Model based analysis for Chip-seq
macs2 -h

## peak calling
## -n is namestring of the experiment
## -g is genome size
##-q is fdr cutoff
## callpeak is for peak calling from alignment results
## -t is treatment file which could be sam or bam file
## -n is experiment name
## -g is effective genome size
## -q is minimum fdr cutoff for peak detection
macs2 callpeak -t /mnt/nfs/data/chipseq/p53/ChIP_p53.sorted.bam  --outdir macs2_p53 -n p53 -g 59128983 -q 0.001

## produces 8 different files
cd macs2_p53

macs2 callpeak

ls

## -g is general numeric sort
## -r is descending
## -k9 means key that is column 9 in this case
cat p53_peaks.narrowPeak | sort -k9 -g -r | head -5

pwd
wc -l /mnt/nfs/r0618335/jupyternotebooks/chip-seq/macs2_p53/p53_peaks.narrowPeak

cat p53_peaks.narrowPeak | wc -l

ls

cd macs2_p53


cat p53_peaks.narrowPeak | wc -l

##p53_peaks.xls has info about fold enrichment and -log 10 p value
