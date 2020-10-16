create or replace view rdr.rrv_ag_reinsurance
as
select
    le_1_cd 
  , le_2_cd
  , chartfield_cd
  , reins_le_cd
from
    stn.posting_method_derivation_rein;