#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH -t 05:00:00
#SBATCH -p standard
#SBATCH -A insect_spatial_ecology
#SBATCH -o job_%a.out
#SBATCH --array=1-27


# load modules
#--------------
module purge
#module load goolf/9.2.0_3.1.6 R/4.2.1
module load goolf/11.4.0_4.1.4 R/4.3.1


# run script
#------------
TIMEFRAME=""
Rscript 9_matrix_regressions_by_species.R  $SLURM_ARRAY_TASK_ID ""

