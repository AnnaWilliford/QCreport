#https://confluence.broadinstitute.org/display/GDAC/Nozzle
#https://github.com/parklab/nozzle

require( Nozzle.R1 )

args<-commandArgs(TRUE)
myPath_fastq<-args[1]
myPath_out<-args[2]

newdir=paste0(myPath_out,"/FastqReports")
dir.create( newdir, showWarnings=FALSE );
file.copy("dna_3.png", paste0(newdir,"/dna_3.png"), overwrite=TRUE) 

########### create report elements ###########

report <- newCustomReport( "" );
myFiles<-newSection("Analyzed files");
dataOverview <- newSection( "Data overview" );
qualScores <- newSection("Distribution of quality scores");
qualScorePos<- newSection("Quality scores across read positions");
dupLevels<-newSection("Duplication levels");
references<-newSection("References");


########### prepare data to add to report elements ###########
#----  logo ------------
html1 <- newHtml("<img src='dna_3.png' alt='' width=100% height=250 >")
title <- newHtml( "<h1>Basic fastq report</h1>", style="color: #2E2E2E; text-align:left;font-family:courier" )
author <- newHtml( "<h3>Created by Anna Williford</h3>", style="color: #2E2E2E; text-align:left;font-family:courier" )

#---- input files -------
Myfiles_names <- list.files(path=myPath_fastq, pattern="*fastq.gz", full.names=TRUE, recursive=FALSE)
Myfiles_names<-basename(Myfiles_names)
Myfiles_names<-as.data.frame(Myfiles_names)
names(Myfiles_names)<-"Input files"
t2<-newTable( Myfiles_names);

#----- summary table -----------
summaryTable<-read.table(paste0(myPath_out,"/Summary.txt"), header=TRUE,quote = "")
t <- newTable( summaryTable, "Data summary", significantDigits = 4);

#----- figures -----------
qualFigures<- list.files(path=paste0(myPath_out,"/QualityFig"), pattern="*Quality.png", full.names=TRUE, recursive=FALSE)
qualPerPosFigures<-list.files(path=paste0(myPath_out,"/QualityPerPosFig"), pattern="*quality.png", full.names=TRUE, recursive=FALSE)
dupLevelsFigures<-list.files(path=paste0(myPath_out,"/DupLevelsFig"), pattern="*levels.png", full.names=TRUE, recursive=FALSE)


# --- References ---
ref_p1 <- newParagraph( "Tools used to create this report:" );

fastqc_cite <- newCitation( title="FastQC v0.11.7", url="https://www.bioinformatics.babraham.ac.uk/projects/fastqc/" ); 
fqtools_cite<- newCitation( authors="Alastair P.Droop", title="fqtools: An efficient software suite for modern FASTQ file manipulation", publication="Bioinformatics", issue="12", pages="1883-1884", year="2016", url="https://doi.org/10.1093/bioinformatics/btw088" );
Nozzle_cite <- newCitation( authors="Nils Gehlenborg", title="Nozzle: a report generation toolkit for data analysis pipelines", publication="Bioinformatics", issue="29", pages="1089-1091", year="2013", url="http://bioinformatics.oxfordjournals.org/content/29/8/1089" );

########## assemble report structure bottom-up ##############
myFiles<- addTo(myFiles, t2)
dataOverview <- addTo( dataOverview, t ); 

for (item in qualFigures){
  item<-paste0("../QualityFig/",basename(item))
  fig <- newFigure(item, paste0(basename(item),". Click on image to enlarge."))
  qualScores <- addTo(qualScores,fig);
}

for (item in qualPerPosFigures){
  item<-paste0("../QualityPerPosFig/",basename(item))
  fig <- newFigure(item, paste0(basename(item),". Click on image to enlarge."))
  qualScorePos <- addTo(qualScorePos,fig);
}

for (item in dupLevelsFigures){
  item<-paste0("../DupLevelsFig/",basename(item))
  fig <- newFigure(item, paste0(basename(item),". Click on image to enlarge."))
  dupLevels <- addTo(dupLevels,fig);
}

references<-addTo(references, ref_p1, fastqc_cite, fqtools_cite, Nozzle_cite )
report <- addTo( report, title, author, html1, myFiles, dataOverview, qualScores, qualScorePos, dupLevels,references);

############ render report to file #################

writeReport( report,filename=paste0(newdir,"/QCreport"))


