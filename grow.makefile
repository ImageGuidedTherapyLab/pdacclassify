SHELL := /bin/bash

LISTUID    = $(shell sed 1d dicom/wideformatgrow.csv | cut -d, -f2 )
LISTDELTA  = $(shell sed 1d dicom/wideformatgrow.csv | cut -d, -f3 )
CONTRASTLIST = Art 

raw: $(foreach idc,$(CONTRASTLIST),$(addprefix GrowProcessed/,$(addsuffix /$(idc).raw.nii.gz,$(LISTUID)))) 
truth: $(addprefix GrowProcessed/,$(addsuffix /Bl.raw.nii.gz,$(LISTUID))) $(addprefix GrowProcessed/,$(addsuffix /Normal.raw.nii.gz,$(LISTUID)))
artdiff: $(addprefix GrowProcessed/,$(addsuffix /Artdiff.nii.gz,$(LISTUID))) 
lesionmask: $(addprefix GrowProcessed/,$(addsuffix /lesionmask.nii.gz,$(LISTUID))) 
lesionrad: $(addprefix GrowProcessed/,$(addsuffix /lesionrad.nii.gz,$(LISTUID))) 
rmbg: $(addprefix GrowProcessed/,$(addsuffix /Artrmbg.nii.gz,$(LISTUID))) 
roi: $(addprefix GrowProcessed/,$(addsuffix /lesionroi.nii.gz,$(LISTUID))) 
viewraw: $(addprefix GrowProcessed/,$(addsuffix /viewraw,$(LISTUID)))  
viewbb: $(addprefix GrowProcessed/,$(addsuffix /viewbb,$(LISTUID)))  
viewinfo: $(addprefix GrowProcessed/,$(addsuffix /viewinfo,$(LISTUID)))  

dicom/radiomicsout.csv: dicom/wideclassificationgrowrad.csv 
	pyradiomics  $< -o $@   -v  5  -j 8  -p Params.yaml -f csv

dbg:
	@echo $(LISTUID)    
	@echo $(LISTDELTA)    
GrowProcessed/%/Art.raw.nii.gz:
	mkdir -p $(@D); dcm2niix  -m y -f Artfixme  -v 1 -z y  -t y -o $(@D)  "$(shell python getd2db.py --uid=$* --art )"
	DicomSeriesReadImageWrite2  "$(shell python getd2db.py --uid=$* --art )" $@

GrowProcessed/%/Artdiff.nii.gz: GrowProcessed/%/Art.raw.nii.gz GrowProcessed/%/Normal.raw.nii.gz
	python3 pdacdiff.py --image=$< --mask=$(word 2,$^) --output=$@

GrowProcessed/%/Bl.raw.nii.gz: GrowProcessed/%/Art.raw.nii.gz
	mkdir -p $(@D)
	plastimatch convert --fixed $(@D)/Art.raw.nii.gz  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input   "$(shell python getd2db.py --uid=$* --bl )"
	echo vglrun itksnap -g $< -s $@
GrowProcessed/%/Normal.raw.nii.gz: GrowProcessed/%/Art.raw.nii.gz
	mkdir -p $(@D)
	plastimatch convert --fixed $(@D)/Art.raw.nii.gz  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input   "$(shell python getd2db.py --uid=$* --nrm )"
	echo vglrun itksnap -g $< -s $@

GrowProcessed/%/lesionrad.nii.gz: 
	if [  $(word $(shell sed 1d dicom/wideformatd2.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTDELTA))  == "Low" ] ; then c3d -verbose $(@D)/Bl.raw.nii.gz -replace 1 2 -o $@  ; elif [  $(word $(shell sed 1d dicom/wideformatd2.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTDELTA))  == "High" ] ; then c3d -verbose $(@D)/Bl.raw.nii.gz -replace 1 3 -o $@  ;fi
	c3d -verbose $@ $(@D)/Normal.raw.nii.gz -add  -o $@  
GrowProcessed/%/lesionmask.nii.gz: 
	c3d -verbose $(@D)/Bl.raw.nii.gz  -replace 1 2  $(@D)/Normal.raw.nii.gz -add  -o $@  
	echo vglrun itksnap -g $(@D)/Art.raw.nii.gz -s $@

GrowProcessed/%/Artrmbg.nii.gz:  GrowProcessed/%/lesionmask.nii.gz
	c3d -verbose $(@D)/Art.raw.nii.gz $< -binarize -multiply -o  $@  
GrowProcessed/%/lesionroi.nii.gz: GrowProcessed/%/Artrmbg.nii.gz GrowProcessed/%/lesionmask.nii.gz
	python3 pdacroi.py --image=$< --mask=$(word 2,$^) --outputdir=$(@D)
	echo vglrun itksnap -g $(@D)/Artroi.nii.gz -s $@

GrowProcessed/%/viewinfo: GrowProcessed/%/Art.raw.nii.gz GrowProcessed/%/Normal.raw.nii.gz GrowProcessed/%/Bl.raw.nii.gz
	c3d  $< -info $(word 2,$^) -info   $(word 3,$^) -info
GrowProcessed/%/viewraw: GrowProcessed/%/Art.raw.nii.gz GrowProcessed/%/Normal.raw.nii.gz GrowProcessed/%/Bl.raw.nii.gz
	vglrun itksnap -g $< -s $(word 2,$^) &  vglrun itksnap -g $< -s $(word 3,$^)
GrowProcessed/%/viewbb:  GrowProcessed/%/lesionmask.nii.gz
	c3d $< -binarize -dup -lstat
