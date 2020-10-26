#!/bin/bash

#TF_XLA_FLAGS='--tf_xla_auto_jit=2' \
python run_pretraining.py \
  --bert_config_file=cleanup_scripts/input/bert_config.json \
  --output_dir=/tmp/output/ \
  --input_file="cleanup_scripts/tfrecord/part*" \
  --nodo_eval \
  --do_train \
  --eval_batch_size=8 \
  --learning_rate=4e-05 \
  --iterations_per_loop=1 \
  --max_predictions_per_seq=76 \
  --max_seq_length=512 \
  --num_train_steps=5000 \
  --num_warmup_steps=15 \
  --optimizer=lamb \
  --save_checkpoints_steps=5000 \
  --start_warmup_step=0 \
  --num_gpus=1 \
  --train_batch_size=1
