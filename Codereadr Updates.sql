CREATE OR replace TABLE demo_db.PUBLIC.unnestedscans as
SELECT parse_json(answer) AS ANSWER_ARRAY, * FROM "DEMO_DB"."PUBLIC"."SCANS" WHERE answer IS NOT null;


CREATE OR REPLACE table demo_db.PUBLIC.unnestedscans as
SELECT
     unnested_neighbors.value, t1.*
FROM demo_db.PUBLIC.unnestedscans t1, TABLE(flatten(t1.answer_array)) as unnested_neighbors;


CREATE OR REPLACE table demo_db.PUBLIC.unnestedscans_final as
SELECT REPLACE(value['qid'],'"','') AS Question_id, REPLACE(value['qtext'],'"','') AS question_text, REPLACE(value['answer'],'"','') AS Answer_Actual, CASE WHEN value['answer'] LIKE '%link%' then parse_json(value['answer']) ELSE value['answer'] END AS PHOTO_LINK , * FROM
demo_db.PUBLIC.unnestedscans;


CREATE OR REPLACE TABLE demo_db.PUBLIC.unnestedscans_final as
SELECT replace(PHOTO_LINK['link'],'"','') AS PHOTO_LINK_FINAL, * FROM
demo_db.PUBLIC.unnestedscans_final ;


























select * from 