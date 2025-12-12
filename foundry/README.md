Foundry provides tooling and infrastructure for using and training all classes of models for protein design, including design (RFD3), inverse folding (ProteinMPNN) and protein folding (RF3).

Foundry 为使用和训练各类蛋白质设计模型提供了工具和服务，包括设计模型（RFD3）、逆折叠模型（ProteinMPNN）以及蛋白质折叠模型（RF3）

For more info please read [Foundry](https://github.com/RosettaCommons/foundry/)

--------

# How to build
1. Install singularity first.
```
wget https://github.com/sylabs/singularity/releases/download/v4.3.5/singularity-ce_4.3.5-noble_amd64.deb
sudo apt install singularity-ce_4.3.5-noble_amd64.deb
rm -rf singularity-ce_4.3.5-noble_amd64.deb
```

2. download the *.def file then run the following:
```
sudo singularity build foundry.sif foundry.def
```
This script will download the checkpoints into the image

# How to run
After build the sif, run it with singularity or apptainer:

1. Run in Jupyter:
```
singularity run \
  --nv \
  --containall \
  -B workdir/:/foundry/workdir \
  foundry.sif \
  jupyter lab  \
  --allow-root \
  --ip=0.0.0.0 \
  --notebook-dir=/foundry
```
copy the auth key in the console,then you can open jupyter in your web browser and login.

After opening jupyter, you can find a example folder in the left pannel. There are some example notebooks.

Or you can open new terminal in jupyter and run your own script. Please note that all changes will **NOT** be saved, except changes in workdir you had bind.

2. Or you can run your script
```
singularity run --nv -B workdir/:/workdir  foundry.sif bash /workdir/your_script
```

# Design
For RFd3 binder design, please read the tutorial in model/rfd3. It can be found in the jupyter left panel.
Or you can read [here, De novo Design of Biomolecular Interactions with RFdiffusion3](https://github.com/RosettaCommons/foundry/tree/production/models/rfd3)

All commands can be run in foundry image.

# Test

## RFdiffusion3
```
mkdir rfd3_output
singularity run --nv \
  -B rfd3_output:/rfd3_output \
  foundry.sif \
  rfd3 design \
  out_dir=/rfd3_output \
  inputs=/foundry/models/rfd3/docs/demo.json \
  skip_existing=False \
  dump_trajectories=True \
  prevalidate_inputs=True
```
