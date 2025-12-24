# Foundry

Foundry 为蛋白质设计的全流程提供了完整的工具链与基础设施，支持多种核心模型的训练与应用，涵盖**蛋白质设计（RFD3）**、**逆折叠（ProteinMPNN）** 与**蛋白质折叠（RF3）** 等关键任务。  
Foundry provides comprehensive tooling and infrastructure for the entire protein design workflow, supporting training and application of core models including **design (RFD3)**, **inverse folding (ProteinMPNN)**, and **protein folding (RF3)**.

了解更多信息，请访问项目主页，此处仅为我自己创建的singularity def文件：  
For more information, please visit the project homepage. This Repo is created for record my def file:  
**[Foundry](https://github.com/RosettaCommons/foundry/)**

---

## 🛠️ 构建指南 / How to Build

### 1. 安装 Singularity / Install Singularity
```bash
wget https://github.com/sylabs/singularity/releases/download/v4.3.5/singularity-ce_4.3.5-noble_amd64.deb
sudo apt install singularity-ce_4.3.5-noble_amd64.deb
rm -rf singularity-ce_4.3.5-noble_amd64.deb
```

### 2. 构建镜像 / Build the Image
下载 `foundry.def` 文件后，执行以下命令：  
After downloading the `foundry.def` file, run:
```bash
sudo singularity build foundry.sif foundry.def
```
> 该脚本会自动将模型检查点下载至镜像内。  
> This script will automatically download model checkpoints into the image.

---

## 🚀 运行方式 / How to Run

构建完成后，可通过 Singularity 或 Apptainer 运行镜像。

### 1. 在 Jupyter Lab 中运行（推荐） / Run in Jupyter Lab (Recommended)
```bash
mkdir -p workdir
singularity run \
  --nv \
  --containall \
  -B workdir/:/foundry/workdir \
  foundry.sif \
  jupyter lab \
  --allow-root \
  --ip=0.0.0.0 \
  --notebook-dir=/foundry
```
运行后，控制台将输出访问 URL 及认证密钥。复制并粘贴至浏览器即可登录 Jupyter Lab。  
After running, copy the URL and authentication key from the console to access Jupyter Lab in your browser.

**使用提示 / Tips:**
- 左侧文件浏览器中可找到 `example` 文件夹，内含多个示例 Notebook（如 `all.ipynb`），供快速上手。  
  An `example` folder is available in the file browser, containing sample notebooks (e.g., `all.ipynb`) for getting started.
- 可在 Jupyter 中新建终端运行自定义脚本。  
  You can open a new terminal in Jupyter to run your own scripts.
- **请注意：容器内的修改不会被持久保存，请务必将工作文件保存至 `workdir` 目录。**  
  **Note: Changes inside the container are not persisted. Please save your work to the `workdir` directory.**

### 2. 直接运行脚本 / Run Scripts Directly
```bash
singularity run --nv -B workdir/:/workdir foundry.sif bash /workdir/your_script
```

---

## 🧬 蛋白质设计 / Protein Design

### RFdiffusion3（RFD3）结合剂设计
详细教程位于 Jupyter Lab 左侧面板的 `models/rfd3` 目录中。  
A detailed tutorial is available in the `models/rfd3` directory within Jupyter Lab.

也可在线查阅文档：  
You can also read the documentation online:  
**[De novo Design of Biomolecular Interactions with RFdiffusion3](https://github.com/RosettaCommons/foundry/tree/production/models/rfd3)**

> 所有设计相关命令均可在 Foundry 镜像中直接执行。  
> All design commands can be run directly within the Foundry image.

---

## ✅ 测试示例 / Test Examples

### RFdiffusion3 测试运行
```bash
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

---

## 📁 目录说明 / Directory Structure
```
workdir/          # 用户工作目录，用于保存持久化文件
rfd3_output/      # RFdiffusion3 输出目录
foundry.sif       # 构建的 Singularity 镜像
```

---

## 🔗 相关资源 / Resources
- [Foundry GitHub](https://github.com/RosettaCommons/foundry/)
- [RFdiffusion3 文档](https://github.com/RosettaCommons/foundry/tree/production/models/rfd3)
- [Singularity 安装指南](https://docs.sylabs.io/guides/latest/user-guide/installation.html)

---

## 📄 许可证 / License
本项目基于 RosettaCommons 开源协议。  
This project is licensed under the RosettaCommons open-source license.

---
*如有问题或建议，欢迎在 GitHub 提交 Issue 或参与讨论。  
For questions or suggestions, please submit an Issue or join the discussion on GitHub.*
