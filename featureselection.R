#=======================================================================
# source('featureselection.R')

# Rattle is Copyright (c) 2006-2021 Togaware Pty Ltd.
# It is free (as in libre) open source software.
# It is licensed under the GNU General Public License,
# Version 2. Rattle comes with ABSOLUTELY NO WARRANTY.
# Rattle was written by Graham Williams with contributions
# from others as acknowledged in 'library(help=rattle)'.
# Visit https://rattle.togaware.com/ for details.

#=======================================================================
# Rattle timestamp: 2022-10-13 14:28:57 x86_64-pc-linux-gnu 

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
options("width"=200)

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
# Rattle timestamp: 2022-10-13 14:29:19 x86_64-pc-linux-gnu 

# Load a dataset from file.

fname         <- "file:///rsrch3/ip/dtfuentes/github/pdacclassify/dicom/radiomicsoutwide.csv" 
crs$dataset <- read.csv(fname,
			na.strings=c(".", "NA", "", "?"),
			strip.white=TRUE, encoding="UTF-8")

#=======================================================================
# Rattle timestamp: 2022-10-13 14:29:20 x86_64-pc-linux-gnu 

# Action the user selections from the Data tab. 

# Build the train/validate/test datasets.

# nobs=87 train=61 validate=13 test=13

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

crs$input     <- c("X", "id", "truthid",
                   "original_shape_Elongation_1",
                   "original_shape_Elongation_2",
                   "original_shape_Elongation_3",
                   "original_shape_Flatness_1",
                   "original_shape_Flatness_2",
                   "original_shape_Flatness_3",
                   "original_shape_LeastAxisLength_1",
                   "original_shape_LeastAxisLength_2",
                   "original_shape_LeastAxisLength_3",
                   "original_shape_MajorAxisLength_1",
                   "original_shape_MajorAxisLength_2",
                   "original_shape_MajorAxisLength_3",
                   "original_shape_Maximum2DDiameterColumn_1",
                   "original_shape_Maximum2DDiameterColumn_2",
                   "original_shape_Maximum2DDiameterColumn_3",
                   "original_shape_Maximum2DDiameterRow_1",
                   "original_shape_Maximum2DDiameterRow_2",
                   "original_shape_Maximum2DDiameterRow_3",
                   "original_shape_Maximum2DDiameterSlice_1",
                   "original_shape_Maximum2DDiameterSlice_2",
                   "original_shape_Maximum2DDiameterSlice_3",
                   "original_shape_Maximum3DDiameter_1",
                   "original_shape_Maximum3DDiameter_2",
                   "original_shape_Maximum3DDiameter_3",
                   "original_shape_MeshVolume_1",
                   "original_shape_MeshVolume_2",
                   "original_shape_MeshVolume_3",
                   "original_shape_MinorAxisLength_1",
                   "original_shape_MinorAxisLength_2",
                   "original_shape_MinorAxisLength_3",
                   "original_shape_Sphericity_1",
                   "original_shape_Sphericity_2",
                   "original_shape_Sphericity_3",
                   "original_shape_SurfaceArea_1",
                   "original_shape_SurfaceArea_2",
                   "original_shape_SurfaceArea_3",
                   "original_shape_SurfaceVolumeRatio_1",
                   "original_shape_SurfaceVolumeRatio_2",
                   "original_shape_SurfaceVolumeRatio_3",
                   "original_shape_VoxelVolume_1",
                   "original_shape_VoxelVolume_2",
                   "original_shape_VoxelVolume_3",
                   "original_firstorder_10Percentile_1",
                   "original_firstorder_10Percentile_2",
                   "original_firstorder_10Percentile_3",
                   "original_firstorder_90Percentile_1",
                   "original_firstorder_90Percentile_2",
                   "original_firstorder_90Percentile_3",
                   "original_firstorder_Energy_1",
                   "original_firstorder_Energy_2",
                   "original_firstorder_Energy_3",
                   "original_firstorder_Entropy_1",
                   "original_firstorder_Entropy_2",
                   "original_firstorder_Entropy_3",
                   "original_firstorder_InterquartileRange_1",
                   "original_firstorder_InterquartileRange_2",
                   "original_firstorder_InterquartileRange_3",
                   "original_firstorder_Kurtosis_1",
                   "original_firstorder_Kurtosis_2",
                   "original_firstorder_Kurtosis_3",
                   "original_firstorder_Maximum_1",
                   "original_firstorder_Maximum_2",
                   "original_firstorder_Maximum_3",
                   "original_firstorder_MeanAbsoluteDeviation_1",
                   "original_firstorder_MeanAbsoluteDeviation_2",
                   "original_firstorder_MeanAbsoluteDeviation_3",
                   "original_firstorder_Mean_1",
                   "original_firstorder_Mean_2",
                   "original_firstorder_Mean_3",
                   "original_firstorder_Median_1",
                   "original_firstorder_Median_2",
                   "original_firstorder_Median_3",
                   "original_firstorder_Minimum_1",
                   "original_firstorder_Minimum_2",
                   "original_firstorder_Minimum_3",
                   "original_firstorder_Range_1",
                   "original_firstorder_Range_2",
                   "original_firstorder_Range_3",
                   "original_firstorder_RobustMeanAbsoluteDeviation_1",
                   "original_firstorder_RobustMeanAbsoluteDeviation_2",
                   "original_firstorder_RobustMeanAbsoluteDeviation_3",
                   "original_firstorder_RootMeanSquared_1",
                   "original_firstorder_RootMeanSquared_2",
                   "original_firstorder_RootMeanSquared_3",
                   "original_firstorder_Skewness_1",
                   "original_firstorder_Skewness_2",
                   "original_firstorder_Skewness_3",
                   "original_firstorder_TotalEnergy_1",
                   "original_firstorder_TotalEnergy_2",
                   "original_firstorder_TotalEnergy_3",
                   "original_firstorder_Uniformity_1",
                   "original_firstorder_Uniformity_2",
                   "original_firstorder_Uniformity_3",
                   "original_firstorder_Variance_1",
                   "original_firstorder_Variance_2",
                   "original_firstorder_Variance_3",
                   "original_glcm_Autocorrelation_1",
                   "original_glcm_Autocorrelation_2",
                   "original_glcm_Autocorrelation_3",
                   "original_glcm_ClusterProminence_1",
                   "original_glcm_ClusterProminence_2",
                   "original_glcm_ClusterProminence_3",
                   "original_glcm_ClusterShade_1",
                   "original_glcm_ClusterShade_2",
                   "original_glcm_ClusterShade_3",
                   "original_glcm_ClusterTendency_1",
                   "original_glcm_ClusterTendency_2",
                   "original_glcm_ClusterTendency_3",
                   "original_glcm_Contrast_1",
                   "original_glcm_Contrast_2",
                   "original_glcm_Contrast_3",
                   "original_glcm_Correlation_1",
                   "original_glcm_Correlation_2",
                   "original_glcm_Correlation_3",
                   "original_glcm_DifferenceAverage_1",
                   "original_glcm_DifferenceAverage_2",
                   "original_glcm_DifferenceAverage_3",
                   "original_glcm_DifferenceEntropy_1",
                   "original_glcm_DifferenceEntropy_2",
                   "original_glcm_DifferenceEntropy_3",
                   "original_glcm_DifferenceVariance_1",
                   "original_glcm_DifferenceVariance_2",
                   "original_glcm_DifferenceVariance_3",
                   "original_glcm_Id_1", "original_glcm_Id_2",
                   "original_glcm_Id_3", "original_glcm_Idm_1",
                   "original_glcm_Idm_2", "original_glcm_Idm_3",
                   "original_glcm_Idmn_1", "original_glcm_Idmn_2",
                   "original_glcm_Idmn_3", "original_glcm_Idn_1",
                   "original_glcm_Idn_2", "original_glcm_Idn_3",
                   "original_glcm_Imc1_1", "original_glcm_Imc1_2",
                   "original_glcm_Imc1_3", "original_glcm_Imc2_1",
                   "original_glcm_Imc2_2", "original_glcm_Imc2_3",
                   "original_glcm_InverseVariance_1",
                   "original_glcm_InverseVariance_2",
                   "original_glcm_InverseVariance_3",
                   "original_glcm_JointAverage_1",
                   "original_glcm_JointAverage_2",
                   "original_glcm_JointAverage_3",
                   "original_glcm_JointEnergy_1",
                   "original_glcm_JointEnergy_2",
                   "original_glcm_JointEnergy_3",
                   "original_glcm_JointEntropy_1",
                   "original_glcm_JointEntropy_2",
                   "original_glcm_JointEntropy_3",
                   "original_glcm_MCC_1", "original_glcm_MCC_2",
                   "original_glcm_MCC_3",
                   "original_glcm_MaximumProbability_1",
                   "original_glcm_MaximumProbability_2",
                   "original_glcm_MaximumProbability_3",
                   "original_glcm_SumAverage_1",
                   "original_glcm_SumAverage_2",
                   "original_glcm_SumAverage_3",
                   "original_glcm_SumEntropy_1",
                   "original_glcm_SumEntropy_2",
                   "original_glcm_SumEntropy_3",
                   "original_glcm_SumSquares_1",
                   "original_glcm_SumSquares_2",
                   "original_glcm_SumSquares_3",
                   "original_glrlm_GrayLevelNonUniformity_1",
                   "original_glrlm_GrayLevelNonUniformity_2",
                   "original_glrlm_GrayLevelNonUniformity_3",
                   "original_glrlm_GrayLevelNonUniformityNormalized_1",
                   "original_glrlm_GrayLevelNonUniformityNormalized_2",
                   "original_glrlm_GrayLevelNonUniformityNormalized_3",
                   "original_glrlm_GrayLevelVariance_1",
                   "original_glrlm_GrayLevelVariance_2",
                   "original_glrlm_GrayLevelVariance_3",
                   "original_glrlm_HighGrayLevelRunEmphasis_1",
                   "original_glrlm_HighGrayLevelRunEmphasis_2",
                   "original_glrlm_HighGrayLevelRunEmphasis_3",
                   "original_glrlm_LongRunEmphasis_1",
                   "original_glrlm_LongRunEmphasis_2",
                   "original_glrlm_LongRunEmphasis_3",
                   "original_glrlm_LongRunHighGrayLevelEmphasis_1",
                   "original_glrlm_LongRunHighGrayLevelEmphasis_2",
                   "original_glrlm_LongRunHighGrayLevelEmphasis_3",
                   "original_glrlm_LongRunLowGrayLevelEmphasis_1",
                   "original_glrlm_LongRunLowGrayLevelEmphasis_2",
                   "original_glrlm_LongRunLowGrayLevelEmphasis_3",
                   "original_glrlm_LowGrayLevelRunEmphasis_1",
                   "original_glrlm_LowGrayLevelRunEmphasis_2",
                   "original_glrlm_LowGrayLevelRunEmphasis_3",
                   "original_glrlm_RunEntropy_1",
                   "original_glrlm_RunEntropy_2",
                   "original_glrlm_RunEntropy_3",
                   "original_glrlm_RunLengthNonUniformity_1",
                   "original_glrlm_RunLengthNonUniformity_2",
                   "original_glrlm_RunLengthNonUniformity_3",
                   "original_glrlm_RunLengthNonUniformityNormalized_1",
                   "original_glrlm_RunLengthNonUniformityNormalized_2",
                   "original_glrlm_RunLengthNonUniformityNormalized_3",
                   "original_glrlm_RunPercentage_1",
                   "original_glrlm_RunPercentage_2",
                   "original_glrlm_RunPercentage_3",
                   "original_glrlm_RunVariance_1",
                   "original_glrlm_RunVariance_2",
                   "original_glrlm_RunVariance_3",
                   "original_glrlm_ShortRunEmphasis_1",
                   "original_glrlm_ShortRunEmphasis_2",
                   "original_glrlm_ShortRunEmphasis_3",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis_1",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis_2",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis_3",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis_1",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis_2",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis_3",
                   "original_glszm_GrayLevelNonUniformity_1",
                   "original_glszm_GrayLevelNonUniformity_2",
                   "original_glszm_GrayLevelNonUniformity_3",
                   "original_glszm_GrayLevelNonUniformityNormalized_1",
                   "original_glszm_GrayLevelNonUniformityNormalized_2",
                   "original_glszm_GrayLevelNonUniformityNormalized_3",
                   "original_glszm_GrayLevelVariance_1",
                   "original_glszm_GrayLevelVariance_2",
                   "original_glszm_GrayLevelVariance_3",
                   "original_glszm_HighGrayLevelZoneEmphasis_1",
                   "original_glszm_HighGrayLevelZoneEmphasis_2",
                   "original_glszm_HighGrayLevelZoneEmphasis_3",
                   "original_glszm_LargeAreaEmphasis_1",
                   "original_glszm_LargeAreaEmphasis_2",
                   "original_glszm_LargeAreaEmphasis_3",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis_1",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis_2",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis_3",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis_1",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis_2",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis_3",
                   "original_glszm_LowGrayLevelZoneEmphasis_1",
                   "original_glszm_LowGrayLevelZoneEmphasis_2",
                   "original_glszm_LowGrayLevelZoneEmphasis_3",
                   "original_glszm_SizeZoneNonUniformity_1",
                   "original_glszm_SizeZoneNonUniformity_2",
                   "original_glszm_SizeZoneNonUniformity_3",
                   "original_glszm_SizeZoneNonUniformityNormalized_1",
                   "original_glszm_SizeZoneNonUniformityNormalized_2",
                   "original_glszm_SizeZoneNonUniformityNormalized_3",
                   "original_glszm_SmallAreaEmphasis_1",
                   "original_glszm_SmallAreaEmphasis_2",
                   "original_glszm_SmallAreaEmphasis_3",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis_1",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis_2",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis_3",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis_1",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis_2",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis_3",
                   "original_glszm_ZoneEntropy_1",
                   "original_glszm_ZoneEntropy_2",
                   "original_glszm_ZoneEntropy_3",
                   "original_glszm_ZonePercentage_1",
                   "original_glszm_ZonePercentage_2",
                   "original_glszm_ZonePercentage_3",
                   "original_glszm_ZoneVariance_1",
                   "original_glszm_ZoneVariance_2",
                   "original_glszm_ZoneVariance_3",
                   "meandifftumornormal", "meandiffdilate")

crs$numeric   <- c("X", "id", "truthid",
                   "original_shape_Elongation_1",
                   "original_shape_Elongation_2",
                   "original_shape_Elongation_3",
                   "original_shape_Flatness_1",
                   "original_shape_Flatness_2",
                   "original_shape_Flatness_3",
                   "original_shape_LeastAxisLength_1",
                   "original_shape_LeastAxisLength_2",
                   "original_shape_LeastAxisLength_3",
                   "original_shape_MajorAxisLength_1",
                   "original_shape_MajorAxisLength_2",
                   "original_shape_MajorAxisLength_3",
                   "original_shape_Maximum2DDiameterColumn_1",
                   "original_shape_Maximum2DDiameterColumn_2",
                   "original_shape_Maximum2DDiameterColumn_3",
                   "original_shape_Maximum2DDiameterRow_1",
                   "original_shape_Maximum2DDiameterRow_2",
                   "original_shape_Maximum2DDiameterRow_3",
                   "original_shape_Maximum2DDiameterSlice_1",
                   "original_shape_Maximum2DDiameterSlice_2",
                   "original_shape_Maximum2DDiameterSlice_3",
                   "original_shape_Maximum3DDiameter_1",
                   "original_shape_Maximum3DDiameter_2",
                   "original_shape_Maximum3DDiameter_3",
                   "original_shape_MeshVolume_1",
                   "original_shape_MeshVolume_2",
                   "original_shape_MeshVolume_3",
                   "original_shape_MinorAxisLength_1",
                   "original_shape_MinorAxisLength_2",
                   "original_shape_MinorAxisLength_3",
                   "original_shape_Sphericity_1",
                   "original_shape_Sphericity_2",
                   "original_shape_Sphericity_3",
                   "original_shape_SurfaceArea_1",
                   "original_shape_SurfaceArea_2",
                   "original_shape_SurfaceArea_3",
                   "original_shape_SurfaceVolumeRatio_1",
                   "original_shape_SurfaceVolumeRatio_2",
                   "original_shape_SurfaceVolumeRatio_3",
                   "original_shape_VoxelVolume_1",
                   "original_shape_VoxelVolume_2",
                   "original_shape_VoxelVolume_3",
                   "original_firstorder_10Percentile_1",
                   "original_firstorder_10Percentile_2",
                   "original_firstorder_10Percentile_3",
                   "original_firstorder_90Percentile_1",
                   "original_firstorder_90Percentile_2",
                   "original_firstorder_90Percentile_3",
                   "original_firstorder_Energy_1",
                   "original_firstorder_Energy_2",
                   "original_firstorder_Energy_3",
                   "original_firstorder_Entropy_1",
                   "original_firstorder_Entropy_2",
                   "original_firstorder_Entropy_3",
                   "original_firstorder_InterquartileRange_1",
                   "original_firstorder_InterquartileRange_2",
                   "original_firstorder_InterquartileRange_3",
                   "original_firstorder_Kurtosis_1",
                   "original_firstorder_Kurtosis_2",
                   "original_firstorder_Kurtosis_3",
                   "original_firstorder_Maximum_1",
                   "original_firstorder_Maximum_2",
                   "original_firstorder_Maximum_3",
                   "original_firstorder_MeanAbsoluteDeviation_1",
                   "original_firstorder_MeanAbsoluteDeviation_2",
                   "original_firstorder_MeanAbsoluteDeviation_3",
                   "original_firstorder_Mean_1",
                   "original_firstorder_Mean_2",
                   "original_firstorder_Mean_3",
                   "original_firstorder_Median_1",
                   "original_firstorder_Median_2",
                   "original_firstorder_Median_3",
                   "original_firstorder_Minimum_1",
                   "original_firstorder_Minimum_2",
                   "original_firstorder_Minimum_3",
                   "original_firstorder_Range_1",
                   "original_firstorder_Range_2",
                   "original_firstorder_Range_3",
                   "original_firstorder_RobustMeanAbsoluteDeviation_1",
                   "original_firstorder_RobustMeanAbsoluteDeviation_2",
                   "original_firstorder_RobustMeanAbsoluteDeviation_3",
                   "original_firstorder_RootMeanSquared_1",
                   "original_firstorder_RootMeanSquared_2",
                   "original_firstorder_RootMeanSquared_3",
                   "original_firstorder_Skewness_1",
                   "original_firstorder_Skewness_2",
                   "original_firstorder_Skewness_3",
                   "original_firstorder_TotalEnergy_1",
                   "original_firstorder_TotalEnergy_2",
                   "original_firstorder_TotalEnergy_3",
                   "original_firstorder_Uniformity_1",
                   "original_firstorder_Uniformity_2",
                   "original_firstorder_Uniformity_3",
                   "original_firstorder_Variance_1",
                   "original_firstorder_Variance_2",
                   "original_firstorder_Variance_3",
                   "original_glcm_Autocorrelation_1",
                   "original_glcm_Autocorrelation_2",
                   "original_glcm_Autocorrelation_3",
                   "original_glcm_ClusterProminence_1",
                   "original_glcm_ClusterProminence_2",
                   "original_glcm_ClusterProminence_3",
                   "original_glcm_ClusterShade_1",
                   "original_glcm_ClusterShade_2",
                   "original_glcm_ClusterShade_3",
                   "original_glcm_ClusterTendency_1",
                   "original_glcm_ClusterTendency_2",
                   "original_glcm_ClusterTendency_3",
                   "original_glcm_Contrast_1",
                   "original_glcm_Contrast_2",
                   "original_glcm_Contrast_3",
                   "original_glcm_Correlation_1",
                   "original_glcm_Correlation_2",
                   "original_glcm_Correlation_3",
                   "original_glcm_DifferenceAverage_1",
                   "original_glcm_DifferenceAverage_2",
                   "original_glcm_DifferenceAverage_3",
                   "original_glcm_DifferenceEntropy_1",
                   "original_glcm_DifferenceEntropy_2",
                   "original_glcm_DifferenceEntropy_3",
                   "original_glcm_DifferenceVariance_1",
                   "original_glcm_DifferenceVariance_2",
                   "original_glcm_DifferenceVariance_3",
                   "original_glcm_Id_1", "original_glcm_Id_2",
                   "original_glcm_Id_3", "original_glcm_Idm_1",
                   "original_glcm_Idm_2", "original_glcm_Idm_3",
                   "original_glcm_Idmn_1", "original_glcm_Idmn_2",
                   "original_glcm_Idmn_3", "original_glcm_Idn_1",
                   "original_glcm_Idn_2", "original_glcm_Idn_3",
                   "original_glcm_Imc1_1", "original_glcm_Imc1_2",
                   "original_glcm_Imc1_3", "original_glcm_Imc2_1",
                   "original_glcm_Imc2_2", "original_glcm_Imc2_3",
                   "original_glcm_InverseVariance_1",
                   "original_glcm_InverseVariance_2",
                   "original_glcm_InverseVariance_3",
                   "original_glcm_JointAverage_1",
                   "original_glcm_JointAverage_2",
                   "original_glcm_JointAverage_3",
                   "original_glcm_JointEnergy_1",
                   "original_glcm_JointEnergy_2",
                   "original_glcm_JointEnergy_3",
                   "original_glcm_JointEntropy_1",
                   "original_glcm_JointEntropy_2",
                   "original_glcm_JointEntropy_3",
                   "original_glcm_MCC_1", "original_glcm_MCC_2",
                   "original_glcm_MCC_3",
                   "original_glcm_MaximumProbability_1",
                   "original_glcm_MaximumProbability_2",
                   "original_glcm_MaximumProbability_3",
                   "original_glcm_SumAverage_1",
                   "original_glcm_SumAverage_2",
                   "original_glcm_SumAverage_3",
                   "original_glcm_SumEntropy_1",
                   "original_glcm_SumEntropy_2",
                   "original_glcm_SumEntropy_3",
                   "original_glcm_SumSquares_1",
                   "original_glcm_SumSquares_2",
                   "original_glcm_SumSquares_3",
                   "original_glrlm_GrayLevelNonUniformity_1",
                   "original_glrlm_GrayLevelNonUniformity_2",
                   "original_glrlm_GrayLevelNonUniformity_3",
                   "original_glrlm_GrayLevelNonUniformityNormalized_1",
                   "original_glrlm_GrayLevelNonUniformityNormalized_2",
                   "original_glrlm_GrayLevelNonUniformityNormalized_3",
                   "original_glrlm_GrayLevelVariance_1",
                   "original_glrlm_GrayLevelVariance_2",
                   "original_glrlm_GrayLevelVariance_3",
                   "original_glrlm_HighGrayLevelRunEmphasis_1",
                   "original_glrlm_HighGrayLevelRunEmphasis_2",
                   "original_glrlm_HighGrayLevelRunEmphasis_3",
                   "original_glrlm_LongRunEmphasis_1",
                   "original_glrlm_LongRunEmphasis_2",
                   "original_glrlm_LongRunEmphasis_3",
                   "original_glrlm_LongRunHighGrayLevelEmphasis_1",
                   "original_glrlm_LongRunHighGrayLevelEmphasis_2",
                   "original_glrlm_LongRunHighGrayLevelEmphasis_3",
                   "original_glrlm_LongRunLowGrayLevelEmphasis_1",
                   "original_glrlm_LongRunLowGrayLevelEmphasis_2",
                   "original_glrlm_LongRunLowGrayLevelEmphasis_3",
                   "original_glrlm_LowGrayLevelRunEmphasis_1",
                   "original_glrlm_LowGrayLevelRunEmphasis_2",
                   "original_glrlm_LowGrayLevelRunEmphasis_3",
                   "original_glrlm_RunEntropy_1",
                   "original_glrlm_RunEntropy_2",
                   "original_glrlm_RunEntropy_3",
                   "original_glrlm_RunLengthNonUniformity_1",
                   "original_glrlm_RunLengthNonUniformity_2",
                   "original_glrlm_RunLengthNonUniformity_3",
                   "original_glrlm_RunLengthNonUniformityNormalized_1",
                   "original_glrlm_RunLengthNonUniformityNormalized_2",
                   "original_glrlm_RunLengthNonUniformityNormalized_3",
                   "original_glrlm_RunPercentage_1",
                   "original_glrlm_RunPercentage_2",
                   "original_glrlm_RunPercentage_3",
                   "original_glrlm_RunVariance_1",
                   "original_glrlm_RunVariance_2",
                   "original_glrlm_RunVariance_3",
                   "original_glrlm_ShortRunEmphasis_1",
                   "original_glrlm_ShortRunEmphasis_2",
                   "original_glrlm_ShortRunEmphasis_3",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis_1",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis_2",
                   "original_glrlm_ShortRunHighGrayLevelEmphasis_3",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis_1",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis_2",
                   "original_glrlm_ShortRunLowGrayLevelEmphasis_3",
                   "original_glszm_GrayLevelNonUniformity_1",
                   "original_glszm_GrayLevelNonUniformity_2",
                   "original_glszm_GrayLevelNonUniformity_3",
                   "original_glszm_GrayLevelNonUniformityNormalized_1",
                   "original_glszm_GrayLevelNonUniformityNormalized_2",
                   "original_glszm_GrayLevelNonUniformityNormalized_3",
                   "original_glszm_GrayLevelVariance_1",
                   "original_glszm_GrayLevelVariance_2",
                   "original_glszm_GrayLevelVariance_3",
                   "original_glszm_HighGrayLevelZoneEmphasis_1",
                   "original_glszm_HighGrayLevelZoneEmphasis_2",
                   "original_glszm_HighGrayLevelZoneEmphasis_3",
                   "original_glszm_LargeAreaEmphasis_1",
                   "original_glszm_LargeAreaEmphasis_2",
                   "original_glszm_LargeAreaEmphasis_3",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis_1",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis_2",
                   "original_glszm_LargeAreaHighGrayLevelEmphasis_3",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis_1",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis_2",
                   "original_glszm_LargeAreaLowGrayLevelEmphasis_3",
                   "original_glszm_LowGrayLevelZoneEmphasis_1",
                   "original_glszm_LowGrayLevelZoneEmphasis_2",
                   "original_glszm_LowGrayLevelZoneEmphasis_3",
                   "original_glszm_SizeZoneNonUniformity_1",
                   "original_glszm_SizeZoneNonUniformity_2",
                   "original_glszm_SizeZoneNonUniformity_3",
                   "original_glszm_SizeZoneNonUniformityNormalized_1",
                   "original_glszm_SizeZoneNonUniformityNormalized_2",
                   "original_glszm_SizeZoneNonUniformityNormalized_3",
                   "original_glszm_SmallAreaEmphasis_1",
                   "original_glszm_SmallAreaEmphasis_2",
                   "original_glszm_SmallAreaEmphasis_3",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis_1",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis_2",
                   "original_glszm_SmallAreaHighGrayLevelEmphasis_3",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis_1",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis_2",
                   "original_glszm_SmallAreaLowGrayLevelEmphasis_3",
                   "original_glszm_ZoneEntropy_1",
                   "original_glszm_ZoneEntropy_2",
                   "original_glszm_ZoneEntropy_3",
                   "original_glszm_ZonePercentage_1",
                   "original_glszm_ZonePercentage_2",
                   "original_glszm_ZonePercentage_3",
                   "original_glszm_ZoneVariance_1",
                   "original_glszm_ZoneVariance_2",
                   "original_glszm_ZoneVariance_3",
                   "meandifftumornormal", "meandiffdilate")

crs$categoric <- NULL

crs$target    <- "target"
crs$risk      <- NULL
crs$ident     <- NULL
crs$ignore    <- NULL
crs$weights   <- NULL

#=======================================================================
# Rattle timestamp: 2022-10-13 14:29:56 x86_64-pc-linux-gnu 

# Action the user selections from the Data tab. 

# Build the train/validate/test datasets.

# nobs=87 train=61 validate=13 test=13

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

crs$input     <- c("original_firstorder_Energy_1",
                   "original_firstorder_Energy_2",
                   "original_firstorder_Energy_3",
                   "original_firstorder_Median_1",
                   "original_firstorder_Median_2",
                   "original_firstorder_Median_3")

crs$numeric   <- c("original_firstorder_Energy_1",
                   "original_firstorder_Energy_2",
                   "original_firstorder_Energy_3",
                   "original_firstorder_Median_1",
                   "original_firstorder_Median_2",
                   "original_firstorder_Median_3")

crs$categoric <- NULL

crs$target    <- "target"
crs$risk      <- NULL
crs$ident     <- NULL
crs$ignore    <- c("X", "id", "truthid", "original_shape_Elongation_1", "original_shape_Elongation_2", "original_shape_Elongation_3", "original_shape_Flatness_1", "original_shape_Flatness_2", "original_shape_Flatness_3", "original_shape_LeastAxisLength_1", "original_shape_LeastAxisLength_2", "original_shape_LeastAxisLength_3", "original_shape_MajorAxisLength_1", "original_shape_MajorAxisLength_2", "original_shape_MajorAxisLength_3", "original_shape_Maximum2DDiameterColumn_1", "original_shape_Maximum2DDiameterColumn_2", "original_shape_Maximum2DDiameterColumn_3", "original_shape_Maximum2DDiameterRow_1", "original_shape_Maximum2DDiameterRow_2", "original_shape_Maximum2DDiameterRow_3", "original_shape_Maximum2DDiameterSlice_1", "original_shape_Maximum2DDiameterSlice_2", "original_shape_Maximum2DDiameterSlice_3", "original_shape_Maximum3DDiameter_1", "original_shape_Maximum3DDiameter_2", "original_shape_Maximum3DDiameter_3", "original_shape_MeshVolume_1", "original_shape_MeshVolume_2", "original_shape_MeshVolume_3", "original_shape_MinorAxisLength_1", "original_shape_MinorAxisLength_2", "original_shape_MinorAxisLength_3", "original_shape_Sphericity_1", "original_shape_Sphericity_2", "original_shape_Sphericity_3", "original_shape_SurfaceArea_1", "original_shape_SurfaceArea_2", "original_shape_SurfaceArea_3", "original_shape_SurfaceVolumeRatio_1", "original_shape_SurfaceVolumeRatio_2", "original_shape_SurfaceVolumeRatio_3", "original_shape_VoxelVolume_1", "original_shape_VoxelVolume_2", "original_shape_VoxelVolume_3", "original_firstorder_10Percentile_1", "original_firstorder_10Percentile_2", "original_firstorder_10Percentile_3", "original_firstorder_90Percentile_1", "original_firstorder_90Percentile_2", "original_firstorder_90Percentile_3", "original_firstorder_Entropy_1", "original_firstorder_Entropy_2", "original_firstorder_Entropy_3", "original_firstorder_InterquartileRange_1", "original_firstorder_InterquartileRange_2", "original_firstorder_InterquartileRange_3", "original_firstorder_Kurtosis_1", "original_firstorder_Kurtosis_2", "original_firstorder_Kurtosis_3", "original_firstorder_Maximum_1", "original_firstorder_Maximum_2", "original_firstorder_Maximum_3", "original_firstorder_MeanAbsoluteDeviation_1", "original_firstorder_MeanAbsoluteDeviation_2", "original_firstorder_MeanAbsoluteDeviation_3", "original_firstorder_Mean_1", "original_firstorder_Mean_2", "original_firstorder_Mean_3", "original_firstorder_Minimum_1", "original_firstorder_Minimum_2", "original_firstorder_Minimum_3", "original_firstorder_Range_1", "original_firstorder_Range_2", "original_firstorder_Range_3", "original_firstorder_RobustMeanAbsoluteDeviation_1", "original_firstorder_RobustMeanAbsoluteDeviation_2", "original_firstorder_RobustMeanAbsoluteDeviation_3", "original_firstorder_RootMeanSquared_1", "original_firstorder_RootMeanSquared_2", "original_firstorder_RootMeanSquared_3", "original_firstorder_Skewness_1", "original_firstorder_Skewness_2", "original_firstorder_Skewness_3", "original_firstorder_TotalEnergy_1", "original_firstorder_TotalEnergy_2", "original_firstorder_TotalEnergy_3", "original_firstorder_Uniformity_1", "original_firstorder_Uniformity_2", "original_firstorder_Uniformity_3", "original_firstorder_Variance_1", "original_firstorder_Variance_2", "original_firstorder_Variance_3", "original_glcm_Autocorrelation_1", "original_glcm_Autocorrelation_2", "original_glcm_Autocorrelation_3", "original_glcm_ClusterProminence_1", "original_glcm_ClusterProminence_2", "original_glcm_ClusterProminence_3", "original_glcm_ClusterShade_1", "original_glcm_ClusterShade_2", "original_glcm_ClusterShade_3", "original_glcm_ClusterTendency_1", "original_glcm_ClusterTendency_2", "original_glcm_ClusterTendency_3", "original_glcm_Contrast_1", "original_glcm_Contrast_2", "original_glcm_Contrast_3", "original_glcm_Correlation_1", "original_glcm_Correlation_2", "original_glcm_Correlation_3", "original_glcm_DifferenceAverage_1", "original_glcm_DifferenceAverage_2", "original_glcm_DifferenceAverage_3", "original_glcm_DifferenceEntropy_1", "original_glcm_DifferenceEntropy_2", "original_glcm_DifferenceEntropy_3", "original_glcm_DifferenceVariance_1", "original_glcm_DifferenceVariance_2", "original_glcm_DifferenceVariance_3", "original_glcm_Id_1", "original_glcm_Id_2", "original_glcm_Id_3", "original_glcm_Idm_1", "original_glcm_Idm_2", "original_glcm_Idm_3", "original_glcm_Idmn_1", "original_glcm_Idmn_2", "original_glcm_Idmn_3", "original_glcm_Idn_1", "original_glcm_Idn_2", "original_glcm_Idn_3", "original_glcm_Imc1_1", "original_glcm_Imc1_2", "original_glcm_Imc1_3", "original_glcm_Imc2_1", "original_glcm_Imc2_2", "original_glcm_Imc2_3", "original_glcm_InverseVariance_1", "original_glcm_InverseVariance_2", "original_glcm_InverseVariance_3", "original_glcm_JointAverage_1", "original_glcm_JointAverage_2", "original_glcm_JointAverage_3", "original_glcm_JointEnergy_1", "original_glcm_JointEnergy_2", "original_glcm_JointEnergy_3", "original_glcm_JointEntropy_1", "original_glcm_JointEntropy_2", "original_glcm_JointEntropy_3", "original_glcm_MCC_1", "original_glcm_MCC_2", "original_glcm_MCC_3", "original_glcm_MaximumProbability_1", "original_glcm_MaximumProbability_2", "original_glcm_MaximumProbability_3", "original_glcm_SumAverage_1", "original_glcm_SumAverage_2", "original_glcm_SumAverage_3", "original_glcm_SumEntropy_1", "original_glcm_SumEntropy_2", "original_glcm_SumEntropy_3", "original_glcm_SumSquares_1", "original_glcm_SumSquares_2", "original_glcm_SumSquares_3", "original_glrlm_GrayLevelNonUniformity_1", "original_glrlm_GrayLevelNonUniformity_2", "original_glrlm_GrayLevelNonUniformity_3", "original_glrlm_GrayLevelNonUniformityNormalized_1", "original_glrlm_GrayLevelNonUniformityNormalized_2", "original_glrlm_GrayLevelNonUniformityNormalized_3", "original_glrlm_GrayLevelVariance_1", "original_glrlm_GrayLevelVariance_2", "original_glrlm_GrayLevelVariance_3", "original_glrlm_HighGrayLevelRunEmphasis_1", "original_glrlm_HighGrayLevelRunEmphasis_2", "original_glrlm_HighGrayLevelRunEmphasis_3", "original_glrlm_LongRunEmphasis_1", "original_glrlm_LongRunEmphasis_2", "original_glrlm_LongRunEmphasis_3", "original_glrlm_LongRunHighGrayLevelEmphasis_1", "original_glrlm_LongRunHighGrayLevelEmphasis_2", "original_glrlm_LongRunHighGrayLevelEmphasis_3", "original_glrlm_LongRunLowGrayLevelEmphasis_1", "original_glrlm_LongRunLowGrayLevelEmphasis_2", "original_glrlm_LongRunLowGrayLevelEmphasis_3", "original_glrlm_LowGrayLevelRunEmphasis_1", "original_glrlm_LowGrayLevelRunEmphasis_2", "original_glrlm_LowGrayLevelRunEmphasis_3", "original_glrlm_RunEntropy_1", "original_glrlm_RunEntropy_2", "original_glrlm_RunEntropy_3", "original_glrlm_RunLengthNonUniformity_1", "original_glrlm_RunLengthNonUniformity_2", "original_glrlm_RunLengthNonUniformity_3", "original_glrlm_RunLengthNonUniformityNormalized_1", "original_glrlm_RunLengthNonUniformityNormalized_2", "original_glrlm_RunLengthNonUniformityNormalized_3", "original_glrlm_RunPercentage_1", "original_glrlm_RunPercentage_2", "original_glrlm_RunPercentage_3", "original_glrlm_RunVariance_1", "original_glrlm_RunVariance_2", "original_glrlm_RunVariance_3", "original_glrlm_ShortRunEmphasis_1", "original_glrlm_ShortRunEmphasis_2", "original_glrlm_ShortRunEmphasis_3", "original_glrlm_ShortRunHighGrayLevelEmphasis_1", "original_glrlm_ShortRunHighGrayLevelEmphasis_2", "original_glrlm_ShortRunHighGrayLevelEmphasis_3", "original_glrlm_ShortRunLowGrayLevelEmphasis_1", "original_glrlm_ShortRunLowGrayLevelEmphasis_2", "original_glrlm_ShortRunLowGrayLevelEmphasis_3", "original_glszm_GrayLevelNonUniformity_1", "original_glszm_GrayLevelNonUniformity_2", "original_glszm_GrayLevelNonUniformity_3", "original_glszm_GrayLevelNonUniformityNormalized_1", "original_glszm_GrayLevelNonUniformityNormalized_2", "original_glszm_GrayLevelNonUniformityNormalized_3", "original_glszm_GrayLevelVariance_1", "original_glszm_GrayLevelVariance_2", "original_glszm_GrayLevelVariance_3", "original_glszm_HighGrayLevelZoneEmphasis_1", "original_glszm_HighGrayLevelZoneEmphasis_2", "original_glszm_HighGrayLevelZoneEmphasis_3", "original_glszm_LargeAreaEmphasis_1", "original_glszm_LargeAreaEmphasis_2", "original_glszm_LargeAreaEmphasis_3", "original_glszm_LargeAreaHighGrayLevelEmphasis_1", "original_glszm_LargeAreaHighGrayLevelEmphasis_2", "original_glszm_LargeAreaHighGrayLevelEmphasis_3", "original_glszm_LargeAreaLowGrayLevelEmphasis_1", "original_glszm_LargeAreaLowGrayLevelEmphasis_2", "original_glszm_LargeAreaLowGrayLevelEmphasis_3", "original_glszm_LowGrayLevelZoneEmphasis_1", "original_glszm_LowGrayLevelZoneEmphasis_2", "original_glszm_LowGrayLevelZoneEmphasis_3", "original_glszm_SizeZoneNonUniformity_1", "original_glszm_SizeZoneNonUniformity_2", "original_glszm_SizeZoneNonUniformity_3", "original_glszm_SizeZoneNonUniformityNormalized_1", "original_glszm_SizeZoneNonUniformityNormalized_2", "original_glszm_SizeZoneNonUniformityNormalized_3", "original_glszm_SmallAreaEmphasis_1", "original_glszm_SmallAreaEmphasis_2", "original_glszm_SmallAreaEmphasis_3", "original_glszm_SmallAreaHighGrayLevelEmphasis_1", "original_glszm_SmallAreaHighGrayLevelEmphasis_2", "original_glszm_SmallAreaHighGrayLevelEmphasis_3", "original_glszm_SmallAreaLowGrayLevelEmphasis_1", "original_glszm_SmallAreaLowGrayLevelEmphasis_2", "original_glszm_SmallAreaLowGrayLevelEmphasis_3", "original_glszm_ZoneEntropy_1", "original_glszm_ZoneEntropy_2", "original_glszm_ZoneEntropy_3", "original_glszm_ZonePercentage_1", "original_glszm_ZonePercentage_2", "original_glszm_ZonePercentage_3", "original_glszm_ZoneVariance_1", "original_glszm_ZoneVariance_2", "original_glszm_ZoneVariance_3", "meandifftumornormal", "meandiffdilate")
crs$weights   <- NULL

#=======================================================================
# Rattle timestamp: 2022-10-13 14:30:22 x86_64-pc-linux-gnu 

# Perform Test 

# Use the fBasics package for statistical tests.

library(fBasics, quietly=TRUE)

# Perform the test.

wilcox.test(na.omit(crs$dataset[crs$dataset[["target"]] == "High", "original_firstorder_Energy_1"]), na.omit(crs$dataset[crs$dataset[["target"]] == "Low", "original_firstorder_Energy_1"]))

#=======================================================================
# Rattle timestamp: 2022-10-13 14:31:02 x86_64-pc-linux-gnu 

# Regression model 

# Build a Regression model.

crs$glm <- glm(target ~ .,
    data=crs$dataset[crs$train, c(crs$input, crs$target)],
    family=binomial(link="logit"))

# Generate a textual view of the Linear model.

print(summary(crs$glm))

cat(sprintf("Log likelihood: %.3f (%d df)\n",
            logLik(crs$glm)[1],
            attr(logLik(crs$glm), "df")))

cat(sprintf("Null/Residual deviance difference: %.3f (%d df)\n",
            crs$glm$null.deviance-crs$glm$deviance,
            crs$glm$df.null-crs$glm$df.residual))

cat(sprintf("Chi-square p-value: %.8f\n",
            dchisq(crs$glm$null.deviance-crs$glm$deviance,
                   crs$glm$df.null-crs$glm$df.residual)))

cat(sprintf("Pseudo R-Square (optimistic): %.8f\n",
             cor(crs$glm$y, crs$glm$fitted.values)))

cat('\n==== ANOVA ====\n\n')
print(anova(crs$glm, test="Chisq"))
cat("\n")

# Time taken: 0.02 secs

#=======================================================================
# https://glmnet.stanford.edu/articles/glmnet.html#linear-regression-family-gaussian-default-
library(glmnet)
mydat = na.omit(crs$dataset[crs$train, c(crs$input, crs$target)])
glmnetfit <- cv.glmnet(as.matrix(mydat[1:6]) , as.numeric(unlist(mydat[7])), alpha = 1.0, nlambda = 100,family = "binomial")
plot(glmnetfit )
print(glmnetfit )
coef(glmnetfit , s = "lambda.min")
predict(glmnetfit , newx = as.matrix(mydat[1,1:6]), s = "lambda.min")


#=======================================================================
# Rattle timestamp: 2022-10-13 14:31:24 x86_64-pc-linux-gnu 

# Evaluate model performance on the testing dataset. 

# Generate an Error Matrix for the Linear model.

# Obtain the response from the Linear model.

crs$pr <- as.vector(ifelse(predict(crs$glm, 
   type    = "response",
   newdata = crs$dataset[crs$test, c(crs$input, crs$target)]) > 0.5, "Low", "High"))

# Generate the confusion matrix showing counts.

rattle::errorMatrix(crs$dataset[crs$test, c(crs$input, crs$target)]$target, crs$pr, count=TRUE)

# Generate the confusion matrix showing proportions.

(per <- rattle::errorMatrix(crs$dataset[crs$test, c(crs$input, crs$target)]$target, crs$pr))

# Calculate the overall error percentage.

cat(100-sum(diag(per), na.rm=TRUE))

# Calculate the averaged class error percentage.

cat(mean(per[,"Error"], na.rm=TRUE))

#=======================================================================
# Rattle timestamp: 2022-10-13 14:31:30 x86_64-pc-linux-gnu 

# Evaluate model performance on the testing dataset. 

# ROC Curve: requires the ROCR package.

library(ROCR)

# ROC Curve: requires the ggplot2 package.

library(ggplot2, quietly=TRUE)

# Generate an ROC Curve for the glm model on radiomicsoutwide.csv [test].

crs$pr <- predict(crs$glm, 
   type    = "response",
   newdata = crs$dataset[crs$test, c(crs$input, crs$target)])

# Remove observations with missing target.

no.miss   <- na.omit(crs$dataset[crs$test, c(crs$input, crs$target)]$target)
miss.list <- attr(no.miss, "na.action")
attributes(no.miss) <- NULL

if (length(miss.list))
{
  pred <- prediction(crs$pr[-miss.list], no.miss)
} else
{
  pred <- prediction(crs$pr, no.miss)
}

pe <- performance(pred, "tpr", "fpr")
au <- performance(pred, "auc")@y.values[[1]]
pd <- data.frame(fpr=unlist(pe@x.values), tpr=unlist(pe@y.values))
p <- ggplot(pd, aes(x=fpr, y=tpr))
p <- p + geom_line(colour="red")
p <- p + xlab("False Positive Rate") + ylab("True Positive Rate")
p <- p + ggtitle("ROC Curve Linear radiomicsoutwide.csv [test] target")
p <- p + theme(plot.title=element_text(size=10))
p <- p + geom_line(data=data.frame(), aes(x=c(0,1), y=c(0,1)), colour="grey")
p <- p + annotate("text", x=0.50, y=0.00, hjust=0, vjust=0, size=5,
                   label=paste("AUC =", round(au, 2)))
print(p)

# Calculate the area under the curve for the plot.


# Remove observations with missing target.

no.miss   <- na.omit(crs$dataset[crs$test, c(crs$input, crs$target)]$target)
miss.list <- attr(no.miss, "na.action")
attributes(no.miss) <- NULL

if (length(miss.list))
{
  pred <- prediction(crs$pr[-miss.list], no.miss)
} else
{
  pred <- prediction(crs$pr, no.miss)
}
performance(pred, "auc")
