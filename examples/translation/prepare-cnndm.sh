#!/usr/bin/env bash
#
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh
set -x
set -e
echo 'Cloning Subword NMT repository (for BPE pre-processing)...'
git clone https://github.com/rsennrich/subword-nmt.git

BPEROOT=subword-nmt
BPE_TOKENS=32000


src=source
tgt=target
lang=source-target
prep=cnndm
tmp=$prep/tmp

mkdir -p  $prep $tmp

for fn in test.source train.source val.source; do
    if [ -f $prep/$fn ]; then
        mv $prep/$fn $tmp
        python truncate.py $tmp/$fn $prep/$fn.tok
    else
        echo "$fn does not exist, please check your data path!"
        exit
    fi
done
for fn in test.target train.target val.target; do
    if [ -f $prep/$fn ]; then
        mv $prep/$fn $prep/$fn.tok
    else
        echo "$fn does not exist, please check your data path!"
        exit
    fi
done

TRAIN=$prep/train.source-target
BPE_CODE=$prep/code
rm -f $TRAIN
for l in train.source train.target; do
    cat $prep/$l.tok >> $TRAIN
done

echo "learn_bpe.py on ${TRAIN}..."
python $BPEROOT/learn_bpe.py -s $BPE_TOKENS < $TRAIN > $BPE_CODE

for L in test.source test.target train.source train.target val.source val.target; do
    f=$prep/$L.tok
    echo "apply_bpe.py to ${f}..."
    python $BPEROOT/apply_bpe.py -c $BPE_CODE < $f > $prep/$L
done

cd ../..
TEXT=examples/translation/$prep
python preprocess.py --source-lang source --target-lang target \
  --trainpref $TEXT/train --validpref $TEXT/val --testpref $TEXT/test \
  --destdir data-bin/text_summarization --joined-dictionary --workers 20
