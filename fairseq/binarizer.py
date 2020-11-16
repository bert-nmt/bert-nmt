# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the license found in the LICENSE file in
# the root directory of this source tree. An additional grant of patent rights
# can be found in the PATENTS file in the same directory.

from collections import Counter
import os

from fairseq.tokenizer import tokenize_line
from transformers import PreTrainedTokenizer, AutoTokenizer
import torch
def safe_readline(f):
    pos = f.tell()
    while True:
        try:
            return f.readline()
        except UnicodeDecodeError:
            pos -= 1
            f.seek(pos)  # search where this character begins


class Binarizer:

    @staticmethod
    def binarize(filename, dict, consumer, tokenize=tokenize_line, append_eos=True, reverse_order=False,
                 offset=0, end=-1):
        nseq, ntok = 0, 0
        replaced = Counter()
        if isinstance(dict, PreTrainedTokenizer):
            dict.unk_word = dict.special_tokens_map['unk_token']
            dict.unk_index = dict.vocab[dict.special_tokens_map['unk_token']]
        def replaced_consumer(word, idx):
            if idx == dict.unk_index and word != dict.unk_word:
                replaced.update([word])

        with open(filename, 'r', encoding='utf-8') as f:
            f.seek(offset)
            # next(f) breaks f.tell(), hence readline() must be used
            line = safe_readline(f)
            while line:
                if end > 0 and f.tell() > end:
                    break
                if isinstance(dict, PreTrainedTokenizer):
                    line = line.strip()
                    tokenizedline = dict.tokenize(dict.special_tokens_map['cls_token'] +
                                                  line + dict.special_tokens_map['sep_token'])
                    input_ids = dict(line)['input_ids']
                    if len(input_ids) > dict.model_max_length:
                        input_ids = input_ids[:dict.model_max_length-1] + [input_ids[-1]]
                        tokenizedline = tokenizedline[:dict.model_max_length-1] + [dict.special_tokens_map['sep_token']]
                    assert len(input_ids) == len(tokenizedline)
                    nwords = len(input_ids)
                    ids = torch.IntTensor(nwords)
                    for i, word in enumerate(input_ids):
                        ids[i] = word
                        replaced_consumer(tokenizedline[i], word)
                else:
                    ids = dict.encode_line(
                            line=line,
                            line_tokenizer=tokenize,
                            add_if_not_exist=False,
                            consumer=replaced_consumer,
                            append_eos=append_eos,
                            reverse_order=reverse_order,
                    )
                nseq += 1
                ntok += len(ids)
                consumer(ids)
                line = f.readline()
        return {'nseq': nseq, 'nunk': sum(replaced.values()), 'ntok': ntok, 'replaced': replaced}

    @staticmethod
    def find_offsets(filename, num_chunks):
        with open(filename, 'r', encoding='utf-8') as f:
            size = os.fstat(f.fileno()).st_size
            chunk_size = size // num_chunks
            offsets = [0 for _ in range(num_chunks + 1)]
            for i in range(1, num_chunks):
                f.seek(chunk_size * i)
                safe_readline(f)
                offsets[i] = f.tell()
            return offsets
