-- Pre-Load SQL
delete from fdr.fr_posting_driver;

delete from fdr.fr_account_lookup;
delete from fdr.fr_general_lookup where lk_lkt_lookup_type_code IN 
    ('EVENT_HIERARCHY',
     'EVENT_CLASS', 
     'EVENT_GROUP',
     'EVENT_SUBGROUP',
     'EVENT_CATEGORY');
delete from fdr.fr_acc_event_type where aet_input_by NOT IN ('SPS', 'FDR Create');
commit;