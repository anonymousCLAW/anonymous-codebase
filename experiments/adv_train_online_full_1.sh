DATASET_NAME="sri/py150"
DATASET_NAME_SMALL="py150"
# DATASET_NAME="c2s/java-small"
# DATASET_NAME_SMALL="javasmall"
TRANSFORM_NAME="transforms.Combined"
MODEL_SHORT_NAME="finetuned_sri_hidden_identity_adversarial_online_transforms.Combined_decoder-only-false-epochs-1"
MODEL_NAME="final-models/seq2seq/$DATASET_NAME/$MODEL_SHORT_NAME"
FINETUNED_MODEL="finetuned_sri_hidden_identity_adversarial_online_transforms.Combined_decoder-only-false-epochs-5"
EXPT_NAME="v2-3-z_rand_1-pgd_3-no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-$TRANSFORM_NAME-$FINETUNED_MODEL-AT"

NUM_REPLACE=1500
#bash ./experiments/adv_train_seq2seq_online.sh 1 2 1 false 1 1 true 3 false false false $EXPT_NAME $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $MODEL_NAME $NUM_REPLACE 0 false true false "Best_F1"

# no attack + test on full test set
./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 false 1 false false false v2-1-z_no_no-pgd_no_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-adv-AT-full-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $MODEL_NAME $NUM_REPLACE 0 true true false "Latest4"

# z_1_random + u_optim (uwisc) attack + test on exact matches
./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-adv-AT-em-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $MODEL_NAME $NUM_REPLACE 1 true true false "Latest4"

# z_1_random + u_optim (uwisc) attack + test on full test set
./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-adv-AT-full-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $MODEL_NAME $NUM_REPLACE 0 true true false "Latest4"

# z_1_random + u random attack + test on full test set
bash ./experiments/attack_and_test_random_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-adv-AT-full-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $MODEL_NAME $NUM_REPLACE 0 true false true "Latest4"

# z_1_random + u random attack + test on exact match
bash ./experiments/attack_and_test_random_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-adv-AT-em-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $MODEL_NAME $NUM_REPLACE 1 true false true "Latest4"