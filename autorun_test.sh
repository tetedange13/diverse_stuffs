
#!/bin/bash

#######################################################
# Script Name: autorun.sh
# Description: This script automates a bioinformatics analysis pipeline for exome 
#              data processing at UMAI. It specifically targets files with names 
#              starting with MAI or DI and ending in _inputs.json. Upon identifying 
#              these files, it executes the cww.sh command with the respective files as 
#              inputs and logs the process into appropriately named log files.
# Usage:       Scheduled to run every hour via a cron job, this script facilitates 
#              continuous and automated processing of exome data without manual intervention.
# Author:      Jean-Charles DELMAS
# Created on:  2024/01/26
# Version:     0.1
# License:     [If applicable]
#######################################################

source activate Exome_prod

for file in $(ls | grep -E '^(MAI|DI).*_inputs.json$'); do
    log_name=$(echo $file | sed 's/_inputs.json/.log/')
    echo $file
    echo $log_name
    run=$(nohup /mnt/Bioinfo/Softs/src/MobiDL/cww.sh -e /mnt/Bioinfo/Softs/src/cromwell/cromwell.jar -w /mnt/chu-ngs/Labos/Transversal/Softs/Interne/Exome/Exome.wdl -o /mnt/Bioinfo/Softs/src/cromwell/conf/cromwell_option_cluster.json -c /mnt/Bioinfo/Softs/src/cromwell/conf/Cluster_noDB.conf -i $file > $log_name)
    echo $run
    folder_name=$(basename $file _inputs.json)
    mv $file $folder_name/.
    mv $log_name $folder_name/.
    find $folder_name/. -name "*.sort.*.bam*" -exec rm {} \;

    # Moving the run in the right UMAI's repository for each run (NFS path)
    if [[$folder_name == *rerun* || $folder_name == *rech* ]]; then
        mv $folder_name /mnt/chu-ngs2/Labos/UMAI/Run_Exomes/RERUNS/.
    else
        mv $folder_name /mnt/chu-ngs2/Labos/UMAI/Run_Exomes/DIAGNOSTIC/.
    fi
done
