#!/bin/bash

# #####################################################################################################################################################################
# Usage: ./StartProjects
# #####################################################################################################################################################################

C_SUCCESS_RETURN_CODE=0
C_FAILURE_RETURN_CODE=3
C_APTITUDE_HOST=#{aptitudeHost}
C_APTITUDE_BUS_PORT=#{aptitudeBusPort}
C_APTITUDE_SERVER_NAME=#{aptitudeEnv}
C_TIMEOUT_MILLISECONDS=10000

C_PATH_TO_THIS_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
C_TIMESTAMP=`date +"%C%y%m%d%H%M%S"`

return_code=0

SECONDS=0;

function printDivider
{
    echo "****************************************************************************************************************************************************************"
}

function printLegend
{
    printDivider
    echo "*StartProjects                     :"
    echo "*StartProjects run datetime        : ${C_TIMESTAMP}"
    echo "*StartProjects aptitude host       : ${C_APTITUDE_HOST}"
    echo "*StartProjects aptitude bus port   : ${C_APTITUDE_BUS_PORT}"
    printDivider
}

function printCompletionMessage
{
    C_DURATION=$SECONDS;

    if [ ${return_code} -eq ${C_SUCCESS_RETURN_CODE} ]
    then
        echo "Projects started successfully."
    else
        return_code=${C_FAILURE_RETURN_CODE}
        echo "An error occurred."
    fi

    echo "Return code = ${return_code}";
    echo "$(($C_DURATION / 60)) minutes and $(($C_DURATION % 60)) seconds elapsed.";
}

printLegend
java -server -cp ${C_PATH_TO_THIS_FOLDER}/startStopProjects.jar com.aptitudesoftware.appsvr.StartProjects ${C_APTITUDE_HOST} ${C_APTITUDE_BUS_PORT} ${C_TIMEOUT_MILLISECONDS} ${C_APTITUDE_SERVER_NAME}
return_code=$?
printCompletionMessage
exit ${return_code}