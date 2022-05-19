VIEWS="adv-contra" \
DATASET="sri/py150" \
MODEL_NAME="pretrain_py150_hidden_identity_512_512_adv_online" \
adv_lr=1 \
U_PGD_EPOCHS=1 \
NUM_SITES=3 \
    time make adv-pretrain-contracode