delete from stn.posting_method_derivation_mtm
where event_typ_id in (
(select event_typ_id from stn.event_type where event_typ in (
    'FV_DAC_CC_CAP_DEF',
    'FV_DAC_AMORT',
    'VIECC_FVDAC_CAP_DEF',
    'VIECD_FVDAC_CAP_DEF',
    'VIECF_FVDAC_CAP_DEF',
    'VIECF_FVDAC_AMORT',
    'VIECC_ADAC_CAP_DEF',
    'VIECD_ADAC_CAP_DEF',
    'VIECF_ADAC_CAP_DEF',
    'VIECF_ADAC_AMORT') )
);    

delete from stn.vie_posting_method_ledger vpl 
where VPL.EVENT_TYP_ID in
    (select event_typ_id from stn.event_type where event_typ in (
    'FV_DAC_CC_CAP_DEF',
    'FV_DAC_AMORT',
    'VIECC_FVDAC_CAP_DEF',
    'VIECD_FVDAC_CAP_DEF',
    'VIECF_FVDAC_CAP_DEF',
    'VIECF_FVDAC_AMORT',
    'VIECC_ADAC_CAP_DEF',
    'VIECD_ADAC_CAP_DEF',
    'VIECF_ADAC_CAP_DEF',
    'VIECF_ADAC_AMORT') )  
OR
VPL.VIE_EVENT_TYP_ID in
    (select event_typ_id from stn.event_type where event_typ in (
    'FV_DAC_CC_CAP_DEF',
    'FV_DAC_AMORT',
    'VIECC_FVDAC_CAP_DEF',
    'VIECD_FVDAC_CAP_DEF',
    'VIECF_FVDAC_CAP_DEF',
    'VIECF_FVDAC_AMORT',
    'VIECC_ADAC_CAP_DEF',
    'VIECD_ADAC_CAP_DEF',
    'VIECF_ADAC_CAP_DEF',
    'VIECF_ADAC_AMORT') );

delete from stn.vie_event_type where event_typ_id in
(select event_typ_id from stn.event_type
where event_typ in (
'FV_DAC_CC_CAP_DEF',
'FV_DAC_AMORT',
'VIECC_FVDAC_CAP_DEF',
'VIECD_FVDAC_CAP_DEF',
'VIECF_FVDAC_CAP_DEF',
'VIECF_FVDAC_AMORT',
'VIECC_ADAC_CAP_DEF',
'VIECD_ADAC_CAP_DEF',
'VIECF_ADAC_CAP_DEF',
'VIECF_ADAC_AMORT'));


    
delete from stn.event_type
where event_typ in (
'FV_DAC_CC_CAP_DEF',
'FV_DAC_AMORT',
'VIECC_FVDAC_CAP_DEF',
'VIECD_FVDAC_CAP_DEF',
'VIECF_FVDAC_CAP_DEF',
'VIECF_FVDAC_AMORT',
'VIECC_ADAC_CAP_DEF',
'VIECD_ADAC_CAP_DEF',
'VIECF_ADAC_CAP_DEF',
'VIECF_ADAC_AMORT');


