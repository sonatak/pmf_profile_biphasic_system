#!/bin/bash
gmx grompp -f NVT.mdp -c em.gro -p topol.top -o nvt.tpr
gmx mdrun  -deffnm nvt
gmx grompp -f NPT.mdp -c nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
gmx mdrun  -deffnm npt

