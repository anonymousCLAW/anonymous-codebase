## Setting up training pipeline

## Commands

- Download and normalize datasets
```
make download-datasets
make normalize-datasets
```
- Create the transformed datasets
```
make apply-transforms-sri-py150
make apply-transforms-csn-python
make extract-transformed-tokens
```
- Train a normal seq2seq model for 10 epochs on `sri/py150`
```
bash experiments/normal_seq2seq_train.sh
```
- Run adversarial training and testing on `sri/py150` for 5 epochs
```
bash experiments/normal_adv_train.sh
```
- Get the augmented `csn-python` datasets with random and adversarial views
```
bash scripts/augment.sh
```
- Pretrain a seq2seq encoder on a `csn-python` augmented dataset, finetune the encoder on `sri/py150`, and test the final model on normal and adversarial datasets.
```
bash experiments/finetune_and_test_0.sh
```
- Pretrain a seq2seq encoder on `csn-python` and run adversasrial training starting from the pretrained model.
```
bash experiments/pretrain_adv_train.sh
```

