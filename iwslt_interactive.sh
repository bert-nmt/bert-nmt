#!/usr/bin/env bash
#interactive_baseline.sh
if [ "$1" == '-h' ]
then
    echo "bash interactive_baseline.sh  cktpath --beam 5 --lenpen 1. -s en -t es "
fi
set -x
set -e
export PYTHONIOENCODING="UTF-8"
export TORCH_HOME=/code/bertnmt/checkpoints/bert
cd /code/bertnmt
pip install --editable . --user --quiet
MOSE=/code/mosesdecoder
sockeye=/code/sockeye

cktpath=$1
shift
if [ -z $cktpath ]
then
exit
fi
POSITIONAL=()
beam=5
lenpen=1.0
srclng=en
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
  --beam)
    beam=$2; shift 2;;
  --lenpen)
    lenpen=$2; shift 2;;
  -s)
    srclng=$2; shift 2;;
  -t)
    tgtlng=$2; shift 2;;
  *)
  POSITIONAL+=("$1")
  shift
  ;;
esac
done

if [ $tgtlng == 'es' ]; then
suffix="/data/iwslt/en_es/test.es"
elif [ $tgtlng == 'zh' ]; then
suffix="-t iwslt17 -l ${srclng}-${tgtlng} --tok zh "
else
suffix="-t iwslt17 -l ${srclng}-${tgtlng}"
fi


bpefile=/data/iwslt/${srclng}_${tgtlng}/test.$srclng
dictpath=/data/iwslt/${srclng}_${tgtlng}/databin
set -- "${POSITIONAL[@]}"
tgtlog=$cktpath.log
sed -r 's/(@@ )|(@@ ?$)//g' $bpefile > $bpefile.debpe
if [ $srclng == zh ]
then
    sed -r 's/ //g' $bpefile.debpe > $bpefile.debpe.detok
else
    perl $MOSE/scripts/tokenizer/detokenizer.perl -l $srclng <  $bpefile.debpe > $bpefile.debpe.detok
fi
paste -d "\n" $bpefile $bpefile.debpe.detok > $bpefile.in

cat $bpefile.in | python interactive.py $dictpath --path $cktpath --buffer-size 1024 \
--batch-size 128 --beam $beam --lenpen $lenpen -s $srclng -t $tgtlng --remove-bpe > $tgtlog
grep ^H $tgtlog  | cut -f3- > $tgtlog.h
if [ $tgtlng == 'zh' ]
then
    sed -r 's/ //g' $tgtlog.h > $tgtlog.h.detok
else
    perl $MOSE/scripts/tokenizer/detokenizer.perl -l $tgtlng < $tgtlog.h > $tgtlog.h.detok
fi
cat $tgtlog.h.detok | $sockeye/sockeye_contrib/sacrebleu/sacrebleu.py $suffix
