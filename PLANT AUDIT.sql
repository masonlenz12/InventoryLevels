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
select fg.ROOM_BEGIN_TIME as room_begin_time, fg.STRAIN, max(f.strain) as strain_join, fg.ROOM_NUMBER as room_number, fg.LOCATION, fg.room_front_back as room_front_back, fg.PLANT_ID from ANALYTICS_DB.CULTIVATION.CURRENTLY_IN_FLOWERING fg
left join demo_db.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER f
on lower(fg.STRAIN) like f.KEYWORD
where fg.PLANT_ID is not null
group by  fg.ROOM_BEGIN_TIME, fg.STRAIN, fg.ROOM_NUMBER, fg.LOCATION, fg.room_front_back, fg.PLANT_ID)
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


select * from ANALYTICS_DB.CULTIVATION.CURRENTLY_IN_FLOWERING