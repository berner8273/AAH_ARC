-- script replaces all entries in posting_method_deviation_rein

begin

delete from stn.posting_method_derivation_rein;


insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGREL','AGFRA','REIN2','CA003');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGREL','FSANY','REIN2','CA003');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGREL','FSAUK','REIN2','CA003');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGREL','AGCRP','REIN2','CA003');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGROL','AGFRA','REIN2','CA003');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGROL','FSANY','REIN2','CA003');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGROL','FSAUK','REIN2','CA003');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGROL','AGCRP','REIN2','CA003');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGCRP','FSANY','REIN4','CA002');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGCRP','FSAUK','REIN4','CA002');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('AGCRP','AGFRA','REIN4','CA002');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('FSANY','FSAUK','REIN4','CA002');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('FSANY','AGFRA','REIN4','CA002');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('CA002','AGREL',null,'CA003');
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) values ('CA002','AGROL',null,'CA003');


-- insert records going the other way.
insert into stn.posting_method_derivation_rein (le_1_cd, le_2_cd, chartfield_cd, reins_le_cd) 
select le_2_cd, le_1_cd, chartfield_cd, reins_le_cd
from stn.posting_method_derivation_rein
where le_1_cd <> 'CA002';


commit;
end;
/
