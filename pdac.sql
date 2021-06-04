-- cat methodist.sql  | sqlite3 dicom/ctkDICOM.sql
-- sqlite3  -init pdac.sql dicom/ctkDICOM.sql
.headers on
attach database ':memory:' as tmp;
-- .mode csv
-- .import dicom/EDRNidentifiers.csv  tmp.edrn
-- sqlite> select distinct im.seriesDescription from series im;
-- Portal resampled
-- LIVER/PANCREAS
-- PRE resampled
-- Series Description
-- POS CONTRAST
-- Pre resampled
-- POST CONTRAST
-- Pre-10112010 resampled
-- PV-10112010 resampled
-- Recon 2: POST CONTRAST
-- PV resampled
-- Recon 2: LIVER 3 PHASE (AP)
-- PRE LIVER resampled
-- 3.75
-- OSF-PV resampled

create table tmp.flagdata  as
select im.StudyInstanceUID,im.SeriesInstanceUID,im.seriesDescription,
CASE WHEN im.seriesDescription like '%PRE%'        THEN 'Pre'
     WHEN (im.seriesDescription like '%port%' or im.seriesDescription like '%PV%' )  THEN 'Ven'
     WHEN im.seriesDescription == 'Series Description' THEN 'Truth'
     ELSE 'Art' END AS ImageType
from series im ;
