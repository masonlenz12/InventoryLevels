----In these queries I will be updating the dates below in my "Placement Dates" Table
        --The placement dates in the master yield tracker are usually wrong so I need to make updates like this

--Room 130 Updates
----10-31-18 need to be added
update ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
set PLACEMENT_DATE = '2018-10-31'
where LOCATION_ROOM = 'JOL-130' and PLACEMENT_DATE = '2018-11-13';


--Room 131 Updates
----Fix room start <> room end for the 6/4 harvests to flow in (Potentially add exclusion to where statment for this one harvest dates)
----3-7-2019 needs to be added

update ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
set PLACEMENT_DATE = '2019-03-07'
where LOCATION_ROOM = 'JOL-131' and PLACEMENT_DATE = '2018-03-07';


--Room 132 Updates
----10-31-2018 add
update ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
set PLACEMENT_DATE = '2018-10-31'
where LOCATION_ROOM = 'JOL-132' and PLACEMENT_DATE = '2018-11-13';

--Room 133 Updates
----12-26-2018 add
----3/7/2019 add
update ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
set PLACEMENT_DATE = '2019-03-07'
where LOCATION_ROOM = 'JOL-133' and PLACEMENT_DATE = '2019-03-13';
update ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
set PLACEMENT_DATE = '2018-12-26'
where LOCATION_ROOM = 'JOL-133' and PLACEMENT_DATE = '2019-01-11';

--Room 134
----11-1-2018
update ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
set PLACEMENT_DATE = '2018-11-01'
where LOCATION_ROOM = 'JOL-134' and PLACEMENT_DATE = '2018-11-13';

--Room 231
----10-16-2019(New) <-- 11-1-2019(Old)
update ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
set PLACEMENT_DATE = '2019-10-16'
where LOCATION_ROOM = 'JOL-231' and PLACEMENT_DATE = '2019-11-01';

--Room 232
----9-3-2019
----7-3-2019

insert into ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
select  'JOL-232' as LOCATION_ROOM ,'2019-09-03' as PLACEMENT_DATE , '2019-10-29' as HARVEST_DATE ;


insert into ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES
select 'JOL-232' as LOCATION_ROOM , '2019-07-03' as PLACEMENT_DATE , '2019-09-01' as HARVEST_DATE  ;

select * from ANALYTICS_DB.CULTIVATION.PLACEMENT_DATES;


select distinct ROOM_FRONT_BACK, ROOM_NUMBER, ROOM_NAME from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where LOCATION = 'Kankakee' and ROOM_TYPE = 'Flowering'





