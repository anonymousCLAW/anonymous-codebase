DATASET=$4 \
MODEL=seq2seq \
GPU=$1 \
SHORT_NAME="$2" \
ARGS='--batch_size 1' \
CHECKPOINT=$6 \
SRC_FIELD="$3" \
DATASET_NAME=datasets/codeclone/adversarial/${SHORT_NAME}/tokens/${DATASET}/gradient-targeting \
RESULTS_OUT=final-results/seq2seq/codeclone/${DATASET}/${SHORT_NAME} \
MODELS_IN=$5 \
  time make test-model-seq2seq-codeclone

