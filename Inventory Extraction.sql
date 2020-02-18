----Inventory: Extraction Percentages



---Current State: Table with Levels 1-8
    --Levels1: our first connection from initial inventory entry and plants
        --This houses our starting flower/ FF lots from harvest

--Inventory type represents the current state of this inventory ID
---- For example: 6 = Starting Flower Lot, 9 = Starting Other Materials Lot
select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYTYPES --Not all data housed in this table is correct

----Converted Final Weights 1 & 2: These indicate the min and max values for the child inventory ID's of this ID
select conversionid,inventoryroom_name, sessiondate, sum(quantity) as QTY, max(converted_Final_weight) as final_weight,max(converted_Final_weight)/sum(quantity) as Percent from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where (inventoryroom_name like '%BHO%' or inventoryroom_name like '%CO2%') and inventorytype in ('13', '14') and conversionid is not null group by conversionid, inventoryroom_name, sessiondate order by sessiondate desc
------When start quantity has a comma (like '%,%') then we use the waste + converted_final_weight
    --All the rest are Quantity
select conversionid,inventoryroom_name, sessiondate, strain, max(inventory_id), sum(quantity) as QTY, max(converted_Final_weight) as final_weight,max(converted_Final_weight)/sum(quantity) as Percent from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where  placementgroup = 'JOL-2322019-10-30' and inventorytype in ('13', '14', '6', '9') and conversionid is not null  group by conversionid, inventoryroom_name, sessiondate, strain order by sessiondate desc
select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '5189564028485742'
-----Rooms to look into first: BHO Pod, CO2 Pod,
--
--and productid is not null

(select inventory_id, weight, remainingweight, transferredout, strain, inventorytype, productid, quantity, max(sessiondate) as sessiondate, max(placementgroup) as placementgroup, inventoryroom_name from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where  transferredout = 0 and  deleted = 0 and remainingweight>1 and productid is null  group by inventory_id, weight, remainingweight, transferredout, strain, inventorytype, inventoryroom_name, productid, quantity)



----ASK is: Get dataset procured for Natasha
    -----Replacing Extraction Tracker dataset with live Biotrack
    -----ROI- Christine doesnt have to fill out
    -----









select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where  transferredout = 0 and  deleted = 0 and remainingweight>1