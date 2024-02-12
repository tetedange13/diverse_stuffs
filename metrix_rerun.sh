#!/bin/bash

#######################################################
# Script Name: metrix_rerun.sh 
# Description: the script is reprocessing the metrics of a MAI or DI exome analysis.
# Usage:       enter the directory name of the analysis you want to rerun, and the JSON file path to update. 
# Author:      Jean-Charles DELMAS 
# Created on:  2024/01/29 
# Version:     0.1 
# License:     [If applicable] 
#######################################################

#source activate Exome_prod

# Enter the name of the analysis directory, then the PATH of the JSON file
if [ "$#" -ne 2 ]; then
    echo "Error : wrong use or wrong arguments."
    echo "Usage : $0 <DirectoryName> <JSONTemplateFilePath>"
    exit 1
fi

DIRECTORY_NAME=$1
JSON_FILE=$2
echo "DirectoryName : $DIRECTORY_NAME"
echo "JSONFilePath : $JSON_FILE"

# Check if the configuration file exists
if [ ! -f "$JSON_FILE" ]; then
    echo "The JSON template file does not exist."
    exit 2
fi

# Paths to directories where samples could be located
SAMPLE_DIRS=(
    "/mnt/chu-ngs2/Labos/UMAI/NGS/MAI/Exomes_Diagnostic/${DIRECTORY_NAME}/casIndex/"
    "/mnt/chu-ngs2/Labos/UMAI/Run_Exomes/DIAGNOSTIC/${DIRECTORY_NAME}/casIndex/"
    "/mnt/chu-ngs2/Labos/UMAI/NGS/DI/${DIRECTORY_NAME}/casIndex/"
)

# Check if at least one of the paths exists
path_exists=false
for dir in "${SAMPLE_DIRS[@]}"; do
    echo "Checking : $dir"
    if [ -d "$dir" ]; then
        path_exists=true
        echo "Valid path found: $dir"
	echo
        break
    fi
done

if [ "$path_exists" = false ]; then
    echo "No valid path found for $DIRECTORY_NAME."
    echo 
    read -p "Enter the absolute path for casIndex : " casIndex_path
    while [ ! -d "$casIndex_path" ]; do
	read -p "Invalide path. Please enter it again : " casIndex_path
    done
    echo
    SAMPLE_DIRS=("$casIndex_path")
    path_exists=true
    echo
fi

if [ "$path_exists" = true ]; then
    parent_dir=$(dirname "${dir}")
    # List other directories than 'casIndex', 'Parent', and 'intervals'
    echo "Checking for additional directories in $parent_dir."
    additional_dirs=()
    for d in "${parent_dir}"/*/; do
        dir_name=$(basename "$d")
	# Exclude specific directories already present
        if [[ "$dir_name" != "casIndex" && "$dir_name" != "Parent" && "$dir_name" != "intervals" ]]; then
            additional_dirs+=("$dir_name")
        fi
    done

    # Check if additional directories were found
    if [ ${#additional_dirs[@]} -ne 0 ]; then
        echo "Found additional directories :"
        for ad in "${additional_dirs[@]}"; do
            echo "$ad"
        done
        read -p "Do you want to use one of these directories? (yes/no) " use_additional_dir
        if [[ "$use_additional_dir" == "yes" ]]; then
            read -p "Enter the name of the directory to use: " selected_additional_dir

	    # Ensure that the entered directory name is valid and exists in the list
            while [[ ! " ${additional_dirs[@]} " =~ " ${selected_additional_dir} " ]]; do
                echo "Directory not found. Please enter a valid directory name."
                read -p "Enter the name of the directory to use: " selected_additional_dir
            done
            SAMPLE_DIRS=("${parent_dir}/${selected_additional_dir}/casIndex/")
        fi
    fi
fi

mkdir "${DIRECTORY_NAME}_JSONmetrix"

# Function to update JSON for a sample
update_config_for_sample() {
    local sample_path=$1
    local sample_name=$(basename "$sample_path")

    echo "Attempting to update config for sample: $sample_name"

    # Find the BAM file for this sample
    local bam_file=$(find "${sample_path}" -type f -regex ".*/${sample_name}\\.bam")
    if [ -f "$bam_file" ]; then
        local bai_file="${bam_file}.bai"

        # Check if the corresponding BAI file exists
        if [ ! -f "$bai_file" ]; then
            echo "BAI file not found for $bam_file"
            return 1
        fi

        echo "Sample directory: $sample_path"
        echo "BAM file path: $bam_file"
        echo "BAI file path: $bai_file"

        # Create a JSON file for this sample in the current script directory
        local json_file="$(pwd)/${DIRECTORY_NAME}_JSONmetrix/${DIRECTORY_NAME}_${sample_name}_inputs.json"

        # Modify the configuration for this sample
        sed -e "s|\"MetrixAlign.Bam\": \".*\"|\"MetrixAlign.Bam\": \"$bam_file\"|" \
            -e "s|\"MetrixAlign.BamIdx\": \".*\"|\"MetrixAlign.BamIdx\": \"$bai_file\"|" \
            -e "s|\"MetrixAlign.SampleName\": \".*\"|\"MetrixAlign.SampleName\": \"${sample_name}\"|" \
            -e "s|\"MetrixAlign.outputPath\": \".*\"|\"MetrixAlign.outputPath\": \"/mnt/chu-ngs2/Labos/UMAI/LancementAnalyseCluster/TESTS/${DIRECTORY_NAME}_JSONmetrix/${sample_name}\"|" \
            "$JSON_FILE" > "$json_file"

        echo "JSON file created: $json_file"
        return 0
    else
        echo "No BAM file found for $sample_name in $sample_path"
        return 1
    fi
}

# Traverse the directories to update the configuration
echo "Traversing directories..."
found_bam=false
for SAMPLE_DIR in "${SAMPLE_DIRS[@]}"; do
    echo "Checking samples in $SAMPLE_DIR"
    for sample_path in ${SAMPLE_DIR}*/; do
        echo "Processing $sample_path"
        if update_config_for_sample "$sample_path"; then
            found_bam=true
            echo "Found .bam in $sample_path"
        fi
    done
done

if [ "$found_bam" = false ]; then
    echo "No .bam files found for $DIRECTORY_NAME."
    exit 2
fi

echo "Update completed for $DIRECTORY_NAME."
