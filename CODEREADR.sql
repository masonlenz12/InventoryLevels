--CREATE OR replace TABLE demo_db.PUBLIC.unnestedscans as
--SELECT parse_json(answer) AS ANSWER_ARRAY, * FROM "DEMO_DB"."PUBLIC"."SCANS" WHERE answer IS NOT null;


--CREATE OR REPLACE table demo_db.PUBLIC.unnestedscans as
--SELECT
--     unnested_neighbors.value, t1.*
--FROM demo_db.PUBLIC.unnestedscans t1, TABLE(flatten(t1.answer_array)) as unnested_neighbors;


--CREATE OR REPLACE table demo_db.PUBLIC.unnestedscans_final as
--SELECT REPLACE(value['qid'],'"','') AS Question_id, REPLACE(value['qtext'],'"','') AS question_text, REPLACE(value['answer'],'"','') AS Answer_Actual, CASE WHEN value['answer'] LIKE '%link%' then parse_json(value['answer']) ELSE value['answer'] END AS PHOTO_LINK , * FROM
--demo_db.PUBLIC.unnestedscans;


--CREATE OR REPLACE TABLE demo_db.PUBLIC.unnestedscans_final as
--SELECT replace(PHOTO_LINK['link'],'"','') AS PHOTO_LINK_FINAL, * FROM
--demo_db.PUBLIC.unnestedscans_final ;



select distinct STRAIN, ROOM_NUMBER ,PLACEMENT_DATE,FRESH_FROZEN_WET_WEIGHT ,FRESH_FROZEN_BUD_WEIGHT,1- (FRESH_FROZEN_BUD_WEIGHT/FRESH_FROZEN_WET_WEIGHT) from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS where STATE = 'AZ' and FRESH_FROZEN_WET_WEIGHT > 0




select
       LAB_NAME,

       STRAIN,
       CATEGORY,
       TYPE,
       CLASSIFICATION,

case when TERPENES_CAMPHOR = '<LOQ' OR TERPENES_CAMPHOR = NULL THEN 0 ELSE TERPENES_CAMPHOR END as TERPENES_CAMPHOR,
       case when TERPENES_ALPHA_BISABOLOL = '<LOQ' OR TERPENES_ALPHA_BISABOLOL = NULL THEN 0 ELSE TERPENES_ALPHA_BISABOLOL END as TERPENES_ALPHA_BISABOLOL,
       case when TERPENES_ALPHA_PINENE = '<LOQ' OR TERPENES_ALPHA_PINENE = NULL THEN 0 ELSE TERPENES_ALPHA_PINENE END as TERPENES_ALPHA_PINENE,
       case when TERPENES_EUCALYPTOL = '<LOQ' OR TERPENES_EUCALYPTOL = NULL THEN 0 ELSE TERPENES_EUCALYPTOL END as TERPENES_EUCALYPTOL,
       case when TERPENES_ALPHA_TERPINENE = '<LOQ' OR TERPENES_ALPHA_TERPINENE = NULL THEN 0 ELSE TERPENES_ALPHA_TERPINENE END as TERPENES_ALPHA_TERPINENE,
       case when TERPENES_NEROL = '<LOQ' OR TERPENES_NEROL = NULL THEN 0 ELSE TERPENES_NEROL END as TERPENES_NEROL,
       case when TERPENES_GERANIOL = '<LOQ' OR TERPENES_GERANIOL = NULL THEN 0 ELSE TERPENES_GERANIOL END as TERPENES_GERANIOL,
       case when TERPENES_GUAIOL = '<LOQ' OR TERPENES_GUAIOL = NULL THEN 0 ELSE TERPENES_GUAIOL END as TERPENES_GUAIOL,
       case when TERPENES_ISOBORNEOL = '<LOQ' OR TERPENES_ISOBORNEOL = NULL THEN 0 ELSE TERPENES_ISOBORNEOL END as TERPENES_ISOBORNEOL,
       case when TERPENES_FENCHOL = '<LOQ' OR TERPENES_FENCHOL = NULL THEN 0 ELSE TERPENES_FENCHOL END as TERPENES_FENCHOL,
       case when TERPENES_BETA_PINENE = '<LOQ' OR TERPENES_BETA_PINENE = NULL THEN 0 ELSE TERPENES_BETA_PINENE END as TERPENES_BETA_PINENE,
--       case when TERPENES_BETA_MYRCENE = '<LOQ' OR TERPENES_BETA_MYRCENE = NULL THEN 0 ELSE TERPENES_BETA_MYRCENE END as TERPENES_BETA_MYRCENE,
       coalesce(TERPENES_BETA_MYRCENE, 0) as TERPENES_BETA_MYRCENE,
       case when TERPENES_MENTHOL = '<LOQ' OR TERPENES_MENTHOL = NULL THEN 0 ELSE TERPENES_MENTHOL END as TERPENES_MENTHOL,
       case when TERPENES_CARYOPHYLLENE_OXIDE = '<LOQ' OR TERPENES_CARYOPHYLLENE_OXIDE = NULL THEN 0 ELSE TERPENES_CARYOPHYLLENE_OXIDE END as TERPENES_CARYOPHYLLENE_OXIDE,
       case when TERPENES_OCIMENE = '<LOQ' OR TERPENES_OCIMENE = NULL THEN 0 ELSE TERPENES_OCIMENE END as TERPENES_OCIMENE,
       case when TERPENES_PULEGONE = '<LOQ' OR TERPENES_PULEGONE = NULL THEN 0 ELSE TERPENES_PULEGONE END as TERPENES_PULEGONE,
       case when TERPENES_ALPHA_CEDRENE = '<LOQ' OR TERPENES_ALPHA_CEDRENE = NULL THEN 0 ELSE TERPENES_ALPHA_CEDRENE END as TERPENES_ALPHA_CEDRENE,
       case when TERPENES_SABINENE_HYDRATE = '<LOQ' OR TERPENES_SABINENE_HYDRATE = NULL THEN 0 ELSE TERPENES_SABINENE_HYDRATE END as TERPENES_SABINENE_HYDRATE,
       case when TERPENES_RO_CYMENE = '<LOQ' OR TERPENES_RO_CYMENE = NULL THEN 0 ELSE TERPENES_RO_CYMENE END as TERPENES_RO_CYMENE,
       case when TERPENES_CAMPHENE = '<LOQ' OR TERPENES_CAMPHENE = NULL THEN 0 ELSE TERPENES_CAMPHENE END as TERPENES_CAMPHENE,
       case when TERPENES_BORNEOL = '<LOQ' OR TERPENES_BORNEOL = NULL THEN 0 ELSE TERPENES_BORNEOL END as TERPENES_BORNEOL,
       case when TERPENES_CEDROL = '<LOQ' OR TERPENES_CEDROL = NULL THEN 0 ELSE TERPENES_CEDROL END as TERPENES_CEDROL,
       case when TERPENES_DELTA_3_CARENE = '<LOQ' OR TERPENES_DELTA_3_CARENE = NULL THEN 0 ELSE TERPENES_DELTA_3_CARENE END as TERPENES_DELTA_3_CARENE,
       case when TERPENES_VALENCENE = '<LOQ' OR TERPENES_VALENCENE = NULL THEN 0 ELSE TERPENES_VALENCENE END as TERPENES_VALENCENE,
       case when TERPENES_ALPHA_HUMULENE = '<LOQ' OR TERPENES_ALPHA_HUMULENE = NULL THEN 0 ELSE TERPENES_ALPHA_HUMULENE END as TERPENES_ALPHA_HUMULENE,
 --      case when TERPENES_BETA_CARYOPHYLLENE = '<LOQ' OR TERPENES_BETA_CARYOPHYLLENE = NULL THEN 0 ELSE TERPENES_BETA_CARYOPHYLLENE END as TERPENES_BETA_CARYOPHYLLENE,
       coalesce(TERPENES_BETA_CARYOPHYLLENE, 0) as TERPENES_BETA_CARYOPHYLLENE,
       case when TERPENES_TERPINOLENE = '<LOQ' OR TERPENES_TERPINOLENE = NULL THEN 0 ELSE TERPENES_TERPINOLENE END as TERPENES_TERPINOLENE,
       case when TERPENES_TRANS_NEROLIDOL = '<LOQ' OR TERPENES_TRANS_NEROLIDOL = NULL THEN 0 ELSE TERPENES_TRANS_NEROLIDOL END as TERPENES_TRANS_NEROLIDOL,
       case when TERPENES_GERANYL_ACETATE = '<LOQ' OR TERPENES_GERANYL_ACETATE = NULL THEN 0 ELSE TERPENES_GERANYL_ACETATE END as TERPENES_GERANYL_ACETATE,
       case when TERPENES_GAMMA_TERPINENE = '<LOQ' OR TERPENES_GAMMA_TERPINENE = NULL THEN 0 ELSE TERPENES_GAMMA_TERPINENE END as TERPENES_GAMMA_TERPINENE,
       case when TERPENES_ALPHA_PHELLANDRENE = '<LOQ' OR TERPENES_ALPHA_PHELLANDRENE = NULL THEN 0 ELSE TERPENES_ALPHA_PHELLANDRENE END as TERPENES_ALPHA_PHELLANDRENE,
       case when TERPENES_S_PAREN__PAREN_LIMONENE = '<LOQ' OR TERPENES_S_PAREN__PAREN_LIMONENE = NULL THEN 0 ELSE TERPENES_S_PAREN__PAREN_LIMONENE END as TERPENES_S_PAREN__PAREN_LIMONENE,
 --      case when TERPENES_TERPENES_UNIT = '<LOQ' OR TERPENES_TERPENES_UNIT = NULL THEN 0 ELSE TERPENES_TERPENES_UNIT END as TERPENES_TERPENES_UNIT,
       coalesce(TERPENES_TERPENES_UNIT, 'ppm') as TERPENES_TERPENES_UNIT,
       case when TERPENES_SABINENE = '<LOQ' OR TERPENES_SABINENE = NULL THEN 0 ELSE TERPENES_SABINENE END as TERPENES_SABINENE,
       case when TERPENES_ISOPULEGOL = '<LOQ' OR TERPENES_ISOPULEGOL = NULL THEN 0 ELSE TERPENES_ISOPULEGOL END as TERPENES_ISOPULEGOL,
       case when TERPENES_CIS_NEROLIDOL = '<LOQ' OR TERPENES_CIS_NEROLIDOL = NULL THEN 0 ELSE TERPENES_CIS_NEROLIDOL END as TERPENES_CIS_NEROLIDOL,
       case when TERPENES_FENCHONE = '<LOQ' OR TERPENES_FENCHONE = NULL THEN 0 ELSE TERPENES_FENCHONE END as TERPENES_FENCHONE,
       case when TERPENES_LINALOOL = '<LOQ' OR TERPENES_LINALOOL = NULL THEN 0 ELSE TERPENES_LINALOOL END as TERPENES_LINALOOL,
       case when TERPENES_ALPHA_TERPINEOL = '<LOQ' OR TERPENES_ALPHA_TERPINEOL = NULL THEN 0 ELSE TERPENES_ALPHA_TERPINEOL END as TERPENES_ALPHA_TERPINEOL
from ANALYTICS_DB.QUALITY.mitto_testing_il
;


describe table ANALYTICS_DB.QUALITY.mitto_testing_il


select max(PRODUCT_NAME) as productname, loc, min(coalesce(QUANTITY, REMAININGWEIGHT)) as minquantity, max(coalesce(QUANTITY, REMAININGWEIGHT)) as maxquantity, min(SESSIONDATE) as Min_Date, max(SESSIONDATE) as max_Date, ORIGINATINGINVID from (select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL order by sessiondate asc)  group by  loc, INVENTORYTYPE, ORIGINATINGINVID having Min_Date <> max_Date



select a.ORIGINATINGINVID, startDT, qty, b.INVENTORYTYPE, a.loc, max(b.sessiondate) as maxdt, min(b.SESSIONDATE) as minmaxdate,  max(PRODUCT_NAME) as productname  from (select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL order by sessiondate asc) b
left join (select ORIGINATINGINVID, inventorytype, min(sessiondate) as startDT, min(weight) as qty, loc from (Select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL ORDER BY SESSIONDATE ASC) where INVENTORYTYPE in (13,17) and INVENTORY_ID = ORIGINATINGINVID group by ORIGINATINGINVID, loc, inventorytype) a
on b.ORIGINATINGINVID = a.ORIGINATINGINVID
and case when b.INVENTORYTYPE = 28 then 13 else a.INVENTORYTYPE end = a.inventorytype
where  DELETED = 0
and a.ORIGINATINGINVID is not null
and b.PRODUCT_NAME is not null
and b.INVENTORYTYPE not in (13,17)
group by a.ORIGINATINGINVID, startDT, qty, b.INVENTORYTYPE, a.loc;


select * from ANALYTICS_DB.CULTIVATION.plant_audit

select * from ANALYTICS_DB.CULTIVATION.CURRENTLY_IN_FLOWERING where ROOM_NUMBER = 'Zone 4' and LOCATION = 'Lincoln' group by strain, ROOM_NUMBER



select begintime,
       location,
       room_number,
       room_front_back,
       strain_join, Biotrack_plants,  b.COUNT as Planner_Curr_Count,b.placement_count as Planner_Placement_Count ,b.STRAIN,
       case when a.Biotrack_plants = b.count THEN 'MATCHED' when (a.biotrack_plants < b.count or a.biotrack_plants > b.count) THEN concat('Mis-matched by :',cast( cast(a.Biotrack_plants as int ) - cast(b.count as int) as string),' Plants')
           ELSE 'No-Match'
           END as Planner_Biotrack_MisMatch
       from
(
select strain,  count(distinct plant_id) as Biotrack_plants, min(room_begin_time) as begintime, max(location) as location, room_number, room_front_back, strain_join from
(
select min(ROOM_BEGIN_TIME) as room_begin_time, a.STRAIN, max(f.strain) as strain_join, min(a.ROOM_NUMBER) as room_number, a.LOCATION, min(a.room_front_back) as room_front_back, min(ROOM_NAME) as roomname,  a.PLANT_ID from analytics_db.cultivation.BT_PLANT_CYCLES a
left join analytics_db.cultivation.PLANT_YIELDS b
on a.PLANT_ID = b.PLANT_ID
left join demo_db.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER f
on lower(a.STRAIN) like f.KEYWORD
    where  (a.PLANT_ID in (select distinct PLANT_ID from ANALYTICS_DB.CULTIVATION.CURRENTLY_IN_FLOWERING))
group by  a.STRAIN, a.PLANT_ID, a.location)
group by strain, room_number,  room_front_back, strain_join) a
left join (select strain, facility, room, sum(count) as count, sum(placement_count) as placement_count, plant_placement from demo_db.PRODUCTION_PLAN.PLACEMENT_NEW where harvest_date is null group by strain, facility, room, plant_placement) b
on case when lower(a.room_number) like '%zone%' then CONCAT('Bay',split_part(trim(a.room_number),' ',2))
    when (lower(a.room_number) in ('130','131') and room_front_back = 'FRONT' and location in ('Kankakee')) THEN concat('Flower ',room_number,' FH')
    when (lower(a.room_number) in ('130','131') and room_front_back = 'BACK' and location in ('Kankakee')) THEN concat('Flower ',room_number,' BH')
    when (lower(a.room_number) in ('130','131', '204') and room_front_back not in ('BACK','FRONT') and location in ('Kankakee')) THEN concat('Flower ',room_number)

    else trim(a.room_number) END = trim(b.ROOM)
and lower(trim(a.strain_join)) = lower(trim(b.STRAIN))
and lower(a.location) = lower(b.FACILITY)
;

select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where ORIGINATINGINVID = '0568041448922596'

select * from ANALYTICS_DB.CULTIVATION.FLOWER_CURE_CURRENT


Create or replace table Flower_cure_current as
select *, product_name as productid
from analytics_db.cultivation.level_final
where deleted = 0
  and transferredout = 0
  and inventorytype = 13
  and ((lower(inventoryroom_name) like '%vault%' and lower(inventoryroom_name) like '%flower%') or
       (lower(inventoryroom_name) like '%vault%' and loc in ('LNL', 'KKE')) or (lower(inventoryroom_name) like '%cure%room%'))
  and lower(inventoryroom_name) not like '%pre%'
  and remainingweight > 0;
--62
--34



