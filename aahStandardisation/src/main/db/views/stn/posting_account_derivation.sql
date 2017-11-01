create or replace view stn.posting_account_derivation
as
select distinct
       fpd.pd_posting_schema     posting_schema
     , fpd.pd_aet_event_type     event_typ
     , fpd.pd_sub_event          sub_event
     , fal.al_lookup_1           business_typ
     , fal.al_lookup_2           is_mark_to_market
     , fal.al_lookup_3           business_unit
     , fal.al_ccy                currency
     , fal.al_account            sub_account
  from
       fdr.fr_posting_driver              fpd
  join fdr.fr_account_lookup              fal   on fpd.pd_posting_code    = fal.al_posting_code
  join fdr.fr_gl_account                  fgl   on fal.al_account         = fgl.ga_account_code
  join stn.event_type                     et    on fpd.pd_aet_event_type  = et.event_typ
  join stn.posting_amount_derivation      pad   on et.event_typ_id        = pad.event_typ_id
  join stn.posting_amount_derivation_type padt  on pad.amount_typ_id      = padt.amount_typ_id
 where
       fgl.ga_account_type     = 'B'
   and padt.amount_typ_descr   in ( 'DERIVED' , 'DERIVED_PLUS' )
     ;