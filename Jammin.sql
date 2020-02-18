

select distinct Case when Facility = 'Encanto' and left(room, 2 ) = 'GH' THEN TRIM(CONCAT('Room ', LEFT(room, 2) )) WHEN Facility = 'Encanto'  and left(room, 2 ) <> 'GH' and room not like '%Room%' THEN TRIM(CONCAT('Room ', LEFT(room, 1) ))
WHEN Facility = 'Lincoln' and room like '%Zone%' THEN TRIM(CONCAT('Bay',TRIM(RIGHT(room, 2))))
    WHEN  (Facility = 'Lincoln' and room not like '%Zone%' and room not like '%Bay%') THEN TRIM(CONCAT('Bay',LEFT(TRIM(room),1)))
WHEN Facility = 'Kankakee' and (room like '%FH%' or room like '%BH%') and room not like '%Flower%' THEN TRIM(CONCAT('Flower ', room)) WHEN  Facility = 'Kankakee' and room like '%Mini%' THEN 'Mini Bloom'
WHEN Facility = 'Brookville' and room like '%224%' THEN 'Flower 1-224' WHEN  Facility = 'Brookville' and room like '%227%' THEN 'Flower 2-227' WHEN  Facility = 'Brookville' and room like '%222%' THEN 'Flower 3-222' WHEN  Facility = 'Brookville' and room like '%226%' THEN 'Flower 4-226' WHEN  Facility = 'Brookville' and room like '%220%' THEN 'Flower 5-220' WHEN  Facility = 'Brookville' and room like '%225%' THEN 'Flower 6-225' WHEN  Facility = 'Brookville' and room like '%217%' THEN 'Flower 7-217' WHEN Facility = 'Brookville' and room like '%GH1%' THEN TRIM(CONCAT('GH1','-','Bay',RIGHT(room, 1)))
When Facility = 'Fall River' and room like '%Flower House%' THEN TRIM(CONCAT('FR ', right(room, 1)))
WHEN Facility = 'Vicksburg' and room like '%South %' THEN 'South Field'
WHEN Facility = 'Yellow Springs' and room like '%Indoor Flower%' and (room like '%FH%' or room like '%BH%') THEN TRIM(CONCAT(case when room like '%FH%' THEN 'Indr Flwer ' ELSE 'Indr Flwr ' END,RIGHT(room, 2), CASE WHEN room LIKE '%FH%' THEN ' (T1-8)' ELSE ' (T9-16)' END))
WHEN Facility in ('Carpenteria','Carpinteria') THEN TRIM(RIGHT(TRIM(room), 4))
    when Facility = 'Joliet' THEN TRIM(CAST(room as INT)) ELSE TRIM(room) END, FACILITY from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW


select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW





select distinct Case when Facility = 'Encanto' and left(room, 2 ) = 'GH' THEN TRIM(CONCAT('Room ', LEFT(room, 2) )) WHEN Facility = 'Encanto'  and left(room, 2 ) <> 'GH' and room not like '%Room%' THEN TRIM(CONCAT('Room ', LEFT(room, 1) ))
WHEN Facility = 'Lincoln' and room like '%Zone%' THEN TRIM(CONCAT('Bay',TRIM(RIGHT(room, 2))))
    WHEN  (Facility = 'Lincoln' and room not like '%Zone%' and room not like '%Bay%') THEN TRIM(CONCAT('Bay',LEFT(TRIM(room),1)))
WHEN Facility = 'Kankakee' and (room like '%FH%' or room like '%BH%') and room not like '%Flower%' THEN TRIM(CONCAT('Flower ', room)) WHEN  Facility = 'Kankakee' and room like '%Mini%' THEN 'Mini Bloom'
WHEN Facility = 'Brookville' and room like '%224%' THEN 'Flower 1-224' WHEN  Facility = 'Brookville' and room like '%227%' THEN 'Flower 2-227' WHEN  Facility = 'Brookville' and room like '%222%' THEN 'Flower 3-222' WHEN  Facility = 'Brookville' and room like '%226%' THEN 'Flower 4-226' WHEN  Facility = 'Brookville' and room like '%220%' THEN 'Flower 5-220' WHEN  Facility = 'Brookville' and room like '%225%' THEN 'Flower 6-225' WHEN  Facility = 'Brookville' and room like '%217%' THEN 'Flower 7-217' WHEN Facility = 'Brookville' and room like '%GH1%' THEN TRIM(CONCAT('GH1','-','Bay',RIGHT(room, 1)))
When Facility = 'Fall River' and room like '%Flower House%' THEN TRIM(CONCAT('FR ', right(room, 1)))
WHEN Facility = 'Vicksburg' and room like '%South %' THEN 'South Field'
WHEN Facility = 'Yellow Springs' and room like '%Indoor Flower%' and (room like '%FH%' or room like '%BH%') THEN TRIM(CONCAT(case when room like '%FH%' THEN 'Indr Flwer ' ELSE 'Indr Flwr ' END,RIGHT(room, 2), CASE WHEN room LIKE '%FH%' THEN ' (T1-8)' ELSE ' (T9-16)' END))
WHEN Facility in ('Carpenteria','Carpinteria') THEN TRIM(RIGHT(TRIM(room), 4))
    when Facility = 'Joliet' THEN TRIM(CAST(room as INT)) ELSE TRIM(room) END, FACILITY from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW_HISTORICAL


select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW_HISTORICAL


alter table DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW add column Room_Name_Original string;

--update demo_db.PRODUCTION_PLAN.PLACEMENT_NEW p
--set Room_Name_Original = room ,room = Case when Facility = 'Encanto' and left(room, 2 ) = 'GH' THEN TRIM(CONCAT('Room ', LEFT(room, 2) )) WHEN Facility = 'Encanto'  and left(room, 2 ) <> 'GH' and room not like '%Room%' THEN TRIM(CONCAT('Room ', LEFT(room, 1) ))
--WHEN Facility = 'Lincoln' and room like '%Zone%' THEN TRIM(CONCAT('Bay',TRIM(RIGHT(room, 2))))
--    WHEN  (Facility = 'Lincoln' and room not like '%Zone%' and room not like '%Bay%') THEN TRIM(CONCAT('Bay',LEFT(TRIM(room),1)))
--WHEN Facility = 'Kankakee' and (room like '%FH%' or room like '%BH%') and room not like '%Flower%' THEN TRIM(CONCAT('Flower ', room)) WHEN  Facility = 'Kankakee' and room like '%Mini%' THEN 'Mini Bloom'
--WHEN Facility = 'Brookville' and room like '%224%' THEN 'Flower 1-224' WHEN  Facility = 'Brookville' and room like '%227%' THEN 'Flower 2-227' WHEN  Facility = 'Brookville' and room like '%222%' THEN 'Flower 3-222' WHEN  Facility = 'Brookville' and room like '%226%' THEN 'Flower 4-226' WHEN  Facility = 'Brookville' and room like '%220%' THEN 'Flower 5-220' WHEN  Facility = 'Brookville' and room like '%225%' THEN 'Flower 6-225' WHEN  Facility = 'Brookville' and room like '%217%' THEN 'Flower 7-217' WHEN Facility = 'Brookville' and room like '%GH1%' THEN TRIM(CONCAT('GH1','-','Bay',RIGHT(room, 1)))
--When Facility = 'Fall River' and room like '%Flower House%' THEN TRIM(CONCAT('FR ', right(room, 1)))
--WHEN Facility = 'Vicksburg' and room like '%South %' THEN 'South Field'
--WHEN Facility = 'Yellow Springs' and room like '%Indoor Flower%' and (room like '%FH%' or room like '%BH%') THEN TRIM(CONCAT(case when room like '%FH%' THEN 'Indr Flwer ' ELSE 'Indr Flwr ' END,RIGHT(room, 2), CASE WHEN room LIKE '%FH%' THEN ' (T1-8)' ELSE ' (T9-16)' END))
--WHEN Facility in ('Carpenteria','Carpinteria') THEN TRIM(RIGHT(TRIM(room), 4))
--    when Facility = 'Joliet' THEN TRIM(CAST(room as INT)) ELSE TRIM(room) END
--;



select * from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES

--update DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES
--set location = 'Massachusetts'
--where location = 'Fall River'

--    select * from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS



select * from ANALYTICS_DB.CULTIVATION.INVOICES_BIOTRACK;

select * from ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY where STRAIN = 'Rocket Fuel';


ROOM,FACILITY
Indr Flwer FH (T1-8),Yellow Springs
Indr Flwr BH (T9-16),Yellow Springs
Indr Flwr FH (T1-8),Yellow Springs

    --Placement New
ROOM,FACILITY
Indr Flwer FH (T1-8),Yellow Springs
Indr Flwr BH (T9-16),Yellow Springs
select distinct
Case when Facility = 'Encanto' and left(room, 2 ) = 'GH' THEN TRIM(CONCAT('Room ', LEFT(room, 2) )) WHEN Facility = 'Encanto'  and left(room, 2 ) <> 'GH' and room not like '%Room%' THEN TRIM(CONCAT('Room ', LEFT(room, 1) ))
WHEN Facility = 'Lincoln' and room like '%Zone%' THEN TRIM(CONCAT('Bay',TRIM(RIGHT(room, 2))))
    WHEN  (Facility = 'Lincoln' and room not like '%Zone%' and room not like '%Bay%') THEN TRIM(CONCAT('Bay',LEFT(TRIM(room),1)))
WHEN Facility = 'Kankakee' and (room like '%FH%' or room like '%BH%') and room not like '%Flower%' THEN TRIM(CONCAT('Flower ', room)) WHEN  Facility = 'Kankakee' and room like '%Mini%' THEN 'Mini Bloom'
WHEN Facility = 'Brookville' and room like '%224%' THEN 'Flower 1-224' WHEN  Facility = 'Brookville' and room like '%227%' THEN 'Flower 2-227' WHEN  Facility = 'Brookville' and room like '%222%' THEN 'Flower 3-222' WHEN  Facility = 'Brookville' and room like '%226%' THEN 'Flower 4-226' WHEN  Facility = 'Brookville' and room like '%220%' THEN 'Flower 5-220' WHEN  Facility = 'Brookville' and room like '%225%' THEN 'Flower 6-225' WHEN  Facility = 'Brookville' and room like '%217%' THEN 'Flower 7-217' WHEN Facility = 'Brookville' and room like '%GH1%' THEN TRIM(CONCAT('GH1','-','Bay',RIGHT(room, 1)))
When Facility = 'Fall River' and room like '%Flower House%' THEN TRIM(CONCAT('FR ', right(room, 1)))
WHEN Facility = 'Vicksburg' and room like '%South %' THEN 'South Field'
WHEN Facility = 'Yellow Springs' and room like '%Indoor Flower%' and (room like '%FH%' or room like '%BH%') THEN TRIM(CONCAT(case when room like '%FH%' THEN 'Indr Flwer ' ELSE 'Indr Flwr ' END,RIGHT(room, 2), CASE WHEN room LIKE '%FH%' THEN ' (T1-8)' ELSE ' (T9-16)' END))
WHEN Facility = 'Carpenteria' THEN TRIM(RIGHT(room, 4))
    when Facility = 'Joliet' THEN TRIM(CAST(room as INT)) ELSE TRIM(room) END, facility from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW



update "ANALYTICS_DB"."BUSINESS"."CULTIVATION_YIELDS"
set room_number = Case when Location = 'Encanto' and left(room_number, 2 ) = 'GH' THEN TRIM(CONCAT('Room ', LEFT(room_number, 2) )) WHEN Location = 'Encanto'  and left(room_number, 2 ) <> 'GH' and room_number not like '%Room%' THEN TRIM(CONCAT('Room ', LEFT(room_number, 1) ))
WHEN Location = 'Lincoln' and room_number like '%Zone%' THEN TRIM(CONCAT('Bay',TRIM(RIGHT(room_number, 2)))) WHEN  Location = 'Lincoln' and room_number not like '%Zone%' and room_number not like '%Bay%' THEN TRIM(CONCAT('Bay',LEFT(TRIM(room_number),1)))
WHEN Location = 'Kankakee' and (room_number like '%FH%' or room_number like '%BH%') and room_number not like '%Flower%' THEN TRIM(CONCAT('Flower ', room_number)) WHEN  Location = 'Kankakee' and room_number like '%Mini%' THEN 'Mini Bloom'
WHEN Location = 'Brookville' and room_number like '%224%' THEN 'Flower 1-224' WHEN  Location = 'Brookville' and room_number like '%227%' THEN 'Flower 2-227' WHEN  Location = 'Brookville' and room_number like '%222%' THEN 'Flower 3-222' WHEN  Location = 'Brookville' and room_number like '%226%' THEN 'Flower 4-226' WHEN  Location = 'Brookville' and room_number like '%220%' THEN 'Flower 5-220' WHEN  Location = 'Brookville' and room_number like '%225%' THEN 'Flower 6-225' WHEN  Location = 'Brookville' and room_number like '%217%' THEN 'Flower 7-217' WHEN Location = 'Brookville' and room_number like '%GH1%' THEN TRIM(CONCAT(RIGHT(LEFT(room_number, 6),3),'-','Bay',RIGHT(room_number, 1)))
When Location = 'Fall River' and room_number like '%Flower House%' THEN TRIM(CONCAT('FR ', right(room_number, 1)))
WHEN Location = 'Vicksburg' and room_number like '%South %' THEN 'South Field'
WHEN Location = 'Yellow Springs' and room_number like '%Indoor Flower%' and (room_number like '%FH%' or room_number like '%BH%') THEN TRIM(CONCAT('Indr Flwr ',RIGHT(room_number, 2), CASE WHEN room_number LIKE '%FH%' THEN ' (T1-8)' ELSE ' (T9-16)' END))
WHEN Location = 'Carpenteria' THEN TRIM(RIGHT(room_number, 4))
    when location = 'Joliet' THEN TRIM(CAST(ROOM_NUMBER as INT)) ELSE TRIM(room_number) END
,location = trim(location)
;