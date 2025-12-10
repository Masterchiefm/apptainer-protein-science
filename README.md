# About
[中文](https://github.com/Masterchiefm/apptainer-protein-science/blob/main/README_CN.md)


This repo provides def file for apptainer/singularity.

Apptainer/singularity is a container manager like docker. It DO NOT require root. It's the best choise for HPC plaform.

## Install
To install apptainer, please read the [Installing Apptainer](https://apptainer.org/docs/admin/main/installation.html#installation-on-linux)

To install singularity, download the deb file from [singularity release](https://github.com/sylabs/singularity/releases), then install it.

For example:
```
wget https://github.com/sylabs/singularity/releases/download/v4.3.5/singularity-ce_4.3.5-noble_amd64.deb
sudo apt install singularity-ce_4.3.5-noble_amd64.deb
rm -rf singularity-ce_4.3.5-noble_amd64.deb
```

## How to build sif image
Clone this repo and cd to the project file you need.
singularity use *.sif file as image. To build it, for example, run the following:

```
cd LigandMPNN
sudo singularity build ligandmpnn.sif ligandmpnn.def
```

Then you can see the ligandmpnn.sif on your local machine.

## How to run
You dont need sudo to run.

run script with ``singularity run --nv -B folder/on/host/:/folder/on/image -B -B folder2/on/host/:/folder2/on/image [bash_or_python3] [your_script]``

This is an example:
```
singularity run \
  --nv \
  -B outputs:/outputs \
  ligandmpnn.sif \
  python3 /app/LigandMPNN/run.py \
  --seed 111 \
  --verbose 1 \
  --pdb_path "/app/LigandMPNN/inputs/1BC8.pdb" \
  --out_folder "/outputs/verbose"
```
