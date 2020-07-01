select
       ig.isgrp_name  group_name
     , iu.isusr_name  user_name
  from
       fdr.is_groupuser igu
  join 
       fdr.is_user  iu on iu.isusr_id = igu.isgu_usr_ref
  join
       fdr.is_group ig on ig.isgrp_id = igu.isgu_grp_ref