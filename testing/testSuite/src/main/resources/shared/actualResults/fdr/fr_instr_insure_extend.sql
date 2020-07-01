select
       fi.i_instr_desc_line1
     , fiie.iie_movement_type
     , fiie.iie_cost_centre
     , ico.co_country_name             insured_country_name
     , dco.co_country_name             debtor_country_name
     , fiie.iie_tax_code1
     , fiie.iie_tax_code2
     , fiie.iie_tax_code3
     , fpb1.pbu_party_bus_client_code  party1
     , fpb2.pbu_party_bus_client_code  party2
     , fpb3.pbu_party_bus_client_code  party3
     , fiie.iie_premium
     , fiie.iie_jurisdiction
     , fiie.iie_sign_date
     , fiie.iie_indemnity
     , fiie.iie_benefit_limit
     , fiie.iie_cover_note_create_date
     , fiie.iie_cover_note_description
     , fiie.iie_cover_start_date
     , fiie.iie_cover_end_date
     , fiie.iie_cover_signature_date
     , fiie.iie_cover_signing_party
     , fiie.iie_cover_signed
  from
            fdr.fr_instr_insure_extend fiie
       join fdr.fr_instrument          fi   on fiie.iie_instrument_id         = fi.i_instrument_id
       join fdr.fr_party_business      fpb1 on fiie.iie_pbu_party1            = fpb1.pbu_party_business_id
       join fdr.fr_party_business      fpb2 on fiie.iie_pbu_party2            = fpb2.pbu_party_business_id
       join fdr.fr_party_business      fpb3 on fiie.iie_pbu_party3            = fpb3.pbu_party_business_id
       join fdr.fr_country             ico  on fiie.iie_co_insured_country_id = ico.co_country_id
       join fdr.fr_country             dco  on fiie.iie_co_debtor_country_id  = dco.co_country_id