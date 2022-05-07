#Confusion matrices: https://github.com/EGates1/RadPath/blob/master/Code/GradePreds.R#L688
#For “plotting” the tables you can use the xtable package to automatically TeX format them as they print https://www.rdocumentation.org/packages/xtable/versions/1.8-4/topics/xtable
 
#ROC plots: https://github.com/EGates1/RadPath/blob/master/Code/GradePreds.R#L751
#PR plot: https://github.com/EGates1/RadPath/blob/master/Code/GradePreds.R#L761

graphics.off()

# Rscript d2stats.R
# source('d2stats.R')

mydataset0 <- read.csv('preds_unet_pocket0.csv', na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")
mydataset1 <- read.csv('preds_unet_pocket.csv', na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

mydataset = rbind(mydataset0 ,mydataset1 )

# summary stats
print( 'unique patients' )
print( unique(mydataset$ptid) )
print( 'lesion summary' )
print( table(mydataset$truthid))


# The `pROC' package implements various AUC functions.
# Calculate the Area Under the Curve (AUC).
myroca     = pROC::roc( response = mydataset$truthid , predictor = mydataset$unet_pocket_0, curve=T   )


png('myrocd2.png');     plot(myroca    ,main=sprintf("ROC curve NN a \nAUC=%0.3f", myroca$auc  )); dev.off()
