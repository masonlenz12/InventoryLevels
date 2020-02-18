





----Fir

select  ROOM_NUMBER, ROOM_NAME, min(ROOM_BEGIN_TIME) from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where ROOM_TYPE = 'Flowering' and LOCATION = 'Lincoln' group by ROOM_NUMBER, ROOM_NAME

select * from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_NEXT

select CURRENTROOM,* from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY where TRANSFERREDOUT = 0 and DELETED = 0 and INVENTORYTYPE = 13 order by sessiontime desc;

select * from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where ROOM_NUMBER = 'Zone 12'

select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.REPLICATION_HISTORY where --tabname = 'rooms' and
                                                                      (primary_val['f1'] in ('120') or new_val['id'] in ('120'))


select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.REPLICATION_HISTORY where --tabname = 'rooms' and
                                                                      NEW_VAL['roomname'] in ('Freezer 1') --or new_val['id'] in ('120'))



select replace(new_val['roomname'],'"','') as roomname,coalesce(replace(new_val['id'], '"', ''),replace(PRIMARY_VAL['f1'],'"','') ) as id, to_date(min(ts)) as min, to_date(max(ts)) as max  from "FIVETRAN_DB"."BT_LINCOLN_PUBLIC"."REPLICATION_HISTORY"
where tabname = 'rooms'
//and OPERATION = 'INSERT'
--and coalesce(replace(new_val['id'], '"', ''),replace(PRIMARY_VAL['f1'],'"','') ) in (100, 101, 102, 103, 104, 105, 106, 107 , 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 532, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 97, 98, 99, 59,60,61,62,63,64,65,66,67,68,69,70, 71, 72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96)

  and id is not null
and NEW_VAL['roomname'] is not null
group by 1,2
order by id desc
;

59,60,61,62,63,64,65,66,67,68,69,70, 71, 72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96

select new_val['roomname'] as roomname,coalesce(new_val['id'],PRIMARY_VAL['f1']) as id, to_date(min(ts)) as min, to_date(max(ts)) as max  from "FIVETRAN_DB"."BT_LINCOLN_PUBLIC"."REPLICATION_HISTORY"
where tabname = 'rooms'
//and OPERATION = 'INSERT'
and new_val['roomname'] like '%Zone 9%'
and id is not null
group by 1,2
;


select ROOM_BEGIN_TIME,
       ROOM_END_TIME,
       NEWROOM,
       PLANT_ID,
       ROOM_NAME,
       NEWSTATE,
       OLDROOMDELETED,
       ROOM_TYPE,
       PHASE,
       ROOM_NUMBER,
       ROOM_FRONT_BACK,
       TABLE_ID,
       SUB_ROOM_ID,
       STRAIN,
       HARVESTGROUPID,
       LST_PHASE_ID,
       STRAIN_TYPE,
       BRTH_DT,
       LOCATION,
       max(b.roomname) as room_name_old
from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES a
left join (select replace(new_val['roomname'],'"','') as roomname,coalesce(replace(new_val['id'], '"', ''),replace(PRIMARY_VAL['f1'],'"','') ) as id, to_date(min(ts)) as min, to_date(max(ts)) as max  from "FIVETRAN_DB"."BT_LINCOLN_PUBLIC"."REPLICATION_HISTORY"
where tabname = 'rooms'
//and OPERATION = 'INSERT'
--and coalesce(replace(new_val['id'], '"', ''),replace(PRIMARY_VAL['f1'],'"','') ) in (100, 101, 102, 103, 104, 105, 106, 107 , 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 532, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 97, 98, 99, 59,60,61,62,63,64,65,66,67,68,69,70, 71, 72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96)

  and id is not null
and NEW_VAL['roomname'] is not null
group by 1,2
order by min desc
) b
on a.NEWROOM = b.id
and b.max between ROOM_BEGIN_TIME and ROOM_END_TIME
where ROOM_TYPE = 'Flowering'
and ROOM_NUMBER = 'Zone 12'
group by ROOM_BEGIN_TIME,
       ROOM_END_TIME,
       NEWROOM,
       PLANT_ID,
       ROOM_NAME,
       NEWSTATE,
       OLDROOMDELETED,
       ROOM_TYPE,
       PHASE,
       ROOM_NUMBER,
       ROOM_FRONT_BACK,
       TABLE_ID,
       SUB_ROOM_ID,
       STRAIN,
       HARVESTGROUPID,
       LST_PHASE_ID,
       STRAIN_TYPE,
       BRTH_DT,
       LOCATION;



select ROOM_BEGIN_TIME,
       ROOM_END_TIME,
       a.NEWROOM,



       ROOM_TYPE,
       PHASE,
       ROOM_NUMBER,
       ROOM_FRONT_BACK,
       TABLE_ID,
       SUB_ROOM_ID,
       STRAIN,

       STRAIN_TYPE,

       a.LOCATION,
       max(b.newroom) as newroom,
       max(b.room_name) as roomname,
       max(b.location) as location,
       max(min) as min,
       max(max) as max
from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES a left join
(select cast(newroom as integer) as newroom, room_name, location, min, max          from
(-----select coalesce(replace(new_val['id'], '"', ''),replace(PRIMARY_VAL['f1'],'"','') ) as newroom, case when tabname = 'planttables' THEN replace(new_val['name'],'"','') ELSE replace(new_val['roomname'],'"','') END as roomname, 'Lincoln' as location
-----, to_date(min(ts)) as min, to_date(max(ts)) as max
-----from "FIVETRAN_DB"."BT_LINCOLN_PUBLIC"."REPLICATION_HISTORY"
-----where tabname in ('rooms', 'inventoryrooms', 'planttables')
//and OPERATION = 'INSERT'
--and coalesce(replace(new_val['id'], '"', ''),replace(PRIMARY_VAL['f1'],'"','') ) in (100, 101, 102, 103, 104, 105, 106, 107 , 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 532, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 97, 98, 99, 59,60,61,62,63,64,65,66,67,68,69,70, 71, 72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96)

----  and id is not null
----and case when tabname = 'planttables' THEN NEW_VAL['name'] ELSE  NEW_VAL['roomname'] END is not null
--and coalesce(replace(new_val['id'], '"', ''),replace(PRIMARY_VAL['f1'],'"','') ) in (122)
----group by 1,2
--order by id desc
----UNION
select *, '2016-09-23' as min, '2016-09-23' as max from ANALYTICS_DB.CULTIVATION.OLD_ROOM_NAMES_9_23_2019_TImestamp where LOCATION = 'Lincoln')
order by cast(newroom as integer) asc) b
on a.NEWROOM = b.newroom
and b.min <= a.ROOM_BEGIN_TIME
and a.location = b.location
where a.location = 'Lincoln'
group by ROOM_BEGIN_TIME,
       ROOM_END_TIME,
       a.NEWROOM,
       PLANT_ID,

       NEWSTATE,
       OLDROOMDELETED,
       ROOM_TYPE,
       PHASE,
       ROOM_NUMBER,
       ROOM_FRONT_BACK,
       TABLE_ID,
       SUB_ROOM_ID,
       STRAIN,
       HARVESTGROUPID,
       LST_PHASE_ID,
       STRAIN_TYPE,
       BRTH_DT,
       a.LOCATION
;

--select * from ANALYTICS_DB.BUSINESS_FLOW.MAKE_CULTIVATION_YIELDS


select distinct room, FACILITY from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_START is null

----Testing to see if room 99 has any historicals as a first test
select distinct ROOM_NAME from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where LOCATION = 'Encanto'-- and NEWROOM = 99;

--where TABNAME = 'rooms'
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.REPLICATION_HISTORY where NEW_VAL like '%99%'-- is not null --order by ts asc

                                                                     --and  PRIMARY_VAL like '%"99"%'
order by ts asc;

--select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.REP_REPORTS where lower(name) like '%room%'

select distinct f.STRAIN, f.FACILITY
from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW f
         left join "ANALYTICS_DB"."PRODUCTION_PLAN"."CLEANER_STRAINS" s on lower(f.STRAIN) like s.KEYWORD
where s.strain is null;


select * from "ANALYTICS_DB"."PRODUCTION_PLAN"."CLEANER_STRAINS"


select distinct strain from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where FACILITY = 'Yellow Springs'

--update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
--set STRAIN =  trim(strain)
--where FACILITY = 'Yellow Springs'





select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where FACILITY = 'Yellow Springs'












SELECT locations.name, rooms.roomname AS Room, strain AS Strain, count(*) AS Count
FROM plants
         JOIN locations ON plants.location = locations.id
         JOIN rooms ON plants.room = rooms.id
WHERE plants.state < 2
  AND plants.deleted = 0
  AND plants.location = $Location
  AND plants.strain = $Strain
  AND plants.room = $Room
GROUP BY locations.name, strain, rooms.roomname
ORDER BY locations.name, rooms.roomname, strain, count;

CREATE or replace table ANALYTICS_DB.CULTIVATION.OLD_PLANT_CYCLES_9_23_2019_TImestamp as
select * from ANALYTICS_db.CULTIVATION.PLANT_CYCLES_F_ROOM;

select * from ANALYTICS_DB.CULTIVATION.OLD_ROOM_NAMES_9_23_2019_TImestamp where LOCATION = 'Lincoln'

--Insert into "ANALYTICS_DB"."PRODUCTION_PLAN"."CLEANER_STRAINS"
--Select max(__index__)+1 as __index__, '%red%line%haze%' as keyword, 'Red Line Haze' as strain, 'Sativa' as type
--From analytics_db.production_plan.cleaner_strains;

select max(__INDEX__) from ANALYTICS_DB.PRODUCTION_PLAN.CLEANER_STRAINS

select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where PREDICTED_HARVEST_DATE is null

select * from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS where PLACEMENT_DATE >= '2019-01-01'

SELECT locations.name AS Location, inventory.strain,to_char(to_timestamp(inventorymoves.datetime),'MM/DD/YYYY HH12:MI AM') AS Date, inventorymoves.weight AS amount, CASE WHEN inventorymoves.oldroom > 0 THEN (SELECT roomname FROM inventoryrooms WHERE id = inventorymoves.oldroom) ELSE 'Bulk Inventory' END AS Old_Room, CASE WHEN inventorymoves.newroom > 0 THEN (SELECT roomname FROM inventoryrooms WHERE id = inventorymoves.newroom) ELSE 'Bulk Inventory' END AS New_Room
     , userid AS Employee FROM fivetran_db.bt_lincoln_public.inventorymoves,inventory,locations WHERE inventory.id = inventorymoves.inventoryid AND locations.id = inventorymoves.location AND inventorymoves.location = $Location AND inventorymoves.datetime >= EXTRACT(EPOCH FROM TIMESTAMP WITH TIME ZONE $Start) AND inventorymoves.datetime <= EXTRACT(EPOCH FROM TIMESTAMP WITH TIME ZONE $End) ORDER BY datetime;
--select * from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES at(offset => -60*100);
ID
103
104
105
106
107
108
110
111
112

--update "ANALYTICS_DB"."BUSINESS"."CULTIVATION_YIELDS"
--set Production_planner_room = Case when Location = 'Encanto' and left(Production_planner_room, 2 ) = 'GH' THEN TRIM(CONCAT('Room ', LEFT(Production_planner_room, 2) )) WHEN Location = 'Encanto'  and left(Production_planner_room, 2 ) <> 'GH' and Production_planner_room not like '%Room%' THEN TRIM(CONCAT('Room ', LEFT(Production_planner_room, 1) ))
--WHEN Location = 'Lincoln' and Production_planner_room like '%Zone%' THEN TRIM(CONCAT('Bay',TRIM(RIGHT(Production_planner_room, 2)))) WHEN  Location = 'Lincoln' and Production_planner_room not like '%Zone%' and Production_planner_room not like '%Bay%' THEN TRIM(CONCAT('Bay',LEFT(TRIM(Production_planner_room),1)))
--WHEN Location = 'Kankakee' and (Production_planner_room like '%FH%' or Production_planner_room like '%BH%') and Production_planner_room not like '%Flower%' THEN TRIM(CONCAT('Flower ', Production_planner_room)) WHEN  Location = 'Kankakee' and Production_planner_room like '%Mini%' THEN 'Mini Bloom'
--WHEN Location = 'Brookville' and Production_planner_room like '%224%' THEN 'Flower 1-224' WHEN  Location = 'Brookville' and Production_planner_room like '%227%' THEN 'Flower 2-227' WHEN  Location = 'Brookville' and Production_planner_room like '%222%' THEN 'Flower 3-222' WHEN  Location = 'Brookville' and Production_planner_room like '%226%' THEN 'Flower 4-226' WHEN  Location = 'Brookville' and Production_planner_room like '%220%' THEN 'Flower 5-220' WHEN  Location = 'Brookville' and Production_planner_room like '%225%' THEN 'Flower 6-225' WHEN  Location = 'Brookville' and Production_planner_room like '%217%' THEN 'Flower 7-217' WHEN Location = 'Brookville' and Production_planner_room like '%GH1%' THEN TRIM(CONCAT(RIGHT(LEFT(Production_planner_room, 6),3),'-','Bay',RIGHT(Production_planner_room, 1)))
--When Location = 'Fall River' and Production_planner_room like '%Flower House%' THEN TRIM(CONCAT('FR ', right(Production_planner_room, 1)))
--WHEN Location = 'Vicksburg' and Production_planner_room like '%South %' THEN 'South Field'
--WHEN Location = 'Yellow Springs' and Production_planner_room like '%Indoor Flower%' and (Production_planner_room like '%FH%' or Production_planner_room like '%BH%') THEN TRIM(CONCAT('Indr Flwr ',RIGHT(Production_planner_room, 2), CASE WHEN Production_planner_room LIKE '%FH%' THEN ' (T1-8)' ELSE ' (T9-16)' END))
--WHEN Location = 'Carpenteria' THEN TRIM(RIGHT(Production_planner_room, 4))
--    when location = 'Joliet' THEN TRIM(CAST(Production_planner_room as INT)) ELSE TRIM(Production_planner_room) END
--,location = trim(location)--
--;


select distinct NEWROOM from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where ROOM_TYPE = 'Flowering' and ROOM_NUMBER = 'Zone 12' and BRTH_DT < '2019-01-01'

select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.ROOMS where id = 87

select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.REPLICATION_HISTORY where NEW_VAL like '%"roomname"%'
                                                                  and TABNAME = 'rooms'
                                                                 and left(TS,10) between '2019-12-15' and '2020-01-08'
                                                                  and PRIMARY_VAL is not null and (PRIMARY_VAL like '%"109"%' or PRIMARY_VAL like '%"108"%' or PRIMARY_VAL like '%"107"%' or PRIMARY_VAL like '%"106"%' or PRIMARY_VAL like '%"105"%' or PRIMARY_VAL like '%"104"%' or PRIMARY_VAL like '%"103"%' or PRIMARY_VAL like '%"102"%')
--REPLICATION_VAL = '90605'
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.REPLICATION_HISTORY where --NEW_VAL like '%"roomname"%'
                                                                  TABNAME = 'rooms'
--                                                                  and left(TS,10) between '2015-01-01' and '2020-01-08'
                                                                  and PRIMARY_VAL is not null and (PRIMARY_VAL like '%"109"%' or PRIMARY_VAL like '%"108"%' or PRIMARY_VAL like '%"107"%' or PRIMARY_VAL like '%"106"%' or NEW_VAL like '%"105"%' or NEW_VAL like '%"104"%' or NEW_VAL like '%"103"%' or NEW_VAL like '%"102"%')





















---Predicted next placement and predicted next harvest
----+63----+65
----Brookville, Yellow Springs, Carpenteria, Vicksburg, Encanto


select * from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES

-- where PREDICTED_NEXT_PLACEMENT_DATE is null

insert into DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES
select Days, status, 'Vicksburg' as location, type, trig_name
from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES
where days in (63,65) and location = 'Joliet' and TRIG_NAME in ('End Harvest','Next Placement');






