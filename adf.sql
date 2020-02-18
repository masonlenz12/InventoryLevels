---1/23/2020 - 1/24/2020
--131 BH
select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where FACILITY = 'Joliet' and HARVEST_START is null



---1/16/2020
--131 FH
create table ANALYTICS_DB.CULTIVATION.PLANT_AUDIT as
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
select strain,  count(distinct plant_id) as Biotrack_plants, room_begin_time as begintime, max(location) as location, room_number, room_front_back, strain_join from
(
select min(ROOM_BEGIN_TIME) as room_begin_time, a.STRAIN, max(f.strain) as strain_join, min(a.ROOM_NUMBER) as room_number, a.LOCATION, min(a.room_front_back) as room_front_back, min(ROOM_NAME) as roomname,  a.PLANT_ID from analytics_db.cultivation.BT_PLANT_CYCLES a
left join analytics_db.cultivation.PLANT_YIELDS b
on a.PLANT_ID = b.PLANT_ID
left join demo_db.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER f
on lower(a.STRAIN) like f.KEYWORD
    where  (a.PHASE = 'Flowering') and  BRTH_DT > '2019-01-01' and b.PLANT_ID is null
and ((a.plant_id in (select distinct id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTS where DELETED = 0 and phase = 4) and a.location = 'Joliet')

or (a.plant_id in (select distinct id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS where DELETED = 0 and phase = 4) and a.location = 'Lincoln')

or (a.plant_id in (select distinct id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTS where DELETED = 0 and phase = 4) and a.location = 'Kankakee'))
group by  a.STRAIN, a.PLANT_ID, a.location)
group by strain, room_number,  room_front_back, strain_join, room_begin_time) a
left join (select strain, facility, room, sum(count) as count, sum(placement_count) as placement_count, plant_placement from demo_db.PRODUCTION_PLAN.PLACEMENT_NEW where harvest_date is null group by strain, facility, room, plant_placement) b
on case when lower(a.room_number) like '%zone%' then CONCAT('Bay',split_part(trim(a.room_number),' ',2))
    when (lower(a.room_number) in ('130','131') and room_front_back = 'FRONT' and location in ('Kankakee')) THEN concat('Flower ',room_number,' FH')
    when (lower(a.room_number) in ('130','131') and room_front_back = 'BACK' and location in ('Kankakee')) THEN concat('Flower ',room_number,' BH')
    else trim(a.room_number) END = trim(b.ROOM)
and lower(trim(a.strain_join)) = lower(trim(b.STRAIN))
and lower(a.location) = lower(b.FACILITY)
;

select * from ANALYTICS_DB.CULTIVATION.PLANT_AUDIT

select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW


select * from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where PLANT_ID = '1421403232913713';
---1/31/2020 KANK
STRAIN,PLANTS,BEGINTIME,LOCATION,ROOM_NUMBER
Katsu Bubba Kush,108,2019-12-20,Kankakee,130
Apple Rock Candy,47,2019-12-20,Kankakee,130
Rollins,74,2019-12-20,Kankakee,130
Face Mints,26,2019-12-20,Kankakee,130
Rollins,17,2019-12-20,Kankakee,No Specified Room
----KANKAKEE IS OKAY: potential issue is that the "Veg Room 130" is categorized as Flowering (no way to differenciate flowering/veg for this group)


-----Joliet
STRAIN,PLANTS,BEGINTIME,LOCATION,ROOM_NUMBER
Sojay Haze,241,2019-12-27,Joliet,130
----We have 233
Wedding Crasher,15,2020-01-20,Joliet,131
Sojay Haze,70,2020-01-20,Joliet,131
Pheno 51,45,2020-01-20,Joliet,131
Pineapple Express,35,2020-01-20,Joliet,131
Rocket Fuel,10,2020-01-20,Joliet,131
Durban Poison,38,2020-01-20,Joliet,131
Durban Poison,32,2019-12-03,Joliet,132
Wedding Crasher,15,2020-01-20,Joliet,133
Rocket Fuel,10,2020-01-20,Joliet,133
Pineapple Express,35,2020-01-20,Joliet,133
Sojay Haze,70,2020-01-20,Joliet,133
Pheno 51,45,2020-01-20,Joliet,133
Durban Poison,38,2020-01-20,Joliet,133
Durban Poison,273,2019-12-18,Joliet,231
Rocket Fuel,125,2019-12-18,Joliet,231
Sojay Haze,46,2019-12-18,Joliet,231
Pineapple Express,55,2019-12-18,Joliet,231
Pheno 51,126,2019-12-18,Joliet,231
Durban Poison,187,2020-01-09,Joliet,232
Sojay Haze,60,2020-01-09,Joliet,232
Pineapple Express,210,2020-01-09,Joliet,232
Rocket Fuel,34,2020-01-09,Joliet,232
Pheno 51,143,2020-01-09,Joliet,232




select *
from ANALYTICS_DB.masonl.placementnew --where FACILITY = 'Lincoln'
;

select * from ANALYTICS_DB.masonl.placementnew_UPDATES where harvest_Start is null and facility = 'Kankakee'
--alter table DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
--add column FF_MODIFIER number;


---TESTING Flower 131 FH	PLACEMENT_COUNT

--~274
select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_new where HARVEST_START is null

__INDEX__,FACILITY,ROOM,PREDICTED_PLACEMENT_DATE,START_PLACEMENT,PLANT_PLACEMENT,PREDICTED_HARVEST_DATE,HARVEST_START,HARVEST_DATE,READY_FOR_SALE,STRAIN,PLACEMENT_COUNT,COUNT,PREDICTED_NEXT_PLACEMENT_DATE,Yield_Mod,TRIGGER_DATE_1,TRIGGER_DATE_2,TRIGGER_DATE_3,STRAIN_TYPE,CLONE,VEGETATIVE,SOURCE,CULTIVATION_ENVIRONMENT,ROOM_NAME_ORIGINAL,FF_MODIFIER
,Joliet,133,2020-01-17,2020-01-20,2020-01-20,2020-03-23,,,2020-04-13,Sojay Haze,70,70,2020-03-25,1,53,55,60,Sativa,-12,-42,Production Tool,Indoor,133,



select * from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES where LOCATION = 'Lincoln'

select * from DEMO_DB.PRODUCTION_PLAN.MITTO_USER_ADJUSTMENT



select * from ANALYTICS_DB.CULTIVATION.PLANT_AUDIT

select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_START is null and room = '232'  ;
--              JOL232 durban -2 unfinished
--                JOL231 RF - 1 we updated and got rid of extra line item
--Harvest Lincoln - bay3 on feb1 until feb3

select DOMO_HARVEST_DATE,
       PLANNER_HARVEST_DATE,
       LOCATION,
       ROOM_NUMBER,
       STATE,
       PLACEMENTGROUP,
       PLACEMENT_DATE,
       ROOM_CANOPY,
       CULTIVATION_ENVIRONMENT,
       STRAIN_RD,
       STRAIN,
       DRY_PLANTS,
       FF_PLANTS,
       TOTAL_PLANTS,
       TOTAL_WET_WEIGHT,
       TOTAL_WET_WEIGHT_NEW,
       FRESH_FROZEN_WET_WEIGHT,
       DRY_BUDS_WET_WEIGHT,
       WET_TO_DRY_RATIO,
       TOTAL_BUD_WEIGHT,
       FRESH_FROZEN_BUD_WEIGHT,
       DRY_BUDS_BUD_WEIGHT,
       BARCODE1_BIOTRACK,
       BARCODE2_BIOTRACK,
       DATA_SOURCE,
       STRAIN_TYPE
from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS


----Against Cultivation Yields
select a.strain, b.strain as bstrain, b.keyword from
(select distinct strain from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS
    UNION
select distinct strain from ANALYTICS_DB.BUSINESS.LAB_EXTRACTION
    UNION
select distinct strain from ANALYTICS_DB.BUSINESS.CULTIVATION_PROCESSING
    ) a
left join DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER_test b
on coalesce( lower(a.strain) like b.keyword , a.strain = b.strain )
where b.strain is null
;


select a.strain, a.state, b.strain as bstrain, b.keyword from
(select distinct strain, state from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS) a
left join DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER_test b
on coalesce( lower(a.strain) like b.keyword , a.strain = b.strain )
    where b.strain is null;


-----Against Extraction



----No match so far
STRAIN,BSTRAIN,KEYWORD
Lemon Bean,,
Bubba Kush,,
Grease Monkey,,
Super Silver Haze #9,,
Zkittlez,,
Sour Skywalker,,
Kindness #2,,
Sunflower,,
MAC ,,
Red Line Haze,,
Gorilla Train Haze,,
Super Silver Haze #10,,
Querkle,,
Kush 52,,
Lemon AK,,
MAC 7,,
Prayer Tower #2,,
Silver Kush #6,,
Orange 43 #9,,
DreamWeaver,,
Grape Ape,,
Sherbet,,
Lucid Blue #6,,
Lemon OG,,

select * from DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER_test

select * from DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER a
left join
DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER_test b
on a.keyword = b.KEYWORD
and a.strain = b.strain
and a.type = b.TYPE
where b.keyword is null
/*


 */



select * from FIVETRAN_DB.ASAHI_POSTGRES_PROD_PUBLIC.INVENTORY where LOCATION_ID = 20 and remaining_qty_med > 1 and deleted is null;


select * from FIVETRAN_DB.ASAHI_POSTGRES_PROD_PUBLIC.LOCATIONS;


