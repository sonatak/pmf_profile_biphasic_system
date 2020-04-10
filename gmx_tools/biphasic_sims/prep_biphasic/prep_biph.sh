#!/bin/bash
#cp ./../mdp_umbr/* .
cp oct_box/npt* .
cp oct_box/topol* .
mv vdwradii.dat.old vdwradii.dat
# Take the last snapshot of equilibrated system
echo 0 | gmx trjconv -s npt.tpr -f npt.xtc -o prod_noPBC.xtc -pbc mol -ur compact 
gmx trjconv -f prod_noPBC.xtc -s npt.tpr -pbc mol -b 200 -e 200 -o prod_last.gro -center
# Change radii!!!
gmx editconf -f prod_last.gro -o prod_newbox.gro -box 4.05556 4.05412 13.08897 -center 2.0278 2.02706 4.044485
gmx solvate -cp  prod_newbox.gro -cs spc216.gro -p topol.top -o prod_solv.gro
mv vdwradii.dat vdwradii.dat.old
gmx make_ndx -f npt_solv.gro
# Minim
gmx grompp -f EM.mdp -c prod_solv.gro -p topol.top -o em.tpr
gmx mdrun -deffnm em
# Equilibration
#gmx grompp -f npt.mdp -c em.gro -p topol.top -r em.gro -o npt.tpr
#gmx mdrun -deffnm npt


