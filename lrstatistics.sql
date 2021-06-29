-- cat qastats/*/lstat.csv > qastats/lstat.csv
-- cat lrstatistics.sql  | sqlite3
-- sqlite3 -init lrstatistics.sql
.mode csv
--.import qastats/lstat.csv  tmplstat
.import qastatslr/lstat.csv  tmplstat

-- cleanup
create table lstat  as
select InstanceUID,SegmentationID,FeatureID,LabelID,Mean,StdD,Max,Min,cast(Count as int) Count,`Vol.mm.3`,ExtentX,ExtentY,ExtentZ from tmplstat where cast(Count as int) >0 ;

-- select HCCDate from datekey;
.headers on

create table volumestats  as
select lt.InstanceUID,1  LabelID,
            max(CASE WHEN lt.SegmentationID='Truth.raw-1.nii.gz' and FeatureID = 'lirads.nii.gz' and lt.LabelID=1 THEN lt.Count ELSE NULL END) countlr1,
            max(CASE WHEN lt.SegmentationID='Truth.raw-1.nii.gz' and FeatureID = 'lirads.nii.gz' and lt.LabelID=2 THEN lt.Count ELSE NULL END) countlr2,
            max(CASE WHEN lt.SegmentationID='Truth.raw.nii.gz' and FeatureID= 'Truth.raw.nii.gz' and lt.LabelID=1 THEN lt.Count ELSE NULL END) compsize 
from lstat lt
GROUP BY   lt.InstanceUID
ORDER BY   lt.InstanceUID  ASC;
-- UNION
-- select lt.InstanceUID,2  LabelID,
--             max(CASE WHEN lt.SegmentationID='Truth.raw-2.nii.gz' and FeatureID = 'lirads.nii.gz' and lt.LabelID=3 THEN lt.Count ELSE NULL END) countlr3,
--             max(CASE WHEN lt.SegmentationID='Truth.raw-2.nii.gz' and FeatureID = 'lirads.nii.gz' and lt.LabelID=4 THEN lt.Count ELSE NULL END) countlr4,
--             max(CASE WHEN lt.SegmentationID='Truth.raw-2.nii.gz' and FeatureID = 'lirads.nii.gz' and lt.LabelID=5 THEN lt.Count ELSE NULL END) countlr5,
--             max(CASE WHEN lt.SegmentationID='Truth.raw.nii.gz' and FeatureID= 'Truth.raw.nii.gz' and lt.LabelID=2 THEN lt.Count ELSE NULL END) compsize 
-- from lstat lt
-- GROUP BY   lt.InstanceUID
-- ORDER BY   lt.InstanceUID  ASC;


create table widelstat  as
select lt.InstanceUID,cast(lt.LabelID as int) LabelID,
            max(CASE WHEN lt.SegmentationID='Truth.raw.nii.gz' and FeatureID = 'Art.raw.nii.gz' THEN lt.Mean ELSE NULL END)  ART,
            max(CASE WHEN lt.SegmentationID='Truth.raw.nii.gz' and FeatureID = 'lirads-1.nii.gz' THEN lt.Mean ELSE NULL END)  predict1,
            max(CASE WHEN lt.SegmentationID='Truth.raw.nii.gz' and FeatureID = 'lirads-2.nii.gz' THEN lt.Mean ELSE NULL END)  predict2,
            max(CASE WHEN lt.SegmentationID='Truth.raw.nii.gz' and FeatureID = 'Truth.raw.nii.gz'  THEN lt.Mean ELSE NULL END)  truth,
            lt.Count
from lstat lt
where lt.LabelID !=0
GROUP BY   lt.InstanceUID, lt.LabelID
ORDER BY   lt.InstanceUID  ASC, cast(lt.LabelID as int) ASC;


.output qastats/wide.csv  
select ws.InstanceUID  ptid, ws.*, vs.* from volumestats vs join  widelstat ws  on vs.InstanceUID = ws.InstanceUID and vs.LabelID = ws.LabelID ;
.quit
