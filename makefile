SHELL := /bin/bash

LISTUID    = $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 )
LISTDELTA  = $(shell sed 1d dicom/wideformat.csv | cut -d, -f3 )
LISTPRE    = $(shell sed 1d dicom/wideformat.csv | cut -d, -f13 )
LISTART    = $(shell sed 1d dicom/wideformat.csv | cut -d, -f14 )
LISTVEN    = $(shell sed 1d dicom/wideformat.csv | cut -d, -f15 )
LISTTRUTH  = $(shell sed 1d dicom/wideformat.csv | cut -d, -f16 )
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

#plastimatch convert --fixed $<  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input  $(word $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTTRUTH))
Processed/%/Truth.raw.nii.gz: Processed/%/Art.raw.nii.gz
	mkdir -p $(@D)
	plastimatch convert  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input  $(word $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTTRUTH))
	if [  $(word $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTDELTA))  == "High" ] ; then c3d -verbose $@ -replace 1 2 -o $@  ; fi
	c3d $< $@ -reslice-identity -o $@ 
	echo vglrun itksnap -g $< -s $@
