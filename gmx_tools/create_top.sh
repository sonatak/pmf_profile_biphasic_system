#!/bin/bash
read -p "Enter molecule name  "  MOL
PS3="Please, select a number and press enter "
select options in antechamber tleap ambgro exit
do
 case $options in
 antechamber)
 antechamber -i $MOL.gesp -fi gesp -o $MOL.prepc -fo prepc -c resp -eq 2 -at gaff2 -nc 0 -s 2
 parmchk2 -i $MOL.prepc -o $MOL.frcmod -f prepc -a Y -s 2
 echo "Antechamber is done. Please check the charges in .prepc file"
rm ANTECHAMBER*
;;

 tleap)
echo "source leaprc.gaff2" > leap.in
echo "source leaprc.protein.ff14SB" >> leap.in
echo "loadamberparams $MOL.frcmod" >> leap.in
echo "loadamberprep $MOL.prepc" >> leap.in
echo "loadamberparams frcmod.ionsjc_tip3p" >> leap.in
#echo "$MOL = loadmol2 $MOL.mol2" >> leap.in # mol2 file generated after optimization from chk file
echo "$MOL = loadpdb NEWPDB.PDB" >> leap.in # pdb generated by antechamber
echo "savepdb $MOL $MOL.pdb" >> leap.in
#echo "$MOL = loadpdb $MOL.pdb" >> leap.in # Original line
echo "saveamberparm $MOL $MOL.prmtop $MOL.inpcrd " >> leap.in
echo "quit" >> leap.in
tleap -f leap.in
;; 
 ambgro)
echo "import parmed as pmd" > ambgro.in
echo "parm = pmd.load_file('$MOL.prmtop', '$MOL.inpcrd')" >> ambgro.in
echo "parm.save('$MOL.top', format='gromacs')" >> ambgro.in
echo "parm.save('$MOL.gro')" >> ambgro.in
amber.python ambgro.in
echo "....Gromacs topology created."
 ;;
 exit)
break
;;
*) " Please select a correct number"
;;
esac
done
