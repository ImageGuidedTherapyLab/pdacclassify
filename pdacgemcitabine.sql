-- cat pdacgemcitabine.sql | sqlite3 
-- sqlite3  -init pdacgemcitabine.sql 
.headers on
-- attach database ':memory:' as tmp;
attach database 'dicom/ctkDICOM.sql' as sl;
.mode csv
.import dicom/NNdatabase06_04updated.csv  edrn

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
select sd.PatientsUID,pt.PatientID,im.StudyInstanceUID,im.SeriesInstanceUID,im.seriesDescription,im.SeriesDate,
CASE WHEN (im.seriesDescription == "PreXRT-PRE  resampled" or im.seriesDescription == "PRE LIVER resampled" or im.seriesDescription == "PostXRT-Pre resampled" or im.seriesDescription == "PreXRT-Pre resampled" or im.seriesDescription == "PRE resampled" or im.seriesDescription == "PreXRT-PRE resampled")  THEN 'Pre'
     WHEN (im.seriesDescription like '%Port%' or im.seriesDescription like '%port%' or im.seriesDescription like '%ven%'or im.seriesDescription like '%PV%' )  THEN 'Ven'
     WHEN (im.seriesDescription == 'normal pancreas' or im.seriesDescription == 'Series Description' or im.seriesDescription == 'SeriesDescription') THEN 'Truth'
     ELSE 'Art' END AS ImageType
from sl.series im 
join sl.studies  sd on sd.StudyInstanceUID = im.StudyInstanceUID
join sl.patients pt on sd.PatientsUID = pt.UID;
-- select * from flagdata where ImageType = 'Ven';

create table labeldatatmp  as
select *,ROW_NUMBER() OVER( partition by PatientsUID  ORDER BY SeriesInstanceUID) AS truthid  from flagdata where ImageType = 'Truth';
select max(truthid) from labeldatatmp  ;
create table labeldata  as
select *, 'Truth'||truthid truthlabel  from labeldatatmp;

create table widestudy  as
select fg.PatientsUID PatientsUID,fg.PatientID PatientID,ed.DeltaScore,fg.StudyInstanceUID StudyInstanceUID,
            max(CASE WHEN fg.ImageType = 'Pre' THEN fg.SeriesInstanceUID       ELSE NULL END)  Pre,
            max(CASE WHEN fg.ImageType = 'Art' THEN fg.SeriesInstanceUID       ELSE NULL END)  Art,
            max(CASE WHEN fg.ImageType = 'Ven' THEN fg.SeriesInstanceUID       ELSE NULL END)  Ven,
            max(CASE WHEN ld.truthlabel = 'Truth1' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth1,
            max(CASE WHEN ld.truthlabel = 'Truth2' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth2,
            max(CASE WHEN ld.truthlabel = 'Truth3' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth3,
            max(CASE WHEN ld.truthlabel = 'Truth4' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth4,
            max(CASE WHEN ld.truthlabel = 'Truth5' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth5,
            max(CASE WHEN ld.truthlabel = 'Truth6' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth6,
            max(CASE WHEN ld.truthlabel = 'Truth7' THEN ld.SeriesInstanceUID     ELSE NULL END)  Truth7
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

---- wide format
--.mode csv
--.output dicom/wideformat.csv 
--select ws.*,dn.seriesDescription PreDescription , an.seriesDescription ArtDescription, pt.seriesDescription VenDescription, tt.seriesDescription TruthDescription,
--rtrim(di.Filename, replace(di.Filename, '/', '')) PreFilename,
--rtrim(ai.Filename, replace(ai.Filename, '/', '')) ArtFilename,
--rtrim(pi.Filename, replace(pi.Filename, '/', '')) VenFilename,
--                           ti.Filename            TruthFilename
--from widestudy ws 
--join sl.images  di on di.SeriesInstanceUID= ws.Pre
--join sl.images  ai on ai.SeriesInstanceUID= ws.Art
--join sl.images  pi on pi.SeriesInstanceUID= ws.Ven
--join sl.images  ti on ti.SeriesInstanceUID= ws.Truth
--join flagdata  dn on dn.SeriesInstanceUID= ws.Pre
--join flagdata  an on an.SeriesInstanceUID= ws.Art
--join flagdata  pt on pt.SeriesInstanceUID= ws.Ven 
--join flagdata  tt on tt.SeriesInstanceUID= ws.Truth 
--GROUP BY    ws.StudyInstanceUID;
--
--.quit
