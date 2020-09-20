#!/bin/bash

CONCURRENCY=$1;

echo "Number of processes - "$CONCURRENCY

INPUT_FOLDER="cleanup_scripts/results/"
OUTPUT_FOLDER="cleanup_scripts/tfrecord/"
PROCS=()
let wait_pid=0

proc_file() {
    python3 create_pretraining_data.py \
            --input_file=$1 \
            --output_file=$2 \
            --vocab_file=cleanup_scripts/input/vocab.txt \
            --do_lower_case=True \
            --max_seq_length=512 \
            --max_predictions_per_seq=76 \
            --masked_lm_prob=0.15 \
            --random_seed=12345 \
            --dupe_factor=10
}

pushd $INPUT_FOLDER

input_files=$(ls)

popd

for file in ${input_files[@]}
do
    if [[ ${#PROCS[@]} -ge $CONCURRENCY ]];
    then
        echo "Waiting for proc #$wait_pid on PID ${PROCS[wait_pid]}"
        wait ${PROCS[wait_pid]}
        let wait_pid++
    fi
    # echo "$INPUT_FOLDER$file => $OUTPUT_FOLDER$file"
    proc_file "${INPUT_FOLDER}${file}" "${OUTPUT_FOLDER}${file}" &
    PROCS+=( $! )
done

echo "*************************************************************************************"
echo "********************************** PROCESSING DONE **********************************"
echo "*************************************************************************************"