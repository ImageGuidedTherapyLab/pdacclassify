#=======================================================================

# Rattle is Copyright (c) 2006-2021 Togaware Pty Ltd.
# It is free (as in libre) open source software.
# It is licensed under the GNU General Public License,
# Version 2. Rattle comes with ABSOLUTELY NO WARRANTY.
# Rattle was written by Graham Williams with contributions
# from others as acknowledged in 'library(help=rattle)'.
# Visit https://rattle.togaware.com/ for details.

#=======================================================================
# Rattle timestamp: 2022-07-07 16:39:10 x86_64-pc-linux-gnu 

# Rattle version 5.5.1 user 'fuentes'

# This log captures interactions with Rattle as an R script. 

# For repeatability, export this activity log to a 
# file, like 'model.R' using the Export button or 
# through the Tools menu. Th script can then serve as a 
# starting point for developing your own scripts. 
# After xporting to a file called 'model.R', for exmample, 
# you can type into a new R Console the command 
# "source('model.R')" and so repeat all actions. Generally, 
# you will want to edit the file to suit your own needs. 
# You can also edit this log in place to record additional 
# information before exporting the script. 
 
# Note that saving/loading projects retains this log.

# We begin most scripts by loading the required packages.
# Here are some initial packages to load and others will be
# identified as we proceed through the script. When writing
# our own scripts we often collect together the library
# commands at the beginning of the script here.

library(rattle)   # Access the weather dataset and utilities.
library(magrittr) # Utilise %>% and %<>% pipeline operators.

# This log generally records the process of building a model. 
# However, with very little effort the log can also be used 
# to score a new dataset. The logical variable 'building' 
# is used to toggle between generating transformations, 
# when building a model and using the transformations, 
# when scoring a dataset.

building <- TRUE
scoring  <- ! building

# A pre-defined value is used to reset the random seed 
# so that results are repeatable.

crv$seed <- 42 

#=======================================================================
# Rattle timestamp: 2022-07-07 16:39:46 x86_64-pc-linux-gnu 

# Load a dataset from file.

fname         <- "file:///rsrch3/ip/dtfuentes/github/pdacclassify/dicom/radiomicsgrowout.csv" 
crs$dataset <- read.csv(fname,
			na.strings=c(".", "NA", "", "?"),
			strip.white=TRUE, encoding="UTF-8")

#=======================================================================
# Rattle timestamp: 2022-07-07 16:39:47 x86_64-pc-linux-gnu 

# Action the user selections from the Data tab. 

# Build the train/validate/test datasets.

# nobs=30 train=21 validate=4 test=5

set.seed(crv$seed)

crs$nobs <- nrow(crs$dataset)

crs$train <- sample(crs$nobs, 0.7*crs$nobs)

crs$nobs %>%
  seq_len() %>%
  setdiff(crs$train) %>%
  sample(0.15*crs$nobs) ->
crs$validate

crs$nobs %>%
  seq_len() %>%
  setdiff(crs$train) %>%
  setdiff(crs$validate) ->
crs$test

# The following variable selections have been noted.

crs$input     <- c("id", "Image", "Mask", "truthid",
                   "diagnostics_Image.original_Hash",
                   "diagnostics_Image.original_Spacing",
                   "diagnostics_Image.original_Size",
                   "diagnostics_Image.original_Mean",
                   "diagnostics_Image.original_Minimum",
                   "diagnostics_Image.original_Maximum",
                   "diagnostics_Mask.original_Hash",
                   "diagnostics_Mask.original_Spacing",
                   "diagnostics_Mask.original_Size",
                   "diagnostics_Mask.original_BoundingBox",
                   "diagnostics_Mask.original_VoxelNum",
                   "diagnostics_Mask.original_VolumeNum",
                   "diagnostics_Mask.original_CenterOfMassIndex",
                   "diagnostics_Mask.original_CenterOfMass",
                   "original_shape_Elongation",
                   "original_shape_Flatness",
                   "original_shape_LeastAxisLength",
                   "original_shape_MajorAxisLength",
                   "original_shape_Maximum2DDiameterColumn",
                   "original_shape_Maximum2DDiameterRow",
                   "original_shape_Maximum2DDiameterSlice",
                   "original_shape_Maximum3DDiameter",
                   "original_shape_MeshVolume",
                   "original_shape_MinorAxisLength",
                   "original_shape_Sphericity",
                   "original_shape_SurfaceArea",
                   "original_shape_SurfaceVolumeRatio",
                   "original_shape_VoxelVolume",
                   "original_firstorder_10Percentile",
                   "original_firstorder_90Percentile",
                   "original_firstorder_Energy",
                   "original_firstorder_Entropy",
                   "original_firstorder_InterquartileRange",
                   "original_firstorder_Kurtosis",
                   "original_firstorder_Maximum",
                   "original_firstorder_MeanAbsoluteDeviation",
                   "original_firstorder_Mean",
                   "original_firstorder_Median",
                   "original_firstorder_Minimum",
                   "original_firstorder_Range",
                   "original_firstorder_RobustMeanAbsoluteDeviation",
                   "original_firstorder_RootMeanSquared",
                   "original_firstorder_Skewness",
                   "original_firstorder_TotalEnergy",
                   "original_firstorder_Uniformity",
                   "original_firstorder_Variance",
                   "original_glcm_Autocorrelation",
                   "original_glcm_ClusterProminence",
                   "original_glcm_ClusterShade",
                   "original_glcm_ClusterTendency",
                   "original_glcm_Contrast",
                   "original_glcm_Correlation",
                   "original_glcm_DifferenceAverage",
                   "original_glcm_DifferenceEntropy",
                   "original_glcm_DifferenceVariance",
                   "original_glcm_Id", "original_glcm_Idm",
                   "original_glcm_Idmn", "original_glcm_Idn",
                   "original_glcm_Imc1", "original_glcm_Imc2",
                   "original_glcm_InverseVariance",
                   "original_glcm_JointAverage",
                   "original_glcm_JointEnergy",
                   "original_glcm_JointEntropy", "original_glcm_MCC",
                   "original_glcm_MaximumProbability",
                   "original_glcm_SumAverage",
                   "original_glcm_SumEntropy",
                   "original_glcm_SumSquares",
                   "original_glrlm_GrayLevelNonUniformity",
                   "original_glrlm_GrayLevelNonUniformityNormalized",
                   "original_glrlm_GrayLevelVariance",
                   "original_glrlm_HighGrayLevelRunEmphasis",
                   "original_glrlm_LongRunEmphasis",
                   "original_glrlm_LongRunHighGrayLevelEmphasis",
                   "original_glrlm_LongRunLowGrayLevelEmphasis",
                   "original_glrlm_LowGrayLevelRunEmphasis",
                   "original_glrlm_RunEntropy",
                   "original_glrlm_RunLengthNonUniformity",
                   "original_glrlm_RunLengthNonUniformityNormalized",
                   "original_glrlm_RunPercentage",
                   "original_glrlm_RunVariance",
                   "original_glrlm_ShortRunEmphasis",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis",
                   "original_glszm_GrayLevelNonUniformity",
                   "original_glszm_GrayLevelNonUniformityNormalized",
                   "original_glszm_GrayLevelVariance",
                   "original_glszm_HighGrayLevelZoneEmphasis",
                   "original_glszm_LargeAreaEmphasis",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis",
                   "original_glszm_LowGrayLevelZoneEmphasis",
                   "original_glszm_SizeZoneNonUniformity",
                   "original_glszm_SizeZoneNonUniformityNormalized",
                   "original_glszm_SmallAreaEmphasis",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis",
                   "original_glszm_ZoneEntropy",
                   "original_glszm_ZonePercentage",
                   "original_glszm_ZoneVariance")

crs$numeric   <- c("id", "truthid",
                   "diagnostics_Image.original_Mean",
                   "diagnostics_Image.original_Minimum",
                   "diagnostics_Image.original_Maximum",
                   "diagnostics_Mask.original_VoxelNum",
                   "diagnostics_Mask.original_VolumeNum",
                   "original_shape_Elongation",
                   "original_shape_Flatness",
                   "original_shape_LeastAxisLength",
                   "original_shape_MajorAxisLength",
                   "original_shape_Maximum2DDiameterColumn",
                   "original_shape_Maximum2DDiameterRow",
                   "original_shape_Maximum2DDiameterSlice",
                   "original_shape_Maximum3DDiameter",
                   "original_shape_MeshVolume",
                   "original_shape_MinorAxisLength",
                   "original_shape_Sphericity",
                   "original_shape_SurfaceArea",
                   "original_shape_SurfaceVolumeRatio",
                   "original_shape_VoxelVolume",
                   "original_firstorder_10Percentile",
                   "original_firstorder_90Percentile",
                   "original_firstorder_Energy",
                   "original_firstorder_Entropy",
                   "original_firstorder_InterquartileRange",
                   "original_firstorder_Kurtosis",
                   "original_firstorder_Maximum",
                   "original_firstorder_MeanAbsoluteDeviation",
                   "original_firstorder_Mean",
                   "original_firstorder_Median",
                   "original_firstorder_Minimum",
                   "original_firstorder_Range",
                   "original_firstorder_RobustMeanAbsoluteDeviation",
                   "original_firstorder_RootMeanSquared",
                   "original_firstorder_Skewness",
                   "original_firstorder_TotalEnergy",
                   "original_firstorder_Uniformity",
                   "original_firstorder_Variance",
                   "original_glcm_Autocorrelation",
                   "original_glcm_ClusterProminence",
                   "original_glcm_ClusterShade",
                   "original_glcm_ClusterTendency",
                   "original_glcm_Contrast",
                   "original_glcm_Correlation",
                   "original_glcm_DifferenceAverage",
                   "original_glcm_DifferenceEntropy",
                   "original_glcm_DifferenceVariance",
                   "original_glcm_Id", "original_glcm_Idm",
                   "original_glcm_Idmn", "original_glcm_Idn",
                   "original_glcm_Imc1", "original_glcm_Imc2",
                   "original_glcm_InverseVariance",
                   "original_glcm_JointAverage",
                   "original_glcm_JointEnergy",
                   "original_glcm_JointEntropy", "original_glcm_MCC",
                   "original_glcm_MaximumProbability",
                   "original_glcm_SumAverage",
                   "original_glcm_SumEntropy",
                   "original_glcm_SumSquares",
                   "original_glrlm_GrayLevelNonUniformity",
                   "original_glrlm_GrayLevelNonUniformityNormalized",
                   "original_glrlm_GrayLevelVariance",
                   "original_glrlm_HighGrayLevelRunEmphasis",
                   "original_glrlm_LongRunEmphasis",
                   "original_glrlm_LongRunHighGrayLevelEmphasis",
                   "original_glrlm_LongRunLowGrayLevelEmphasis",
                   "original_glrlm_LowGrayLevelRunEmphasis",
                   "original_glrlm_RunEntropy",
                   "original_glrlm_RunLengthNonUniformity",
                   "original_glrlm_RunLengthNonUniformityNormalized",
                   "original_glrlm_RunPercentage",
                   "original_glrlm_RunVariance",
                   "original_glrlm_ShortRunEmphasis",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis",
                   "original_glszm_GrayLevelNonUniformity",
                   "original_glszm_GrayLevelNonUniformityNormalized",
                   "original_glszm_GrayLevelVariance",
                   "original_glszm_HighGrayLevelZoneEmphasis",
                   "original_glszm_LargeAreaEmphasis",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis",
                   "original_glszm_LowGrayLevelZoneEmphasis",
                   "original_glszm_SizeZoneNonUniformity",
                   "original_glszm_SizeZoneNonUniformityNormalized",
                   "original_glszm_SmallAreaEmphasis",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis",
                   "original_glszm_ZoneEntropy",
                   "original_glszm_ZonePercentage",
                   "original_glszm_ZoneVariance")

crs$categoric <- c("Image", "Mask",
                   "diagnostics_Image.original_Hash",
                   "diagnostics_Image.original_Spacing",
                   "diagnostics_Image.original_Size",
                   "diagnostics_Mask.original_Hash",
                   "diagnostics_Mask.original_Spacing",
                   "diagnostics_Mask.original_Size",
                   "diagnostics_Mask.original_BoundingBox",
                   "diagnostics_Mask.original_CenterOfMassIndex",
                   "diagnostics_Mask.original_CenterOfMass")

crs$target    <- "target"
crs$risk      <- NULL
crs$ident     <- NULL
crs$ignore    <- c("Label", "diagnostics_Versions_PyRadiomics", "diagnostics_Versions_Numpy", "diagnostics_Versions_SimpleITK", "diagnostics_Versions_PyWavelet", "diagnostics_Versions_Python", "diagnostics_Configuration_Settings", "diagnostics_Configuration_EnabledImageTypes", "diagnostics_Image.original_Dimensionality")
crs$weights   <- NULL

#=======================================================================
# Rattle timestamp: 2022-07-07 16:41:44 x86_64-pc-linux-gnu 

# Action the user selections from the Data tab. 

# Build the train/validate/test datasets.

# nobs=30 train=21 validate=4 test=5

set.seed(crv$seed)

crs$nobs <- nrow(crs$dataset)

crs$train <- sample(crs$nobs, 0.7*crs$nobs)

crs$nobs %>%
  seq_len() %>%
  setdiff(crs$train) %>%
  sample(0.15*crs$nobs) ->
crs$validate

crs$nobs %>%
  seq_len() %>%
  setdiff(crs$train) %>%
  setdiff(crs$validate) ->
crs$test

# The following variable selections have been noted.

crs$input     <- c("original_firstorder_10Percentile",
                   "original_firstorder_90Percentile",
                   "original_firstorder_Energy",
                   "original_firstorder_Entropy",
                   "original_firstorder_InterquartileRange",
                   "original_firstorder_Kurtosis",
                   "original_firstorder_Maximum",
                   "original_firstorder_MeanAbsoluteDeviation",
                   "original_firstorder_Mean",
                   "original_firstorder_Median",
                   "original_firstorder_Minimum",
                   "original_firstorder_Range",
                   "original_firstorder_RobustMeanAbsoluteDeviation",
                   "original_firstorder_RootMeanSquared",
                   "original_firstorder_Skewness",
                   "original_firstorder_TotalEnergy",
                   "original_firstorder_Uniformity",
                   "original_firstorder_Variance",
                   "original_glcm_Autocorrelation",
                   "original_glcm_ClusterProminence",
                   "original_glcm_ClusterShade",
                   "original_glcm_ClusterTendency",
                   "original_glcm_Contrast",
                   "original_glcm_Correlation",
                   "original_glcm_DifferenceAverage",
                   "original_glcm_DifferenceEntropy",
                   "original_glcm_DifferenceVariance",
                   "original_glcm_Id", "original_glcm_Idm",
                   "original_glcm_Idmn", "original_glcm_Idn",
                   "original_glcm_Imc1", "original_glcm_Imc2",
                   "original_glcm_InverseVariance",
                   "original_glcm_JointAverage",
                   "original_glcm_JointEnergy",
                   "original_glcm_JointEntropy", "original_glcm_MCC",
                   "original_glcm_MaximumProbability",
                   "original_glcm_SumAverage",
                   "original_glcm_SumEntropy",
                   "original_glcm_SumSquares",
                   "original_glrlm_GrayLevelNonUniformity",
                   "original_glrlm_GrayLevelNonUniformityNormalized",
                   "original_glrlm_GrayLevelVariance",
                   "original_glrlm_HighGrayLevelRunEmphasis",
                   "original_glrlm_LongRunEmphasis",
                   "original_glrlm_LongRunHighGrayLevelEmphasis",
                   "original_glrlm_LongRunLowGrayLevelEmphasis",
                   "original_glrlm_LowGrayLevelRunEmphasis",
                   "original_glrlm_RunEntropy",
                   "original_glrlm_RunLengthNonUniformity",
                   "original_glrlm_RunLengthNonUniformityNormalized",
                   "original_glrlm_RunPercentage",
                   "original_glrlm_RunVariance",
                   "original_glrlm_ShortRunEmphasis",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis",
                   "original_glszm_GrayLevelNonUniformity",
                   "original_glszm_GrayLevelNonUniformityNormalized",
                   "original_glszm_GrayLevelVariance",
                   "original_glszm_HighGrayLevelZoneEmphasis",
                   "original_glszm_LargeAreaEmphasis",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis",
                   "original_glszm_LowGrayLevelZoneEmphasis",
                   "original_glszm_SizeZoneNonUniformity",
                   "original_glszm_SizeZoneNonUniformityNormalized",
                   "original_glszm_SmallAreaEmphasis",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis",
                   "original_glszm_ZoneEntropy",
                   "original_glszm_ZonePercentage",
                   "original_glszm_ZoneVariance")

crs$numeric   <- c("original_firstorder_10Percentile",
                   "original_firstorder_90Percentile",
                   "original_firstorder_Energy",
                   "original_firstorder_Entropy",
                   "original_firstorder_InterquartileRange",
                   "original_firstorder_Kurtosis",
                   "original_firstorder_Maximum",
                   "original_firstorder_MeanAbsoluteDeviation",
                   "original_firstorder_Mean",
                   "original_firstorder_Median",
                   "original_firstorder_Minimum",
                   "original_firstorder_Range",
                   "original_firstorder_RobustMeanAbsoluteDeviation",
                   "original_firstorder_RootMeanSquared",
                   "original_firstorder_Skewness",
                   "original_firstorder_TotalEnergy",
                   "original_firstorder_Uniformity",
                   "original_firstorder_Variance",
                   "original_glcm_Autocorrelation",
                   "original_glcm_ClusterProminence",
                   "original_glcm_ClusterShade",
                   "original_glcm_ClusterTendency",
                   "original_glcm_Contrast",
                   "original_glcm_Correlation",
                   "original_glcm_DifferenceAverage",
                   "original_glcm_DifferenceEntropy",
                   "original_glcm_DifferenceVariance",
                   "original_glcm_Id", "original_glcm_Idm",
                   "original_glcm_Idmn", "original_glcm_Idn",
                   "original_glcm_Imc1", "original_glcm_Imc2",
                   "original_glcm_InverseVariance",
                   "original_glcm_JointAverage",
                   "original_glcm_JointEnergy",
                   "original_glcm_JointEntropy", "original_glcm_MCC",
                   "original_glcm_MaximumProbability",
                   "original_glcm_SumAverage",
                   "original_glcm_SumEntropy",
                   "original_glcm_SumSquares",
                   "original_glrlm_GrayLevelNonUniformity",
                   "original_glrlm_GrayLevelNonUniformityNormalized",
                   "original_glrlm_GrayLevelVariance",
                   "original_glrlm_HighGrayLevelRunEmphasis",
                   "original_glrlm_LongRunEmphasis",
                   "original_glrlm_LongRunHighGrayLevelEmphasis",
                   "original_glrlm_LongRunLowGrayLevelEmphasis",
                   "original_glrlm_LowGrayLevelRunEmphasis",
                   "original_glrlm_RunEntropy",
                   "original_glrlm_RunLengthNonUniformity",
                   "original_glrlm_RunLengthNonUniformityNormalized",
                   "original_glrlm_RunPercentage",
                   "original_glrlm_RunVariance",
                   "original_glrlm_ShortRunEmphasis",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis",
                   "original_glszm_GrayLevelNonUniformity",
                   "original_glszm_GrayLevelNonUniformityNormalized",
                   "original_glszm_GrayLevelVariance",
                   "original_glszm_HighGrayLevelZoneEmphasis",
                   "original_glszm_LargeAreaEmphasis",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis",
                   "original_glszm_LowGrayLevelZoneEmphasis",
                   "original_glszm_SizeZoneNonUniformity",
                   "original_glszm_SizeZoneNonUniformityNormalized",
                   "original_glszm_SmallAreaEmphasis",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis",
                   "original_glszm_ZoneEntropy",
                   "original_glszm_ZonePercentage",
                   "original_glszm_ZoneVariance")

crs$categoric <- NULL

crs$target    <- "target"
crs$risk      <- NULL
crs$ident     <- NULL
crs$ignore    <- c("id", "Image", "Mask", "Label", "truthid", "diagnostics_Versions_PyRadiomics", "diagnostics_Versions_Numpy", "diagnostics_Versions_SimpleITK", "diagnostics_Versions_PyWavelet", "diagnostics_Versions_Python", "diagnostics_Configuration_Settings", "diagnostics_Configuration_EnabledImageTypes", "diagnostics_Image.original_Hash", "diagnostics_Image.original_Dimensionality", "diagnostics_Image.original_Spacing", "diagnostics_Image.original_Size", "diagnostics_Image.original_Mean", "diagnostics_Image.original_Minimum", "diagnostics_Image.original_Maximum", "diagnostics_Mask.original_Hash", "diagnostics_Mask.original_Spacing", "diagnostics_Mask.original_Size", "diagnostics_Mask.original_BoundingBox", "diagnostics_Mask.original_VoxelNum", "diagnostics_Mask.original_VolumeNum", "diagnostics_Mask.original_CenterOfMassIndex", "diagnostics_Mask.original_CenterOfMass", "original_shape_Elongation", "original_shape_Flatness", "original_shape_LeastAxisLength", "original_shape_MajorAxisLength", "original_shape_Maximum2DDiameterColumn", "original_shape_Maximum2DDiameterRow", "original_shape_Maximum2DDiameterSlice", "original_shape_Maximum3DDiameter", "original_shape_MeshVolume", "original_shape_MinorAxisLength", "original_shape_Sphericity", "original_shape_SurfaceArea", "original_shape_SurfaceVolumeRatio", "original_shape_VoxelVolume")
crs$weights   <- NULL

#=======================================================================
# Rattle timestamp: 2022-07-07 16:41:50 x86_64-pc-linux-gnu 

# The 'Hmisc' package provides the 'contents' function.

library(Hmisc, quietly=TRUE)

# Obtain a summary of the dataset.

contents(crs$dataset[crs$train, c(crs$input, crs$risk, crs$target)])
summary(crs$dataset[crs$train, c(crs$input, crs$risk, crs$target)])

#=======================================================================
# Rattle timestamp: 2022-07-07 16:42:15 x86_64-pc-linux-gnu 

# Build a Random Forest model using the traditional approach.

set.seed(crv$seed)

crs$rf <- randomForest::randomForest(target ~ .,
  data=crs$dataset[crs$train, c(crs$input, crs$target)], 
  ntree=500,
  mtry=8,
  importance=TRUE,
  na.action=randomForest::na.roughfix,
  replace=FALSE)

# Generate textual output of the 'Random Forest' model.

crs$rf

# The `pROC' package implements various AUC functions.

# Calculate the Area Under the Curve (AUC).

pROC::roc(crs$rf$y, as.numeric(crs$rf$predicted))

# Calculate the AUC Confidence Interval.

pROC::ci.auc(crs$rf$y, as.numeric(crs$rf$predicted))

# List the importance of the variables.

rn <- round(randomForest::importance(crs$rf), 2)
rn[order(rn[,3], decreasing=TRUE),]

# Time taken: 0.21 secs

#=======================================================================
# Rattle timestamp: 2022-07-07 16:42:55 x86_64-pc-linux-gnu 

# Action the user selections from the Data tab. 

# Build the train/validate/test datasets.

# nobs=30 train=24 validate=0 test=6

set.seed(crv$seed)

crs$nobs <- nrow(crs$dataset)

crs$train <- sample(crs$nobs, 0.8*crs$nobs)
crs$validate <- NULL

crs$nobs %>%
  seq_len() %>%
  setdiff(crs$train) %>%
  setdiff(crs$validate) ->
crs$test

# The following variable selections have been noted.

crs$input     <- c("original_firstorder_10Percentile",
                   "original_firstorder_90Percentile",
                   "original_firstorder_Energy",
                   "original_firstorder_Entropy",
                   "original_firstorder_InterquartileRange",
                   "original_firstorder_Kurtosis",
                   "original_firstorder_Maximum",
                   "original_firstorder_MeanAbsoluteDeviation",
                   "original_firstorder_Mean",
                   "original_firstorder_Median",
                   "original_firstorder_Minimum",
                   "original_firstorder_Range",
                   "original_firstorder_RobustMeanAbsoluteDeviation",
                   "original_firstorder_RootMeanSquared",
                   "original_firstorder_Skewness",
                   "original_firstorder_TotalEnergy",
                   "original_firstorder_Uniformity",
                   "original_firstorder_Variance",
                   "original_glcm_Autocorrelation",
                   "original_glcm_ClusterProminence",
                   "original_glcm_ClusterShade",
                   "original_glcm_ClusterTendency",
                   "original_glcm_Contrast",
                   "original_glcm_Correlation",
                   "original_glcm_DifferenceAverage",
                   "original_glcm_DifferenceEntropy",
                   "original_glcm_DifferenceVariance",
                   "original_glcm_Id", "original_glcm_Idm",
                   "original_glcm_Idmn", "original_glcm_Idn",
                   "original_glcm_Imc1", "original_glcm_Imc2",
                   "original_glcm_InverseVariance",
                   "original_glcm_JointAverage",
                   "original_glcm_JointEnergy",
                   "original_glcm_JointEntropy", "original_glcm_MCC",
                   "original_glcm_MaximumProbability",
                   "original_glcm_SumAverage",
                   "original_glcm_SumEntropy",
                   "original_glcm_SumSquares",
                   "original_glrlm_GrayLevelNonUniformity",
                   "original_glrlm_GrayLevelNonUniformityNormalized",
                   "original_glrlm_GrayLevelVariance",
                   "original_glrlm_HighGrayLevelRunEmphasis",
                   "original_glrlm_LongRunEmphasis",
                   "original_glrlm_LongRunHighGrayLevelEmphasis",
                   "original_glrlm_LongRunLowGrayLevelEmphasis",
                   "original_glrlm_LowGrayLevelRunEmphasis",
                   "original_glrlm_RunEntropy",
                   "original_glrlm_RunLengthNonUniformity",
                   "original_glrlm_RunLengthNonUniformityNormalized",
                   "original_glrlm_RunPercentage",
                   "original_glrlm_RunVariance",
                   "original_glrlm_ShortRunEmphasis",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis",
                   "original_glszm_GrayLevelNonUniformity",
                   "original_glszm_GrayLevelNonUniformityNormalized",
                   "original_glszm_GrayLevelVariance",
                   "original_glszm_HighGrayLevelZoneEmphasis",
                   "original_glszm_LargeAreaEmphasis",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis",
                   "original_glszm_LowGrayLevelZoneEmphasis",
                   "original_glszm_SizeZoneNonUniformity",
                   "original_glszm_SizeZoneNonUniformityNormalized",
                   "original_glszm_SmallAreaEmphasis",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis",
                   "original_glszm_ZoneEntropy",
                   "original_glszm_ZonePercentage",
                   "original_glszm_ZoneVariance")

crs$numeric   <- c("original_firstorder_10Percentile",
                   "original_firstorder_90Percentile",
                   "original_firstorder_Energy",
                   "original_firstorder_Entropy",
                   "original_firstorder_InterquartileRange",
                   "original_firstorder_Kurtosis",
                   "original_firstorder_Maximum",
                   "original_firstorder_MeanAbsoluteDeviation",
                   "original_firstorder_Mean",
                   "original_firstorder_Median",
                   "original_firstorder_Minimum",
                   "original_firstorder_Range",
                   "original_firstorder_RobustMeanAbsoluteDeviation",
                   "original_firstorder_RootMeanSquared",
                   "original_firstorder_Skewness",
                   "original_firstorder_TotalEnergy",
                   "original_firstorder_Uniformity",
                   "original_firstorder_Variance",
                   "original_glcm_Autocorrelation",
                   "original_glcm_ClusterProminence",
                   "original_glcm_ClusterShade",
                   "original_glcm_ClusterTendency",
                   "original_glcm_Contrast",
                   "original_glcm_Correlation",
                   "original_glcm_DifferenceAverage",
                   "original_glcm_DifferenceEntropy",
                   "original_glcm_DifferenceVariance",
                   "original_glcm_Id", "original_glcm_Idm",
                   "original_glcm_Idmn", "original_glcm_Idn",
                   "original_glcm_Imc1", "original_glcm_Imc2",
                   "original_glcm_InverseVariance",
                   "original_glcm_JointAverage",
                   "original_glcm_JointEnergy",
                   "original_glcm_JointEntropy", "original_glcm_MCC",
                   "original_glcm_MaximumProbability",
                   "original_glcm_SumAverage",
                   "original_glcm_SumEntropy",
                   "original_glcm_SumSquares",
                   "original_glrlm_GrayLevelNonUniformity",
                   "original_glrlm_GrayLevelNonUniformityNormalized",
                   "original_glrlm_GrayLevelVariance",
                   "original_glrlm_HighGrayLevelRunEmphasis",
                   "original_glrlm_LongRunEmphasis",
                   "original_glrlm_LongRunHighGrayLevelEmphasis",
                   "original_glrlm_LongRunLowGrayLevelEmphasis",
                   "original_glrlm_LowGrayLevelRunEmphasis",
                   "original_glrlm_RunEntropy",
                   "original_glrlm_RunLengthNonUniformity",
                   "original_glrlm_RunLengthNonUniformityNormalized",
                   "original_glrlm_RunPercentage",
                   "original_glrlm_RunVariance",
                   "original_glrlm_ShortRunEmphasis",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis",
                   "original_glszm_GrayLevelNonUniformity",
                   "original_glszm_GrayLevelNonUniformityNormalized",
                   "original_glszm_GrayLevelVariance",
                   "original_glszm_HighGrayLevelZoneEmphasis",
                   "original_glszm_LargeAreaEmphasis",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis",
                   "original_glszm_LowGrayLevelZoneEmphasis",
                   "original_glszm_SizeZoneNonUniformity",
                   "original_glszm_SizeZoneNonUniformityNormalized",
                   "original_glszm_SmallAreaEmphasis",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis",
                   "original_glszm_ZoneEntropy",
                   "original_glszm_ZonePercentage",
                   "original_glszm_ZoneVariance")

crs$categoric <- NULL

crs$target    <- "target"
crs$risk      <- NULL
crs$ident     <- NULL
crs$ignore    <- c("id", "Image", "Mask", "Label", "truthid", "diagnostics_Versions_PyRadiomics", "diagnostics_Versions_Numpy", "diagnostics_Versions_SimpleITK", "diagnostics_Versions_PyWavelet", "diagnostics_Versions_Python", "diagnostics_Configuration_Settings", "diagnostics_Configuration_EnabledImageTypes", "diagnostics_Image.original_Hash", "diagnostics_Image.original_Dimensionality", "diagnostics_Image.original_Spacing", "diagnostics_Image.original_Size", "diagnostics_Image.original_Mean", "diagnostics_Image.original_Minimum", "diagnostics_Image.original_Maximum", "diagnostics_Mask.original_Hash", "diagnostics_Mask.original_Spacing", "diagnostics_Mask.original_Size", "diagnostics_Mask.original_BoundingBox", "diagnostics_Mask.original_VoxelNum", "diagnostics_Mask.original_VolumeNum", "diagnostics_Mask.original_CenterOfMassIndex", "diagnostics_Mask.original_CenterOfMass", "original_shape_Elongation", "original_shape_Flatness", "original_shape_LeastAxisLength", "original_shape_MajorAxisLength", "original_shape_Maximum2DDiameterColumn", "original_shape_Maximum2DDiameterRow", "original_shape_Maximum2DDiameterSlice", "original_shape_Maximum3DDiameter", "original_shape_MeshVolume", "original_shape_MinorAxisLength", "original_shape_Sphericity", "original_shape_SurfaceArea", "original_shape_SurfaceVolumeRatio", "original_shape_VoxelVolume")
crs$weights   <- NULL

#=======================================================================
# Rattle timestamp: 2022-07-07 16:42:58 x86_64-pc-linux-gnu 

# Decision Tree 

# The 'rpart' package provides the 'rpart' function.

library(rpart, quietly=TRUE)

# Reset the random number seed to obtain the same results each time.

set.seed(crv$seed)

# Build the Decision Tree model.

crs$rpart <- rpart(target ~ .,
    data=crs$dataset[crs$train, c(crs$input, crs$target)],
    method="class",
    parms=list(split="information"),
    control=rpart.control(usesurrogate=0, 
        maxsurrogate=0),
    model=TRUE)

# Generate a textual view of the Decision Tree model.

print(crs$rpart)
printcp(crs$rpart)
cat("\n")

# Time taken: 0.04 secs

#=======================================================================
# Rattle timestamp: 2022-07-07 16:43:04 x86_64-pc-linux-gnu 

# Build a Random Forest model using the traditional approach.

set.seed(crv$seed)

crs$rf <- randomForest::randomForest(target ~ .,
  data=crs$dataset[crs$train, c(crs$input, crs$target)], 
  ntree=500,
  mtry=8,
  importance=TRUE,
  na.action=randomForest::na.roughfix,
  replace=FALSE)

# Generate textual output of the 'Random Forest' model.

crs$rf

# The `pROC' package implements various AUC functions.

# Calculate the Area Under the Curve (AUC).

pROC::roc(crs$rf$y, as.numeric(crs$rf$predicted))

# Calculate the AUC Confidence Interval.

pROC::ci.auc(crs$rf$y, as.numeric(crs$rf$predicted))

# List the importance of the variables.

rn <- round(randomForest::importance(crs$rf), 2)
rn[order(rn[,3], decreasing=TRUE),]

# Time taken: 0.15 secs

#=======================================================================
# Rattle timestamp: 2022-07-07 16:43:27 x86_64-pc-linux-gnu 

# Evaluate model performance on the testing dataset. 

# Generate an Error Matrix for the Random Forest model.

# Obtain the response from the Random Forest model.

crs$pr <- predict(crs$rf, newdata=na.omit(crs$dataset[crs$test, c(crs$input, crs$target)]))

# Generate the confusion matrix showing counts.

rattle::errorMatrix(na.omit(crs$dataset[crs$test, c(crs$input, crs$target)])$target, crs$pr, count=TRUE)

# Generate the confusion matrix showing proportions.

(per <- rattle::errorMatrix(na.omit(crs$dataset[crs$test, c(crs$input, crs$target)])$target, crs$pr))

# Calculate the overall error percentage.

cat(100-sum(diag(per), na.rm=TRUE))

# Calculate the averaged class error percentage.

cat(mean(per[,"Error"], na.rm=TRUE))
