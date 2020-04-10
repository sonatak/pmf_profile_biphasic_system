#!/bin/bash
read -p "Enter molecule name: "  MOL

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

cp ./../$MOL.top .
cp ./../../octanol/oct.gro .
cp ./../../octanol/oct.top .
# Modify oct.itp
grep -A 1000 moleculetype oct.top | head -n -7 > oct.itp

# Modify $MOL.itp
grep -A 1000 moleculetype $MOL.top | head -n -7 > MOL.itp
sed -i 's/MOL/OCT/g' oct.itp
sed -i 's/MOL/OCT/g' oct.gro


# Echo topol.top fil
echo '#include "./amber99sb-ildn.ff/forcefield.itp"' > topol.top
echo '#include "./MOL.itp" ' >> topol.top
echo '#include "./oct.itp" ' >> topol.top
echo '#include "./amber99sb-ildn.ff/tip3p.itp" ' >> topol.top
echo '#include "./amber99sb-ildn.ff/ions.itp"' >> topol.top
echo " " >> topol.top
echo "[ system ] " >> topol.top
echo "$MOL in octanol" >> topol.top
echo " " >> topol.top
echo "[ molecules ] ">> topol.top
echo "; Compound    " >>topol.top
echo "OCT     301    ">>topol.top
echo "MOL     1     ">>topol.top


# System prep
gmx editconf -f ./../$MOL.gro -o $MOL.pdb
gmx editconf -f oct.gro -o OCT.pdb

echo "# Create pacmol input" > packmol.inp 
echo "tolerance 2.0" >> packmol.inp
echo "filetype pdb" >> packmol.inp
echo "# The name of the output file" >> packmol.inp
echo "output packmol.pdb" >> packmol.inp
echo "structure OCT.pdb" >> packmol.inp
echo "  number 301" >> packmol.inp
echo "  inside box 0. 0. 0. 46. 46. 46." >> packmol.inp
echo "end structure" >> packmol.inp
echo "structure $MOL.pdb" >> packmol.inp
echo "  number 1" >> packmol.inp
echo "  inside box 16. 16. 16. 30. 30. 30." >> packmol.inp
echo "end structure" >> packmol.inp
packmol < packmol.inp > packmol.out
gmx editconf -f packmol.pdb -o system.gro -d 0.01
#real_mol=`tail -n 2 system_solv.gro | head -n 1 | awk -FO  '{print $1-1}'` # Actual number of inserted molecules
gmx grompp -f EM.mdp -c system.gro -p topol.top -o ions.tpr -maxwarn 1
gmx genion -s ions.tpr -o system_ions.gro -p topol.top -nname CL -nn 1
## Checking if minimization works with grompp
gmx grompp -f EM.mdp -c system_ions.gro -p topol.top -o em.tpr


