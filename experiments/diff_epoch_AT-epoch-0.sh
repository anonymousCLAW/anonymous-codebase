DATASET_NAME="sri/py150"
#VIEWS=("random" "v2-3-z_rand_1-pgd_3_no-transforms.Replace-csn-py")
#VIEWS=("v2-3-z_rand_1-pgd_3_no-transforms.Replace-csn-py")
#VIEWS =("pretrain_csn_hidden_identity_512_512_adv_online")
VIEWS=("adv-contra_1_3")
#VIEWS=("512_512_transforms_Combined_1_3_beta_3")
TRAIN_DECODER_ONLY=("false")
#TRANSFORM_NAME="transforms.Replace"
TRANSFORM_NAME="transforms.Combined"
#TRANSFORM_NAME="transforms.Insert"
for VIEWS_TYPE in "${VIEWS[@]}"; do

    #PRETRAINED_MODEL="pretrain_csn_hidden_identity_${VIEWS_TYPE}"
    PRETRAINED_MODEL="pretrain_py150_hidden_identity_${VIEWS_TYPE}"
    #PRETRAINED_MODEL=VIEWS_TYPE
    # pretrain a seq2seq encoder on the csn python train set
    VIEWS=${VIEWS_TYPE} \
    DATASET=csn/python \
    MODEL_NAME=${PRETRAINED_MODEL} \
        #time make pretrain-contracode

    for DECODER_ONLY in "${TRAIN_DECODER_ONLY[@]}"; do
            
        echo "CONFIG: views=${VIEWS_TYPE}; decoder_only=${DECODER_ONLY} "
        if [ "$VIEWS_TYPE" != "random" ]; then 
            VIEWS_TYPE="adversarial"
        fi
        #FINETUNED_MODEL="finetuned_sri_hidden_identity_${VIEWS_TYPE}_decoder-only-${DECODER_ONLY}-epochs-1"
        FINETUNED_MODEL="finetuned_sri_hidden_identity_${VIEWS_TYPE}_online_${TRANSFORM_NAME}_decoder-only-${DECODER_ONLY}-epochs-1"
        #FINETUNED_MODEL="v2-3-z_rand_1-pgd_3-no-transforms.Combined-py150-finetuned_sri_hidden_identity_adversarial_online_transforms.Combined_decoder-only-false-epochs-1-AT"
        # finetune the decoder for one epoch
        GPU=1 \
        MODEL_TYPE="seq2seq" \
        DATASET=${DATASET_NAME} \
        DECODER_ONLY=${DECODER_ONLY} \
        EPOCHS=1 \
        CHECKPOINT="${PRETRAINED_MODEL}/ckpt_pretrain_ep0047_step0055000.pth" \
        MODEL_NAME=${FINETUNED_MODEL} \
            #time make finetune-contracode

        # adversarial training starting from the partially finetuned model from above
        NUM_REPLACE=1500
        DATASET_NAME_SMALL="py150"
        TRANSFORM_NAME="transforms.Combined"
        TRANSFORM_NAME_FINE="transforms.Combined"
        EXPT_NAME="v2-3-z_rand_2-pgd_3-no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-$TRANSFORM_NAME_FINE-$FINETUNED_MODEL-AT-FRE-2"
        #./experiments/adv_train_seq2seq.sh 0 2 1 false 1 1 true 3 false false false $EXPT_NAME $TRANSFORM_NAME_FINE 0.5 0.5 0.01 $DATASET_NAME 1 $FINETUNED_MODEL $NUM_REPLACE 0 $DECODER_ONLY 2 0.4
        # attack and test the trained model
        EXPT_NAME="v2-3-z_rand_1-pgd_3-no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-$TRANSFORM_NAME_FINE-$FINETUNED_MODEL-AT-FRE-5"
        ./experiments/adv_train_seq2seq.sh 0 2 1 false 1 1 true 3 false false false $EXPT_NAME $TRANSFORM_NAME_FINE 0.5 0.5 0.01 $DATASET_NAME 1 $FINETUNED_MODEL $NUM_REPLACE 0 $DECODER_ONLY 5 0.4
        #attack and test the trained model
        # EXPT_NAME="v2-3-z_rand_2-pgd_3-no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-$TRANSFORM_NAME_FINE-$FINETUNED_MODEL-AT-FRE-10"
        #./experiments/adv_train_seq2seq.sh 0 2 1 false 1 1 true 3 false false false $EXPT_NAME $TRANSFORM_NAME_FINE 0.5 0.5 0.01 $DATASET_NAME 1 $FINETUNED_MODEL $NUM_REPLACE 0 $DECODER_ONLY 10 0.4
        # attack and test the trained model
        EXPT_NAME="v2-3-z_rand_1-pgd_3-no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-$TRANSFORM_NAME_FINE-$FINETUNED_MODEL-AT-FRE-5"
        ADVERSARIAL_MODEL="final-models/seq2seq/$EXPT_NAME/$DATASET_NAME/$TRANSFORM_NAME_FINE/adversarial"
        #ADVERSARIAL_MODEL="final-models/seq2seq/v2-3-z_rand_1-pgd_3-no-transforms.Combined-py150-finetuned_sri_hidden_identity_adversarial_online_transforms.Combined_decoder-only-false-epochs-1-AT/$DATASET_NAME/$TRANSFORM_NAME_FINE/adversarial" 
        # no attack + test on full test set
        
        #./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 false 1 false false false v2-1-z_no_no-pgd_no_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-FRE-5 $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"

        # # z_1_random + u_optim (uwisc) attack + test on exact matches
        # ./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-em-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 1 true true false "Latest"

        # # z_1_random + u_optim (uwisc) attack + test on full test set
        #./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-FRE-5 $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"
        # z_5_random + u_optim (uwisc) attack + test on full test set
        #./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 5 true 3 false false false v2-3-z_rand_5-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-FRE-5 $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"


        EXPT_NAME="v2-3-z_rand_1-pgd_3-no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-$TRANSFORM_NAME_FINE-$FINETUNED_MODEL-AT-FRE-2"
        ADVERSARIAL_MODEL="final-models/seq2seq/$EXPT_NAME/$DATASET_NAME/$TRANSFORM_NAME_FINE/adversarial"
        #ADVERSARIAL_MODEL="final-models/seq2seq/v2-3-z_rand_1-pgd_3-no-transforms.Combined-py150-finetuned_sri_hidden_identity_adversarial_online_transforms.Combined_decoder-only-false-epochs-1-AT/$DATASET_NAME/$TRANSFORM_NAME_FINE/adversarial"
        # no attack + test on full test set
        #./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 false 1 false false false v2-1-z_no_no-pgd_no_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-FRE-2 $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"

        # # z_1_random + u_optim (uwisc) attack + test on exact matches
        # ./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-em-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 1 true true false "Latest"

        # # z_1_random + u_optim (uwisc) attack + test on full test set
        #./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-FRE-2 $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"
        # z_5_random + u_optim (uwisc) attack + test on full test set
        #./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 5 true 3 false false false v2-3-z_rand_5-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-FRE-2 $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"



        # EXPT_NAME="v2-3-z_rand_1-pgd_3-no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-$TRANSFORM_NAME_FINE-$FINETUNED_MODEL-AT-FRE-10"
        # ADVERSARIAL_MODEL="final-models/seq2seq/$EXPT_NAME/$DATASET_NAME/$TRANSFORM_NAME_FINE/adversarial"
        # #ADVERSARIAL_MODEL="final-models/seq2seq/v2-3-z_rand_1-pgd_3-no-transforms.Combined-py150-finetuned_sri_hidden_identity_adversarial_online_transforms.Combined_decoder-only-false-epochs-1-AT/$DATASET_NAME/$TRANSFORM_NAME_FINE/adversarial"
        # # no attack + test on full test set
        #./experiments/attack_and_test_seq2seq.sh 0 2 1 false 1 1 false 1 false false false v2-1-z_no_no-pgd_no_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-FRE-10 $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"

        # # z_1_random + u_optim (uwisc) attack + test on exact matches
        #./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-em-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 1 true true false "Latest"

        # # # z_1_random + u_optim (uwisc) attack + test on full test set
        #./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-FRE-10 $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"
        # # z_5_random + u_optim (uwisc) attack + test on full test set
        # ./experiments/attack_and_test_seq2seq.sh 1 2 1 false 1 5 true 3 false false false v2-3-z_rand_5-pgd_3_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT-FRE-10 $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true true false "Latest"



        # z_1_random + u random attack + test on exact match
        # bash ./experiments/attack_and_test_random_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true false true "Latest"
        # # z_5_random + u random attack + test on exact match
        # bash ./experiments/attack_and_test_random_seq2seq.sh 1 2 1 false 1 5 true 3 false false false v2-3-z_rand_5-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE}-$TRANSFORM_NAME_FINE-full-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 0 true false true "Latest"
        # # z_1_random + u random attack + test on exact match
        # bash ./experiments/attack_and_test_random_seq2seq.sh 1 2 1 false 1 1 true 3 false false false v2-3-z_rand_1-random_no-$TRANSFORM_NAME-$DATASET_NAME_SMALL-${VIEWS_TYPE-}-$TRANSFORM_NAME_FINE-em-dec_only-${DECODER_ONLY}-AT $TRANSFORM_NAME 0.5 0.5 0.01 $DATASET_NAME 1 $ADVERSARIAL_MODEL $NUM_REPLACE 1 true false true "Latest"
    done
done
