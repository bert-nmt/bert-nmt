# Introduction
This branch contains the updated code which can use more pretrained language models contained in [huggingface/transformers](https://github.com/huggingface/transformers).
# Requirements and Installation

All requirements are updated in [Dockerfile](Dockerfile).

* [PyTorch](http://pytorch.org/) version == 1.5.0
* Python version == 3.6
* [huggingface/transformers](https://github.com/huggingface/transformers) version == 3.5.0

**Installing from source**

To install fairseq from source and develop locally:
```shell script
git clone https://github.com/bert-nmt/bert-nmt
cd bert-nmt
git checkout update-20-10
pip install --editable .
```

# Getting Started
### Data Preprocessing



First, you should run Fairseq [prepare-xxx.sh](examples/translation) to get tokenized&bped files like:
```
# bash prepare-iwslt14.sh
train.en train.de valid.en valid.de test.en test.de
```
Then you can use  [makedataforbert.sh](examples/translation/makedataforbert.sh) to get input file for BERT model (please note that the path is correct).
You can get
```shell script
# cd iwslt14.tokenized.de-en
# cp ../makedataforbert.sh .
# bash makedataforbert.sh de
train.en train.de valid.en valid.de test.en test.de train.bert.de valid.bert.de test.bert.de
```
Then preprocess data like Fairseq:
```shell script
cd ../../..
TEXT=examples/translation/iwslt14.tokenized.de-en
src=de
tgt=en
destdir=iwslt_${src}_${tgt}
python preprocess.py --source-lang $src --target-lang $tgt \
  --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
  --destdir $destdir  --joined-dictionary --bert-model-name bert-base-german-dbmdz-uncased
```
### Train a vanilla NMT model using [Fairseq](https://github.com/pytorch/fairseq)
Using data above and standard [Fairseq](https://github.com/pytorch/fairseq) repository, you can get a pretrained NMT model.


The version should be `a8f28ecb63ee01c33ea9f6986102136743d47ec2`.
```shell script
git clone https://github.com/pytorch/fairseq
git checkout a8f28ecb63ee01c33ea9f6986102136743d47ec2

```
### Train a BERT-fused NMT model
The important options I have added are
```
        parser.add_argument('--bert-model-name', default='bert-base-uncased', type=str)
        parser.add_argument('--warmup-from-nmt', action='store_true', )
        parser.add_argument('--warmup-nmt-file', default='checkpoint_nmt.pt', )
        parser.add_argument('--encoder-bert-dropout', action='store_true',)
        parser.add_argument('--encoder-bert-dropout-ratio', default=0.25, type=float)
```
1. `--bert-model-name` specify the BERT model name, provided in [file](bert/modeling.py).
2. `--warmup-from-nmt` indicate you will also use a pretrained NMT model to train your BERT-fused NMT model. If you this option, we suggest you use `--reset-lr-scheduler`, too.
3. `--warmup-nmt-file` specify the NMT model name (in your savedir).
4. `--encoder-bert-dropout` indicate you will use drop-net trick.
5. `--encoder-bert-dropout-ratio` specify the ratio ($\in [0, 0.5]$) used in drop-net.
This is my training script example:
```shell script
#!/usr/bin/env bash
nvidia-smi

cd /yourpath/bertnmt
python3 -c "import torch; print(torch.__version__)"

src=de
tgt=en
bedropout=0.5
ARCH=transformer_s2_iwslt_de_en
DATAPATH=/yourdatapath
SAVEDIR=checkpoints/iwed_${src}_${tgt}_${bedropout}
mkdir -p $SAVEDIR
if [ ! -f $SAVEDIR/checkpoint_nmt.pt ]
then
    cp /your_pretrained_nmt_model $SAVEDIR/checkpoint_nmt.pt
fi
if [ ! -f "$SAVEDIR/checkpoint_last.pt" ]
then
warmup="--warmup-from-nmt --reset-lr-scheduler"
else
warmup=""
fi

export CUDA_VISIBLE_DEVICES=${1:-0}
python train.py $DATAPATH \
    -a $ARCH --optimizer adam --lr 0.0005 -s $src -t $tgt --label-smoothing 0.1 \
    --dropout 0.3 --max-tokens 4000 --min-lr '1e-09' --lr-scheduler inverse_sqrt --weight-decay 0.0001 \
    --criterion label_smoothed_cross_entropy --max-update 150000 --warmup-updates 4000 --warmup-init-lr '1e-07' \
    --adam-betas '(0.9,0.98)' --save-dir $SAVEDIR --share-all-embeddings $warmup \
    --encoder-bert-dropout --encoder-bert-dropout-ratio $bedropout \
    --bert-model-name bert-base-german-dbmdz-uncased | tee -a $SAVEDIR/training.log
```

### Generate
Using the `generate.py` to test model is the same as the Fairseq, but you should add `--bert-model-name` to indicate your BERT model name.
```shell script
python generate.py dictpath --path model_path -s $src -t $tgt \
--batch-size 128 --beam 5 --remove-bpe  --bert-model-name bert-base-german-dbmdz-uncased
```

Using the `interactive.py` to test model is a little different from the Fairseq. You should follow this procedure:
```shell script
sed -r 's/(@@ )|(@@ ?$)//g' $bpefile > $bpefile.debpe
$MOSE/scripts/tokenizer/detokenizer.perl -l $src < $bpefile.debpe > $bpefile.debpe.detok
paste -d "\n" $bpefile $bpefile.debpe.detok > $bpefile.in
cat $bpefile.in | python interactive.py dictpath --path model_path -s $src -t $tgt \
--buffer-size 1024 --batch-size 128 --beam 5 --remove-bpe  > output.log
```
We get a new result on IWSLT'14 de->en task with `bert-base-german-dbmdz-uncased`, as shown below
```shell script
Generate test with beam=5: BLEU4 = 37.34, 69.7/45.1/31.2/21.9 (BP=0.974, ratio=0.975, syslen=127837, reflen=131156)
```
