create global temporary table fdr.fr_combination_check_input (
  ci_input_id     varchar2(100) null,
  ci_ruleset      varchar2(80)  not null,
  ci_attribute_1  varchar2(100) null,
  ci_attribute_2  varchar2(100) null,
  ci_attribute_3  varchar2(100) null,
  ci_attribute_4  varchar2(100) null,
  ci_attribute_5  varchar2(100) null,
  ci_attribute_6  varchar2(100) null,
  ci_attribute_7  varchar2(100) null,
  ci_attribute_8  varchar2(100) null,
  ci_attribute_9  varchar2(100) null,
  ci_attribute_10 varchar2(100) null,
  ci_suspense_id  varchar2(40)  null)
on commit delete rows;
comment on table fdr.fr_combination_check_input is 'Temporary storage of source data attributes that require combination checking to be performed.';
comment on column fdr.fr_combination_check_input.ci_input_id     is 'The source data input identifier (e.g. Journal/Line ID, Hopper PK etc.) Can be left empty if required. When supplied, it must be unique.';
comment on column fdr.fr_combination_check_input.ci_ruleset      is 'The set of rules to apply to this source data combination (FR_GENERAL_LOOKUP. gl_lookup_value1 where gl_glt_id = ''COMBO_RULESET'').';
comment on column fdr.fr_combination_check_input.ci_attribute_1  is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_attribute_2  is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_attribute_3  is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_attribute_4  is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_attribute_5  is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_attribute_6  is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_attribute_7  is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_attribute_8  is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_attribute_9  is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_attribute_10 is 'The combination attribute value to check.';
comment on column fdr.fr_combination_check_input.ci_suspense_id  is 'The combination suspense rule if the combination validation fails (FR_GENERAL_LOOKUP.lk_lookup_key_id where lk_lkt_lookup_type_code = ''COMBO_SUSPENSE''.'
;