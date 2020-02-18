Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY as
    select PLANTID, INVENTORY_ID,PLANT_ID_Original,  dd.PLACEMENTGROUP, dd.ROOM_NBR_TAB as Room_Number, dd.ROOM_FRONT_BACK from
    (select PLANTID, INVENTORY_ID, trim(f.value, '"') as PLANT_ID_Original
   from
 (select  cast(SPLIT(cast(replace(NEW_VAL['plantid'],'"','') as varchar), ',') as ARRAY) as PLANTID, coalesce(replace(NEW_VAL['id'],'"',''),replace(PRIMARY_VAL['f1'],'"','')) as inventory_id
from FIVETRAN_DB.BT_JOLIET_PUBLIC.REPLICATION_HISTORY where
                        TABNAME like '%inventory%' and LENGTH(NEW_VAL['plantid']) > 0    UNION
select  cast(SPLIT(cast(replace(NEW_VAL['plantid'],'"','') as varchar), ',') as ARRAY) as PLANTID, coalesce(replace(NEW_VAL['id'],'"',''),replace(PRIMARY_VAL['f1'],'"','')) as inventory_id from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.REPLICATION_HISTORY where
                        TABNAME like '%inventory%' and LENGTH(NEW_VAL['plantid']) > 0
     UNION
select  cast(SPLIT(cast(replace(NEW_VAL['plantid'],'"','') as varchar), ',') as ARRAY) as PLANTID, coalesce(replace(NEW_VAL['id'],'"',''),replace(PRIMARY_VAL['f1'],'"','')) as inventory_id from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.REPLICATION_HISTORY where
                        TABNAME like '%inventory%' and LENGTH(NEW_VAL['plantid']) > 0
     ) ly, table(flatten(ly.PLANTID)) f) f
left join ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS dd
on PLANT_ID_Original = dd.PLANT_ID
UNION
    select PLANTID, INVENTORY_ID,PLANT_ID_Original, dd.PLACEMENTGROUP, dd.ROOM_NBR_TAB as Room_Number, dd.ROOM_FRONT_BACK from
    (select PLANTID, INVENTORY_ID, trim(f.value, '"') as PLANT_ID_Original
   from
 (select  cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
where plantid is not null
     UNION
 select  cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id
 from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
where plantid is not null
     UNION
select  cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id
 from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
where plantid is not null
     ) ly, table(flatten(ly.PLANTID)) f) f
left join ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS dd
on PLANT_ID_Original = dd.PLANT_ID
;






/*
Mason Lenz
Last Update: 2020-01-22 (yyy-mm-dd)

This first level of the code outlines our connection from Plants to the first inventory ID
    -In the inventory table if you filter the table to just the results with Plant_id's present it will give you the first entry into inventory
        --Examples of products presents: Flower Material Lots, Transfer Lots, Fresh Frozen Lots

This table will have duplicates of Inventory_id, parentid, weight, remainingweight, transferredout, transferredouttime, strain, etc (All columns from the inventory table)



*/
Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY as
select PLANTID,
       INVENTORY_ID,
       parentid,
       PLANT_ID_Original,
       weight,
       REMAININGWEIGHT,
       TRANSFERREDOUT,
       TRANSFERREDOUTTIME,
       f.Strain,
       inventorytype,
       SessionDate,
       dd.PLACEMENTGROUP,
       dd.ROOM_NBR_TAB as Room_Number,
       dd.ROOM_FRONT_BACK,
       k.roomname
from (select PLANTID,
             INVENTORY_ID,
             PARENTID,
             trim(f.value, '"')        as PLANT_ID_Original,
             weight,
             REMAININGWEIGHT,
             TRANSFERREDOUT,
             TRANSFERREDOUTTIME,
             Strain,
             inventorytype,
             cast(SessionDate as Date) as SessionDate,
             CURRENTROOM
      from (select cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID,
                   id                                                  as inventory_id,
                   PARENTID,
                   INVENTORYPARENTID,
                   Weight,
                   REMAININGWEIGHT,
                   TRANSFERREDOUT,
                   TRANSFERREDOUTTIME,
                   Strain,
                   to_timestamp(SESSIONTIME)                           as SessionDate,
                   inventorytype,
                   CURRENTROOM
            from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
            where plantid is not null
            UNION
            select cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID,
                   id                                                  as inventory_id,
                   PARENTID,
                   INVENTORYPARENTID,
                   Weight,
                   REMAININGWEIGHT,
                   TRANSFERREDOUT,
                   TRANSFERREDOUTTIME,
                   Strain,
                   to_timestamp(SESSIONTIME)                           as SessionDate,
                   inventorytype,
                   CURRENTROOM
            from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
            where plantid is not null
            UNION
            select cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID,
                   id                                                  as inventory_id,
                   PARENTID,
                   INVENTORYPARENTID,
                   Weight,
                   REMAININGWEIGHT,
                   TRANSFERREDOUT,
                   TRANSFERREDOUTTIME,
                   Strain,
                   to_timestamp(SESSIONTIME)                           as SessionDate,
                   inventorytype,
                   CURRENTROOM
            from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
            where plantid is not null
           ) ly,
           table (flatten(ly.PLANTID)) f) f
         left join ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS dd
                   on PLANT_ID_Original = dd.PLANT_ID
         left join FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS k
                   on CURRENTROOM = k.id


;


Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY as
select g.id as inventory_id, g.id as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select *, 'JOL' as LOC
      from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
      UNION
      select * , 'LNL' as LOC
      from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
      UNION
      select *, 'KKE' as LOC
      from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     )

    g
left join ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY f
on  f.inventory_id = g.INVENTORYPARENTID

left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from

 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA


     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3


left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS) k
on g.CURRENTROOM = k.id
and g.LOC = k.LOC

where f.inventory_id is not null /*and g.INVENTORYTYPE in (12,13,14,6,9)*/
group by g.id , g.id ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.LOC, LEFT(to_timestamp(g.created),10)
UNION
select g.id as inventory_id, g.id as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select *, 'JOL' as LOC
      from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
      UNION
      select * , 'LNL' as LOC
      from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
      UNION
      select *, 'KKE' as LOC
      from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     )

    g
left join ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY f
on f.INVENTORY_ID = g.id



left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA


     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3

left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS) k
on g.CURRENTROOM = k.id
and g.LOC = k.LOC

where f.inventory_id is not null
group by g.id , g.id ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.LOC, LEFT(to_timestamp(g.created),10);
-----OLD AMOUNT = 190,710
/*
 UNION
select g.id as inventory_id, g.id as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select *, 'JOL' as LOC
      from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
      UNION
      select * , 'LNL' as LOC
      from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
      UNION
      select *, 'KKE' as LOC
      from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     )

    g
left join ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY f
on  f.INVENTORY_ID = split_part(g.PARENTID, ',', 1)



left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA


     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3

left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS) k
on g.CURRENTROOM = k.id
and g.LOC = k.LOC

where f.inventory_id is not null /*and g.INVENTORYTYPE in (12,13,14,6,9)*/
group by g.id , g.id ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.LOC, LEFT(to_timestamp(g.created),10)
UNION
select g.id as inventory_id, g.id as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select *, 'JOL' as LOC
      from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
      UNION
      select * , 'LNL' as LOC
      from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
      UNION
      select *, 'KKE' as LOC
      from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     )

    g
left join ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY f
on   f.INVENTORY_ID = split_part(g.PARENTID, ',', 2)


left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA


     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3

left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS) k
on g.CURRENTROOM = k.id
and g.LOC = k.LOC

where f.inventory_id is not null /*and g.INVENTORYTYPE in (12,13,14,6,9)*/
group by g.id , g.id ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.LOC, LEFT(to_timestamp(g.created),10)
UNION
select g.id as inventory_id, g.id as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select *, 'JOL' as LOC
      from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
      UNION
      select * , 'LNL' as LOC
      from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
      UNION
      select *, 'KKE' as LOC
      from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     )

    g
left join ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY f
on   f.INVENTORY_ID = split_part(g.PARENTID, ',', 3)


left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA


     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3

left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS) k
on g.CURRENTROOM = k.id
and g.LOC = k.LOC

where f.inventory_id is not null /*and g.INVENTORYTYPE in (12,13,14,6,9)*/
group by g.id , g.id ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.LOC, LEFT(to_timestamp(g.created),10);

 */







alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;



alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Working%' and InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column TestResults1 string;



update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select parentid as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;




update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;





Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt from (select *, 'JOL' as LOC
      from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
      UNION
      select * , 'LNL' as LOC
      from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
      UNION
      select *, 'KKE' as LOC
      from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     ) g

left join ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY f

on case when g.parentid like '%,%' THEN coalesce(array_contains(f.inventory_id::variant, split(g.parentid, ',' )) = True, array_contains(f.conversionid::variant, split(g.id, ',' )) = True) ELSE f.inventory_id = g.parentid END
left join (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA) fh on  CASE WHEN fh.parentid like '%,%' THEN
        array_contains(g.id::variant, SPLIT(fh.parentid,',' )) = True
        ELSE g.id = fh.parentid end
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS) k
on g.CURRENTROOM = k.id
and g.LOC = k.LOC
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc, LEFT(to_timestamp(g.created),10);

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Working%' and InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column TestResults1 string;



update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select parentid as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;




update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;






Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select * from    (select *, trim(f.value, '"') as parentid_Join2
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'JOL' as LOC
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'KKE' as LOC from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'LNL' as LOC from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY



     ) ly, table(flatten(ly.parentid_join)) f) f

     ) g




left join ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY f
on
 f.inventory_id = g.parentid_join2
left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA



     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS ) k
on g.CURRENTROOM = k.id
and g.loc = k.loc
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) ;





alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Mixed/Oils Lot'
when InventoryRoom_Name like '%Cold Room%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Edibles Lot'
when InventoryRoom_Name like '%Extract%' and InventoryRoom_Name like '%-%' THEN 'Extraction Stage Lot'

when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%!%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%**%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%-%' and left(InventoryRoom_Name,1) in ('5','4','6','3','2','1') THEN 'PackoutRetailer Lot'


when InventoryRoom_Name like '%Working%' or InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select parentid as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select INVENTORYPARENTID as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.sample_id;



update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;































Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select * from    (select *, trim(f.value, '"') as parentid_Join2
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'JOL' as LOC
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'KKE' as LOC from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'LNL' as LOC from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY



     ) ly, table(flatten(ly.parentid_join)) f) f

     ) g




left join ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY f
on
 f.inventory_id = g.parentid_join2
left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA



     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS ) k
on g.CURRENTROOM = k.id
and g.loc = k.loc
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc, LEFT(to_timestamp(g.created),10);

alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Mixed/Oils Lot'
when InventoryRoom_Name like '%Cold Room%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Edibles Lot'
when InventoryRoom_Name like '%Extract%' and InventoryRoom_Name like '%-%' THEN 'Extraction Stage Lot'

when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%!%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%**%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%-%' and left(InventoryRoom_Name,1) in ('5','4','6','3','2','1') THEN 'PackoutRetailer Lot'


when InventoryRoom_Name like '%Working%' or InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;

Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select * from    (select *, trim(f.value, '"') as parentid_Join2
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'JOL' as LOC
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'KKE' as LOC from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'LNL' as LOC from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY



     ) ly, table(flatten(ly.parentid_join)) f) f

     ) g




left join ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY f
on
 f.inventory_id = g.parentid_join2
left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA



     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS ) k
on g.CURRENTROOM = k.id
and g.loc = k.loc
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc,LEFT(to_timestamp(g.created),10);

alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Mixed/Oils Lot'
when InventoryRoom_Name like '%Cold Room%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Edibles Lot'
when InventoryRoom_Name like '%Extract%' and InventoryRoom_Name like '%-%' THEN 'Extraction Stage Lot'

when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%!%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%**%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%-%' and left(InventoryRoom_Name,1) in ('5','4','6','3','2','1') THEN 'PackoutRetailer Lot'


when InventoryRoom_Name like '%Working%' or InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;

Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select * from    (select *, trim(f.value, '"') as parentid_Join2
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'JOL' as LOC
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'KKE' as LOC from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'LNL' as LOC from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY



     ) ly, table(flatten(ly.parentid_join)) f) f

     ) g




left join ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY f
on
 f.inventory_id = g.parentid_join2
left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA



     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS ) k
on g.CURRENTROOM = k.id
and g.loc = k.loc
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc, LEFT(to_timestamp(g.created),10);


alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Mixed/Oils Lot'
when InventoryRoom_Name like '%Cold Room%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Edibles Lot'
when InventoryRoom_Name like '%Extract%' and InventoryRoom_Name like '%-%' THEN 'Extraction Stage Lot'

when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%!%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%**%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%-%' and left(InventoryRoom_Name,1) in ('5','4','6','3','2','1') THEN 'PackoutRetailer Lot'


when InventoryRoom_Name like '%Working%' or InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;




Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select * from    (select *, trim(f.value, '"') as parentid_Join2
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'JOL' as LOC
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'KKE' as LOC from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'LNL' as LOC from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY



     ) ly, table(flatten(ly.parentid_join)) f) f

     ) g




left join ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY f
on
 f.inventory_id = g.parentid_join2
left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA



     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS ) k
on g.CURRENTROOM = k.id
and g.loc = k.loc
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) ;


alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Mixed/Oils Lot'
when InventoryRoom_Name like '%Cold Room%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Edibles Lot'
when InventoryRoom_Name like '%Extract%' and InventoryRoom_Name like '%-%' THEN 'Extraction Stage Lot'

when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%!%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%**%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%-%' and left(InventoryRoom_Name,1) in ('5','4','6','3','2','1') THEN 'PackoutRetailer Lot'


when InventoryRoom_Name like '%Working%' or InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;



Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select * from    (select *, trim(f.value, '"') as parentid_Join2
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'JOL' as LOC
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'KKE' as LOC from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'LNL' as LOC from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY



     ) ly, table(flatten(ly.parentid_join)) f) f

     ) g




left join ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY f
on
 f.inventory_id = g.parentid_join2
left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA



     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS ) k
on g.CURRENTROOM = k.id
and g.loc = k.loc
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc, LEFT(to_timestamp(g.created),10);


alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Mixed/Oils Lot'
when InventoryRoom_Name like '%Cold Room%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Edibles Lot'
when InventoryRoom_Name like '%Extract%' and InventoryRoom_Name like '%-%' THEN 'Extraction Stage Lot'

when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%!%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%**%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%-%' and left(InventoryRoom_Name,1) in ('5','4','6','3','2','1') THEN 'PackoutRetailer Lot'


when InventoryRoom_Name like '%Working%' or InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;

Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select * from    (select *, trim(f.value, '"') as parentid_Join2
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'JOL' as LOC
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'KKE' as LOC from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'LNL' as LOC from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY



     ) ly, table(flatten(ly.parentid_join)) f) f

     ) g




left join ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY f
on
 f.inventory_id = g.parentid_join2
left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA



     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS ) k
on g.CURRENTROOM = k.id
and g.loc = k.loc
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc, LEFT(to_timestamp(g.created),10);


alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Mixed/Oils Lot'
when InventoryRoom_Name like '%Cold Room%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Edibles Lot'
when InventoryRoom_Name like '%Extract%' and InventoryRoom_Name like '%-%' THEN 'Extraction Stage Lot'

when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%!%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%**%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%-%' and left(InventoryRoom_Name,1) in ('5','4','6','3','2','1') THEN 'PackoutRetailer Lot'


when InventoryRoom_Name like '%Working%' or InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;



Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL_FINAL as


    (select *, 'Level1' as Level from ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
UNION
select *, 'Level2' as Level from ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
UNION
select *, 'Level3' as level from ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
UNION
select *, 'Level4' as level from ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
UNION
select *, 'level5' as level from ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
UNION
select *, 'level6' as level from ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
UNION
select *, 'level7' as level from ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
UNION
select *, 'level8' as level from ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
UNION
select *, 'level9' as level from ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
    )

;



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


create or replace table ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY as
select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where transferredout = 0 and remainingweight > 0 and deleted = 0;


select count(distinct INVENTORY_ID) from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL--- where INVENTORY_ID = '1704212604508051'
----Back 2 190K bb

select distinct INVENTORY_ID, STRAIN, SESSIONDATE, QUANTITY, REMAININGWEIGHT, PRODUCT_NAME, INVENTORYROOM_NAME from ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY where PRODUCT_NAME like '%Flower%' -- INVENTORYROOM_NAME like '%+%Cold%' or INVENTORYROOM_NAME is null

select count(distinct inventory_id), loc from ANALYTICS_DB.cultivation.LEVEL_FINAL group by loc





















































CREATE OR REPLACE TABLE ANALYTICS_DB.CULTIVATION.INVOICES_BIOTRACK as
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
       CULTIVATOR, inventory_id, remainingweight as Remaining_Weight,INVENTORYROOM_NAME as BT_INVENTORYROOM,PRODUCTID as BT_PRODUCT
from "ANALYTICS_DB"."WHOLESALE"."WHOLESALE_SALES" a
left join (select  sum(remainingweight) as remainingweight,product_name as productid, strain, INVENTORY_ID, INVENTORYROOM_NAME from ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY where  ( lower(inventoryroom_name) like '%pre%' or (lower(INVENTORYROOM_NAME) like '%+%vault%' and lower(inventoryroom_name) not like '%retention%') or lower(inventoryroom_name) like '%+%cold%fg%') and remainingweight > 1
group by product_name, strain, INVENTORY_ID, INVENTORYROOM_NAME) b

on
 lower(b.productid) like
    concat('%', CONCAT(LOWER(SPLIT_PART(split_part(split_part(SKU_NAME, ' - ', 2), 'g', 1), ' ',
                                           1)), '%'))
and lower(b.productid) like
           REPLACE(CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%'),'g','')
and lower(b.productid) like
           CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',1),' ' , 1))
     ,'%')
and lower(b.productid) like
     CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',3),' ' , 1))
     ,'%')

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
       CULTIVATOR, INVENTORY_ID, remainingweight , INVENTORYROOM_NAME , PRODUCTID;



select concat('%', CONCAT(LOWER(SPLIT_PART(split_part(split_part(SKU_NAME, ' - ', 2), 'g', 1), ' ',
                                           1)), '%')) as Join_1,

       REPLACE(CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',2),' ' , 2))
     ,'%'),'g','')  as Join2
       ,

       CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',1),' ' , 1))
     ,'%') as Join3,
       CONCAT('%',
LOWER(SPLIT_PART(split_part(SKU_NAME,' - ',3),' ' , 1))
     ,'%') as Join4

from ANALYTICS_DB.BUSINESS.WHOLESALE_SALES
where status = 'Pending'
  and state = 'IL';

