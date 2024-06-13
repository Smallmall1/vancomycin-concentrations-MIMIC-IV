
-- 创建万古霉素血药浓度的表
DROP table if EXISTS xueyao_cal_adm_lab_vancomycin;
create table xueyao_cal_adm_lab_vancomycin as
SELECT * from mimiciv_hosp.labevents 
where itemid=51009;

DROP table if EXISTS xueyao_cal_icu_lab_vancomycin;
create table xueyao_cal_icu_lab_vancomycin as
SELECT lab.*, icu.stay_id from mimiciv_hosp.labevents lab
join mimiciv_icu.icustays icu
on lab.hadm_id=icu.hadm_id and lab.charttime BETWEEN icu.intime and icu.outtime
where lab.itemid=51009;



-- 创建 患者基本信息表

CREATE table patient_admission_icustay as 
with heig as (
SELECT
*
from (
SELECT 
hg.stay_id,
hg.charttime,
hg.height,
ROW_NUMBER() over (partition by hg.stay_id ORDER BY hg.charttime) as idx
from
mimiciv_derived.height hg
) aa where aa.idx=1
),
 weig as (
 SELECT * 
 from 
 (
SELECT 
wd.stay_id,
wd.starttime,
wd.weight,
-- wd.weight_type,
ROW_NUMBER() over (partition by wd.stay_id ORDER BY wd.starttime) as idx
from 
mimiciv_derived.weight_durations  wd
) bb WHERE idx=1
),
 pvt as (
SELECT
icu.subject_id,
icu.hadm_id,
icu.stay_id,
pa.gender,
pa.anchor_age, 
ad.race,
ad.hospital_expire_flag,
icu.intime,
icu.outtime,
icu.los
from mimiciv_hosp.patients pa join mimiciv_hosp.admissions ad on pa.subject_id=ad.subject_id 
join mimiciv_icu.icustays icu on ad.hadm_id=icu.hadm_id )

SELECT pvt.*, heig.height, weig.weight from pvt join heig on pvt.stay_id = heig.stay_id 
join weig on pvt.stay_id = weig.stay_id;


-- 创建检验肌酐数据表

drop table if EXISTS xueyao_cal_adm_lab_creatine;
create table xueyao_cal_adm_lab_creatine as 
SELECT ch.* from mimiciv_derived.chemistry ch;

drop table if EXISTS xueyao_cal_icu_lab_creatine;
create table xueyao_cal_icu_lab_creatine as 
SELECT ch.*, icu.stay_id from mimiciv_derived.chemistry ch join mimiciv_icu.icustays icu
on ch.hadm_id=icu.hadm_id and ch.charttime BETWEEN icu.intime and icu.outtime;


-- 创建万古霉素使用的情况表
-- drop table if EXISTS xueyao_cal_input_vancomycin;
-- create table  xueyao_cal_input_vancomycin as 
-- SELECT * from mimiciv_icu.inputevents where itemid=225798;

drop table if EXISTS xueyao_cal_adm_vancomycin_usage;
create table  xueyao_cal_adm_vancomycin_usage as 
SELECT em.*, prt.dose_val_rx, dose_unit_rx, prt.route
from mimiciv_hosp.emar em 
join mimiciv_hosp.prescriptions prt on em.pharmacy_id=prt.pharmacy_id 
WHERE em.medication ilike '%vancomy%' and prt.drug ilike '%vancomy%';


drop table if EXISTS xueyao_cal_icu_vancomycin_usage;
create table  xueyao_cal_icu_vancomycin_usage as 
SELECT em.*, prt.dose_val_rx, dose_unit_rx, prt.route, icu.stay_id
from mimiciv_hosp.emar em 
join mimiciv_hosp.prescriptions prt on em.pharmacy_id=prt.pharmacy_id 
join mimiciv_icu.icustays icu
on em.hadm_id=icu.hadm_id and em.charttime BETWEEN icu.intime and icu.outtime
WHERE em.medication ilike '%vancomy%' and prt.drug ilike '%vancomy%';

