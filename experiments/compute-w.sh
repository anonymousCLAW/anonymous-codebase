GPU=1 \
MODEL_TYPE="seq2seq" \
DATASET="sri/py150" \
DECODER_ONLY="true" \
EPOCHS=10 \
CHECKPOINT="pretrain_py150_hidden_identity_adv-contra_transforms.Combined_1_3/ckpt_pretrain_ep0047_step0055000.pth" \
MODEL_NAME="v2-3-z_rand_1-pgd_3-no-transforms.Combined-py150-finetuned_sri_hidden_identity_adversarial_online_transforms.Combined_decoder-only-false-epochs-1-AT/sri/py150/transforms.Combined/adversarial/" \
    time make compute-w