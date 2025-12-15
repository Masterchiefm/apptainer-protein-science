# Apptainer/Singularity Containers for Protein Science

[中文文档](https://github.com/Masterchiefm/apptainer-protein-science/blob/main/README_CN.md)

This repository provides **Apptainer/Singularity definition files** for protein science tools.  
Apptainer/Singularity is a container platform designed for HPC and scientific computing—**no root privileges required**, making it ideal for shared cluster environments.

---

## 🚀 Quick Start

### 1. Install Apptainer/Singularity

- **Apptainer** (recommended): Follow the official [Installation Guide](https://apptainer.org/docs/admin/main/installation.html#installation-on-linux).

```bash
sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt update
sudo apt install -y apptainer
```

- **SingularityCE**: Download the `.deb` package from [releases](https://github.com/sylabs/singularity/releases) and install:

```bash
wget https://github.com/sylabs/singularity/releases/download/v4.3.5/singularity-ce_4.3.5-noble_amd64.deb
sudo apt install ./singularity-ce_4.3.5-noble_amd64.deb
rm singularity-ce_4.3.5-noble_amd64.deb
```

### 2. Build a Container Image

Clone the repository and navigate to the desired tool directory:

```bash
git clone https://github.com/Masterchiefm/apptainer-protein-science.git
cd apptainer-protein-science/LigandMPNN
```

Build the Singularity Image File (`.sif`):

```bash
sudo singularity build ligandmpnn.sif ligandmpnn.def
```

> **Note:** `sudo` is only required for building images. Running containers does **not** require root privileges.

### 3. Run the Container

Run commands inside the container with `singularity run`. Example for LigandMPNN:

```bash
singularity run \
  --nv \                          # Enable NVIDIA GPU support
  -B outputs:/outputs \           # Bind host directory to container
  ligandmpnn.sif \
  python3 /app/LigandMPNN/run.py \
  --seed 111 \
  --verbose 1 \
  --pdb_path "/app/LigandMPNN/inputs/1BC8.pdb" \
  --out_folder "/outputs/verbose"
```

---

## 📁 Available Tools

Each subdirectory contains a definition file (`.def`) for building a container:

- **LigandMPNN**
- **BoltzGen**
- **Foundry(RFd,RF,LigandMPNN)**
- **BindCraft**

---

## 🔧 Usage Details

### Binding Directories
Use `-B /host/path:/container/path` to mount host directories into the container. Multiple `-B` flags are supported.

### GPU Support
Add `--nv` to leverage NVIDIA GPUs inside the container.

### Running Custom Scripts
You can execute any command inside the container:

```bash
singularity run -B /data:/data mytool.sif python3 /app/script.py
```

Or start an interactive shell:

```bash
singularity shell mytool.sif
```

---

## ❓ Why Apptainer/Singularity?

- **No root required** – Safe for multi-user HPC environments
- **Native HPC integration** – Works with schedulers (SLURM, PBS)
- **Reproducibility** – Encapsulates software stacks and dependencies
- **Performance** – Minimal overhead compared to virtual machines

---

## 📄 License

This repository is provided under the [MIT License](LICENSE).  
Please check individual tool licenses for compliance.

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or pull request to add new definition files or improve existing ones.
