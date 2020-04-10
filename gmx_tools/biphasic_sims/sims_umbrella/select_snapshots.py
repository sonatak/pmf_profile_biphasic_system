# Script to select configurations for umbrella sampling
file="pull_pullx.xvg"
f=open(file,"r")
lines=f.readlines()[16:]
time=[]
distance=[]
for line in lines:
    columns=" ".join(line.split())
    time.append(columns.split(" ")[0])
    distance.append(columns.split(" ")[1])
    #distance.append(distance_single)
count=0
i=0
time_selected=[]
dist_selected=[]
for i in range(1,len(time),100):
    dist_selected.append(float(distance[i])) #  distance in z axis
    time_selected.append(int(float(time[i])/10.)) # Divided by timesteep to write trajecorty 
    #time[i]=(float(time[i])/10.0) # Divided by timesteep to write trajecorty

#print(dist_selected)
#print((time_selected))

#Finding elements that satisfy criteria (dx=0.1nm=1Angstrom)
window_dist=[]
window_time=[]
dist=0.1
tresh=0.01
for element in dist_selected:
    if abs(element-dist) < tresh:
        dist=dist+0.1 #adding one angsrem
        window_dist.append(element)
        window_time.append(time_selected[count])
    count=count+1

print(window_time,window_dist, len(window_dist))
count=1
script=open("mv_gro.sh","w")
for element in window_time:
    file1="window"+str(count)+".sh"
    f=open(file1,"w")
    f.write('#!/bin/bash\n#!/bin/bash\n### Request number of GPUs \n#$ -pe shm_n 1\n### Home directory where the input files are located\nexport HOME_JOB_DIR=`pwd`\n### Previleges\n#$ -P grupoA\n#$ -q NVIDIA\n### System variables\necho "This job is running on " $HOSTNAME\necho "Parallel computing in $NSLOTS procs"\n#$ -cwd\nsource /opt/programs/VARS/loadvars.gromacs2018\n')
    f.write('\ngmx grompp -f npt_umbrella'+str(count)+'.mdp -c conf'+str(element)+'.gro -r conf'+str(element)+'.gro -p topol.top -n index.ndx -o npt'+str(count)+'.tpr' )
    f.write('\ngmx mdrun -deffnm npt'+str(count))

    f.write('\ngmx grompp -f md_umbrella'+str(count)+'.mdp -c npt'+str(count)+'.gro -t npt'+str(count)+'.cpt -r npt'+str(count)+'.gro -p topol.top -n index.ndx -o umbrella'+str(count)+'.tpr' )
    f.write('\ngmx mdrun -deffnm umbrella'+str(count))
    count=count+1
 
for element in window_time:
    script.write('mv conf'+str(element)+'.gro windows/.\n' )

