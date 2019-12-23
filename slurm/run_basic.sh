#!/bin/bash -l
##Nazwa zlecenia
#SBATCH -J Basic
## Liczba alokowanych węzłów
#SBATCH -N 1
## Liczba zadań per węzeł (domyślnie jest to liczba alokowanych rdzeni na węźle)
#SBATCH --ntasks-per-node=12
## Ilość pamięci przypadającej na jeden rdzeń obliczeniowy (domyślnie 4GB na rdzeń)
#SBATCH --mem-per-cpu=1GB
## Maksymalny czas trwania zlecenia (format HH:MM:SS)
#SBATCH --time=3:0:0 
## Specyfikacja partycji
#SBATCH -p plgrid
#SBATCH -A chapelresearchzeus
## Plik ze standardowym wyjściem
#SBATCH --output="logs/basic/%j.csv"
## Plik ze standardowym wyjściem błędów
#SBATCH --error="logs/basic/%j.err"
 
module load plgrid/tools/chapel/1.20.0
export  GASNET_PHYSMEM_MAX='128MB'
export CHPL_RT_NUM_THREADS_PER_LOCALE=12

## go to execution dir
cd $SLURM_SUBMIT_DIR

chpl -o bin/basic src/bb_basic.chpl

echo "root,shortest,time"

for procs in 2 4 6 8 10 12
do
    bin/basic -nl 1 --file data/a280.tsp --N 13 --initRoot 1 --split $procs
done


