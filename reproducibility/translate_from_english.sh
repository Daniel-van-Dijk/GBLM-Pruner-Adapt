#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --gpus=1
#SBATCH --job-name=translate
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=18
#SBATCH --time=01:30:00
#SBATCH --output=slurm/slurm_output_%A.out

module purge
module load 2023
module load Anaconda3/2023.07-2

source activate ALMA_compression

model_hf="haoranxu/ALMA-7B"
model="ALMA-7B"

declare -A languages=(["de"]="german"
                    ["cs"]="czech"
                    ["is"]="icelandic"
                    ["zh"]="chinese"
                    ["ru"]="russian")

src="en"

for tgt in "${!languages[@]}"; do
    echo "$model: Translating from $src to $tgt"
    echo "data/from_english/${languages[$tgt]}/src.txt"
    echo "output/from_english/${languages[$tgt]}/out.txt"
    
    python translate.py \
        --fin "data/from_english/${languages[$tgt]}/src.txt" \
        --fout "output/from_english/${languages[$tgt]}/$model.txt" \
        --ckpt translate.ckpt \
        --src "$src" \
        --tgt "$tgt" \
        --dtype bfloat16 \
        --model "$model_hf" \
        --beam 5
done