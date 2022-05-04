SHELL := /bin/bash

LISTUID    = $(shell sed 1d dicom/wideformatd2.csv | cut -d, -f2 )
LISTDELTA  = $(shell sed 1d dicom/wideformatd2.csv | cut -d, -f3 )
CONTRASTLIST = Art 

raw: $(foreach idc,$(CONTRASTLIST),$(addprefix D2Processed/,$(addsuffix /$(idc).raw.nii.gz,$(LISTUID)))) 
truth: $(addprefix D2Processed/,$(addsuffix /Bl.raw.nii.gz,$(LISTUID))) $(addprefix D2Processed/,$(addsuffix /Normal.raw.nii.gz,$(LISTUID)))
viewraw: $(addprefix D2Processed/,$(addsuffix /viewraw,$(MRILIST)))  

dbg:
	@echo $(LISTUID)    
	@echo $(LISTDELTA)    
D2Processed/%/Art.raw.nii.gz:
	mkdir -p $(@D); dcm2niix  -m y -f Art.raw  -v 1 -z y  -t y -o $(@D)  "$(shell python getd2db.py --uid=$* --art )"

D2Processed/%/Bl.raw.nii.gz: D2Processed/%/Art.raw.nii.gz
	mkdir -p $(@D)
	plastimatch convert  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input   "$(shell python getd2db.py --uid=$* --bl )"
	if [  $(word $(shell sed 1d dicom/wideformatd2.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTDELTA))  == "High" ] ; then c3d -verbose $@ -replace 1 2 -o $@  ; fi
	c3d -verbose -interpolation 0 $< $@ -reslice-identity -o $@  -binarize -o $(@D)/lesionmask.nii.gz
	echo vglrun itksnap -g $< -s $@
D2Processed/%/Normal.raw.nii.gz: D2Processed/%/Art.raw.nii.gz
	mkdir -p $(@D)
	plastimatch convert  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input   "$(shell python getd2db.py --uid=$* --nrm )"
	c3d -verbose -interpolation 0 $< $@ -reslice-identity -o $@  -binarize -o $(@D)/lesionmask.nii.gz
	echo vglrun itksnap -g $< -s $@

D2Processed/%/viewraw: D2Processed/%/Art.raw.nii.gz D2Processed/%/Normal.raw.nii.gz D2Processed/%/Bl.raw.nii.gz
	vglrun itksnap -g $< -s $(word 2,$^) &  vglrun itksnap -g $< -s $(word 3,$^)
