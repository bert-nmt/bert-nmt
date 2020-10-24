import io
import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument('src', type=str)
parser.add_argument('tgt', type=str)
args = parser.parse_args()
srcfn = args.src
tgtfn = args.tgt
assert os.path.exists(srcfn)
with io.open(srcfn, 'r', encoding='utf8', newline='\n') as src:
    with io.open(tgtfn, 'w', encoding='utf8', newline='\n') as tgt:
        for line in src:
            words = line.strip().split()[:400]
            newline = ' '.join(words)
            print(newline, file=tgt)

