DATASET_NAME="sri/py150"
# VIEWS=("adv-contra")
VIEWS=("random")
TRAIN_DECODER_ONLY=("true" "false")
TRANSFORM_NAME="transforms.Combined"
NUM_REPLACE=1500
DATASET_NAME_SMALL="py150"
for VIEWS_TYPE in "${VIEWS[@]}"; do

    
    # pretrain a seq2seq encoder on the csn python train set
    # VIEWS=${VIEWS_TYPE} \
    # DATASET=sri/py150 \
    # adv_lr=0.5 \
    # U_PGD_EPOCHS=3 \
    # NUM_SITES=1 \
    # PRETRAINED_MODEL="pretrain_py150_transformer_${VIEWS_TYPE}_${U_PGD_EPOCHS}_${NUM_SITES}" \
    # MODEL_NAME=${PRETRAINED_MODEL} \
    #     #time make adv-pretrain-contracode-transformer

    # VIEWS=${VIEWS_TYPE} \
    # DATASET=sri/py150 \
    # adv_lr=1 \
    # U_PGD_EPOCHS=1 \
    # NUM_SITES=3 \
    # PRETRAINED_MODEL="pretrain_py150_hidden_identity_${VIEWS_TYPE}_${U_PGD_EPOCHS}_${NUM_SITES}" \
    # MODEL_NAME=${PRETRAINED_MODEL} \
    #     #time make adv-pretrain-contracode

    # VIEWS=${VIEWS_TYPE} \
    # DATASET=sri/py150 \
    # adv_lr=1 \
    # U_PGD_EPOCHS=3 \
    # NUM_SITES=1 \
    # PRETRAINED_MODEL="pretrain_py150_hidden_identity_${VIEWS_TYPE}_${U_PGD_EPOCHS}_${NUM_SITES}" \
    # MODEL_NAME=${PRETRAINED_MODEL} \
    #     #time make adv-pretrain-contracode

    # VIEWS=${VIEWS_TYPE} \
    # DATASET=sri/py150 \
    # adv_lr=1 \
    # U_PGD_EPOCHS=1 \
    # NUM_SITES=1 \
    # PRETRAINED_MODEL="pretrain_py150_hidden_identity_${VIEWS_TYPE}_${U_PGD_EPOCHS}_${NUM_SITES}" \
    # MODEL_NAME=${PRETRAINED_MODEL} \
    #     #time make adv-pretrain-contracode

    PRETRAINED_MODEL="pretrain_sri_hidden_identity_512_512_random"
    for DECODER_ONLY in "${TRAIN_DECODER_ONLY[@]}"; do

        echo "CONFIG: views=${VIEWS_TYPE}; decoder_only=${DECODER_ONLY}"
        FINETUNE_EPOCHS=10
        if [ "$VIEWS_TYPE" != "random" ]; then 
            VIEWS_TYPE="adversarial"
        fi
        FINETUNED_MODEL="finetuned_sri_transformer_${VIEWS_TYPE}_decoder-only-${DECODER_ONLY}-epochs-${FINETUNE_EPOCHS}"

        # finetune the pretrained model for code summarization
        GPU=0 \
        MODEL_TYPE="seq2seq" \
        DATASET=${DATASET_NAME} \
        DECODER_ONLY=${DECODER_ONLY} \
        EPOCHS=${FINETUNE_EPOCHS} \
        CHECKPOINT="${PRETRAINED_MODEL}/ckpt_pretrain_ep0100_step0155000.pth" \
        MODEL_NAME=${FINETUNED_MODEL} \
            #time make finetune-contracode-transformer

        # attack and test the trained model

        FINAL_MODEL="final-models/seq2seq/$DATASET_NAME/$FINETUNED_MODEL"

        # no attack + test on full test set
        #./experiments/attack_and_test_transformer.sh 0 2 1 false 1 1 false 1 false false false v2-1-z_no_no-pgd_no_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-full-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true true false "Best_F1"

        # # z_1_random + u_optim (uwisc) attack + test on exact matches
        # ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-em-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 1 true true false "Best_F1"

        # # z_1_random + u_optim (uwisc) attack + test on full test set
        ./experiments/attack_and_test_transformer.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-rand_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-full-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.75 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true true false "Best_F1"

        # # z_1_random + u random attack + test on full test set
        # bash ./experiments/attack_and_test_random_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-full-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true false true "Best_F1"
        
        # # z_1_random + u random attack + test on exact match
        # bash ./experiments/attack_and_test_random_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-em-dec_only-${DECODER_ONLY} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 1 true false true "Best_F1"
    done
done

# MODEL_NAME="normal"
# FINAL_MODEL="final-models/seq2seq/$DATASET_NAME/$MODEL_NAME"
# # no attack + test on full test set
# ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 false 1 false false false v2-1-z_no_no-pgd_no_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-normal-full $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true true false "Best_F1"

# # z_1_random + u_optim (uwisc) attack + test on exact matches
# ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-noraml-em $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 1 true true false "Best_F1"

# # z_1_random + u_optim (uwisc) attack + test on full test set
# ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-normal-full $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true true false "Best_F1"

# # z_1_random + u random attack + test on full test set
# bash ./experiments/attack_and_test_random_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-normal-full $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true false true "Best_F1"

# # z_1_random + u random attack + test on exact match
# bash ./experiments/attack_and_test_random_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-normal-em $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 1 true false true "Best_F1"

# MODEL_NAME="finetuned_csn_h-sz-512-identity-advv2"
# FINAL_MODEL="final-models/seq2seq/$DATASET_NAME/$MODEL_NAME"
# # no attack + test on full test set
# ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 false 1 false false false v2-1-z_no_no-pgd_no_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-full $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true true false "Best_F1"

# # z_1_random + u_optim (uwisc) attack + test on exact matches
# ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-em $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 1 true true false "Best_F1"

# # z_1_random + u_optim (uwisc) attack + test on full test set
# ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-full $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true true false "Best_F1"

# # z_1_random + u random attack + test on full test set
# bash ./experiments/attack_and_test_random_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-full $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true false true "Best_F1"

# # z_1_random + u random attack + test on exact match
# bash ./experiments/attack_and_test_random_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-em $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 1 true false true "Best_F1"

# MODEL_NAME="finetuned_csn_h-sz-512-identity-advv2-fz"
# FINAL_MODEL="final-models/seq2seq/$DATASET_NAME/$MODEL_NAME"
# # no attack + test on full test set
# ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 false 1 false false false v2-1-z_no_no-pgd_no_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-fz-full $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true true false "Best_F1"

# # z_1_random + u_optim (uwisc) attack + test on exact matches
# ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-fz-em $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 1 true true false "Best_F1"

# # z_1_random + u_optim (uwisc) attack + test on full test set
# ./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-fz-full $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true true false "Best_F1"

# # z_1_random + u random attack + test on full test set
# bash ./experiments/attack_and_test_random_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-fz-full $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 0 true false true "Best_F1"

# # z_1_random + u random attack + test on exact match
# bash ./experiments/attack_and_test_random_seq2seq.sh 0 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-advv2-fz-em $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $FINAL_MODEL $NUM_REPLACE 1 true false true "Best_F1"
