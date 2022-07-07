-- cat pdacgrow.sql | sqlite3 
-- sqlite3  -init pdacgrow.sql 
.headers on
-- attach database ':memory:' as tmp;
attach database 'regiongrow/ctkDICOM.sql' as sl;

.mode csv
.import dicom/NNdatabase07_07updated.csv  edrn

-- sqlite> select distinct im.seriesDescription from sl.series im;
-- "Recon 2: LIVER/PANCREAS"
-- "Series Description"
-- "PreXRT-PRE resampled"
-- "PreXRT-PV resampled"
-- "PRE resampled"
-- "PreXRT - PV resampled"
-- "PreXRT-PV added resampled"
-- LIVER/PANCREAS
-- "PreXRT-Pre resampled"
-- "PreXRT-Portal resampled"
-- "normal pancreas"
-- "Portovenous resampled"
-- "PostXRT-Pre resampled"
-- "PostXRT-Portal resampled"
-- "Recon 2: LIVER/PANC AP"
-- "PreXRT-PRE  resampled"
-- "PRE LIVER resampled"
-- "Recon 2: C-A-P"
-- ""
-- "Recon 3: LIVER/PANCREAS"
-- "portovenous resampled"
-- "Recon 2: LIVER/PANC CAP"


create table flagdata  as
select sd.PatientsUID,pt.PatientID,im.StudyInstanceUID,im.SeriesInstanceUID,im.seriesDescription,im.SeriesDate,di.FileName,
CASE WHEN (im.seriesDescription == "PreXRT-PRE  resampled" or im.seriesDescription == "PRE LIVER resampled" or im.seriesDescription == "PostXRT-Pre resampled" or im.seriesDescription == "PreXRT-Pre resampled" or im.seriesDescription == "PRE resampled" or im.seriesDescription == "PreXRT-PRE resampled")  THEN 'Pre'
     WHEN (im.seriesDescription like '%Port%' or im.seriesDescription like '%port%' or im.seriesDescription like '%ven%'or im.seriesDescription like '%PV%' )  THEN 'Ven'
     WHEN im.Modality == 'RTSTRUCT'  THEN 'Truth'
     ELSE 'Art' END AS ImageType
from sl.series im 
join sl.images di on di.SeriesInstanceUID= im.SeriesInstanceUID
join sl.studies  sd on sd.StudyInstanceUID = im.StudyInstanceUID
join sl.patients pt on sd.PatientsUID = pt.UID;
-- select * from flagdata where ImageType = 'Truth';

create table labeldatatmp  as
select *,
       CASE WHEN Filename like '%normal%'   THEN 1
            WHEN Filename like '%BL%' THEN 2
            END AS truthid
       from flagdata where ImageType = 'Truth';
select max(truthid) from labeldatatmp  ;
create table labeldata  as
select *, 'Truth'||truthid truthlabel  from labeldatatmp;

create table widestudy  as
select fg.PatientsUID PatientsUID,fg.PatientID PatientID,ed.DeltaScore,fg.StudyInstanceUID StudyInstanceUID,
            max(CASE WHEN fg.ImageType = 'Pre' THEN fg.SeriesInstanceUID       ELSE NULL END)  Pre,
            max(CASE WHEN fg.ImageType = 'Pre' THEN fg.SeriesDescription       ELSE NULL END)  PreDescription,
            max(CASE WHEN fg.ImageType = 'Pre' THEN rtrim(fg.Filename, replace(fg.Filename, '/', '')) ELSE NULL END) PreFilename,
            max(CASE WHEN fg.ImageType = 'Art' THEN fg.SeriesInstanceUID       ELSE NULL END)  Art,
            max(CASE WHEN fg.ImageType = 'Art' THEN fg.SeriesDescription       ELSE NULL END)  ArtDescription,
            max(CASE WHEN fg.ImageType = 'Art' THEN rtrim(fg.Filename, replace(fg.Filename, '/', '')) ELSE NULL END) ArtFilename,
            max(CASE WHEN fg.ImageType = 'Ven' THEN fg.SeriesInstanceUID       ELSE NULL END)  Ven,
            max(CASE WHEN fg.ImageType = 'Ven' THEN fg.SeriesDescription       ELSE NULL END)  VenDescription,
            max(CASE WHEN fg.ImageType = 'Ven' THEN rtrim(fg.Filename, replace(fg.Filename, '/', '')) ELSE NULL END) VenFilename,
            max(CASE WHEN ld.truthlabel = 'Truth1' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth1,
            max(CASE WHEN ld.truthlabel = 'Truth1' THEN ld.SeriesDescription     ELSE NULL END)  Truth1Description,
            max(CASE WHEN ld.truthlabel = 'Truth1' THEN ld.Filename              ELSE NULL END)  Truth1FileName,
            max(CASE WHEN ld.truthlabel = 'Truth2' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth2,
            max(CASE WHEN ld.truthlabel = 'Truth2' THEN ld.SeriesDescription     ELSE NULL END)  Truth2Description,
            max(CASE WHEN ld.truthlabel = 'Truth2' THEN ld.Filename              ELSE NULL END)  Truth2FileName,
            max(CASE WHEN ld.truthlabel = 'Truth3' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth3,
            max(CASE WHEN ld.truthlabel = 'Truth3' THEN ld.SeriesDescription     ELSE NULL END)  Truth3Description,
            max(CASE WHEN ld.truthlabel = 'Truth3' THEN ld.Filename              ELSE NULL END)  Truth3FileName,
            max(CASE WHEN ld.truthlabel = 'Truth4' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth4,
            max(CASE WHEN ld.truthlabel = 'Truth4' THEN ld.SeriesDescription     ELSE NULL END)  Truth4Description,
            max(CASE WHEN ld.truthlabel = 'Truth4' THEN ld.Filename              ELSE NULL END)  Truth4FileName,
            max(CASE WHEN ld.truthlabel = 'Truth5' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth5,
            max(CASE WHEN ld.truthlabel = 'Truth5' THEN ld.SeriesDescription     ELSE NULL END)  Truth5Description,
            max(CASE WHEN ld.truthlabel = 'Truth5' THEN ld.Filename              ELSE NULL END)  Truth5FileName,
            max(CASE WHEN ld.truthlabel = 'Truth6' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth6,
            max(CASE WHEN ld.truthlabel = 'Truth6' THEN ld.SeriesDescription     ELSE NULL END)  Truth6Description,
            max(CASE WHEN ld.truthlabel = 'Truth6' THEN ld.Filename              ELSE NULL END)  Truth6FileName,
            max(CASE WHEN ld.truthlabel = 'Truth7' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth7,
            max(CASE WHEN ld.truthlabel = 'Truth7' THEN ld.SeriesDescription     ELSE NULL END)  Truth7Description,
            max(CASE WHEN ld.truthlabel = 'Truth7' THEN ld.Filename              ELSE NULL END)  Truth7FileName
from flagdata  fg
join edrn      ed on   ed.MRN=fg.PatientID
join labeldata      ld on   ld.PatientID=fg.PatientID
GROUP BY    fg.StudyInstanceUID;
-- select * from widestudy;

-- error check
select distinct im.seriesDescription from sl.series im;
select count(ws.StudyInstanceUID),count(ws.Pre),count(ws.Art),count(ws.Ven),count(ws.Truth1) ,count(ws.Truth2) ,count(ws.Truth3) ,count(ws.Truth4) ,count(ws.Truth5) ,count(ws.Truth6) ,count(ws.Truth7)  from widestudy  ws;
select ws.* , se.SeriesDescription
from widestudy  ws 
join sl.studies sd on sd.PatientsUID = ws.PatientsUID
join sl.series  se on sd.StudyInstanceUID=se.StudyInstanceUID
where ws.Art is null;

-- error check
select ws.PatientID from  widestudy ws  where ws.Truth2 is NULL ;

-- FIXME HACK remove problem data
delete FROM widestudy  WHERE PatientsUID = 15;

-- wide format
-- FIXME use group by to remove duplicates
.mode csv
.output dicom/wideformatd2.csv 
select ws.* from widestudy ws;

.output dicom/wideclassificationd2.csv 
select ws.PatientID as id, 'D2Processed/'||ws.PatientID||'/Art.raw.nii.gz' as Art,'D2Processed/'||ws.PatientID||'/lesionmask.nii.gz' as Mask,
       ws.DeltaScore as target,
       CASE WHEN ws.DeltaScore = 'High'   THEN 1
            WHEN ws.DeltaScore = 'Low'   THEN 0
            ELSE NULL 
            END AS truthid
       from widestudy ws;

.output dicom/wideclassificationroigrow.csv 
select ws.PatientID as id, 'D2Processed/'||ws.PatientID||'/Artroi.nii.gz' as Art,'D2Processed/'||ws.PatientID||'/lesionroi.nii.gz' as Mask,
       ws.DeltaScore as target,
       CASE WHEN ws.DeltaScore = 'High'   THEN 1
            WHEN ws.DeltaScore = 'Low'   THEN 0
            ELSE NULL 
            END AS truthid
       from widestudy ws;
.output dicom/wideclassificationgrowrad.csv 
select ws.PatientID as id, '/rsrch3/ip/dtfuentes/github/pdacclassify/D2Processed/'||ws.PatientID||'/Artdiff.nii.gz' as Image,'/rsrch3/ip/dtfuentes/github/pdacclassify/D2Processed/'||ws.PatientID||'/lesionmask.nii.gz' as Mask, 1 as Label,
       ws.DeltaScore as target,
       CASE WHEN ws.DeltaScore = 'High'   THEN 1
            WHEN ws.DeltaScore = 'Low'   THEN 0
            ELSE NULL 
            END AS truthid
       from widestudy ws;
select ws.PatientID as id, '/rsrch3/ip/dtfuentes/github/pdacclassify/D2Processed/'||ws.PatientID||'/Artdiff.nii.gz' as Image,'/rsrch3/ip/dtfuentes/github/pdacclassify/D2Processed/'||ws.PatientID||'/lesionmask.nii.gz' as Mask, 2 as Label,
       ws.DeltaScore as target,
       CASE WHEN ws.DeltaScore = 'High'   THEN 1
            WHEN ws.DeltaScore = 'Low'   THEN 0
            ELSE NULL 
            END AS truthid
       from widestudy ws;


.quit
