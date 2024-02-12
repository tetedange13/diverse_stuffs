#!/bin/bash

# Activation de l'environnement conda
conda_path="/mnt/Bioinfo/Softs/src/conda/Anaconda2-2019.10"
source "$conda_path/etc/profile.d/conda.sh"
conda activate Exome_prod
echo "Environnement Conda actif : $(conda env list | grep '*' | awk '{print $1}')"

input_dir="/mnt/chu-ngs2/Labos/UMAI/LancementAnalyseCluster"
mobidl_script="/mnt/Bioinfo/Softs/src/MobiDL/cww.sh"
cromwell_jar="/mnt/Bioinfo/Softs/src/cromwell/cromwell.jar"
wdl_file="/mnt/chu-ngs/Labos/Transversal/Softs/Interne/Exome/Exome.wdl"
cromwell_conf="/mnt/Bioinfo/Softs/src/cromwell/conf/cromwell_option_cluster.json"
cluster_conf="/mnt/Bioinfo/Softs/src/cromwell/conf/Cluster_noDB.conf"

# Boucler sur chaque fichier d'entrée correspondant au motif dans le répertoire spécifié.
for input_file in "$input_dir"/* do
    if [[ "$inputs_file" == "MAI"*"_inputs.json" ]] || [[ "$inputs_file" == "DI"*"_inputs.json" ]]; then
    	log_file="${input_file%_inputs.json}.log"
    	command="$mobidl_script -e $cromwell_jar -w $wdl_file -o $cromwell_conf -c $cluster_conf -i $input_file > $log_file 2>&1 &"
    	echo "Commande à exécuter : $command"
    	echo
    	pid=$!
    	# décommenter la ligne suivante pour exécuter la commande après vérification.
    	eval $command
    	echo "Commande lancée pour $input_file avec PID $pid, en attente de 'Succeeded' dans $log_file."
  	while : ; do
    		if grep -q "Succeeded" "$log_file"; then
      			echo "Le processus a réussi pour $file."
      			break # Sortie de la boucle si le processus a réussi
    		elif grep -q "ERROR" "$log_file"; then
      			echo "Une erreur a été détectée pour $file. Vérifiez $log_file pour les détails."
      			kill $pid 2>/dev/null # Tente de tuer le processus en cas d'erreur
      			exit 1 # Sort du script entièrement
    		fi
    	sleep 10 # Attendre avant de vérifier à nouveau.
  	done
    fi
    echo "Analyses terminées pour $input_file."
done
echo "Analyses terminées."

