#!/bin/bash -l
##Nazwa zlecenia
#SBATCH -J Advanced
## Liczba alokowanych węzłów
#SBATCH -N 1
## Liczba zadań per węzeł (domyślnie jest to liczba alokowanych rdzeni na węźle)
#SBATCH --ntasks-per-node=12
## Ilość pamięci przypadającej na jeden rdzeń obliczeniowy (domyślnie 4GB na rdzeń)
#SBATCH --mem-per-cpu=1GB
## Maksymalny czas trwania zlecenia (format HH:MM:SS)
#SBATCH --time=4:0:0 
## Specyfikacja partycji
#SBATCH -p plgrid
#SBATCH -A chapelresearchzeus
## Plik ze standardowym wyjściem
#SBATCH --output="logs/advanced/%j.csv"
## Plik ze standardowym wyjściem błędów
#SBATCH --error="logs/advanced/%j.err"
 
module load plgrid/tools/chapel/1.20.0
export  GASNET_PHYSMEM_MAX='128MB'

## go to execution dir
cd $SLURM_SUBMIT_DIR

chpl -o bin/advanced src/bb_advanced.chpl

echo "root,split,maxTaskPar,shortest,time"

for n_cores in {1..12}
do
    export CHPL_RT_NUM_THREADS_PER_LOCALE=$n_cores
    for procs in 4 10
    do
        bin/advanced -nl 1 --file data/a280.tsp --N 13 --initRoot 1 --split $procs
    done
done


