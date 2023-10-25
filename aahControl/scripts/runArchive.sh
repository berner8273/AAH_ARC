
function runArchive()
{
    runStep parchiveSTN1
    runStep parchiveFDR1
    runStep parchiveSTN2
    runStep parchiveFDR2
    runStep parchiveSLR1
    runStep pDeleteSLRPartitions
}
ERR_EXIT () {
	printf "Error: ********************************************\n$@\n"
	exit 1
}
function runStep()
{
    stepName=${1}
    /aah/scripts/StartStep.sh ${1}
    [[ $? = 0 ]] || ERR_EXIT ${1}
}
runArchive "$@" 2>&1 | tee runArchive$(date +"%b-%d-%y").log