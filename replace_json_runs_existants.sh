#!/bin/bash

json_dir="/mnt/chu-ngs2/Labos/UMAI/LancementAnalyseCluster"
runs_dir="/mnt/chu-ngs/NEXTSEQ/runs"

# Durée de pause entre chaque affichage pour vérification.
sleep_duration=2

# Boucle sur chaque fichier JSON qui correspond au motif dans le répertoire spécifié.
for json_file in "$json_dir"/MAI_rech*.json; do
    base_name=$(basename "$json_file" _inputs.json)

    # Affiche la modification prévue pour le champ Run Name.
    sed -i "s|\"Exome.RunName\": \"Run_Name\"|\"Exome.RunName\": \"$base_name\"|g" "$json_file"
    echo "Le champ Exome.RunName a été mis à jour en $base_name pour le fichier $json_file"

    sleep $sleep_duration

    # Initialise run_full_name comme vide pour chaque itération.
    run_full_name=""
    # Utilisez ls et grep pour capturer le nom complet du run.
    if [[ "$base_name" == *"211201"* && "$base_name" != *"CSG216037"* ]]; then
        run_full_name=$(ls "$runs_dir" | grep "211201" | head -n 1)
        echo "Trouvé Run_Full_Name correspondant à 211201 (excluant CSG216037): $run_full_name"
    elif [[ "$base_name" == *"211209"* && "$base_name" == *"CSG215808"* ]]; then
        run_full_name=$(ls "$runs_dir" | grep "211209" | head -n 1)
        echo "Trouvé Run_Full_Name correspondant à 211209 uniquement pour CSG215808: $run_full_name"
    elif [[ "$base_name" == *"211118"* && ("$base_name" == *"CSG192700"* || "$base_name" == *"CAD210296"*) ]]; then
        run_full_name=$(ls "$runs_dir" | grep "211118" | head -n 1)
        echo "Trouvé Run_Full_Name correspondant à 211118 pour le duo de sœurs CSG192700 et CAD210296: $run_full_name"
    elif [[ "$base_name" == *"220228"* && ("$base_name" == *"CSG196186"* || "$base_name" == *"CSG201103"*) ]]; then
        run_full_name=$(ls "$runs_dir" | grep "220228" | head -n 1)
        echo "Trouvé Run_Full_Name correspondant à 220228 pour CSG196186 et CSG201103: $run_full_name"
    elif [[ "$base_name" == *"220328"* && ("$base_name" == *"CSG220799"* || "$base_name" == *"CSG220798"* || "$base_name" == *"CSG220608"*) ]]; then
        run_full_name=$(ls "$runs_dir" | grep "220328" | head -n 1)
        echo "Trouvé Run_Full_Name correspondant à 220328 pour CSG220799, CSG220798, et CSG220608: $run_full_name"
    elif [[ "$base_name" == *"220509"* && "$base_name" == *"CSG220787"* ]]; then
        run_full_name=$(ls "$runs_dir" | grep "220509" | head -n 1)
        echo "Trouvé Run_Full_Name correspondant à 220509 uniquement pour CSG220787: $run_full_name"
    elif [[ "$base_name" == *"220530"* && "$base_name" == *"CSG221528"* ]]; then
        run_full_name=$(ls "$runs_dir" | grep "220530" | head -n 1)
        echo "Trouvé Run_Full_Name correspondant à 220530 uniquement pour CSG221528: $run_full_name"
    elif [[ "$base_name" == *"220324"* && "$base_name" == *"CSG220100"* ]]; then
        run_full_name=$(ls "$runs_dir" | grep "220324" | head -n 1)
        echo "Trouvé Run_Full_Name correspondant à 220324 uniquement pour CSG220100: $run_full_name"
    fi
    if [[ ! -z "$run_full_name" ]]; then
        sed -i "s|/mnt/chu-ngs/NEXTSEQ/runs/Run_Full_Name/FastQs/|/mnt/chu-ngs/NEXTSEQ/runs/$run_full_name/FastQs/|g" "$json_file"
        echo "Le chemin Exome.FastqDir a été mis à jour avec $run_full_name pour le fichier $json_file"
    fi

    sleep $sleep_duration
done

echo "Fin des modifications."

