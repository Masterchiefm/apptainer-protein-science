Foundry provides tooling and infrastructure for using and training all classes of models for protein design, including design (RFD3), inverse folding (ProteinMPNN) and protein folding (RF3).

Foundry 为使用和训练各类蛋白质设计模型提供了工具和服务，包括设计模型（RFD3）、逆折叠模型（ProteinMPNN）以及蛋白质折叠模型（RF3）

[Foundry](https://github.com/RosettaCommons/foundry/)

--------

# How to build
download the *.def file then run the following:
```
sudo singularity build foundry.sif foundry.def
```

# How to run
After build the sif, run it with singularity or apptainer:

1. Run in Jupyter:
```
singularity run --nv -B workdir/:/foundry/workdir foundry.sif jupyter lab --app-dir=/foundry --allow-root
```
copy the auth key in the console,then you can open jupyter in your web browser and login.


2. Run your script
```
singularity run --nv -B workdir/:/workdir foundry.sif bash [your_script]
```
