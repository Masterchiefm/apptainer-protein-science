Foundry provides tooling and infrastructure for using and training all classes of models for protein design, including design (RFD3), inverse folding (ProteinMPNN) and protein folding (RF3).  
Foundry 为使用和训练各类蛋白质设计模型提供了工具和服务，包括设计模型（RFD3）、逆折叠模型（ProteinMPNN）以及蛋白质折叠模型（RF3）。

For more info please read [Foundry](https://github.com/RosettaCommons/foundry/)  
更多信息请阅读 [Foundry](https://github.com/RosettaCommons/foundry/)

--------

# How to build / 如何构建
1. Install singularity first. / 首先安装 Singularity。
```
wget https://github.com/sylabs/singularity/releases/download/v4.3.5/singularity-ce_4.3.5-noble_amd64.deb
sudo apt install singularity-ce_4.3.5-noble_amd64.deb
rm -rf singularity-ce_4.3.5-noble_amd64.deb
```

2. download the *.def file then run the following: / 下载 *.def 文件，然后运行以下命令：
```
sudo singularity build foundry.sif foundry.def
```
This script will download the checkpoints into the image / 此脚本会将检查点下载到镜像中。

# How to run / 如何运行
After build the sif, run it with singularity or apptainer: / 构建 sif 文件后，使用 Singularity 或 Apptainer 运行它：

1. Run in Jupyter (**Recommed**): / 在 Jupyter 中运行（推荐）：
```
mkdir -p workdir
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
copy the URL and auth key in the console,then you can open jupyter in your web browser and login. / 复制控制台中的网址与认证密钥，然后即可在网页浏览器中打开 Jupyter 并登录。

After opening jupyter, you can find a example folder in the left pannel. There are some example notebooks. You can learn alot from all.ipynb/ 打开 Jupyter 后，你可以在左侧面板找到一个示例文件夹，其中包含一些示例笔记本。从all.ipynb中学习你所需要的内容。

Or you can open new terminal in jupyter and run your own script. Please note that all changes will **NOT** be saved, please save your work to workdir. / 或者，你可以在 Jupyter 中打开新终端并运行自己的脚本。请注意，所有更改将**不会**被保存，请将你的工作保存到 workdir 目录。

2. Or you can run your script / 或者，你可以运行自己的脚本：
```
singularity run --nv -B workdir/:/workdir  foundry.sif bash /workdir/your_script
```

# Design / 设计
For RFd3 binder design, please read the tutorial in model/rfd3. It can be found in the jupyter left panel. / 关于 RFd3 结合剂设计，请阅读 model/rfd3 中的教程。可以在 Jupyter 左侧面板中找到它。
Or you can read [here, De novo Design of Biomolecular Interactions with RFdiffusion3](https://github.com/RosettaCommons/foundry/tree/production/models/rfd3) / 或者你可以阅读[此处，使用 RFdiffusion3 进行生物分子相互作用的从头设计](https://github.com/RosettaCommons/foundry/tree/production/models/rfd3)

All commands can be run in foundry image. / 所有命令都可以在 Foundry 镜像中运行。

# Test / 测试

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
