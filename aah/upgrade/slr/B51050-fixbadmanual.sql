UPDATE SLR.SLR_JRNL_LINES jl
SET JL_REFERENCE_2='NVS'
where 
     jl.jl_reference_1= 'FSANYAORECOMMUTATION'
    and jl.JL_REFERENCE_2 = 'FSANY'
    and jl.JL_EFFECTIVE_DATE>='31-MAR-2020';
commit;

