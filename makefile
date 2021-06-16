SHELL := /bin/bash

LISTUID    = $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 )
LISTPRE    = $(shell sed 1d dicom/wideformat.csv | cut -d, -f12 )
LISTART    = $(shell sed 1d dicom/wideformat.csv | cut -d, -f13 )
LISTVEN    = $(shell sed 1d dicom/wideformat.csv | cut -d, -f14 )
LISTTRUTH  = $(shell sed 1d dicom/wideformat.csv | cut -d, -f15 )
CONTRASTLIST = Pre Art Ven 

raw: $(foreach idc,$(CONTRASTLIST),$(addprefix Processed/,$(addsuffix /$(idc).raw.nii.gz,$(LISTUID)))) 
truth: $(addprefix Processed/,$(addsuffix /Truth.raw.nii.gz,$(LISTUID)))
viewraw: $(addprefix Processed/,$(addsuffix /viewraw,$(MRILIST)))  

Processed/%/Pre.raw.nii.gz:
	mkdir -p $(@D); dcm2niix  -m y -f Pre.raw  -v 1 -z y  -t y -o $(@D)  $(word $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTPRE))
Processed/%/Art.raw.nii.gz:
	mkdir -p $(@D); dcm2niix  -m y -f Art.raw  -v 1 -z y  -t y -o $(@D)  $(word $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTART))
Processed/%/Ven.raw.nii.gz:
	mkdir -p $(@D); dcm2niix  -m y -f Ven.raw  -v 1 -z y  -t y -o $(@D)  $(word $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTVEN))

Processed/%/Truth.raw.nii.gz: Processed/%/Art.raw.nii.gz
	mkdir -p $(@D)
	#plastimatch convert --fixed $<  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input  $(word $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTTRUTH))
	plastimatch convert  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input  $(word $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTTRUTH))
	c3d $< $@ -reslice-identity -o $@ 
	echo vglrun itksnap -g $< -s $@
