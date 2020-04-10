#!/bin/bash

#!/bin/bash

### Request number of GPUs 
#$ -pe shm_n 1

### Home directory where the input files are located
export HOME_JOB_DIR=`pwd`

### Previleges
#$ -P grupoA
#$ -q NVIDIA

### System variables
echo "This job is running on " $HOSTNAME
echo "Parallel computing in $NSLOTS procs" 
#$ -cwd

source /opt/programs/VARS/loadvars.gromacs2018

#gmx grompp -f EM.mdp -c system_ions.gro -p topol.top -o em.tpr
#gmx mdrun -v -deffnm em
gmx grompp -f NVT.mdp -c em.gro -p topol.top -o nvt.tpr
gmx mdrun -ntmpi 1 -ntomp 8 -deffnm nvt
gmx grompp -f NPT.mdp -c nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
gmx mdrun -ntmpi 1 -ntomp 8 -deffnm npt
#mx grompp -f PROD.mdp -c npt.gro -t npt.cpt -p topol.top -o prod.tpr
#ohup gmx mdrun -ntmpi 1 -ntomp 8 -deffnm prod 
#echo "22 0" | gmx energy -f prod.edr -s prod.tpr -o density.xvg

