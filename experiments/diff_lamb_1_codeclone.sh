DATASET_NAME="codeclone/java"
#VIEWS=("random" "v2-3-z_rand_1-pgd_3_no-transforms.Replace-csn-py")
#VIEWS=("v2-3-z_rand_1-pgd_3_no-transforms.Replace-csn-py")
# VIEWS=("adv-contra_3_1")
VIEWS=("adv")
#VIEWS=("adv-contra_transforms.Insert_1_3")
TRAIN_DECODER_ONLY=("false")
TRANSFORM_NAME="transforms.Combined"
#TRANSFORM_NAME="transforms.Combined"
#TRANSFORM_NAME="transforms.Insert"
for VIEWS_TYPE in "${VIEWS[@]}"; do

    #PRETRAINED_MODEL="pretrain_csn_hidden_identity_${VIEWS_TYPE}"
    # PRETRAINED_MODEL="pretrain_py150_transformer_${VIEWS_TYPE}"
    PRETRAINED_MODEL="pretrain_codeclone_combined_adv_1_1"
    #PRETRAINED_MODEL="pretrain_java_small_hidden_identity_adv-contra_transforms.Combined_1_2"
    #PRETRAINED_MODEL=VIEWS_TYPE
    # pretrain a seq2seq encoder on the csn python train set
    VIEWS=${VIEWS_TYPE} \
    DATASET=csn/python \
    MODEL_NAME=${PRETRAINED_MODEL} \
        #time make pretrain-contracode

    for DECODER_ONLY in "${TRAIN_DECODER_ONLY[@]}"; do
        LAMB=0.4    
        echo "CONFIG: views=${VIEWS_TYPE}; decoder_only=${DECODER_ONLY} "
        if [ "$VIEWS_TYPE" != "random" ]; then 
            VIEWS_TYPE="adversarial"
        fi
        #FINETUNED_MODEL="finetuned_sri_hidden_identity_${VIEWS_TYPE}_decoder-only-${DECODER_ONLY}-epochs-1"
        FINETUNED_MODEL="finetuned_sri_${VIEWS_TYPE}_online_${TRANSFORM_NAME}_codeclone_decoder-only-${DECODER_ONLY}-epochs-1-${LAMB}"
        # finetune the decoder for one epoch
        GPU=0 \
        MODEL_TYPE="seq2seq" \
        DATASET="codeclone/java" \
        DECODER_ONLY="false" \
        EPOCHS=1 \
        CHECKPOINT="${PRETRAINED_MODEL}/ckpt_pretrain_ep0026_step0030000.pth" \
        MODEL_NAME=${FINETUNED_MODEL} \
            # time make finetune-contracode-codeclone

        # adversarial training starting from the partially finetuned model from above
        NUM_REPLACE=1500
        DATASET_NAME_SMALL="codeclonejava"
        TRANSFORM_NAME="transforms.Combined"
        TRANSFORM_NAME_FINE="transforms.Combined"
        EXPT_NAME="v2-3-z_rand_1-pgd_3-no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-$TRANSFORM_NAME_FINE-$FINETUNED_MODEL-AT-lamb-${LAMB}-fre-10"
        ./experiments/adv_train_seq2seq_codeclone.sh 0 2 1 false 1 1 true 1 false false false $EXPT_NAME $TRANSFORM_NAME_FINE 0.5 0.5 0.01 $DATASET_NAME 1 $FINETUNED_MODEL $NUM_REPLACE 0 $DECODER_ONLY 10 $LAMB | tee adv_pretrain_adv_train_${LAMB}_10.txt


        EXPT_NAME="v2-3-z_rand_1-pgd_3-no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-$TRANSFORM_NAME_FINE-$FINETUNED_MODEL-AT-lamb-${LAMB}-fre-5"
        # ./experiments/adv_train_seq2seq_codeclone.sh 0 2 1 false 1 1 true 1 false false false $EXPT_NAME $TRANSFORM_NAME_FINE 0.5 0.5 0.01 $DATASET_NAME 1 $FINETUNED_MODEL $NUM_REPLACE 0 $DECODER_ONLY 5 $LAMB | tee adv_pretrain_adv_train_${LAMB}5.txt

        # attack and test the trained model

        #ADVERSARIAL_MODEL="final-models/seq2seq/$EXPT_NAME/$DATASET_NAME/$TRANSFORM_NAME_FINE/adversarial"
        
        # no attack + test on full test set
        #./experiments/attack_and_test_transformer.sh 1 2 1 false 1 1 false 1 false false false v2-1-z_no_no-pgd_no_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-${LAMB} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"

        # z_1_random + u_optim (uwisc) attack + test on exact matches
        #./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-em-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 1 true true false "Latest"

        # z_1_random + u_optim (uwisc) attack + test on full test set
        #./experiments/attack_and_test_transformer.sh 1 2 1 false 1 1 true 10 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-${LAMB} $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"
        #./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 5 true 3 false false false v2-3-z_rand_5-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"

        #bash ./experiments/attack_and_test_random_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true false true "Latest"

        # z_1_random + u random attack + test on exact match
        #bash ./experiments/attack_and_test_random_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE-}-$TRANSFORM_NAME_FINE-em-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 1 true false true "Latest"
    done
done
