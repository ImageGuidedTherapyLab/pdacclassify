
# source('longwide.R')
library(tidyr)
olddata_long <- read.csv("dicom/radiomicsout.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")
colnames(olddata_long )
subold = subset(olddata_long , select = grepl("^original_|Label|id|target", names(olddata_long )))
#data_wide <- spread(olddata_long, Label,value=c('original_glszm_ZonePercentage','original_glszm_ZoneVariance'))
mycolumn = colnames(subold )

data_wide <- pivot_wider(subold ,names_from = Label, values_from = mycolumn[5:length(mycolumn)])

firstordermean1 = data_wide$original_firstorder_Mean_1
firstordermean1[is.na( firstordermean1 )] = 0
firstordermean1[sapply(firstordermean1 , is.null)] = 0
firstordermean2 = data_wide$original_firstorder_Mean_2
firstordermean2[is.na( firstordermean2 )] = 0
firstordermean2[sapply(firstordermean2 , is.null)] = 0
firstordermean3 = data_wide$original_firstorder_Mean_3
firstordermean3[is.na( firstordermean3 )] = 0
firstordermean3[sapply(firstordermean3 , is.null)] = 0
data_wide ['meandifftumornormal'] <- unlist(firstordermean2) - unlist(firstordermean1) 
data_wide ['meandiffdilate']      <- unlist(firstordermean2) - unlist(firstordermean3) 

widecolumn = colnames(data_wide )

write.csv(as.matrix(data_wide),'dicom/radiomicsoutwide.csv')
