create or replace force view stn.scv_combination_check_jlh
(
   ci_input_id,
   ci_ruleset,
   ci_attribute_1,
   ci_attribute_2,
   ci_attribute_3,
   ci_attribute_4,
   ci_attribute_5,
   ci_attribute_6,
   ci_attribute_7,
   ci_attribute_8,
   ci_attribute_9,
   ci_attribute_10,
   ci_suspense_id,
   epg_id,
   status
)
as
   select jl.row_sid as ci_input_id,
          jl.ledger_cd || '_' || pl_le_id.pl_party_legal_id as ci_ruleset,
          pl_le_id.pl_party_legal_id as ci_attribute_1,
          jl.acct_cd as ci_attribute_2,
          fga.ga_client_text4 AS ci_attribute_3,
          case jl.ledger_cd when 'NVS' then null else jl.ledger_cd end
             as ci_attribute_4,                                    --ledger_cd
          case jl.basis_cd when 'NVS' then null else jl.basis_cd end
             as ci_attribute_5,                                     --basis_cd
          case jl.dept_cd when 'NVS' then null else jl.dept_cd end
             AS ci_attribute_6,                                      --dept_cd
          case pl_affiliate.pl_party_legal_id
             when 'NVS' then null
             else pl_affiliate.pl_party_legal_id
          end
             as ci_attribute_7,                                    --affiliate
          jl.ledger_cd || '_' || pl_le_id.pl_party_legal_id as ci_attribute_8, --ledger/entity combo
          null as ci_attribute_9,
          null as ci_attribute_10,
          null as ci_suspense_id,
          'AG' AS epg_id,
          jl.event_status as status
     from stn.journal_line jl
          inner join stn.identified_record idr on jl.row_sid = idr.row_sid
          inner join stn.feed fd on jl.feed_uuid = fd.feed_uuid
          inner join stn.journal_line_default jl_default on 1 = 1
          inner join fdr.fr_party_legal pl_le_id
             on jl.le_id = to_number (pl_le_id.pl_global_id)
          left outer join fdr.fr_party_legal pl_owner_le_id
             on jl.owner_le_id = to_number (pl_owner_le_id.pl_global_id)
          left outer join fdr.fr_party_legal pl_ultimate_parent_le_id
             on jl.ultimate_parent_le_id =
                   to_number (pl_ultimate_parent_le_id.pl_global_id)
          left outer join fdr.fr_party_legal pl_counter_party
             on jl.counterparty_le_id =
                   to_number (pl_counter_party.pl_global_id)
          left outer join fdr.fr_party_legal pl_affiliate
             on jl.affiliate_le_id = to_number (pl_affiliate.pl_global_id)
          join fdr.fr_gl_account fga on jl.acct_cd = fga.ga_account_code;
