SHELL := /bin/bash
-include  lrmda256kfold010.makefile
WORKDIR=$(TRAININGROOT)/Processed
DATADIR=$(TRAININGROOT)/datalocation/train
mask:        $(addprefix $(WORKDIR)/,$(addsuffix /unet/mask.nii.gz,$(UIDLIST)))
normalize:   $(addprefix $(WORKDIR)/,$(addsuffix /Ven.normalize.nii.gz,$(UIDLIST)))
normroi:     $(addprefix $(WORKDIR)/,$(addsuffix /Ven.normroi.nii.gz,$(UIDLIST)))
roi:         $(addprefix $(WORKDIR)/,$(addsuffix /Ven.roi.nii.gz,$(UIDLIST)))
combine:     $(addprefix $(DATADIR)/,$(addsuffix /TruthVen6.nii.gz,$(UIDLIST)))
labels:      $(addprefix $(WORKDIR)/,$(addsuffix /$(DATABASEID)/lirads.nii.gz,$(UIDLIST)))
labelsmrf:   $(addprefix $(WORKDIR)/,$(addsuffix /$(DATABASEID)/tumormrf.nii.gz,$(UIDLIST)))
labelsmedian:$(addprefix $(WORKDIR)/,$(addsuffix /$(DATABASEID)/tumormedian.nii.gz,$(UIDLIST)))
overlap:     $(addprefix $(WORKDIR)/,$(addsuffix /$(DATABASEID)/overlap.sql,$(UIDLIST)))
overlappost: $(addprefix $(WORKDIR)/,$(addsuffix /$(DATABASEID)/overlapmrf.sql,$(UIDLIST))) $(addprefix $(WORKDIR)/,$(addsuffix /$(DATABASEID)/overlapmedian.sql,$(UIDLIST)))
reviewsoln:  $(addprefix $(WORKDIR)/,$(addsuffix /reviewsoln,$(UIDLIST)))
C3DEXE=/rsrch2/ip/dtfuentes/bin/c3d
# keep tmp files
.SECONDARY: 

LIRADSLIST = $(shell sed 1d dicom/wideformat.csv | cut -d, -f2 )
lstat:       $(addprefix    qastatslr/,$(addsuffix /lstat.csv,$(LIRADSLIST)))
qalirads: $(addprefix Processed/,$(addsuffix /qalirads,$(LIRADSLIST)))  
viewlirads: $(addprefix Processed/,$(addsuffix /viewlirads,$(LIRADSLIST)))  
multiphaselirads: $(addprefix Processed/,$(addsuffix /multiphase.nii.gz,$(LIRADSLIST)))  
Processed/%/qalirads: 
	c3d Processed/$*fixed.train.nii.gz -info -dup -lstat  -thresh 3 inf  1 0 -comp -lstat Processed/$*/fixed.liver.nii.gz -info Processed/$*/Art.longregcc.nii.gz -info Processed/$*/Art.raw.nii.gz  -info 
Processed/%/viewlirads: 
	echo $*
	c3d Processed/$*fixed.train.nii.gz -info -dup -lstat  -thresh 3 inf  1 0 -comp -lstat
	vglrun itksnap -l labelkey.txt  -g  $(@D)/Art.raw.nii.gz -s  Processed/$*/Truth.raw.nii.gz 
Processed/%/multiphase.nii.gz: Processed/%/Pre.longregcc.nii.gz  Processed/%/Art.longregcc.nii.gz  Processed/%/Ven.longregcc.nii.gz Processed/%/Del.longregcc.nii.gz  Processed/%/Pst.longregcc.nii.gz
	c3d $^ -omc $@

Processed/%/viewnnlirads: 
	vglrun itksnap -g Processed/$*/multiphase.nii.gz  -s Processed/$*/lrmdapocket/lirads.nii.gz -o Processed/$*/lrmdapocket/lirads-?.nii.gz Processed/$*/Truth.raw.nii.gz  Processed/$*/lesionmask.nii.gz

## intensity statistics
qastatslr/%/lstat.csv: 
	mkdir -p $(@D)
	c3d Processed/$*/Truth.raw.nii.gz -dup -binarize -comp  -lstat > $(@D)/truth.txt &&  sed "1,2d;s/^\s\+/$(subst /,\/,$*),Truth.raw.nii.gz,Truth.raw.nii.gz,/g;s/\s\+/,/g;s/LabelID/InstanceUID,SegmentationID,FeatureID,LabelID/g;s/Vol(mm^3)/Vol.mm.3/g;s/Extent(Vox)/ExtentX,ExtentY,ExtentZ/g" $(@D)/truth.txt > $(@D)/truth.csv 
	c3d Processed/$*/Art.raw.nii.gz Processed/$*/Truth.raw.nii.gz  -binarize -comp  -lstat > $(@D)/art.txt &&  sed "1,2d;s/^\s\+/$(subst /,\/,$*),Truth.raw.nii.gz,Art.raw.nii.gz,/g;s/\s\+/,/g;s/LabelID/InstanceUID,SegmentationID,FeatureID,LabelID/g;s/Vol(mm^3)/Vol.mm.3/g;s/Extent(Vox)/ExtentX,ExtentY,ExtentZ/g" $(@D)/art.txt > $(@D)/art.csv 
	c3d Processed/$*/lrmdapocket/lirads-1.nii.gz Processed/$*/Truth.raw.nii.gz  -binarize -comp  -lstat > $(@D)/predict.1.txt &&  sed "1,2d;s/^\s\+/$(subst /,\/,$*),Truth.raw.nii.gz,lirads-1.nii.gz,/g;s/\s\+/,/g;s/LabelID/InstanceUID,SegmentationID,FeatureID,LabelID/g;s/Vol(mm^3)/Vol.mm.3/g;s/Extent(Vox)/ExtentX,ExtentY,ExtentZ/g" $(@D)/predict.1.txt > $(@D)/predict.1.csv 
	c3d Processed/$*/lrmdapocket/lirads-2.nii.gz Processed/$*/Truth.raw.nii.gz  -binarize -comp  -lstat > $(@D)/predict.2.txt &&  sed "1,2d;s/^\s\+/$(subst /,\/,$*),Truth.raw.nii.gz,lirads-2.nii.gz,/g;s/\s\+/,/g;s/LabelID/InstanceUID,SegmentationID,FeatureID,LabelID/g;s/Vol(mm^3)/Vol.mm.3/g;s/Extent(Vox)/ExtentX,ExtentY,ExtentZ/g" $(@D)/predict.2.txt > $(@D)/predict.2.csv 
	c3d Processed/$*/Truth.raw.nii.gz  -binarize -comp -thresh 1 1  1 0  -dup Processed/$*/lrmdapocket/lirads.nii.gz  -multiply -lstat > $(@D)/label-1.txt && sed "1,2d;s/^\s\+/$(subst /,\/,$*),Truth.raw-1.nii.gz,lirads.nii.gz,/g;s/\s\+/,/g;s/LabelID/InstanceUID,SegmentationID,FeatureID,LabelID/g;s/Vol(mm^3)/Vol.mm.3/g;s/Extent(Vox)/ExtentX,ExtentY,ExtentZ/g" $(@D)/label-1.txt > $(@D)/label-1.csv 
	c3d Processed/$*/Truth.raw.nii.gz  -binarize -comp -thresh 2 2  1 0  -dup Processed/$*/lrmdapocket/lirads.nii.gz  -multiply -lstat > $(@D)/label-2.txt && sed "1,2d;s/^\s\+/$(subst /,\/,$*),Truth.raw-2.nii.gz,lirads.nii.gz,/g;s/\s\+/,/g;s/LabelID/InstanceUID,SegmentationID,FeatureID,LabelID/g;s/Vol(mm^3)/Vol.mm.3/g;s/Extent(Vox)/ExtentX,ExtentY,ExtentZ/g" $(@D)/label-2.txt > $(@D)/label-2.csv 
	cat $(@D)/label-?.csv $(@D)/predict.?.csv $(@D)/truth.csv $(@D)/art.csv > $@

qastatslr/lstat.csv: 
	cat qastatslr/*/lstat.csv > $@

$(DATADIR)/%/TruthVen6.nii.gz:
	c3d -verbose $(@D)/TruthVen1.nii.gz -replace 3 2 4 3 5 4 -o $@
	
##$(WORKDIR)/%/Ven.normalize.nii.gz:
##	python ./tissueshift.py --image=$(@D)/Ven.raw.nii.gz --gmm=$(DATADIR)/$*/TruthVen1.nii.gz  

$(WORKDIR)/%/Ven.normroi.nii.gz:
	python ./tissueshift.py --image=$(@D)/Ven.roi.nii.gz --gmm=$(@D)/Truthroi.nii.gz  

$(WORKDIR)/%/Ven.roi.nii.gz: 
	python ./liverroi.py --image=$(@D)/Ven.raw.nii.gz --gmm=$(DATADIR)/$*/TruthVen6.nii.gz --outputdir=$(@D)

$(WORKDIR)/%/$(DATABASEID)/tumormrf.nii.gz:
	c3d -verbose $(@D)/tumor-1.nii.gz -scale .5 $(@D)/tumor-[2345].nii.gz -vote-mrf  VA .1 -o $@

$(WORKDIR)/%/$(DATABASEID)/tumormedian.nii.gz:
	c3d -verbose $(@D)/tumor.nii.gz -median 1x1x1 -o $@

$(WORKDIR)/%/$(DATABASEID)/overlapmrf.csv: $(WORKDIR)/%/$(DATABASEID)/tumormrf.nii.gz
	$(C3DEXE) $(DATADIR)/$*/TruthVen1.nii.gz  -as A $< -as B -overlap 1 -overlap 2 -overlap 3 -overlap 4  -overlap 5  > $(@D)/overlap.txt
	grep "^OVL" $(@D)/overlap.txt  |sed "s/OVL: \([0-9]\),/\1,$(subst /,\/,$*),/g;s/OVL: 1\([0-9]\),/1\1,$(subst /,\/,$*),/g;s/^/TruthVen1.nii.gz,tumormrf,/g;"  | sed "1 i FirstImage,SecondImage,LabelID,InstanceUID,MatchingFirst,MatchingSecond,SizeOverlap,DiceSimilarity,IntersectionRatio" > $@

$(WORKDIR)/%/overlapmrf.sql: $(WORKDIR)/%/overlapmrf.csv
	-sqlite3 $(SQLITEDB)  -init .loadcsvsqliterc ".import $< overlap"

## dice statistics
$(WORKDIR)/%/$(DATABASEID)/overlap.csv: $(WORKDIR)/%/$(DATABASEID)/tumor.nii.gz
	mkdir -p $(@D)
	$(C3DEXE) $<  -as A $(DATADIR)/$*/TruthVen1.nii.gz -as B -overlap 1 -overlap 2 -overlap 3 -overlap 4  -thresh 2 3 1 0 -comp -as C  -clear -push C -replace 0 255 -split -pop -foreach -push B -multiply -insert A 1 -overlap 1 -overlap 2 -overlap 3 -overlap 4 -pop -endfor
	grep "^OVL" $(@D)/overlap.txt  |sed "s/OVL: \([0-9]\),/\1,$(subst /,\/,$*),/g;s/OVL: 1\([0-9]\),/1\1,$(subst /,\/,$*),/g;s/^/TruthVen1.nii.gz,$(DATABASEID)\/tumor.nii.gz,/g;"  | sed "1 i FirstImage,SecondImage,LabelID,InstanceUID,MatchingFirst,MatchingSecond,SizeOverlap,DiceSimilarity,IntersectionRatio" > $@

$(WORKDIR)/%/overlap.sql: $(WORKDIR)/%/overlap.csv
	-sqlite3 $(SQLITEDB)  -init .loadcsvsqliterc ".import $< overlap"

$(WORKDIR)/%/reviewsoln: 
	vglrun itksnap -g $(WORKDIR)/$*/Ven.raw.nii.gz -s $(DATADIR)/$*/TruthVen1.nii.gz & vglrun itksnap -g $(WORKDIR)/$*/Ven.raw.nii.gz -s $(WORKDIR)/$*/$(DATABASEID)/tumor.nii.gz ;\
        pkill -9 ITK-SNAP



