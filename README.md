# Sorting-Algorithm
Sorting Algorithm for students who rank group projects

The sortingalgo.m is a script for Matlab.  It reads in an Excel Spreadsheet with a list of students and projects, and the ranking of which projects the students prefer. The script sorts the students into groups by optimizing based on student rankings --- the goal of this to maximize 'happiness'.  It outputs a spreadsheet file with a list of students for each project.

In order to run the script you will need Matlab and also the Gurobi Optimizer installed.  You will also a need a spreadsheet with students and projects and rankings --- there is a sample spreadsheet in this repository. 

Note that within the code there is a specific location that you must manually adjust --- it includes the names and paths of input/output files, as well as various parameters such as min/max groupsizes for projects.  You can also manually adjust the beginning import data script (suitable to your file's particular path and filename) or import data manually.
