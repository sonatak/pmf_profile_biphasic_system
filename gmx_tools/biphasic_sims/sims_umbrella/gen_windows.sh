#!/bin/bash
echo 0 | gmx trjconv -s pull.tpr -f pull.xtc -o conf.gro -sep

