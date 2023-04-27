#-------------------------------------------------------------------------------#
# SAM.r
#
# This is the function script to run the assessment using the SAM infrastructure
#
#The structure of the assessment follows the guidelines for ICES TAF
#
# Directives: 
# input data - /bootstrap/ICES_data
# model configuration - /bootstrap/model
#-------------------------------------------------------------------------------#


#-------------------------------------------------------------------------------#
# Remove everything from memory to avoid conflicts
#-------------------------------------------------------------------------------#
rm(list=ls())


#-------------------------------------------------------------------------------#
# Set the working directory to location of the script. 
# (it requires a new rstudio version)
#-------------------------------------------------------------------------------#
setwd(dirname(rstudioapi::getSourceEditorContext()$path))



#-------------------------------------------------------------------------------#
#load some needed packages
#-------------------------------------------------------------------------------#
library(stockassessment)


#-------------------------------------------------------------------------------#
#load the data
#-------------------------------------------------------------------------------#
cn<-read.ices("bootstrap/ICES_data/caa.dat")
cw<-read.ices("bootstrap/ICES_data/cw.dat")
dw<-read.ices("bootstrap/ICES_data/dw.dat")
lf<-read.ices("bootstrap/ICES_data/lf.dat")
lf <- lf[,1:11]       #Fix of the dimension
lw<-read.ices("bootstrap/ICES_data/lw.dat")
mo<-read.ices("bootstrap/ICES_data/mo.dat")
mo <- mo[,1:11]       #Fix of the dimension
nm<-read.ices("bootstrap/ICES_data/nm.dat")
nm <- nm[,1:11]       #Fix of the dimension
pf<-read.ices("bootstrap/ICES_data/pf.dat")
pf <- nm
pf[pf!=0]<-0
pm<-read.ices("bootstrap/ICES_data/pm.dat")
pm <- pf
sw<-read.ices("bootstrap/ICES_data/sw.dat")
surveys<-read.ices("bootstrap/ICES_data/survey.dat")


#-------------------------------------------------------------------------------#
#load the variance data
#For future SAM runs, this information need to be on standardized format
#-------------------------------------------------------------------------------#
varC = as.matrix(read.table("bootstrap/ICES_data/varCAA.dat", sep = " "))
attributes(cn)$weight = 1/(varC**2)
varS1 = as.matrix(read.table("bootstrap/ICES_data/varSpawn.dat", sep = " "))
attributes(surveys[[1]])$weight = 1/(varS1**2)
varS2 = as.matrix(read.table("bootstrap/ICES_data/varBar.dat", sep = " "))
attributes(surveys[[2]])$weight = 1/(varS2**2)
varS3 = as.matrix(read.table("bootstrap/ICES_data/varMai.dat", sep = " "))
attributes(surveys[[3]])$weight = 1/(varS3**2)


#-------------------------------------------------------------------------------#
#Prepare the SAM data object
#-------------------------------------------------------------------------------#
dat<-setup.sam.data(surveys=surveys,
                    residual.fleet = cn,
                    prop.mature = mo,
                    stock.mean.weight = sw,
                    catch.mean.weight = cw,
                    dis.mean.weight = dw,
                    land.mean.weight = lw,
                    prop.f=pf,
                    prop.m = pm,
                    natural.mortality = nm,
                    land.frac = lf)



#-------------------------------------------------------------------------------#
#Load configuration and parameter 
#-------------------------------------------------------------------------------#
conf = loadConf(dat,"bootstrap/model/model.cfg")
par<-defpar(dat,conf)


#-------------------------------------------------------------------------------#
#Special handling to remove process noise
#-------------------------------------------------------------------------------#
par$logSdLogN = c(-0.35, -5)
map = list(logSdLogN = as.factor(c(0,NA)))


#Run assessment
fit <- stockassessment::sam.fit(dat,conf,par=par,map=map)



