create or replace view gui.vw_ui_segment_4_rel_value
(
   fdr_code,
   lookup_value
) as
select pl.pl_party_legal_clicode,
       pl.pl_party_legal_clicode
from fdr.fr_party_legal pl
;
