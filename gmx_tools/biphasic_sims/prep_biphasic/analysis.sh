#!/bin/bash

gmx energy -f prod.edr -s prod.tpr -o density.xvg

echo 0 | gmx trjconv -s prod.tpr -f prod.xtc -o prod_noPBC.xtc -pbc mol -ur compact
echo 2 | gmx sasa -f prod_noPBC.xtc -s prod.tpr -o SASA_area.xvg -or SASA_resarea.xvg -oa SASA_atomarea.xvg -tv SASA_volume.xvg -probe 0.14 -b 5000 -e 10000
echo 2 | gmx sasa -f prod_noPBC.xtc -s prod.tpr -o SA_area.xvg -or SA_resarea.xvg -oa SA_atomarea.xvg -tv SA_volume.xvg -probe 0.00 -b 5000 -e 10000

sed '1,25d' SASA_volume.xvg > temp_SASA_volume.xvg
sed '1,25d' SA_volume.xvg > temp_SA_volume.xvg
awk '{for(i=1;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2}} END {for (i=1;i<=NF;i++) {printf "%f %f \n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR)}}' temp_SASA_volume.xvg >> aver-std_SASAVol.dat
awk '{for(i=1;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2}} END {for (i=1;i<=NF;i++) {printf "%f %f \n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR)}}' temp_SA_volume.xvg >> aver-std_SAVol.dat
python std.py
