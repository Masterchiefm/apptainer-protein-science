# 关于
本仓库提供 Apptainer/Singularity 的 def 文件。

Apptainer/Singularity 是一个类似 Docker 的容器管理器。它**不需要 root 权限**，是 HPC（高性能计算）平台上的最佳选择。

## 安装
要安装 Apptainer，请阅读 [Installing Apptainer](https://apptainer.org/docs/admin/main/installation.html#installation-on-linux)（英文官方文档）。

要安装 Singularity，请从 [singularity release](https://github.com/sylabs/singularity/releases) 下载 deb 文件，然后进行安装。

例如：
```
wget https://github.com/sylabs/singularity/releases/download/v4.3.5/singularity-ce_4.3.5-noble_amd64.deb
sudo apt install singularity-ce_4.3.5-noble_amd64.deb
rm -rf singularity-ce_4.3.5-noble_amd64.deb
```

## 如何构建 sif 镜像
克隆此仓库并进入你需要的项目目录。
Singularity 使用 *.sif 文件作为镜像。要构建它，例如，运行以下命令：

```
cd LigandMPNN
sudo singularity build ligandmpnn.sif ligandmpnn.def
```

然后你可以在本地机器上看到 ligandmpnn.sif 文件。

## 如何运行
运行**不需要** sudo 权限。

使用以下格式运行脚本：  
`singularity run --nv -B 宿主机上的文件夹:/镜像内的文件夹 -B 宿主机上的文件夹2:/镜像内的文件夹2 [bash或python3] [你的脚本]`

这是一个示例：
```
singularity run \
  --nv \
  -B outputs:/outputs \
  ligandmpnn.sif \
  python3 /app/LigandMPNN/run.py \
  --seed 111 \
  --verbose 0 \
  --pdb_path "/app/LigandMPNN/inputs/1BC8.pdb" \
  --out_folder "/outputs/verbose"
```
