#!/bin/bash
echo " Enter molecule name"
read -p MOL

# Creating mdp files
echo "integrator          = steep  " > EM.mdp 
echo "emtol               = 100.0  ">> EM.mdp  
echo "emstep              = 0.01   ">> EM.mdp 	      
echo "nsteps              = -1     ">> EM.mdp 	     
echo "nstcgsteep          = 1000   ">> EM.mdp 	      
echo "cutoff-scheme   = Verlet     ">> EM.mdp 	     
echo "nstlist             = 10     ">> EM.mdp 
echo "ns_type             = grid   ">> EM.mdp 	      
echo "rlist               = 1.2    ">> EM.mdp 
echo "coulombtype         = PME    ">> EM.mdp 
echo "rcoulomb            = 1.2    ">> EM.mdp 
echo "rvdw                = 1.2    ">> EM.mdp 
echo "pbc                 = xyz    ">> EM.mdp 
echo "constraints     = none       ">> EM.mdp 	     


echo "integrator  = steep     "> ions.mdp 
echo "emtol       = 1000.0    ">> ions.mdp 
echo "emstep      = 0.01      ">> ions.mdp 
echo "nsteps      = 50000     ">> ions.mdp 
echo "nstlist         = 1     ">> ions.mdp 
echo "cutoff-scheme   = Verlet">> ions.mdp  
echo "ns_type         = grid  ">> ions.mdp  
echo "coulombtype     = cutoff">> ions.mdp  
echo "rcoulomb        = 1.0   ">> ions.mdp   
echo "rvdw            = 1.0   ">> ions.mdp   
echo "pbc             = xyz   ">> ions.mdp   


# System prep
gmx editconf -f ./../$MOL.gro -d 1.5 -o system.gro -bt cubic
gmx solvate -cp system.gro -cs tip3p.gro -o system_solv.gro -p ./../$MOL.top
gmx grompp -f EM.mdp -c system_solv.gro -p ./../$MOL.top -o ions.tpr -maxwarn 1
gmx genion -s ions.tpr -o system_solv_ions.gro -p ./../$MOL.top -nname CL -nn 1

# Checking if minimization works with grompp
gmx grompp -f EM.mdp -c system_solv_ions.gro -p ./../$MOL.top -o em.tpr


