select strain, count(distinct PLANT_ID), TYPE_OF_HARVEST, HARVEST_ROOM_NAME, HARVEST_DATE_MIN, HARVEST_DATE_MAX, sum(WET_WEIGHT) as wetweight, sum(BUD_WEIGHT) as debonedweight
from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS
where location = 'Vicksburg'
  and lower(HARVEST_ROOM_NAME) like '%cravo%'
group by strain, TYPE_OF_HARVEST, HARVEST_ROOM_NAME, HARVEST_DATE_MIN, HARVEST_DATE_MAX;



select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTS where PLANTCOUNT > 0 order by PLANTCOUNT desc

Create or replace table ANALYTICS_DB.CULTIVATION.Cravo_Placements_10_01_2019 as
select room, plant_id, end_dt from
(select plant_id, max(ROOM_NAME) as room, max(ROOM_END_TIME) as end_dt from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where LOCATION = 'Vicksburg' and ROOM_TYPE = 'Flowering' and lower(ROOM_NAME) like '%cravo%' and ROOM_END_TIME >= '2019-10-01' group by PLANT_ID) group by room, PLANT_ID, end_dt;

select strain, id, sum(wetweight) as wet_weight, count(distinct id) as plants from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTS where ID in (select distinct plant_id from ANALYTICS_DB.CULTIVATION.Cravo_Placements_10_01_2019 where room = 'Cravo South') and strain like '%Hash%' group by strain, id;

select strain, id, sum(wetweight) as wet_weight, count(distinct id) as plants from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTS where ID in (select distinct PLANT_ID from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where strain = 'Hash Berry Chocolope' and BRTH_DT >= '2019-06-01' and LOCATION = 'Vicksburg') and strain like '%Hash%' and WETWEIGHT > 0 group by strain, id;


select * from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS where lower(HARVEST_ROOM_NAME) like '%cravo%' and HARVEST_DATE_MIN >= '2019-10-01';

select * from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS where PLANT_ID = '0890128593294343';

select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.plants where id = '0890128593294343'

select distinct PLANT_ID from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where strain = 'Hash Berry Chocolope' and BRTH_DT >= '2019-06-01' and LOCATION = 'Vicksburg'-- PLANT_ID = '2180235165305996';
select * from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where HARVESTGROUPID = '3077';-- PLANT_ID = '2901084224424301';

5795114495721133

select distinct strain from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where lower(strain) like '%cookie%'


select * FROM FIVETRAN_DB.BT_ENCANTO_PUBLIC.ROOMS WHERE ID = '114'

HARVESTGROUPID
('3455'
,'3456'
,'3402'
,'3394'
,'3381'
,'3396'
,'3382'
,'3378'
,'3361'
,'3360'
,'3354'
,'3333'
,'3335'
,'3330')


SELECT * FROM ANALYTICS_DB.CULTIVATION.PLANT_YIELDS WHERE HARVESTGROUPID IN ('3455'
,'3456'
,'3402'
,'3394'
,'3381'
,'3396'
,'3382'
,'3378'
,'3361'
,'3360'
,'3354'
,'3333'
,'3335'
,'3330')


select distinct ROOM_NUMBER from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS



select b.name,
       a.ID,
       a.STRAIN,
       STRAINTYPE,
       WEIGHT,
       DISPENSED,
       DISPENSEDSOFAR,
       TRANSACTIONID,
       TRANSFERREDOUT,
       TRANSFERREDOUTTIME,
       DISPENSEDTIME,
       PLANTID,
       ADJUSTEDSOFAR,
       a.LOCATION,
       SESSIONTIME,
       BYPRODUCT,
       REMAININGWEIGHT,
       TRANSFERREDIN,
       TRANSFERREDINTIME,
       TRANSFERREDFROM,
       TRANSFERREDTO,
       PRODUCTID,
       PARENTID,
       a.ISMEDICATED,
       a.REQUIRESWEIGHING,
       QUANTITY,
       PRICEIN,
       VENDORID,
       PRICEOUT,
       CONTAINERWEIGHT,
       a.DELETED,
       COMBINEDWEIGHT,
       a.INVENTORYTYPE,
       PLANTCOUNT,
       ROOMDATA,
       LASTACTION,
       LASTUSER,
       PLANTDATA,
       PLANTDATATYPE,
       PLANTLOCATION,
       PLANTADDITIVES,
       WET,
       GRADE,
       BATCHNO,
       LASTROOM,
       INVENTORYPARENTID,
       SECONDARYID,
       PACKAGEWEIGHT,
       INVENTORYSTATUS,
       INVENTORYSTATUSTIME,
       CURRENTROOM,
       TESTED,
       TEST_SENT,
       SAMPLE_ID,
       TEST_RESULT,
       EXPIRATION,
       LOCAL_CREATED,
       PACKAGEDATE,
       SEIZED,
       SOURCE_ID,
       TRANSACTIONID_ORIGINAL,
       a.REPLICATION_VAL,
       INVENTORY_VALUATION_COGS_EXPENSED,
       COST_PER_UNIT,
       a.CREATED,
       IS_SAMPLE,
       USE_BY,
       CUSTOM_1,
       IS_MEDICAL,
       CUSTOM_2,
       THC_CBD_RATIO,
       CUSTOM_DATA,
       CUSTOM_DATA_2,
       CUSTOM_3,
       CUSTOM_4,
       IN_PROCESS,
       CUSTOM_DATA_3,
       REMOVEREASON,
       REMOVE_REASON_EXTENDED,
       EXPIRATION_TIMESTAMP,
       a._FIVETRAN_SYNCED,
       a._FIVETRAN_DELETED,
       USABLEWEIGHTPERUNIT,
       AC_OUTPUT_ITEM
from FIVETRAN_DB.BT_MEDMAR_LAKEVIEW_PUBLIC.INVENTORY a
left join FIVETRAN_DB.BT_MEDMAR_LAKEVIEW_PUBLIC.PRODUCTS b on a.PRODUCTID = b.id
where a.REMAININGWEIGHT > 0
  and a.DELETED = 0
--  and weight = 14;


select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_START is null



select strain, count(distinct PLANT_ID), ROOM_NUMBER
from ANALYTICS_DB.CULTIVATION.CURRENTLY_IN_FLOWERING
where LOCATION = 'Joliet'
group by strain, ROOM_NUMBER;

select strain,  count(distinct plant_id) as plants, max(room_begin_time) as begintime, max(location) as location from
(
select min(ROOM_BEGIN_TIME) as room_begin_time, a.STRAIN, max(a.ROOM_NUMBER) as room_number, a.LOCATION, max(a.room_front_back) as room_front_back,  a.PLANT_ID from analytics_db.cultivation.BT_PLANT_CYCLES a
left join analytics_db.cultivation.PLANT_YIELDS b
on a.PLANT_ID = b.PLANT_ID

    where  (a.PHASE = 'Flowering') and  BRTH_DT > '2019-01-01' and b.PLANT_ID is null
and ((a.plant_id in (select distinct id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTS where DELETED = 0 and phase = 4) and a.location = 'Joliet')

or (a.plant_id in (select distinct id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS where DELETED = 0 and phase = 4) and a.location = 'Lincoln')

or (a.plant_id in (select distinct id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTS where DELETED = 0 and phase = 4) and a.location = 'Kankakee'))
and a.LOCATION = 'Kankakee'
group by  a.STRAIN, a.PLANT_ID, a.location)
group by strain
;





select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.REPLICATION_HISTORY where NEW_VAL like '%9981556498344882%' or PRIMARY_VAL like '%9981556498344882%'


select NEWROOM, ROOM_NAME, max(PLANT_ID) from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where LOCATION = 'Joliet' and ROOM_BEGIN_TIME > '2019-07-09' group by NEWROOM, ROOM_NAME;


select NEWROOM, ROOM_NAME from ANALYTICS_DB.CULTIVATION.PLANT_CYCLES_F_ROOM where LOCATION = 'Kankakee' group by NEWROOM, ROOM_NAME;
--select max(room_begin_time) from ANALYTICS_DB.CULTIVATION.PLANT_CYCLES_F_ROOM

select room, room_start, count(distinct plant_id), location
from (select PLANT_ID,
             min(case when lower(room_number) like '%cravo%' THEN ROOM_NAME ELSE ROOM_NUMBER END)                                                  as room,
             CONCAT(MONTH(max(ROOM_BEGIN_TIME)),'-', YEAR(max(ROOM_BEGIN_TIME))) as Room_Start, location
      from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES
      where ROOM_TYPE = 'Flowering' and ROOM_BEGIN_TIME >= '2019-01-01' and location = 'Joliet'
      group by PLANT_ID, LOCATION)
group by room, Room_Start, location;



select * from FIVETRAN_DB.ASAHI_POSTGRES_PROD_PUBLIC.INVENTORY where LOCATION_ID in (20) and cultivator = 'Cresco Labs' and BT_REMAINING_QUANTITY > 2  and DELETED is null-- and usage_type = 'medical'


select * from FIVETRAN_DB.ASAHI_POSTGRES_PROD_PUBLIC.LOCATIONS

select distinct level, PRODUCT_NAME from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where PRODUCT_NAME is not null and PRODUCT_NAME not like '%Flower Lot%'



select * from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS where lower(HARVEST_ROOM_NAME) like '%cravo%' and TYPE_OF_HARVEST = 'Fresh Frozen' --and PLANT_ID in (select distinct id from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTS where DRYTIMESTART is not null and DRYTIMEEND is not null)

select * from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where PLANT_ID = '0170493740509772'
select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTS where id = '4851245151543819'




































select room, max(PREDICTED_NEXT_PLACEMENT_DATE), max(source) from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where room in ('131','133') and FACILITY = 'Joliet' group by room;
MAX(PREDICTED_NEXT_PLACEMENT_DATE)
2020-01-17
2020-01-17


/*Inserts for room 131: Durban - 38
                        Pheno 51 - 45
                        Pineapple Express - 35
                        Rocket Fuel - 10
                        Sojay Haze - 70
                        Wedding Crasher - 15
 */
/*
insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '131','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Durban Poison', 38, 38, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','131';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '131','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Pheno 51', 45, 45, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','131';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '131','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Pineapple Express', 35, 35, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','131';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '131','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Rocket Fuel', 10, 10, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','131';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '131','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Sojay Haze', 70, 70, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','131';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '131','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Wedding Crasher', 15, 15, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','131';


--/*Inserts for room 133: Durban - 38
--                        Pheno 51 - 45
--                        Pineapple Express - 35
--                        Rocket Fuel - 10
--                        Sojay Haze - 70
--                        Wedding Crasher - 15
-- */

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '133','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Durban Poison', 38, 38, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','133';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '133','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Pheno 51', 45, 45, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','133';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '133','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Pineapple Express', 35, 35, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','133';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '133','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Rocket Fuel', 10, 10, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','133';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '133','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Sojay Haze', 70, 70, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','133';

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL, 'Joliet', '133','2020-01-17','2020-01-20','2020-01-20',NULL,
           NULL, NULL, NULL, 'Wedding Crasher', 15, 15, NULL, 1, NULL,NULL,
           NULL, NULL,NULL,NULL,'Production Tool', 'Indoor','133';
*/


select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_START is null and room in ('131','133')


select distinct ROOM_NUMBER, ROOM_NAME from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where LOCATION = 'Lincoln' and ROOM_TYPE = 'Flowering'



select strain, room_number, count(distinct plant_id) as plants, max(room_begin_time) as begintime, max(location) as location from
(
select min(ROOM_BEGIN_TIME) as room_begin_time, a.STRAIN, max(a.ROOM_NUMBER) as room_number, a.LOCATION, max(a.room_front_back) as room_front_back,  a.PLANT_ID from analytics_db.cultivation.BT_PLANT_CYCLES a
left join analytics_db.cultivation.PLANT_YIELDS b
on a.PLANT_ID = b.PLANT_ID

    where  (a.ROOM_TYPE in ('Flowering') or phase = 'Flowering' ) and  BRTH_DT > '2019-01-01' and b.PLANT_ID is null
and (a.plant_id in (select distinct id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTS where DELETED = 0 ) and a.location = 'Kankakee')

and a.LOCATION = 'Kankakee'
group by  a.STRAIN, a.PLANT_ID, a.location)
group by strain, room_number
;

select strain, ROOM_BEGIN_TIME, ROOM_NAME, count(distinct PLANT_ID)
from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES
where LOCATION = 'Kankakee'
  and ROOM_NAME like '%Vert%Veg%'
group by strain, ROOM_BEGIN_TIME, ROOM_NAME;

Vert Veg - Tray 10a

select * from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES


select * from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS where LOCATION = 'Fall River'

select count(distinct PLANT_ID), strain, ROOM_NUMBER from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where  ROOM_NUMBER like '%11%' and (plant_id in (select distinct id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS where (STATE = 0) ) and location = 'Lincoln') group by strain, ROOM_NUMBER

PLANT_ID
0664535337595364
1580706330755893
0985246385345636
0614564027246557
3762901286150264


select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW

select * from ANALYTICS_DB.CULTIVATION.DEFAULT_WEIGHTS_YIELD
select * from ANALYTICS_DB.CULTIVATION.PLANT_PRODUCT_TRANSFER


select * from ANALYTICS_DB.CULTIVATION.MASTER_YIELD_TRACKER_UL where FACILITY = ZONE__ROOM;


select  FACILITY, ZONE__ROOM, max(case when ZONE__ROOM = 'Mini' THEN '340' ELSE  ROOM_CANOPY_SQUARE_FOOTAGE END) as ROOM_CANOPY_SQUARE_FOOTAGE from ANALYTICS_DB.CULTIVATION.MASTER_YIELD_TRACKER_UL group by FACILITY, ZONE__ROOM


































select  count(distinct PLANT_ID) as plants from ANALYTICS_DB.CULTIVATION.CURRENTLY_IN_FLOWERING  where LOCATION in ('Joliet','Kankakee','Lincoln')








select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY where id = '9783662148950258';

select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY where PLANTID is not null and CREATED >= '2019-01-01';

select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY where id = '4776915244648361';

select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY where id = '7358053286061367';

select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY where
                                                            INVENTORYPARENTID = '7358053286061367';

select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.REPLICATION_HISTORY where NEW_VAL like '%7358053286061367%' or PRIMARY_VAL like '%7358053286061367%';

--where PLANTID is null and PARENTID is null and INVENTORYTYPE = -1


select b.roomname, a.*
from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY a
         left join FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORYROOMS b on a.CURRENTROOM = b.id
where plantid is not null
  and CREATED >= '2019-01-01';

select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.ACTIONSTATUS

