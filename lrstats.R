#Confusion matrices: https://github.com/EGates1/RadPath/blob/master/Code/GradePreds.R#L688
#For “plotting” the tables you can use the xtable package to automatically TeX format them as they print https://www.rdocumentation.org/packages/xtable/versions/1.8-4/topics/xtable
 
#ROC plots: https://github.com/EGates1/RadPath/blob/master/Code/GradePreds.R#L751
#PR plot: https://github.com/EGates1/RadPath/blob/master/Code/GradePreds.R#L761

graphics.off()

# source('lrstats.R')
fname <- "qastats/wide.csv" 
mydataset <- read.csv(fname, na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

# summary stats
print( 'unique patients' )
print( unique(mydataset$ptid) )
print( 'lesion summary' )
print( table(mydataset$truth))


# The `pROC' package implements various AUC functions.
# Calculate the Area Under the Curve (AUC).
myroca     = pROC::roc( response = mydataset$truth , predictor = mydataset$predict1  , curve=T   )
myrocb     = pROC::roc( response = mydataset$truth , predictor = mydataset$predict2  , curve=T   )
myrocc     = pROC::roc( response = mydataset$truth , predictor = mydataset$countlr1  / mydataset$compsize, curve=T   )
myrocart   = pROC::roc( response = mydataset$truth , predictor = mydataset$ART       , curve=T   )


png('myroca.png');     plot(myroca    ,main=sprintf("ROC curve NN a \nAUC=%0.3f", myroca$auc  )); dev.off()
png('myrocb.png');     plot(myrocb    ,main=sprintf("ROC curve NN b \nAUC=%0.3f", myrocb$auc  )); dev.off()
png('myrocc.png');     plot(myrocc    ,main=sprintf("ROC curve NN c \nAUC=%0.3f", myrocc$auc  )); dev.off()
png('myrocart.png');   plot(myrocart  ,main=sprintf("ROC curve ART  \nAUC=%0.3f", myrocart$auc)); dev.off()
