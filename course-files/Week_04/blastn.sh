#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --time=3:00:00
#SBATCH --partition=instruction  # class node(s)
#SBATCH --account=s2024.eeob.546.1   #account to use
#SBATCH --mail-user=$USER@iastate.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --job-name=blast-10k
#SBATCH --error=blastx-10k.%J.err
#SBATCH --output=blastx10k.%J.out

cd $SLURM_SUBMIT_DIR


module load blast-plus

blastx \
   -db /ptmp/arnstrm/bcb590/546x/blast/zm_pep.fa \
   -query /ptmp/arnstrm/bcb590/546x/blast/Zea_mays_dna_10k.fa \
   -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend qlen sstart send slen evalue frames sgi staxid" \
   -num_threads 8 \
   -out zm_blastx_10k.out

# print job's resource usage
scontrol show job $SLURM_JOB_ID
