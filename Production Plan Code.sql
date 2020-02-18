
select * from ANALYTICS_DB.CULTIVATION.PLANTS_DRYING_CURRENT

select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null

select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTS where id in (select distinct plant_id from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS where PLACEMENTGROUP = 'JOL-2322019-10-30')

select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.plantslog where id in (select distinct plant_id from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS where PLACEMENTGROUP = 'JOL-2322019-10-30') order by id desc


select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null

select * from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES


update DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES
set TRIG_NAME = 'End Harvest'
where TRIG_NAME = 'Harvest';

update DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES
set TRIG_NAME = 'Next Clone Placement'
where TRIG_NAME = 'Clone';

update DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES
set TRIG_NAME = 'Next Placement'
where TRIG_NAME = 'Next_Placement';


update DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES
set TRIG_NAME = 'Start Harvest'
where TRIG_NAME = 'Start_Harvest';


update DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES
set TRIG_NAME = 'Next Vegetative Placement'
where TRIG_NAME = 'Vegetative';


--update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
--set HARVEST_DATE = '2020-01-06',
--    HARVEST_START = '2020-01-02'
--where room = '232'
--and PREDICTED_HARVEST_DATE = '2020-01-01'
--and READY_FOR_SALE = '2020-01-18'
select  to_timestamp(drytimestart) as drytimestart,
        to_timestamp(DRYTIMEEND) as drytimeend,
       a.location,
       min(a.ROOM_NUMBER) as Room_Number,
       a.STRAIN,
       a.HARVESTGROUPID,

       a.PLANT_ID,
       coalesce(r.wetweight, b.wetweight) as wetweight
from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES a
left join (select DRYTIMESTART, DRYTIMEEND, id, WETWEIGHT-coalesce(BUDWEIGHT, 0) as wetweight from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTS
    UNION
  select DRYTIMESTART,DRYTIMEEND, id, WETWEIGHT-coalesce(BUDWEIGHT, 0) as wetweight from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS
    UNION
 select DRYTIMESTART,DRYTIMEEND, id, WETWEIGHT-coalesce(BUDWEIGHT, 0) as wetweight from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTS
    UNION
  select DRYTIMESTART,DRYTIMEEND, id, WETWEIGHT-coalesce(BUDWEIGHT, 0) as wetweight from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTS
    ) b
on a.PLANT_ID = b.ID
left join (select plant_id, HARVEST_ROOM_NAME, sum(WET_WEIGHT) as Wetweight from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS where TYPE_OF_HARVEST = 'Dry Buds' group by PLANT_ID, HARVEST_ROOM_NAME) r
on a.PLANT_ID = r.PLANT_ID
and a.ROOM_NAME = r.HARVEST_ROOM_NAME
where
a.phase in ('Drying', 'Flowering')
 and (left( to_timestamp(drytimestart), 10) <> left(to_timestamp(DRYTIMEEND), 10) or (DRYTIMEEND is null or (DRYTIMESTART is null and DRYTIMEEND is null))  )

  and a.PLANT_ID in (select id
                   from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTS
                   where DELETED <> 1
                     and (DRYTIMESTART is not null
                     and DRYTIMEEND is null) or (harvestcollect > curecollect and state = 1)

                   group by id
                   UNION
                   select id
                   from FIVETRAN_DB.BT_Kankakee_PUBLIC.PLANTS
                   where DRYTIMESTART is not null and drytimeend is not null and state = 1
                     and DELETED <> 1
                   group by id
                   UNION
                   select id
                   from FIVETRAN_DB.BT_Lincoln_PUBLIC.PLANTS
                   where ((DRYTIMESTART is not null
                     and DRYTIMEEND is null) or (DRYTIMESTART is not null and drytimeend is not null and state = 1))
                     and DELETED <> 1
                   group by id                   UNION
                   select id
                   from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTS
                   where DRYTIMESTART is not null
                     and DRYTIMEEND is null
                     and DELETED <> 1
and (curecollect is null or (location = 2 and curecollect <> 1 ))

                   group by id
)
group by
coalesce(r.wetweight, b.wetweight),
         a.location,
                a.PLANT_ID,

         a.STRAIN,
         a.HARVESTGROUPID, drytimestart, drytimeend,
         a.LOCATION;





select distinct a.*, b.placementgroup, b.strain from


(select plantid,  max(WETWEIGHT) from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTDERIVATIVES

where plantid in (select distinct plant_id from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS where PLACEMENTGROUP = 'JOL-2322019-10-30') and plantid in (select distinct plant_id from ANALYTICS_DB.CULTIVATION.PLANTS_DRYING_CURRENT) group by plantid order by plantid desc) a
left join ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS b
on a.PLANTID = b.PLANT_ID




select  to_timestamp(drytimestart) as drytimestart,
        to_timestamp(DRYTIMEEND) as drytimeend,
       a.location,
        max(ROOM_BEGIN_TIME) as begintime,
       min(a.ROOM_NUMBER) as Room_Number,
       a.STRAIN,
       a.HARVESTGROUPID,

       a.PLANT_ID,
       coalesce(r.wetweight, b.wetweight) as wetweight
from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES a
left join (select DRYTIMESTART, DRYTIMEEND, id, WETWEIGHT-coalesce(BUDWEIGHT, 0) as wetweight from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTS
    UNION
  select DRYTIMESTART,DRYTIMEEND, id, WETWEIGHT-coalesce(BUDWEIGHT, 0) as wetweight from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS
    UNION
 select DRYTIMESTART,DRYTIMEEND, id, WETWEIGHT-coalesce(BUDWEIGHT, 0) as wetweight from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTS
    UNION
  select DRYTIMESTART,DRYTIMEEND, id, WETWEIGHT-coalesce(BUDWEIGHT, 0) as wetweight from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTS
    ) b
on a.PLANT_ID = b.ID
left join (select plant_id, HARVEST_ROOM_NAME, sum(WET_WEIGHT) as Wetweight from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS where TYPE_OF_HARVEST = 'Dry Buds' group by PLANT_ID, HARVEST_ROOM_NAME) r
on a.PLANT_ID = r.PLANT_ID
and a.ROOM_NAME = r.HARVEST_ROOM_NAME
where
a.phase in ('Drying', 'Flowering')
  and a.PLANT_ID in (select id
                   from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTS a
                   where DELETED <> 1
                     and (DRYTIMESTART is not null
                     and DRYTIMEEND is null) or (harvestcollect > curecollect and state = 1)
  and ID in (select distinct plantid from (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTDERIVATIVES group by plantid ) where wetweightcheck <> 0 and wetweightcheck is not null)


                   group by id
                   UNION
                    select id
                   from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTS a
  where DRYTIMESTART is not null and drytimeend is not null and state = 1
                     and DELETED <> 1
  and ID in (select distinct plantid from (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTDERIVATIVES group by plantid ) where wetweightcheck <> 0 and wetweightcheck is not null)

                   group by id
                   UNION
                    select id
                   from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS a
                   where ((DRYTIMESTART is not null
                     and DRYTIMEEND is null) or (DRYTIMESTART is not null and drytimeend is not null and state = 1))
                     and DELETED <> 1
  and ID in (select distinct plantid from (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTDERIVATIVES group by plantid ) where wetweightcheck <> 0 and wetweightcheck is not null)

                   group by id
)
group by
coalesce(r.wetweight, b.wetweight),
         a.location,
                a.PLANT_ID,

         a.STRAIN,
         a.HARVESTGROUPID, drytimestart, drytimeend,
         a.LOCATION;

select * from FIVETRAN_DB.BT_HHH_PUBLIC.ROOMS









































select  case when left(to_timestamp(DRYTIMEEND), 10) = left(to_timestamp(drytimestart),10) THEN max(ROOM_BEGIN_TIME) else to_timestamp(drytimestart) end as drytimestart,
        to_timestamp(DRYTIMEEND) as drytimeend,
       a.location,
        max(ROOM_BEGIN_TIME) as begintime,
       min(a.ROOM_NUMBER) as Room_Number,
       a.STRAIN,
       a.HARVESTGROUPID,

       a.PLANT_ID,
       coalesce(b.wetweight, r.wetweight) as wetweight
from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES a
left join (
select DRYTIMESTART, DRYTIMEEND, id, case when left(to_timestamp(DRYTIMEEND), 10) = left(to_timestamp(drytimestart),10) THEN wetweightcheck
WHEN CURECOLLECT = 1 THEN wetweightcheck

ELSE WETWEIGHT-coalesce(BUDWEIGHT, 0) END as wetweight from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTS a
LEFT JOIN (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTDERIVATIVES group by plantid ) b
on a.id = b.PLANTID


    UNION
select DRYTIMESTART, DRYTIMEEND, id, case when left(to_timestamp(DRYTIMEEND), 10) = left(to_timestamp(drytimestart),10) THEN wetweightcheck
WHEN CURECOLLECT = 1 THEN wetweightcheck
ELSE WETWEIGHT-coalesce(BUDWEIGHT, 0) END as wetweight from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS a
LEFT JOIN (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTDERIVATIVES group by plantid ) b
on a.id = b.PLANTID

    UNION
select DRYTIMESTART, DRYTIMEEND, id, case when left(to_timestamp(DRYTIMEEND), 10) = left(to_timestamp(drytimestart),10) THEN wetweightcheck
WHEN CURECOLLECT = 1 THEN wetweightcheck
ELSE WETWEIGHT-coalesce(BUDWEIGHT, 0) END as wetweight from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTS a
LEFT JOIN (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTDERIVATIVES group by plantid ) b
on a.id = b.PLANTID

    UNION
select DRYTIMESTART, DRYTIMEEND, id, case when left(to_timestamp(DRYTIMEEND), 10) = left(to_timestamp(drytimestart),10) THEN

wetweightcheck
WHEN CURECOLLECT = 1 THEN wetweightcheck

ELSE WETWEIGHT-coalesce(BUDWEIGHT, 0) END as wetweight from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTS a
LEFT JOIN (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_ENCANTO_PUBLIC.PLANTDERIVATIVES group by plantid ) b
on a.id = b.PLANTID

    ) b
on a.PLANT_ID = b.ID
left join (select plant_id, HARVEST_ROOM_NAME, sum(WET_WEIGHT) as Wetweight from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS where TYPE_OF_HARVEST = 'Dry Buds' group by PLANT_ID, HARVEST_ROOM_NAME) r
on a.PLANT_ID = r.PLANT_ID
and a.ROOM_NAME = r.HARVEST_ROOM_NAME
where
a.phase in ('Drying', 'Flowering')
  and a.PLANT_ID in (select id
                   from FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTS a
                   where DELETED <> 1
                     and (DRYTIMESTART is not null
                     and DRYTIMEEND is null) or (harvestcollect > curecollect and state = 1)
  and ID in (select distinct plantid from (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_JOLIET_PUBLIC.PLANTDERIVATIVES group by plantid ) where wetweightcheck <> 0 and wetweightcheck is not null)


                   group by id
                   UNION
                    select id
                   from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTS a
  where DRYTIMESTART is not null and drytimeend is not null and state = 1
                     and DELETED <> 1
  and ID in (select distinct plantid from (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PLANTDERIVATIVES group by plantid ) where wetweightcheck <> 0 and wetweightcheck is not null)

                   group by id
                   UNION
                    select id
                   from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS a
                   where ((DRYTIMESTART is not null
                     and DRYTIMEEND is null) or (DRYTIMESTART is not null and drytimeend is not null and state = 1))
                     and DELETED <> 1
  and ID in (select distinct plantid from (select PLANTID, max(WETWEIGHT) as wetweightcheck, max(DRYTIMESTART) as drytime from  FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTDERIVATIVES group by plantid ) where wetweightcheck <> 0 and wetweightcheck is not null)

                   group by id
)
group by
coalesce(b.wetweight, r.wetweight),
         a.location,
                a.PLANT_ID,

         a.STRAIN,
         a.HARVESTGROUPID, drytimestart, drytimeend,
         a.LOCATION;

select spli

















































select ROOM_NUMBER, DOMO_HARVEST_DATE, sum(TOTAL_PLANTS) from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS where location = 'Lincoln' and ROOM_NUMBER = 'Bay2' group by ROOM_NUMBER, DOMO_HARVEST_DATE


ROOM_NUMBER,DOMO_HARVEST_DATE,SUM(TOTAL_PLANTS)
Bay2,2018-02-01,582
Bay2,2018-04-01,590
Bay2,2018-06-01,588
Bay2,2018-09-01,580
Bay2,2018-11-01,617
Bay2,2019-01-01,610
Bay2,2019-04-01,623
Bay2,2019-06-01,520
Bay2,2019-08-01,321
Bay2,2019-09-01,63
Bay2,2019-10-01,57
Bay2,2019-11-01,327


select distinct * from ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES where PLACEMENT_DATE = '2019-02-01'

select distinct PLACEMENT_DATE from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS where ROOM_NUMBER = 'Zone 2';



select max(a.room) as room, max(a.placement_date) as placement_Date, max(c.strain) as strain, c.plant_id as plant_id, concat(max(a.room),max(a.placement_date)) as PlacementGroup, max(a.location) as location, case when max(a.room_number) = 'MBM' then 'Mini-Bloom' else max(a.room_number) end as room_number, max(a.room_front_back) as room_front_back, max(c.RoomNumber) as ROOM_NBR_TAB  from
(select a.room, placement_date as placement_date,

 case when a.ROOM like '%KKE%' then 'Kankakee'
 when a.room like '%LNL%' then 'Lincoln'
 when a.room like '%JOL%' then 'Joliet'
 when a.room like '%Room%' then 'Encanto'
 when a.room like '%House%' then 'Vicksburg'

     else 'None Identified' end as Location,

 case when (a.ROOM like '%Bay%' and RIGHT(a.ROOM, 2) in ('10','11','12','13','14','15','16') )then Concat('Zone ', RIGHT(a.ROOM, 2))
 when (a.ROOM like '%Bay%') then Concat('Zone ', RIGHT(a.ROOM, 1))
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
;



select distinct roomname from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS

select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where loc = 'LNL'
                                                     and TRANSFERREDOUT = 0 and DELETED = 0 and INVENTORYTYPE = 13 and INVENTORYROOM_NAME like '%Vault%' and REMAININGWEIGHT > 0

--select max(id) from FIVETRAN_DB.BT_LINCOLN_PUBLIC.ROOMS where id in (5,120,34)

select * from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_NEXT

select CURRENTROOM,* from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY where TRANSFERREDOUT = 0 and DELETED = 0 and INVENTORYTYPE = 13 order by sessiontime desc;

select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.ROOMS at(timestamp => 'Tue, 24 Dec 2019 16:20:00 -0700'::timestamp);

select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.ROOMS at(offset => -60*13000);
CURRENTROOM
5
120
120
120
120
120
34
34


select distinct NEWROOM from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where ROOM_TYPE = 'Flowering' and ROOM_NUMBER = 'Zone 12' and BRTH_DT < '2019-01-01'

select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.ROOMS where id = 87

select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.REPLICATION_HISTORY where NEW_VAL like '%"roomname"%'
                                                                  and TABNAME = 'rooms'
                                                                 and left(TS,10) between '2019-12-15' and '2020-01-08'
                                                                  and PRIMARY_VAL is not null --and (PRIMARY_VAL like '%"109"%' or PRIMARY_VAL like '%"108"%' or PRIMARY_VAL like '%"107"%' or PRIMARY_VAL like '%"106"%' or PRIMARY_VAL like '%"105"%' or PRIMARY_VAL like '%"104"%' or PRIMARY_VAL like '%"103"%' or PRIMARY_VAL like '%"102"%')
--REPLICATION_VAL = '90605'
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.REPLICATION_HISTORY where --NEW_VAL like '%"roomname"%'
                                                                  TABNAME = 'rooms'
--                                                                  and left(TS,10) between '2015-01-01' and '2020-01-08'
                                                                  and PRIMARY_VAL is not null and (PRIMARY_VAL like '%"109"%' or PRIMARY_VAL like '%"108"%' or PRIMARY_VAL like '%"107"%' or PRIMARY_VAL like '%"106"%' or NEW_VAL like '%"105"%' or NEW_VAL like '%"104"%' or NEW_VAL like '%"103"%' or NEW_VAL like '%"102"%')


select CAST(to_timestamp(min(a.sessiontime))as DATE) as Room_Begin_Time, CAST(to_timestamp(max(c.SESSIONTIME))AS DATE) as Room_End_Time, a.Newroom, a.id as PLANT_ID, b.roomname as Room_Name,
 a.NEWSTATE, x.DELETED as OLDROOMDELETED,


case when ((b.roomname like '%Zone%' and b.roomname not like '%Dry%') or (b.roomname = '0000')) then 'Flowering'
when (b.roomname like '%Dry%' or b.roomname like '%Freezer%') then 'Drying'

when (b.roomname like '%Clone%' or b.roomname like '%Tray%') then 'Clones'
when (b.roomname like '%Rack%' or b.roomname like '%inch%' or b.roomname like '%Veg%') then 'Vegetative'
when b.roomname like '%Mother%' then 'Mother'
when (b.roomname like '%Working%' or b.roomname like '%working%') then 'Working'
when b.roomname like '%Destruction%' then 'Destruction'

else 'Unknown' end as Room_Type,
case when f.PHASENAME like '%Pre-Flowering%' then 'Flowering'
when f.PHASENAME like '%Flowering%' then 'Drying'
when f.PHASENAME like '%Seedling%' then 'Vegetative'
else f.PHASENAME end
as PHASE  ,

case when ((lower(b.roomname) like '%zone 10%' or lower(b.roomname) like '%zone 11%' or (lower(b.roomname) like '%zone 12%' and LEFT(to_timestamp(min(a.sessiontime)),10) >= '2020-01-31' ) or lower(b.roomname) like '%zone 13%' or lower(b.roomname) like '%zone 14%' or lower(b.roomname) like '%zone 15%' or lower(b.roomname) like '%zone 16%' or lower(b.roomname) like '%zone 17%' or lower(b.roomname) like '%zone 18%' or lower(b.roomname) like '%zone 19%') and lower(b.roomname) not like '%drying%') then left(b.roomname, 7)
WHEN (lower(b.roomname) like '%zone 12%' and LEFT(to_timestamp(min(a.sessiontime)),10) <= '2020-01-31' ) THEN 'Zone 2'
when (b.roomname like '%Zone%0%-%' and left(b.roomname, 6) like '%Zone%' ) then CONCAT(TRIM(left(b.roomname, 5)),' ',  TRIM(RIGHT(left(b.roomname, 7),1)))
when (b.roomname not like '%Zone%0%-%' and left(b.roomname, 6) like '%Zone%' ) then TRIM(left(b.roomname, 7))
when ((lower(b.roomname) like '%zone 10%' or lower(b.roomname) like '%zone 11%' or lower(b.roomname) like '%zone 12%'  or lower(b.roomname) like '%zone 13%' or lower(b.roomname) like '%zone 14%' or lower(b.roomname) like '%zone 15%' or lower(b.roomname) like '%zone 16%' or lower(b.roomname) like '%zone 17%' or lower(b.roomname) like '%zone 18%' or lower(b.roomname) like '%zone 19%') and lower(b.roomname) like '%Dry%') then right(b.ROOMNAME, 7)
when (b.roomname like '%Zone%' and b.roomname like '%Dry%') then right(b.ROOMNAME, 6)
when (left(b.roomname, 4) like '%Room%' and b.roomname not like '%Drying%' and b.roomname not like '%Drying%') then right(b.roomname , 3)
when (b.roomname like '%Drying%' and b.roomname like '%Room%' and RIGHT(b.roomname, 3) <> 'oom' ) then right(b.ROOMNAME , 3)
else 'No Specified Room' end as Room_Number,

case when (b.roomname like '%Flower%' and b.roomname like '%BACK%') then RIGHT(b.roomname, 4)
when (b.roomname like '%Flower%' and b.roomname like '%FRONT%') then RIGHT(b.ROOMNAME, 5)
else 'No Room Divider' end as Room_Front_Back,

case when b.roomname like '%Table%' then right(b.roomname, 8)
else 'No Table' end as Table_ID,
case when (right(b.roomname, 1) in ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S')
and (b.roomname like '%Zone%' or b.roomname like '%Veg%') ) then right(b.roomname, 3) else 'No SubID' end as Sub_Room_ID,

min(d.strain) as Strain, min(d.harvestgroupid) as harvestgroupid, coalesce(min(LASTMANUALPHASE), 0) as LST_PHASE_ID, max(e.type) as Strain_Type,


CAST(to_timestamp(min(d.Sessiontime) )AS DATE) as Brth_Dt,
'Lincoln' as Location
from  FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTSLOG a
left join FIVETRAN_DB.BT_LINCOLN_PUBLIC.ROOMS b
on a.NEWROOM = b.id
left join FIVETRAN_DB.BT_LINCOLN_PUBLIC.ROOMS x
on a.OLDROOM = x.id

left join FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTSLOG c
on a.NEWROOM = c.OLDROOM
and a.id = c.id
left join FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS d
on a.id = d.id


left join
(
  select a.strain, a.STRAINTYPE as TYPE
  from ANALYTICS_DB.CULTIVATION.STRAINS a
 group by
a.strain, a.STRAINTYPE) e
on d.strain = e.strain

left join FIVETRAN_DB.BT_JOLIET_PUBLIC.PHASETEXT f
on b.phase = f.id

group by a.Newroom, a.id, a.NEWSTATE,  b.roomname, F.phasename, x.DELETED






















Create or replace table Freezer_Contents as
select *, product_name as productid from analytics_db.cultivation.level_final b
where lower(b.inventoryroom_name) like '%freez%'
and remainingweight <> 0
and TRANSFERREDOUT = 0

select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where DELETED = 0 and TRANSFERREDOUT = 0 and INVENTORYTYPE = 13 and REMAININGWEIGHT > 0 and loc = 'LNL'

--update ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
--set PLACEMENT_DATE = '2020-01-15'
--where PLACEMENT_DATE = '2020-01-06' and LOCATION_ROOM = 'LNL-Bay6';

select * from ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
              where  LOCATION_ROOM = 'LNL-Bay6'


select * from ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES

Create or replace table ANALYTICS_DB.CULTIVATION.Flower_cure_current as
select *, product_name as productid

from analytics_db.cultivation.level_final
where deleted = 0
  and transferredout = 0
  and inventorytype = 13
  and ((lower(inventoryroom_name) like '%vault%' and lower(inventoryroom_name) like '%flower%')  or (lower(inventoryroom_name) like '%vault%' and loc in ('LNL','KKE') ))
  and lower(inventoryroom_name) not like '%pre%'
  and remainingweight > 0











