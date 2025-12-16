# Apptainer/Singularity 蛋白质科学容器

[English Documentation](https://github.com/Masterchiefm/apptainer-protein-science/blob/main/README.md)

本仓库提供用于蛋白质科学工具的 **Apptainer/Singularity 定义文件**。  
Apptainer/Singularity 是一个专为 HPC 和科学计算设计的容器平台——**无需 root 权限**，非常适合共享集群环境。

---

## 🚀 快速开始

### 1. 安装 Apptainer/Singularity

- **Apptainer** (推荐): 按照官方 [安装指南](https://apptainer.org/docs/admin/main/installation.html#installation-on-linux) 进行安装。

```bash
sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt update
sudo apt install -y apptainer
```

- **SingularityCE**: 从 [发布页面](https://github.com/sylabs/singularity/releases) 下载 `.deb` 包并安装：

```bash
wget https://github.com/sylabs/singularity/releases/download/v4.3.5/singularity-ce_4.3.5-noble_amd64.deb
sudo apt install ./singularity-ce_4.3.5-noble_amd64.deb
rm singularity-ce_4.3.5-noble_amd64.deb
```

### 2. 构建容器镜像

克隆仓库并进入所需工具目录：

```bash
git clone https://github.com/Masterchiefm/apptainer-protein-science.git
cd apptainer-protein-science/LigandMPNN
```

构建 Singularity 镜像文件 (`.sif`)：

```bash
sudo singularity build ligandmpnn.sif ligandmpnn.def
```

> **注意：** `sudo` 仅在构建镜像时需要。运行容器**不需要** root 权限。

### 3. 运行容器

使用 `singularity run` 在容器内运行命令。以 LigandMPNN 为例：

```bash
singularity run \
  --nv \                          # 启用 NVIDIA GPU 支持
  -B outputs:/outputs \           # 将主机目录挂载到容器
  ligandmpnn.sif \
  python3 /app/LigandMPNN/run.py \
  --seed 114514 \
  --verbose 1 \
  --pdb_path "/app/LigandMPNN/inputs/1BC8.pdb" \
  --out_folder "/outputs/verbose"
```

---

## 📁 可用工具

每个子目录包含用于构建容器的定义文件 (`.def`)：

- **LigandMPNN**
- **BoltzGen**
- **Foundry(RFd,RF,LigandMPNN)**
- **BindCraft**

---

## 🔧 使用详情

### 挂载目录
使用 `-B /主机路径:/容器路径` 将主机目录挂载到容器内。支持多个 `-B` 参数。

### GPU 支持
添加 `--nv` 参数以在容器内使用 NVIDIA GPU。

### 运行自定义脚本
你可以在容器内执行任何命令：

```bash
singularity run -B /data:/data mytool.sif python3 /app/script.py
```

或者启动交互式 shell：

```bash
singularity shell mytool.sif
```

---

## ❓ 为什么选择 Apptainer/Singularity？

- **无需 root 权限** – 适用于多用户 HPC 环境，安全可靠
- **原生 HPC 集成** – 与调度器（SLURM、PBS）兼容
- **可重复性** – 封装软件栈和依赖项
- **高性能** – 与虚拟机相比，开销极小

---

## 📄 许可证

本仓库基于 [MIT 许可证](LICENSE) 提供。  
请检查各个工具的许可证以确保合规。

---

## 🤝 贡献

欢迎贡献！请提交 issue 或 pull request 来添加新的定义文件或改进现有文件。
