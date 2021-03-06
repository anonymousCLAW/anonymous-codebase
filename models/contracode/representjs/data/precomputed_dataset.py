import gzip
import pathlib
import pickle
import dill
import os

import numpy as np
import torch
from loguru import logger

from data.util import Timer, normalize_program, EncodeAsIds


class PrecomputedDataset(torch.utils.data.Dataset):
    """Defines a Dataset of unsupervised programs stored in pickle format."""

    def __init__(
        self,
        path,
        sp,
        min_alternatives=1,
        limit_size=-1,
        max_length=1024,
        subword_regularization_alpha=0.1,
        program_mode="identity",
        preloaded_examples=None,
        model_type=None,
        vocab=None
    ):
        """Create a JSONLinesDataset given a path and field mapping dictionary.
        Arguments:
            path (str): Path to the data file. Must be in .pickle format.
        """
        super().__init__()
        full_path = pathlib.Path(path).resolve()
        if preloaded_examples is not None:
            logger.debug("Using preloaded examples passed via argument")
            self.examples = preloaded_examples
        else:
            logger.debug(f"Loading {full_path}")
            with Timer() as t:
                if str(path).endswith(".gz"):
                    with gzip.open(str(full_path), "rb") as f:
                        self.examples = pickle.load(f)
                else:
                    with full_path.open("rb") as f:
                        self.examples = pickle.load(f)
            logger.debug(f"Loaded {len(self.examples)} examples in {t.interval:.3f}s")
        if limit_size > 0:
            self.examples = self.examples[:limit_size]
            logger.debug(f"Limited size: took first {limit_size} examples")
        self.examples = list(map(list, self.examples))
        logger.debug("Converted examples to lists of alternatives")
        if min_alternatives:
            self.examples = list(filter(lambda ex: len(ex) >= min_alternatives, self.examples))
        logger.debug(f"Filtered dataset to {len(self.examples)} examples with at least {min_alternatives} alternatives")

        self.program_mode = program_mode
        self.max_length = max_length
        self.model_type = model_type
        self.subword_regularization_alpha = subword_regularization_alpha
        self.sp = sp
        self.vocab = vocab
        if self.model_type=="seq2seq" or self.model_type=="adv" or self.model_type=="transformer" or self.model_type=="adv_transformer":
            self.bos_id = vocab.stoi["<sos>"]
            self.eos_id = vocab.stoi["<eos>"] 
        else:
            self.bos_id = sp.PieceToId("</s>")
            self.eos_id = sp.PieceToId("</s>")

    def __len__(self):
        return len(self.examples)

    def __getitem__(self, idx):
        alternatives = self.examples[idx]
        n_alt = len(alternatives)
        #print(n_alt)
        if self.program_mode == "identity":
            return self.encode(alternatives[0])
        elif self.program_mode == "augmentation":
            i = np.random.randint(n_alt)
            return self.encode(alternatives[i])
        elif self.program_mode == "contrastive":
            i = np.random.randint(n_alt)
            j = i
            if n_alt > 1:
                while j == i:
                    j = np.random.randint(n_alt)
            return self.encode(alternatives[i]), self.encode(alternatives[j])
        elif self.program_mode == "adv_contrastive":
            # print(alternatives[2])
            # print(self.encode(alternatives[2]))
            return self.encode(alternatives[0]), self.encode(alternatives[1]),self.encode(alternatives[2]),alternatives[3],alternatives[4]

        elif self.program_mode == "all_alternatives":
            return [self.encode(alt) for alt in alternatives]
        else:
            raise ValueError(f"Invalid program mode {self.program_mode}")

    def str_to_ids(self, program):
        # EncodeAsIds for seq2seq
        tokens = program.split(" ")
        ids = [self.vocab.stoi[tok] for tok in tokens]
        return ids

    def encode(self, program):
        if self.model_type == "seq2seq" or self.model_type=="adv" or self.model_type=="transformer" or self.model_type=="adv_transformer":
            program = self.str_to_ids(program)
        else:
            program = normalize_program(program)
            program = EncodeAsIds(self.sp, self.subword_regularization_alpha, program)
        return torch.LongTensor([self.bos_id] + program[: (self.max_length - 2)] + [self.eos_id])
