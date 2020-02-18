/*
IN this Piece of code I am adding in any missed plants that were in an associated harvestgroupid
*/
create or replace table ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS_INTERMEDIATE as
select a.room, a.placement_date, a.strain, a.plant_id, a.placementgroup, a.location, a.room_number, a.room_front_back, a.room_nbr_tab, min(harvestgroupid)as group1, max(harvestgroupid) as group2 from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS a
left join ANALYTICS_DB.CULTIVATION.PLANT_YIELDS b
on a.PLANT_ID = b.PLANT_ID
group by a.room, a.placement_date, a.strain, a.plant_id, a.placementgroup, a.location, a.room_number, a.room_front_back, a.room_nbr_tab
;

INSERT INTO ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS
(select b.room, b.placement_date, b.strain, a.plant_id, b.placementgroup, b.location, b.room_number, b.room_front_back, b.room_nbr_tab
from (select min(HARVESTGROUPID) as group1, plant_id, LOCATION as location from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS group by plant_id, LOCATION) a
left join ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS_TEST_2020_01_24 b
on a.group1 = coalesce(b.group1, b.group2) and a.location = b.location
where a.plant_id not in (select distinct plant_id from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS_INTERMEDIATE)
and a.group1 is not null
and b.room is not null
and b.placement_date >= '2018-01-01'
group by b.room, b.placement_date, b.strain, a.plant_id, b.placementgroup, b.location, b.room_number, b.room_front_back, b.room_nbr_tab );
-----Placement Groups began with 81,582
---Testing code to get more
--CODE WILL ADD 2681 more ID's
--Current Count for JOL-133 Rocket Fuel = 231
    --According to the harvest group it should be 232
    --We had an issue with the plant not getting scanned into flowering correctly until a few days late

PLANT_ID
0100006270518062
3528880227106017
4069245787304561
4352497466271442
4983926629552694
6377717560494965
6415052470957085
7910910915393454
8259475468816441
9157580243510121
9671855922382874

select * from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS where HARVESTGROUPID = 59 and LOCATION = 'Kankakee' --where PLANT_ID = '9671855922382874'
--28 Plants

select * from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS where PLANT_ID = '8259475468816441'

select * from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS

select a.*
from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS a
         LEFT JOIN
     (select distinct strain, ROOM_NUMBER, ROOM, PLACEMENT_DATE, PLANT_ID
      from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS
      where ROOM_NUMBER = '133'
        and PLACEMENT_DATE >= '2019-11-01') b
on a.PLANT_ID = b.PLANT_ID

where HARVESTGROUPID = '1543'
  and b.PLANT_ID is not null
  and LOCATION = 'Joliet'
;

-----UNCONNECTED ID
select * from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where plant_id = '0467010482494947'

-----CONNECTED ID
select DATEADD(day,40,ROOM_BEGIN_TIME) as testtime,* from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where plant_id = '9775564362526014'


/*In this code segement we will be investigating the harvest that occured in 'JOL-1332019-11-13' */
(select distinct strain, ROOM_NUMBER, ROOM, PLACEMENT_DATE,  PLANT_ID
from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS
where ROOM_NUMBER = '133'
  and PLACEMENT_DATE >= '2019-11-01') b
--group by strain, ROOM_NUMBER, ROOM, PLACEMENT_DATE;


