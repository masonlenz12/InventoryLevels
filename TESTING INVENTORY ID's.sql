


select distinct  INVENTORY_ID, REMAININGWEIGHT from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where INVENTORY_ID in ('3558048810742624', '1863184195282402', '3355663408352707')
                                                                                               --PRODUCT_NAME like '%Gummy%Cherry%Lime%15:1%' and REMAININGWEIGHT > 1




--3558048810742624, 1863184195282402, 3355663408352707

select distinct room_number, NEWROOM from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where location = 'Lincoln' and ROOM_TYPE = 'Flowering'


select * from ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY where INVENTORY_ID = '1863184195282402';


                                                         REMAININGWEIGHT > 1 and TRANSFERREDOUT = 1

select DOMO_HARVEST_DATE,
       ROOM_NUMBER,
       CULTIVATION_ENVIRONMENT,
       ROOM_CANOPY,
       sum(TOTAL_WET_WEIGHT) / AVG(ROOM_CANOPY) as Biomass_SQFT,
       sum(TOTAL_WET_WEIGHT)                    as Total_WET_WEIGHT,
       sum(TOTAL_PLANTS)                        as plants
from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS
where location = 'Fall River'
group by DOMO_HARVEST_DATE, ROOM_NUMBER, CULTIVATION_ENVIRONMENT, ROOM_CANOPY;


select * from ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY where INVENTORY_ID = '9870032523662358'


update ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS a
set DOMO_HARVEST_DATE = f.DOMODT
FROM
     (select PLACEMENTGROUP, PLACEMENT_DATE, concat(left(max(PLANNER_HARVEST_DATE),8),'01') as DOMODT
from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS
where DATA_SOURCE = 'BioTrack'
group by PLACEMENTGROUP, PLACEMENT_DATE) f

where a.DATA_SOURCE = 'BioTrack' and  a.placementgroup = f.PLACEMENTGROUP
;



select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null

select distinct strain from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PLANTS;

--select * from BT_PLANT_CYCLES where strain like '%Face%int%';


[2020-01-23 10:35:31] 42 rows retrieved starting from 1 in 268 ms (execution: 243 ms, fetching: 25 ms)
ANALYTICS_DB: CULTIVATION, PUBLIC> update ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS
                                   set DOMO_HARVEST_DATE = f.DOMODT
                                   from
                                   ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS a
                                       LEFT JOIN
                                        (select PLACEMENTGROUP, PLACEMENT_DATE, concat(left(max(PLANNER_HARVEST_DATE),8),'01') as DOMODT
                                   from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS
                                   where DATA_SOURCE = 'BioTrack'
                                   group by PLACEMENTGROUP, PLACEMENT_DATE) f
                                   on a.placementgroup = f.PLACEMENTGROUP
                                   where a.DATA_SOURCE = 'BioTrack'
[2020-01-23 10:41:45] 9588 rows affected in 2 s 7 ms


select * from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS

