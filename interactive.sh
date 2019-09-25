#!/usr/bin/env bash
if [ "$1" == '-h' ]
then
    echo "bash interactive.sh bpefile en2de 14 dictpath --path  cktpath --lenpen 1. --beam 5"
    exit
fi
set -x
set -e
export PYTHONIOENCODING="UTF-8"
export TORCH_HOME=/code/bertnmt/checkpoints/bert
cd /code/bertnmt
pip install --editable . --user --quiet
MOSE=/code/mosesdecoder
sockeye=/code/sockeye
bpefile=$1
shift
lng=$1
src=${lng:0:2}
tgt=${lng:3:2}
shift
year=$1
shift


POSITIONAL=()
beam=5
lenpen=1.0
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
  --beam)
    $beam=$2; shift 2;;
  --lenpen)
    $lenpen=$2; shift 2;;
  *)
  POSITIONAL+=("$1")
  shift
  ;;
esac
done
set -- "${POSITIONAL[@]}"

sed -r 's/(@@ )|(@@ ?$)//g' $bpefile > $bpefile.debpe
$MOSE/scripts/tokenizer/detokenizer.perl -l $src < $bpefile.debpe > $bpefile.debpe.detok
paste -d "\n" $bpefile $bpefile.debpe.detok > $bpefile.in
cat $bpefile.in | python interactive.py "${POSITIONAL[@]}" -s $src -t $tgt \
--buffer-size 1024 --batch-size 128 --beam 5 --remove-bpe  > output.log

grep ^H output.log | cut -f3- > output.tok
perl $MOSE/scripts/tokenizer/detokenizer.perl -l $tgt < output.tok > output.tok.detok
cat output.tok.detok | $sockeye/sockeye_contrib/sacrebleu/sacrebleu.py  -t wmt$year -l $src-$tgt
