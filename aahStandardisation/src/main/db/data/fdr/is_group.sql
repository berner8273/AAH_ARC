insert into fdr.is_group ( isgrp_id , isgrp_name , isgrp_kind , isgrp_lock ) values (
  ( select max (ig.isgrp_id) + 1 from fdr.is_group ig )
, ( select max (fgl.lk_lookup_value1) from fdr.fr_general_lookup fgl where fgl.lk_lkt_lookup_type_code = 'USER_DEFAULT' and fgl.lk_match_key1 = 'GROUP_NAME' )
, 2
, 0 );
commit;