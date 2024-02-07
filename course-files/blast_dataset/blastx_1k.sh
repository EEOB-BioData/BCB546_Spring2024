#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --time=3:00:00
#SBATCH --mail-user=$USER@iastate.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=blast-1k
#SBATCH --error=blastx-1k.%J.err
#SBATCH --output=blastx-1k.%J.out

cd $SLURM_SUBMIT_DIR

module load blast-plus


blastx \
   -db zm_pep.fa \
   -query Zea_mays_dna_1k.fa \
   -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend qlen sstart send slen evalue frames sgi staxid" \
   -num_threads 8 \
   -out zm_blastx_1k.out

# print job's resource usage
scontrol show job $SLURM_JOB_ID
