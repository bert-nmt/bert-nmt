# Introduction
This repository contains the code for BERT-fused NMT, which is introduced in the ICLR2020 paper [Incorporating BERT into Neural Machine Translation](https://openreview.net/forum?id=Hyl7ygStwB).

If you find this work helpful in your research, please cite as:
```
@inproceedings{
Zhu2020Incorporating,
title={Incorporating BERT into Neural Machine Translation},
author={Jinhua Zhu and Yingce Xia and Lijun Wu and Di He and Tao Qin and Wengang Zhou and Houqiang Li and Tieyan Liu},
booktitle={International Conference on Learning Representations},
year={2020},
url={https://openreview.net/forum?id=Hyl7ygStwB}
}
```

*NOTE: We have updated our [code](https://github.com/bert-nmt/bert-nmt/tree/update-20-10) to enable you use more powerful pretrained models contained in [huggingface/transformers](https://github.com/huggingface/transformers). With `bert-base-german-dbmdz-uncased`, we get a new result $37.34$ on IWSLT'14 de->en task.*
# Requirements and Installation

* [PyTorch](http://pytorch.org/) version == 1.0.0/1.1.0
* Python version >= 3.5

**Installing from source**

To install fairseq from source and develop locally:
```
git clone https://github.com/bert-nmt/bert-nmt
cd bertnmt
pip install --editable .
```

# Getting Started
### Data Preprocessing
First, you should run Fairseq `prepaer-xxx.sh` to get tokenized&bped files like:
```
train.en train.de valid.en valid.de test.en test.de
```
Then you can use  [makedataforbert.sh](examples/translation/makedataforbert.sh) to get input file for BERT model (please note that the path is correct).
You can get
```
train.en train.de valid.en valid.de test.en test.de train.bert.en valid.bert.en test.bert.en
```
Then preprocess data like Fairseq:
```
python preprocess.py --source-lang src_lng --target-lang tgt_lng \
  --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
  --destdir destdir  --joined-dictionary --bert-model-name bert-base-uncased
```

*Note: For more language pairs used in our paper, please refer to another [repo](https://github.com/teslacool/preprocess_iwslt/blob/master/preprocess.sh).*

### Train a vanilla NMT model using [Fairseq](https://github.com/pytorch/fairseq)
Using data above and standard [Fairseq](https://github.com/pytorch/fairseq) repository, you can get a pretrained NMT model.

*Note: The update_freq in iwslt en->zh translation is set to 2, and other hyper-parameters are the same as de<->en*

### Train a BERT-fused NMT model
The important options we add:
```
        parser.add_argument('--bert-model-name', default='bert-base-uncased', type=str)
        parser.add_argument('--warmup-from-nmt', action='store_true', )
        parser.add_argument('--warmup-nmt-file', default='checkpoint_nmt.pt', )
        parser.add_argument('--encoder-bert-dropout', action='store_true',)
        parser.add_argument('--encoder-bert-dropout-ratio', default=0.25, type=float)
```
1. `--bert-model-name` specify the BERT model name, provided in [file](bert/modeling.py).
2. `--warmup-from-nmt` indicate you will also use a pretrained NMT model to train your BERT-fused NMT model. If you this option, we suggest you use `--reset-lr-scheduler`, too.
3. `--warmup-nmt-file` specify the NMT model name (in your $savedir).
4. `--encoder-bert-dropout` indicate you will use drop-net trick.
5. `--encoder-bert-dropout-ratio` specify the ratio ($\in [0, 0.5]$) used in drop-net.
This is a training script example:
```
#!/usr/bin/env bash
nvidia-smi

cd /yourpath/bertnmt
python3 -c "import torch; print(torch.__version__)"

src=en
tgt=de
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

python train.py $DATAPATH \
-a $ARCH --optimizer adam --lr 0.0005 -s $src -t $tgt --label-smoothing 0.1 \
--dropout 0.3 --max-tokens 4000 --min-lr '1e-09' --lr-scheduler inverse_sqrt --weight-decay 0.0001 \
--criterion label_smoothed_cross_entropy --max-update 150000 --warmup-updates 4000 --warmup-init-lr '1e-07' \
--adam-betas '(0.9,0.98)' --save-dir $SAVEDIR --share-all-embeddings $warmup \
--encoder-bert-dropout --encoder-bert-dropout-ratio $bedropout | tee -a $SAVEDIR/training.log
```

### Generate
Using the `generate.py` to test model is the same as the Fairseq, but you should add `--bert-model-name` to indicate your BERT model name.

Using the `interactive.py` to test model is a little different from the Fairseq. You should follow this procedure:
```
sed -r 's/(@@ )|(@@ ?$)//g' $bpefile > $bpefile.debpe
$MOSE/scripts/tokenizer/detokenizer.perl -l $src < $bpefile.debpe > $bpefile.debpe.detok
paste -d "\n" $bpefile $bpefile.debpe.detok > $bpefile.in
cat $bpefile.in | python interactive.py  -s $src -t $tgt \
--buffer-size 1024 --batch-size 128 --beam 5 --remove-bpe  > output.log
```
