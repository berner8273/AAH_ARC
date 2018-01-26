#!/bin/bash

# #####################################################################################################################################################################
# Usage: ./StartTask <execution folder> <step name>
#       :
#       : <step name> := a symbol/code which can be used to identify a microflow within a specific project
#       :
#       : e.g. :
#       : ./StartTask.sh StandardiseRebates
# #####################################################################################################################################################################

C_SUCCESS_RETURN_CODE=0
C_FAILURE_RETURN_CODE=3
C_APTITUDE_HOST=@aptitudeHost@
C_APTITUDE_BUS_PORT=@aptitudeBusPort@
p_step_cd=$1

C_PATH_TO_THIS_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
C_PATH_TO_LOG_FOLDER=${C_PATH_TO_THIS_FOLDER}/log
C_TIMESTAMP=`date +"%C%y%m%d%H%M%S"`
C_PATH_TO_LOG_FILE=${C_PATH_TO_LOG_FOLDER}/${p_step_cd}_${C_TIMESTAMP}.log

C_TRIGGERING_PROJECT_FOLDER="trigger";
C_TRIGGER_PROJECT="Trigger";
C_TRIGGERING_SERVICE='trigger';
return_code=0

SECONDS=0;

function printDivider
{
    echo "****************************************************************************************************************************************************************"
}

function setupEnvironment
{
    if [ ! -d ${C_PATH_TO_LOG_FOLDER} ]
    then
        mkdir -p ${C_PATH_TO_LOG_FOLDER}
    fi
}

function printLegend
{
    printDivider
    echo "*StartStep                           :"
    echo "*StartStep run datetime              : ${C_TIMESTAMP}"
    echo "*StartStep aptitude host             : ${C_APTITUDE_HOST}"
    echo "*StartStep aptitude bus port         : ${C_APTITUDE_BUS_PORT}"
    echo "*StartStep triggering project folder : ${C_TRIGGERING_PROJECT_FOLDER}"
    echo "*StartStep triggering project        : ${C_TRIGGER_PROJECT}"
    echo "*StartStep triggering service name   : ${C_TRIGGERING_SERVICE}"
    echo "*StartStep step code                 : ${p_step_cd}"
    echo "*StartStep log folder                : ${C_PATH_TO_LOG_FOLDER}"
    echo "*StartStep log                       : ${C_PATH_TO_LOG_FILE}"
    printDivider
}

function validateParameters
{
    if  [ -z ${p_step_cd} ]
    then
        echo "The mandatory 'p_step_cd' parameter was not supplied."
        exit 1
    fi
}

function printCompletionMessage
{
    C_DURATION=$SECONDS;

    if [ ${return_code} -eq ${C_SUCCESS_RETURN_CODE} ]
    then
        echo "Task completed successfully."
    else
        return_code=${C_FAILURE_RETURN_CODE}
        echo "Task completed with an error."
    fi

    echo "Return code = ${return_code}";
    echo "$(($C_DURATION / 60)) minutes and $(($C_DURATION % 60)) seconds elapsed.";

    echo "*StartStep log contents"
    printDivider
    more "${C_PATH_TO_LOG_FILE}"



}

setupEnvironment
printLegend
validateParameters
java -server -cp ${C_PATH_TO_THIS_FOLDER}/batch.jar com.aptitudesoftware.batch.StartStep ${C_APTITUDE_HOST} ${C_APTITUDE_BUS_PORT} ${C_TRIGGERING_PROJECT_FOLDER} ${C_TRIGGER_PROJECT} ${C_TRIGGERING_SERVICE} ${p_step_cd} > ${C_PATH_TO_LOG_FILE}
return_code=$?
printCompletionMessage
exit ${return_code}
