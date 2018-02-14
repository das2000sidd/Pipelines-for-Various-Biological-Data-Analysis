library(gplots)
source("https://bioconductor.org/biocLite.R")
biocLite("DESeq2")
install.packages("htmlTable")
library(htmlTable) ## needed for deseq2
library(DESeq2)
data = read.table(file='GSE47042_RNA-Seq_raw.counts.txt',header = TRUE,sep='\t',row.names = 1)
##data = data[complete.cases(data),]
dim(data)
head(data)
##data = data[,1:5]
##rownames(data) = data$Gene_Symbol
##data$Gene_Symbol = NULL
deseq2.colData = data.frame(condition=factor(c(rep('Ctrl',2),rep('Nutlin',2))),type=factor(rep('single-read',4)))
rownames(deseq2.colData) = colnames(data)
deseq2.dds = DESeqDataSetFromMatrix(countData = data,colData = deseq2.colData,design = ~condition)
ls()
dim(deseq2.dds)
## analysis
deseq2.dds = DESeq(deseq2.dds)
deseq2.res = results(deseq2.dds)

deseq2.res = deseq2.res[order(rownames(deseq2.res)),]

head(deseq2.res,n=100)
write.table(deseq2.res,file='DESeq2_results_table.txt',sep='\t')
sig.results =deseq2.res[!is.na(deseq2.res$padj) & deseq2.res$padj <= 0.05 & deseq2.res$log2FoldChange >1, ]
dim(sig.results)
write.table(sig.results,file='DESeq2_sig_results_table.txt',sep='\t')
## scatter plot of log 2 fold change vs mean expression
plotMA(deseq2.dds,ylim=c(-4,4),main='DESeq2')
dev.copy(png,'deseq2_MAplot.png')
dev.off()
 ## differential expression
##ns1 = as.data.frame(data$NS1)
##write.table(ns1,file='NS1.count',quote = FALSE)
##ns2 = as.data.frame(data$NS2)
##write.table(ns2,file='NS2.count',quote = FALSE)
##s1 = as.data.frame(data$S1)
##write.table(s1,file='S1.count',quote = FALSE)
##s2 = as.data.frame(data$S2)
##write.table(s2,file='S2.count',quote = FALSE)
##sampleFiles = c('NS1.count','NS2.count','S1.count','S2.count')
##conditions = c('NS','NS','S','S')
##directory = 'C:/Users/Siddhartha Das/Desktop/ALL_NON_SYSTEM_FILES/COMPARATIVE AND REGULATORY GENOMICS/VeraVanNoort_Part/Screenshots For Exams'
##sampleTable = data.frame(sampleName=sampleFiles,fileName=sampleFiles,condition=conditions)
##dds = DESeqDataSetFromHTSeqCount(sampleTable = data,design = ~ condition,directory = directory)
