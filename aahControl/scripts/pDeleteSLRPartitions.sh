
function pDeleteSLRPartitions()
{
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
pDeleteSLRPartitions "$@" 2>&1 | tee pDeleteSLRPartitions$(date +"%b-%d-%y").log