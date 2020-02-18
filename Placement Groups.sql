select distinct room, placement_date from     (select max(a.room) as room, max(a.placement_date) as placement_Date, max(c.strain) as strain, c.plant_id as plant_id, concat(max(a.room),max(a.placement_date)) as PlacementGroup, max(a.location) as location, case when max(a.room_number) = 'MBM' then 'Mini-Bloom' else max(a.room_number) end as room_number, max(a.room_front_back) as room_front_back, max(c.RoomNumber) as ROOM_NBR_TAB  from
(select a.room, placement_date as placement_date,

 case when a.ROOM like '%KKE%' then 'Kankakee'
 when a.room like '%LNL%' then 'Lincoln'
 when a.room like '%JOL%' then 'Joliet'
 when a.room like '%Room%' then 'Encanto'
 when a.room like '%House%' then 'Vicksburg'

     else 'None Identified' end as Location,

 case when (a.ROOM like '%Bay%' and RIGHT(a.ROOM, 2) in ('10','11','12','13','14','15','16') )then Concat('Zone ', RIGHT(a.ROOM, 2))
 when (a.ROOM like '%Bay%')then Concat('Zone ', RIGHT(a.ROOM, 1))
 when a.room like '%KKE%' then RIGHT(a.ROOM, 3)
 when a.room like '%JOL%' then right(a.room, 3)
 when a.room like '%House%' then CONCAT('Flower House-',RIGHT(trim(a.room),1))
 when a.room like '%Room%' then TRIM(a.room)

 else 'None Identified' end as ROOM_NUMBER,

 case  when (a.room like '%KKE%' and LEFT(RIGHT(a.ROOM, 5), 2) = 'BH') then 'BACK'
 when (a.room like '%KKE%' and LEFT(RIGHT(a.ROOM, 5), 2) = 'FH') then 'FRONT'
  else 'No Room Divider' end as ROOM_FRONT_BACK

from (select LOCATION_ROOM as room,
      placement_date as Placement_date from ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES group by LOCATION_ROOM, placement_DATE) a ) a

left join (select Room_type, strain, room_begin_Time as room_begin_Time, ROOM_END_TIME as Room_End_Time, plant_id,  location, room_NAME as Roomname,
           case
           when room_number = 'Mini-Bloom' then 'MBM'
                                else room_number end as RoomNumberj,
                                           room_number as RoomNumber,
           room_front_back as Room_Front_back

from
ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES a
left join (

select  a.PLANTID ,a.DRYING as drying, a.NEWPHASE, a.NEWPHASETIME as newphasetime from
FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTPHASECHANGES a

where NEWPHASE = '4'


UNION
select  a.PLANTID ,a.DRYING as drying, a.NEWPHASE, a.NEWPHASETIME as newphasetime from

FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTPHASECHANGES a

where NEWPHASE = '4'
UNION
select  a.PLANTID ,a.DRYING as drying, a.NEWPHASE, a.NEWPHASETIME as newphasetime from

FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTPHASECHANGES a

where NEWPHASE = '4'
UNION
select  a.PLANTID ,a.DRYING as drying, a.NEWPHASE, a.NEWPHASETIME as newphasetime from

FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTPHASECHANGES a

where NEWPHASE = '4'

) b
on a.plant_id = b.plantid
and a.room_begin_time between DATEADD('day', -3,CAST(to_timestamp((b.NEWPHASETIME))as DATE)) and DATEADD('day', 40,CAST(to_timestamp((b.NEWPHASETIME))as DATE))
where

 (room_type = 'Flowering' or (room_type = 'Vegetative' and room_number = '130' and Room_Front_back = 'FRONT'))
and room_number <> ''
and (room_begin_time <> room_end_time or room_begin_time > DATEADD(day , -70,CURRENT_DATE()))
and (b.drying = '0' or b.drying is null)
and a.newstate in (0)
and ((room_end_time - room_begin_time) > 1 or room_begin_time > DATEADD(day , -70,CURRENT_DATE()))
 ) c
on a.ROOM_FRONT_BACK = c.Room_Front_back
and a.location = c.location
and LOWER(TRIM(a.room_number)) = LOWER(TRIM(c.RoomNumberj))
and room_begin_Time between DATEADD(day, -3, placement_date) and DATEADD(day, 40, placement_date)
where c.plant_ID is not null
group by  c.plant_id
)
;







































INVENTORY_ID
4391253649124825
7667337144176656
4315377300106727
0215305459405031
0235622879922387


--select * from
PO,DISPENSARY,STATE,DATE,SKU_NAME,PRICE,QUANTITY,REVENUE,GROSS_SALES,STATUS,BRAND,CATEGORY,FORM,TYPE,SIZE,ITEM_ID,STRAIN,STRAIN_TYPE,STRAIN_STATUS,PACKAGED_WEIGHT,DRY_EQUIVALENT_WEIGHT,GROW_FACILITY,SKU_VOLUME_GRAMS,SKU_VOLUME_DRY_EQUIVALENT_GRAMS,SALES_REP,EXTRACTION_METHOD,CBD_RATIO,PROJECT_ID,DISCOUNT,ZIP,FIPS,CRESCO_OWNED,IS_SAMPLE,SALES_REP_COMPANY,MSO_FLG,CULTIVATOR
Sales Order-SO-014274,HCI Alternatives - Collinsville,IL,2020-01-06,2:1 Harlequin - 1000mg RSO Syringe,30,94,2820,2820,Pending,Remedi,Medicinals,Concentrates,RSO,1000mg,Hq.2.1SRSOC,Harlequin 2:1,CBD,Current,1.01,6.3125,Joliet,94.94,593.375,Nick,Alcohol,2:1,,0,62234,17163,false,false,Cresco,true,Ascend
Sales Order-SO-014274,HCI Alternatives - Collinsville,IL,2020-01-06,Cresco Cookies - 500mg Liquid Live Resin Cartridge,30,124,3720,3720,Pending,Cresco,Vapes,Vapes,Live Cartridge,500mg,GSC.5CPLR,Cresco Cookies,Hybrid,Current,0.53,1.985018727,Joliet,65.72,246.142322097,Nick,Live,,,0,62234,17163,false,false,Cresco,true,Ascend
Sales Order-SO-014274,HCI Alternatives - Collinsville,IL,2020-01-06,OG 18 - 1.0g Flower,10,128,1280,1280,Pending,Cresco,Dry Flower,Dry Flower,Premium Flower,1.0g,OG18.035F,OG 18,Indica,Current,1.01,1.01,Joliet,129.28,129.28,Nick,,,,0,62234,17163,false,false,Cresco,true,Ascend
Sales Order-SO-014274,HCI Alternatives - Collinsville,IL,2020-01-06,Katsu Bubba Kush - shorties 3.5g Joint Pack,17.5,21,367.5,367.5,Pending,Cresco,Dry Flower,Prerolls,Prerolls,3.5g pk,KBKS7J,Katsu Bubba Kush,Indica,Current,3.5,3.5,Joliet,73.5,73.5,Nick,,,,0,62234,17163,false,false,Cresco,true,Ascend
Sales Order-SO-014274,HCI Alternatives - Collinsville,IL,2020-01-06,Pineapple Express - 1.0g Pre Rolled Joint,6,52,312,312,Pending,Cresco,Dry Flower,Prerolls,Prerolls,1.0g,PE1JF,Pineapple Express ,Hybrid,Current,1.01,1.01,Joliet,52.52,52.52,Nick,,,,0,62234,17163,false,false,Cresco,true,Ascend
Sales Order-SO-014274,HCI Alternatives - Collinsville,IL,2020-01-06,High Supply - Shake 7g - Sativa,30,19,570,570,Pending,Other,Accessories,Other,Accessories,NA,HS.25.S.S,,NA,,1,1,Joliet,19,19,Nick,,,,0,62234,17163,false,false,Cresco,true,Ascend
Sales Order-SO-014274,HCI Alternatives - Collinsville,IL,2020-01-06,High Supply - Popcorn 14g - Hybrid,80,6,480,480,Pending,Other,Accessories,Other,Accessories,NA,HS.5.H.PF,,NA,,1,1,Joliet,6,6,Nick,,,,0,62234,17163,false,false,Cresco,true,Ascend

PO,DISPENSARY,STATE,DATE,SKU_NAME,PRICE,QUANTITY,REVENUE,GROSS_SALES,STATUS,BRAND,CATEGORY,FORM,TYPE,SIZE,ITEM_ID,STRAIN,STRAIN_TYPE,STRAIN_STATUS,PACKAGED_WEIGHT,DRY_EQUIVALENT_WEIGHT,GROW_FACILITY,SKU_VOLUME_GRAMS,SKU_VOLUME_DRY_EQUIVALENT_GRAMS,SALES_REP,EXTRACTION_METHOD,CBD_RATIO,PROJECT_ID,DISCOUNT,ZIP,FIPS,CRESCO_OWNED,IS_SAMPLE,SALES_REP_COMPANY,MSO_FLG,CULTIVATOR
Sales Order-SO-014273,Harbory,IL,2020-01-06,2:1 Harlequin - 1000mg RSO Syringe,30,38,1140,1140,Pending,Remedi,Medicinals,Concentrates,RSO,1000mg,Hq.2.1SRSOC,Harlequin 2:1,CBD,Current,1.01,6.3125,Joliet,38.38,239.875,Nick,Alcohol,2:1,,0,62959,17199,false,false,Cresco,true,PTS
Sales Order-SO-014273,Harbory,IL,2020-01-06,Cresco Cookies - 500mg Liquid Live Resin Cartridge,30,50,1500,1500,Pending,Cresco,Vapes,Vapes,Live Cartridge,500mg,GSC.5CPLR,Cresco Cookies,Hybrid,Current,0.53,1.985018727,Joliet,26.5,99.25093633,Nick,Live,,,0,62959,17199,false,false,Cresco,true,PTS
Sales Order-SO-014273,Harbory,IL,2020-01-06,OG 18 - 1.0g Flower,10,51,510,510,Pending,Cresco,Dry Flower,Dry Flower,Premium Flower,1.0g,OG18.035F,OG 18,Indica,Current,1.01,1.01,Joliet,51.51,51.51,Nick,,,,0,62959,17199,false,false,Cresco,true,PTS
Sales Order-SO-014273,Harbory,IL,2020-01-06,Durban Poison - shorties 3.5g Joint Pack,17.5,8,140,140,Pending,Cresco,Dry Flower,Prerolls,Prerolls,3.5g pk,DPS7J,Durban Poison,Sativa,Current,3.5,3.5,Joliet,28,28,Nick,,,,0,62959,17199,false,false,Cresco,true,PTS
Sales Order-SO-014273,Harbory,IL,2020-01-06,Durban Poison - 1.0g Pre Rolled Joint,6,21,126,126,Pending,Cresco,Dry Flower,Prerolls,Prerolls,1.0g,DP1JF,Durban Poison,Sativa,Current,1.01,1.01,Joliet,21.21,21.21,Nick,,,,0,62959,17199,false,false,Cresco,true,PTS
Sales Order-SO-014273,Harbory,IL,2020-01-06,High Supply - Shake 7g - Sativa,30,8,240,240,Pending,Other,Accessories,Other,Accessories,NA,HS.25.S.S,,NA,,1,1,Joliet,8,8,Nick,,,,0,62959,17199,false,false,Cresco,true,PTS
Sales Order-SO-014273,Harbory,IL,2020-01-06,High Supply - 14.0g Shake - Hybrid,60,3,180,180,Pending,Other,Accessories,Other,Accessories,NA,HS.50.H.S,,NA,,1,1,Joliet,3,3,Nick,,,,0,62959,17199,false,false,Cresco,true,PTS


----QUERY FOR CURRENT PREPACK INVENTORY
(select inventory_id, weight, remainingweight, transferredout, strain, inventorytype, max(sessiondate) as sessiondate, max(placementgroup) as placementgroup, inventoryroom_name from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where  transferredout = 0 and  deleted = 0 and remainingweight>1 and inventoryroom_name like '%Pre%' group by inventory_id, weight, remainingweight, transferredout, strain, inventorytype, inventoryroom_name);


--SKU_NAME,QTY
--2:1 Harlequin - 1000mg RSO Syringe,484
--Cresco Cookies - 500mg Liquid Live Resin Cartridge,475
--Durban Poison - 1.0g Pre Rolled Joint,175
--Durban Poison - shorties 3.5g Joint Pack,88
--High Supply - 14.0g Shake - Hybrid,3
--High Supply - 500mg BHO Pen - Indica,174
--High Supply - Popcorn 14g - Hybrid,32
--High Supply - Shake 7g - Sativa,97
--Island Sweet Skunk - 500mg Liquid Live Resin Cartridge,164
--Katsu Bubba Kush - shorties 3.5g Joint Pack,21
--OG 18 - 1.0g Flower,658
--Pineapple Express - 1.0g Pre Rolled Joint,93
select productid, sum(remainingweight) as weight from
(select inventory_id, productid, weight, remainingweight, transferredout, strain, inventorytype, max(sessiondate) as sessiondate, max(placementgroup) as placementgroup, inventoryroom_name from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where  transferredout = 0 and  deleted = 0 and remainingweight>1 and inventoryroom_name like '%Pre%' group by inventory_id, weight, remainingweight, transferredout, strain, inventorytype, inventoryroom_name, productid)
group by productid;
select SKU_NAME, sum(QUANTITY) as qty from "ANALYTICS_DB"."WHOLESALE"."WHOLESALE_SALES" where status = 'Pending' and state = 'IL' group by SKU_NAME

select


select PO,
       DISPENSARY,
       STATE,
       DATE,
       SKU_NAME,
       PRICE,
       QUANTITY,
       REVENUE,
       GROSS_SALES,
       STATUS,
       BRAND,
       CATEGORY,
       FORM,
       TYPE,
       SIZE,
       ITEM_ID,
       a.STRAIN,
       STRAIN_TYPE,
       STRAIN_STATUS,
       PACKAGED_WEIGHT,
       DRY_EQUIVALENT_WEIGHT,
       GROW_FACILITY,
       SKU_VOLUME_GRAMS,
       SKU_VOLUME_DRY_EQUIVALENT_GRAMS,
       SALES_REP,
       EXTRACTION_METHOD,
       CBD_RATIO,
       PROJECT_ID,
       DISCOUNT,
       ZIP,
       FIPS,
       CRESCO_OWNED,
       IS_SAMPLE,
       SALES_REP_COMPANY,
       MSO_FLG,
       CULTIVATOR,sum(b.remainingweight) as remainingweight, remainingweight as Remaining_Weight,INVENTORYROOM_NAME as BT_INVENTORYROOM,PRODUCTID as BT_PRODUCT
from "ANALYTICS_DB"."WHOLESALE"."WHOLESALE_SALES" a
left join (select  sum(remainingweight) as remainingweight, productid, strain, INVENTORY_ID, INVENTORYROOM_NAME from ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY where   inventoryroom_name like '%Pre%' ---or INVENTORYTYPE in (22,23,24,45)
group by productid, strain, INVENTORY_ID, INVENTORYROOM_NAME) b


on lower(b.productid) like lower(concat('%',split_part(SKU_NAME,' - ',1),'%'))   and
   lower(b.productid) like concat('%', CONCAT(LOWER(SPLIT_PART(split_part(split_part(SKU_NAME, ' - ', 2), 'g', 1), ' ',
                                                                1)), '%'))
   and lower(b.productid) like CASE WHEN
                                                                    CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%') in ('%7g%','%14g%')
                                                                 THEN   REPLACE(CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%'), 'g','.0')
                                                                ELSE REPLACE(CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%'),'g','') END
and lower(b.productid) like lower(concat('%',split_part(SKU_NAME,' - ',3),'%'))

where status = 'Pending' and state = 'IL'
group by
PO,
       DISPENSARY,
       STATE,
       DATE,
       SKU_NAME,
       PRICE,
       QUANTITY,
       REVENUE,
       GROSS_SALES,
       STATUS,
       BRAND,
       CATEGORY,
       FORM,
       TYPE,
       SIZE,
       ITEM_ID,
       a.STRAIN,
       STRAIN_TYPE,
       STRAIN_STATUS,
       PACKAGED_WEIGHT,
       DRY_EQUIVALENT_WEIGHT,
       GROW_FACILITY,
       SKU_VOLUME_GRAMS,
       SKU_VOLUME_DRY_EQUIVALENT_GRAMS,
       SALES_REP,
       EXTRACTION_METHOD,
       CBD_RATIO,
       PROJECT_ID,
       DISCOUNT,
       ZIP,
       FIPS,
       CRESCO_OWNED,
       IS_SAMPLE,
       SALES_REP_COMPANY,
       MSO_FLG,
       CULTIVATOR, INVENTORY_ID,remainingweight ,INVENTORYROOM_NAME ,PRODUCTID order by INVENTORY_id desc;

select strain, sum(WETWEIGHT), count(distinct PLANT_ID) from ANALYTICS_DB.CULTIVATION.PLANTS_DRYING_CURrent where STRAIN = 'Pineapple Express' group by strain

PLANT_ID
9130480110556424
3472386868841693
4035504428349809
8245257810142107

select to_timestamp(sessiontime),* from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTDERIVATIVES where plantid in ('9130480110556424','3472386868841693','4035504428349809','8245257810142107')


select distinct lower(concat('%',split_part(SKU_NAME,' - ',1),'%')), concat('%', CONCAT(LOWER(SPLIT_PART(split_part(split_part(SKU_NAME, ' - ', 2), 'g', 1), ' ',
                                                                1)), '%')), CASE WHEN
                                                                    CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%') in ('%7g%','%14g%')
                                                                 THEN   REPLACE(CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%'), 'g','.0')
                                                                ELSE REPLACE(CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%'),'g','') END, lower(concat('%',split_part(SKU_NAME,' - ',3),'%'))

                from ANALYTICS_DB.BUSINESS.WHOLESALE_SALES where status = 'Pending' and state = 'IL';


%high supply%,%500m%,%bho%


SKU_NAME
High Supply - 500mg BHO Pen - Indica
Cresco Cookies - 500mg Liquid Live Resin Cartridge
High Supply - 14.0g Shake - Hybrid



select concat('%', CONCAT(LOWER(SPLIT_PART(split_part(split_part(SKU_NAME, ' - ', 2), 'g', 1), ' ',
                                                                1)), '%')), lower(concat('%',split_part(SKU_NAME,' - ',1),'%')), lower(concat('%',split_part(SKU_NAME,' - ',3),'%')), CASE WHEN
                                                                    CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%') in ('%7g%','%14g%')
                                                                 THEN   REPLACE(CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%'), 'g','.0')
WHEN
                                                                   ( CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%') in ('%pre%') and SKU_NAME like '%Pineapple Express%' and lower(SKU_NAME) not like '%flower%') THEN CONCAT(REPLACE(CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%'),'g','') , '%rolled%')

                                                                ELSE REPLACE(CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%'),'g','') END from ANALYTICS_DB.BUSINESS.WHOLESALE_SALES where status = 'Pending' and state = 'IL';




select * from ANALYTICS_DB.BUSINESS.WHOLESALE_SALES where status = 'Pending' and state = 'IL'

select distinct product_name from
(
    select sum(remainingweight) as remainingweight, product_name, strain, INVENTORY_ID
    from ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY
    where inventoryroom_name like '%Pre%' or INVENTORYROOM_NAME like '%+%Vault%'
--       or INVENTORYTYPE in (22, 23, 24, 28, 30, 32, 45)
    group by product_name, strain, INVENTORY_ID
)
;


Cresco Cookies ,%500m%,%liquid%
OG 18 ,%1.0%,%flower%
Durban Poison ,%shorties%,%3.5%
Durban Poison ,%1.0%,%pre%
Island Sweet Skunk ,%500m%,%liquid%
Katsu Bubba Kush ,%shorties%,%3.5%
Pineapple Express ,%1.0%,%pre%
2:1 Harlequin ,%1000m%,%rso%
High Supply ,%popcorn%,%14.0%
High Supply ,%500m%,%bho%
High Supply ,%14.0%,%shake%
High Supply ,%shake%,%7.0%




create or replace table ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY as
select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where transferredout = 0 and remainingweight > 0 and deleted = 0


select * from ANALYTICS_DB.INFORMATION_SCHEMA.COLUMNS



select * from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS

select CULTIVATION_ENVIRONMENT, case when RIGHT(left(PLACEMENTGROUP,6),2) in ('BH','FH') THEN concat(ROOM_NUMBER, ' ', RIGHT(left(PLACEMENTGROUP,6),2)) ELSE ROOM_NUMBER END ROOM_NUMBER, location from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS group by CULTIVATION_ENVIRONMENT, case when RIGHT(left(PLACEMENTGROUP,6),2) in ('BH','FH') THEN concat(ROOM_NUMBER, ' ', RIGHT(left(PLACEMENTGROUP,6),2)) ELSE ROOM_NUMBER END, location;

select distinct a.room, a.facility, b.environment from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW a
left join DEMO_DB.FASTFIELD.CULTIVATIONENVIRONMENTS b
on a.room = b.room and a.FACILITY = b.facility;


--select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW;
--alter table DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW add column Cultivation_Environment string;

--update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW a
--    set a.Cultivation_Environment = b.environment
--from  DEMO_DB.FASTFIELD.CULTIVATIONENVIRONMENTS b
--    where a.room = b.room and a.FACILITY = b.facility;
---INSERT INTO PRODUCTION PLANNER

--Sorry for the rapid fire. Room H has:
--Animal cookies- 24
--Lemon OG-21

select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null and room like '%H%' and FACILITY = 'Encanto';

--delete from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
--where PREDICTED_PLACEMENT_DATE = '2019-12-20'
--and room = 'Indoor Flower E'
--and facility = 'Encanto'
--and strain in ('Animal Cookies','Lemon OG')
PREDICTED_PLACEMENT_DATE	START_PLACEMENT	PLANT_PLACEMENT	PREDICTED_HARVEST_DATE	HARVEST_START	HARVEST_DATE	READY_FOR_SALE	STRAIN	PLACEMENT_COUNT	COUNT	PREDICTED_NEXT_PLACEMENT_DATE	Yield_Mod	TRIGGER_DATE_1	TRIGGER_DATE_2	TRIGGER_DATE_3	STRAIN_TYPE	CLONE	VEGETATIVE	SOURCE	CULTIVATION_ENVIRONMENT
2019-12-23	2019-12-23	2019-12-23				2020-03-16	Jack Flash	123	123		1				Hybrid			Production Tool



insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL as __INDEX__,'Encanto' as facility, 'Green  House' as room, '2019-12-23' as predicted_placement_date,  '2019-12-23' as Start_placement, '2019-12-23' as plant_placement,
           NULL as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
           '2020-03-16' as ready_for_sale, 'Hashberry Chocolope' as strain, '138' as placement_count , '138' as count,
           NULL as predicted_next_placement_date,
           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
           'Production Tool' as Source, 'Greenhouse' as Cultivation_Environment;


insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL as __INDEX__,'Encanto' as facility, 'Green  House' as room, '2019-12-23' as predicted_placement_date,  '2019-12-23' as Start_placement, '2019-12-23' as plant_placement,
           NULL as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
           '2020-03-16' as ready_for_sale, 'Ride the Boogie' as strain, '72' as placement_count , '72' as count,
           NULL as predicted_next_placement_date,
           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
           'Production Tool' as Source, 'Greenhouse' as Cultivation_Environment;

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL as __INDEX__,'Encanto' as facility, 'Green  House' as room, '2019-12-23' as predicted_placement_date,  '2019-12-23' as Start_placement, '2019-12-23' as plant_placement,
           NULL as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
           '2020-03-16' as ready_for_sale, 'Angels Milk' as strain, '6' as placement_count , '6' as count,
           NULL as predicted_next_placement_date,
           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
           'Production Tool' as Source, 'Greenhouse' as Cultivation_Environment;


update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
set PREDICTED_HARVEST_DATE = dateadd(day, 63,PLANT_PLACEMENT)
where PREDICTED_HARVEST_DATE is null
and HARVEST_DATE is null;


update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
set PREDICTED_NEXT_PLACEMENT_DATE = dateadd(day, 65,PLANT_PLACEMENT)
where PREDICTED_NEXT_PLACEMENT_DATE is null
and HARVEST_DATE is null;

update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
set room = 'Room GH'
where room = 'Green  House'
and HARVEST_DATE is null;



















insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL as __INDEX__,'Encanto' as facility, 'Indoor Flower H' as room, '2020-01-02' as predicted_placement_date,  '2020-01-02' as Start_placement, '2020-01-02' as plant_placement,
           NULL as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
           '2020-03-26' as ready_for_sale, 'Lemon OG' as strain, '21' as placement_count , '21' as count,
           NULL as predicted_next_placement_date,
           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
           'Production Tool' as Source, 'Indoor' as Cultivation_Environment;

--Matt, we have some pheno hunts going in room E currently
select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null and room like '%E%' and FACILITY = 'Encanto';

Mandarin Zkittlez- 27
Peach Crescendo-16
OG DLUX-8
Apex- 6
OG Kush-32


insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL as __INDEX__,'Encanto' as facility, 'Indoor Flower E' as room, '2019-12-20' as predicted_placement_date,  '2019-12-20' as Start_placement, '2019-12-20' as plant_placement,
           NULL as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
           '2020-03-13' as ready_for_sale, 'Mandarin Zkittlez' as strain, '27' as placement_count , '27' as count,
           NULL as predicted_next_placement_date,
           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
           'Production Tool' as Source, 'Indoor' as Cultivation_Environment;



insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL as __INDEX__,'Encanto' as facility, 'Indoor Flower E' as room, '2019-12-20' as predicted_placement_date,  '2019-12-20' as Start_placement, '2019-12-20' as plant_placement,
           NULL as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
           '2020-03-13' as ready_for_sale, 'Peach Crescendo' as strain, '16' as placement_count , '16' as count,
           NULL as predicted_next_placement_date,
           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
           'Production Tool' as Source, 'Indoor' as Cultivation_Environment;


insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL as __INDEX__,'Encanto' as facility, 'Indoor Flower E' as room, '2019-12-20' as predicted_placement_date,  '2019-12-20' as Start_placement, '2019-12-20' as plant_placement,
           NULL as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
           '2020-03-13' as ready_for_sale, 'OG DLUX' as strain, '8' as placement_count , '8' as count,
           NULL as predicted_next_placement_date,
           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
           'Production Tool' as Source, 'Indoor' as Cultivation_Environment;



insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL as __INDEX__,'Encanto' as facility, 'Indoor Flower E' as room, '2019-12-20' as predicted_placement_date,  '2019-12-20' as Start_placement, '2019-12-20' as plant_placement,
           NULL as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
           '2020-03-13' as ready_for_sale, 'Apex' as strain, '6' as placement_count , '6' as count,
           NULL as predicted_next_placement_date,
           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
           'Production Tool' as Source, 'Indoor' as Cultivation_Environment;

insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
    select NULL as __INDEX__,'Encanto' as facility, 'Indoor Flower E' as room, '2019-12-20' as predicted_placement_date,  '2019-12-20' as Start_placement, '2019-12-20' as plant_placement,
           NULL as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
           '2020-03-13' as ready_for_sale, 'OG Kush' as strain, '32' as placement_count , '32' as count,
           NULL as predicted_next_placement_date,
           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
           'Production Tool' as Source, 'Indoor' as Cultivation_Environment;










select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where room = 'Indr Flwr BH (T9-16)' and FACILITY = 'Yellow Springs' and HARVEST_DATE is null

---delete from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
--where room = 'Indr Flwr BH (T9-16)' and FACILITY = 'Yellow Springs' and HARVEST_DATE is null

--insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
--    select NULL as __INDEX__,'Yellow Springs' as facility, 'Greenhouse 2 FH' as room, '2019-12-13' as predicted_placement_date,  '2019-12-13' as Start_placement, '2019-12-13' as plant_placement,
--           '2020-02-14' as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
--           '2020-03-06' as ready_for_sale, '3D' as strain, '3' as placement_count , '3' as count,
--           NULL as predicted_next_placement_date,
--           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
--           'Production Tool' as Source, 'Greenhouse' as Cultivation_Environment;

--insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
--    select NULL as __INDEX__,'Yellow Springs' as facility, 'Greenhouse 2 FH' as room, '2019-12-13' as predicted_placement_date,  '2019-12-13' as Start_placement, '2019-12-13' as plant_placement,
--           '2020-02-14' as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
--           '2020-03-06' as ready_for_sale, 'Cataract Kush' as strain, '2' as placement_count , '2' as count,
--           NULL as predicted_next_placement_date,
--           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
--           'Production Tool' as Source, 'Greenhouse' as Cultivation_Environment;


--insert into DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
--    select NULL as __INDEX__,'Yellow Springs' as facility, 'Greenhouse 2 FH' as room, '2019-12-13' as predicted_placement_date,  '2019-12-13' as Start_placement, '2019-12-13' as plant_placement,
--           '2020-02-14' as  predicted_harvest_date, NULL as harvest_start, NULL as harvest_Date,
--           '2020-03-06' as ready_for_sale, 'Gmo Zkittlez' as strain, '4' as placement_count , '4' as count,
--           NULL as predicted_next_placement_date,
--           1 as "Yield_Mod", NULL as trigger_date_1 , NULL as trigger_date_2 , NULL as trigger_date_3, NULL as strain_type, null as clone, null as vegetative,
--           'Production Tool' as Source, 'Greenhouse' as Cultivation_Environment;


alter table ANALYTICS_DB.CULTIVATION.LEVEL_FINAL
add column InventoryType_Name String;

update ANALYTICS_DB.CULTIVATION.LEVEL_FINAL a
set a.inventorytype_name = case
when a.inventorytype = 6 then 'Flower Materials Harvested'
when a.inventorytype = 9 then 'Other Materials Harvested'
when a.inventorytype = 13 then 'Flower Lot'
WHEN a.inventorytype = 14 THEN 'Other Materials Lot'
WHEN a.inventorytype = 17 THEN 'Hydrocarbon Wax'
WHEN a.inventorytype = 18 THEN 'CO2 Hash Oil'
WHEN a.inventorytype = 22 THEN 'Solid Marijuana Infused Edible'
WHEN a.inventorytype = 23 THEN 'Liquid Marijuana Infused Edible'
WHEN a.inventorytype = 24 THEN 'Marijuana Extract for Inhalation'
WHEN a.inventorytype = 25 THEN 'Marijuana Infused Topicals'
WHEN a.inventorytype = 27 THEN 'Waste'
WHEN a.inventorytype = 28 THEN 'Useable Marijuana'
WHEN a.inventorytype = 30 THEN 'Marijuana Mix'
WHEN a.inventorytype = 32 THEN 'Marijuana Mix Infused'
WHEN a.inventorytype = 45 THEN 'Liquid Marijuana RSO'
WHEN a.inventorytype = 5 THEN 'Kief'
WHEN a.inventorytype = 10 THEN 'Cannabinoid edibles'
WHEN a.inventorytype = 11 THEN 'Cannabinoid topicals'
WHEN a.inventorytype = 12 THEN 'Transfer Lots'
WHEN a.inventorytype = 15 THEN 'Transdermal Patches'
WHEN a.inventorytype = 21 THEN 'Seeds'
WHEN a.inventorytype = 15 THEN 'Transdermal Patches'
    ELSE CONCAT(a.INVENTORYTYPE, ': No Known Type') END
;



alter table ANALYTICS_DB.CULTIVATION.LEVEL_FINAL
rename column productid to product_name;





select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYTYPES
select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL


select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where facility = 'Lincoln' and HARVEST_DATE is null


select * from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES
---------