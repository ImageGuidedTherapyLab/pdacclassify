-- cat pdac.sql  | sqlite3 
-- sqlite3  -init pdac.sql 
.headers on
-- attach database ':memory:' as tmp;
attach database 'dicom/ctkDICOM.sql' as sl;
.mode csv
.import dicom/EDRNidentifiers.csv  edrn
-- sqlite> select distinct im.seriesDescription from sl.series im;
-- SeriesDescription
-- "Portal resampled"
-- LIVER/PANCREAS
-- "PRE resampled"
-- "Series Description"
-- "POS CONTRAST"
-- "Pre resampled"
-- "POST CONTRAST"
-- "Pre-10112010 resampled"
-- "PV-10112010 resampled"
-- "Recon 2: POST CONTRAST"
-- "PV resampled"
-- "Recon 2: LIVER 3 PHASE (AP)"
-- "PRE LIVER resampled"
-- 3.75
-- "OSF-PV resampled"
-- PANCREAS
-- "LIVER/PANC CAP"
-- "LIVER 3 PHASE (AP)"
-- "PRE  resampled"
-- "PRE added"
-- "Recon 2: PRE resampled"
-- "Pre-Liver 5 mm resampled"
-- "Liver Dual Phase"
-- "PRE-LIVER resampled"
-- "LIVER 2 PHASE (C/A/P)"
-- ARTERIAL
-- "VENOUS/CHEST resampled"
-- ABD/PELVIS

create table flagdata  as
select sd.PatientsUID,pt.PatientID,im.StudyInstanceUID,im.SeriesInstanceUID,im.seriesDescription,
CASE WHEN im.seriesDescription like '%PRE%'        THEN 'Pre'
     WHEN (im.seriesDescription like '%port%' or im.seriesDescription like '%ven%'or im.seriesDescription like '%PV%' )  THEN 'Ven'
     WHEN (im.seriesDescription == 'Series Description' or im.seriesDescription == 'SeriesDescription') THEN 'Truth'
     ELSE 'Art' END AS ImageType
from sl.series im 
join sl.studies  sd on sd.StudyInstanceUID = im.StudyInstanceUID
join sl.patients pt on sd.PatientsUID = pt.UID;

create table widestudy  as
select fg.PatientsUID PatientsUID,fg.PatientID PatientID,fg.StudyInstanceUID StudyInstanceUID,
            max(CASE WHEN ImageType = 'Pre' THEN fg.SeriesInstanceUID       ELSE NULL END)  Pre,
            max(CASE WHEN ImageType = 'Art' THEN fg.SeriesInstanceUID       ELSE NULL END)  Art,
            max(CASE WHEN ImageType = 'Ven' THEN fg.SeriesInstanceUID       ELSE NULL END)  Ven,
            max(CASE WHEN ImageType = 'Truth' THEN fg.SeriesInstanceUID     ELSE NULL END)  Truth
from flagdata  fg
GROUP BY    fg.StudyInstanceUID;
-- select * from widestudy;

-- error check
select count(ws.StudyInstanceUID),count(ws.Pre),count(ws.Art),count(ws.Ven),count(ws.Truth)  from widestudy  ws;
select ws.* , se.SeriesDescription
from widestudy  ws 
join sl.studies sd on sd.PatientsUID = ws.PatientsUID
join sl.series  se on sd.StudyInstanceUID=se.StudyInstanceUID
where ws.Art is null;

-- wide format
.mode csv
.output dicom/wideformat.csv 
select ws.*,dn.seriesDescription PreDescription , an.seriesDescription ArtDescription, pt.seriesDescription VenDescription, tt.seriesDescription TruthDescription,
rtrim(di.Filename, replace(di.Filename, '/', '')) PreFilename,
rtrim(ai.Filename, replace(ai.Filename, '/', '')) ArtFilename,
rtrim(pi.Filename, replace(pi.Filename, '/', '')) VenFilename,
rtrim(ti.Filename, replace(ti.Filename, '/', '')) TruthFilename
from widestudy ws 
join sl.images  di on di.SeriesInstanceUID= ws.Pre
join sl.images  ai on ai.SeriesInstanceUID= ws.Art
join sl.images  pi on pi.SeriesInstanceUID= ws.Ven
join sl.images  ti on ti.SeriesInstanceUID= ws.Truth
join flagdata  dn on dn.SeriesInstanceUID= ws.Pre
join flagdata  an on an.SeriesInstanceUID= ws.Art
join flagdata  pt on pt.SeriesInstanceUID= ws.Ven 
join flagdata  tt on tt.SeriesInstanceUID= ws.Truth 
GROUP BY    ws.StudyInstanceUID;

.quit
