
library(ggplot2)

args<-commandArgs(TRUE)
infile<-args[1]
outdir<-args[2]
file_base=args[3]


outfile_Q30=paste0(outdir,"/",file_base,"_Q30.txt")
outfile_QualScores=paste0(outdir,"/",file_base,"_Quality.png")


######################
#make a vector to Illumina 1.8+ Phred+33,  raw reads typically (0, 41)

Qscore<-c(0:41)

names1<-c("!",'"',"#","$","%","&","'","(",")","*","+",",","-",".","/")
names2<-as.character(c(0:9))
names3<-c(":",";","<","=",">","?","@")
names4<-LETTERS[1:10]
names(Qscore)<-c(names1,names2,names3,names4)


##########

##read data- distribution of qulity scores in fastq file (output of fqtools)

qualScores<-read.table(infile, quote = "",comment.char = "")
qualScores<-qualScores[c(1:42),]

#extract data with relevant encoding
newQualScores<-qualScores[qualScores$V1==names(Qscore),]

#newQualScores$V1 must be character, not factor!
newQualScores$V1<-as.character(newQualScores$V1)

#make new column with Q-scores 
newQualScores$V3<-Qscore[newQualScores$V1]

#change colnames
colnames(newQualScores)<-c("symbol", "countQ","Q_score")


####get Q30
totalBases<-sum(qualScores$V2)
Q30_df<-newQualScores[newQualScores$Q_score>=30, ]
PercentBasesWithQ30<-sum(Q30_df$countQ)/totalBases


# Start writing to an output file
sink(outfile_Q30)
cat(round(PercentBasesWithQ30,4)*100)
sink()

#####################
#make with ggplot
pdf(NULL)  
data_line<-data.frame(sx=30,sy=max(newQualScores$countQ/10^6)*0.2,ex=30,ey=max(newQualScores$countQ/10^6))
p<-ggplot(data=newQualScores, aes(x=Q_score, y=countQ/10^6)) +
  geom_bar(stat="identity", width=1, fill="#0386e7",colour = "black", size=0.1) +
  annotate("text", x = 24, y = max(newQualScores$countQ/10^6)*0.8, label = paste0(round(PercentBasesWithQ30,4)*100,"%>= Q30"),size=4)+
  xlab("Q score") +
  ylab("Total Bases (millions)") +
  geom_segment(data=data_line, mapping=aes(x=sx, y=sy, xend=ex, yend=ey), color="red")+
  theme_bw()
ggsave(outfile_QualScores,p)

