SHELL := /bin/bash

LISTUID    = $(shell sed 1d dicom/wideformatd2.csv | cut -d, -f2 )
LISTDELTA  = $(shell sed 1d dicom/wideformatd2.csv | cut -d, -f3 )
CONTRASTLIST = Art 

raw: $(foreach idc,$(CONTRASTLIST),$(addprefix D2Processed/,$(addsuffix /$(idc).raw.nii.gz,$(LISTUID)))) 
truth: $(addprefix D2Processed/,$(addsuffix /Bl.raw.nii.gz,$(LISTUID))) $(addprefix D2Processed/,$(addsuffix /Normal.raw.nii.gz,$(LISTUID)))
lesionmask: $(addprefix D2Processed/,$(addsuffix /lesionmask.nii.gz,$(LISTUID))) 
rmbg: $(addprefix D2Processed/,$(addsuffix /Artrmbg.nii.gz,$(LISTUID))) 
roi: $(addprefix D2Processed/,$(addsuffix /lesionroi.nii.gz,$(LISTUID))) 
viewraw: $(addprefix D2Processed/,$(addsuffix /viewraw,$(LISTUID)))  
viewbb: $(addprefix D2Processed/,$(addsuffix /viewbb,$(LISTUID)))  
viewinfo: $(addprefix D2Processed/,$(addsuffix /viewinfo,$(LISTUID)))  

dbg:
	@echo $(LISTUID)    
	@echo $(LISTDELTA)    
D2Processed/%/Art.raw.nii.gz:
	mkdir -p $(@D); dcm2niix  -m y -f Artfixme  -v 1 -z y  -t y -o $(@D)  "$(shell python getd2db.py --uid=$* --art )"
	DicomSeriesReadImageWrite2  "$(shell python getd2db.py --uid=$* --art )" $@

D2Processed/%/Bl.raw.nii.gz: D2Processed/%/Art.raw.nii.gz
	mkdir -p $(@D)
	plastimatch convert --fixed $(@D)/Art.raw.nii.gz  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input   "$(shell python getd2db.py --uid=$* --bl )"
	echo vglrun itksnap -g $< -s $@
D2Processed/%/Normal.raw.nii.gz: D2Processed/%/Art.raw.nii.gz
	mkdir -p $(@D)
	plastimatch convert --fixed $(@D)/Art.raw.nii.gz  --output-labelmap $@ --output-ss-img $(@D)/ss.nii.gz --output-ss-list $(@D)/ss.txt --output-dose-img $(@D)/dose.nii.gz --input   "$(shell python getd2db.py --uid=$* --nrm )"
	echo vglrun itksnap -g $< -s $@

D2Processed/%/lesionmask.nii.gz: 
	# if [  $(word $(shell sed 1d dicom/wideformatd2.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTDELTA))  == "Low" ] ; then c3d -verbose $(@D)/Bl.raw.nii.gz -replace 1 2 -o $@  ; elif [  $(word $(shell sed 1d dicom/wideformatd2.csv | cut -d, -f2 | grep -n $* |cut -f1 -d: ), $(LISTDELTA))  == "High" ] ; then c3d -verbose $(@D)/Bl.raw.nii.gz -replace 1 3 -o $@  ;fi
	c3d -verbose $(@D)/Bl.raw.nii.gz  -replace 1 2  $(@D)/Normal.raw.nii.gz -add  -o $@  
	echo vglrun itksnap -g $(@D)/Art.raw.nii.gz -s $@

D2Processed/%/Artrmbg.nii.gz:  D2Processed/%/lesionmask.nii.gz
	c3d -verbose $(@D)/Art.raw.nii.gz $< -binarize -multiply -o  $@  
D2Processed/%/lesionroi.nii.gz: D2Processed/%/Artrmbg.nii.gz D2Processed/%/lesionmask.nii.gz
	python3 pdacroi.py --image=$< --mask=$(word 2,$^) --outputdir=$(@D)
	echo vglrun itksnap -g $(@D)/Artroi.nii.gz -s $@

D2Processed/%/viewinfo: D2Processed/%/Art.raw.nii.gz D2Processed/%/Normal.raw.nii.gz D2Processed/%/Bl.raw.nii.gz
	c3d  $< -info $(word 2,$^) -info   $(word 3,$^) -info
D2Processed/%/viewraw: D2Processed/%/Art.raw.nii.gz D2Processed/%/Normal.raw.nii.gz D2Processed/%/Bl.raw.nii.gz
	vglrun itksnap -g $< -s $(word 2,$^) &  vglrun itksnap -g $< -s $(word 3,$^)
D2Processed/%/viewbb:  D2Processed/%/lesionmask.nii.gz
	c3d $< -binarize -dup -lstat
