insert into fdr.is_group ( isgrp_id , isgrp_name , isgrp_kind , isgrp_lock ) values (
  ( select max (ig.isgrp_id) + 1 from fdr.is_group ig )
, 'AG'
, 2
, 0 );
commit;