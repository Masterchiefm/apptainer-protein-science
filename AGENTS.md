# AGENTS.md - Guidelines for Coding Agents

This document provides build commands, testing procedures, and code style guidelines for agentic coding agents working in this repository.

## Repository Overview

This repository provides Apptainer/Singularity definition files for protein science computational tools. Each subdirectory contains a `.def` file that builds a reproducible container environment.

**Available Tools:**
- LigandMPNN - protein-ligand complex design
- RFdiffusion - protein backbone generation and design
- BindCraft - protein binding interface design
- BoltzGen - generative protein modeling
- Foundry - integrated protein design pipeline

---

## Build Commands

### Build All Containers

Build all containers in parallel (recommended):
```bash
./build_all.sh -a
```

Build all containers sequentially:
```bash
./build_all.sh -A
```

### Build Single Container

```bash
./build_all.sh LigandMPNN
./build_all.sh RFdiffusion
./build_all.sh BindCraft
./build_all.sh BoltzGen
./build_all.sh Foundry
```

### Manual Build (Direct Singularity)

```bash
cd /home/chief/apptainer-protein-science
singularity build --fakeroot ligandmpnn.sif LigandMPNN/ligandmpnn.def
```

---

## Testing and Validation

### Verify Container Build

```bash
# Inspect container metadata
singularity inspect <container>.sif

# Check Python version
singularity exec <container>.sif python --version

# Check CUDA version (for GPU containers)
singularity exec <container>.sif nvcc --version

# Test container can import main package
singularity exec ligandmpnn.sif python -c "import ligandmpnn"
```

### Run Functional Tests

Test with example inputs (modify paths as needed):
```bash
# LigandMPNN test
singularity run --nv -B outputs:/outputs ligandmpnn.sif \
  python3 /app/LigandMPNN/run.py \
  --seed 114514 \
  --verbose 1 \
  --pdb_path "/app/LigandMPNN/inputs/1BC8.pdb" \
  --out_folder "/outputs/verbose"
```

### Monitor Build Progress

```bash
# Interactive menu
./monitor.sh

# Watch mode (auto-refresh)
./monitor.sh --watch

# Check specific container log
./monitor.sh --log-LigandMPNN
./monitor.sh --log-RFdiffusion
./monitor.sh --log-BindCraft
./monitor.sh --log-BoltzGen
./monitor.sh --log-Foundry

# View main build log
./monitor.sh --log
```

---

## Code Style Guidelines

### Definition File (.def) Structure

Singularity definition files follow this order:
1. **Bootstrap** - Use `Bootstrap: docker` with CUDA base images
2. **%post** - Installation and configuration (main section)
3. **%environment** - Environment variables for runtime
4. **%labels** - Metadata (Author, Version, Description)
5. **%help** - Usage instructions

#### Bootstrap Section
```bootstrap
Bootstrap: docker
From: nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04
```
- Use NVIDIA CUDA images with matching cuDNN
- Common versions: CUDA 11.1.1, 12.2.2, 12.4.1

#### %post Section

**Environment Variables (set early):**
```bash
export DEBIAN_FRONTEND=noninteractive
export TZ=Etc/UTC
export PIP_NO_CACHE_DIR=1
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export CUDA_HOME=/usr/local/cuda
```

**Install System Packages:**
```bash
apt-get update && apt-get install -y \
    git wget curl build-essential \
    python3.11 python3.11-dev python3.11-venv \
    && rm -rf /var/lib/apt/lists/*
```

**Python Installation:**
- Use Python 3.11 or 3.12 as specified
- Set as default with update-alternatives:
```bash
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
update-alternatives --set python3 /usr/bin/python3.11
```

**Package Managers:**
- **pip**: Configure Tsinghua mirrors for China:
```bash
pip3 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
```
- **conda**: For Miniforge/conda environments (RFdiffusion):
```bash
cat > /opt/miniforge/.condarc << EOF
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
EOF
```

**Clone and Install Tools:**
```bash
mkdir -p /app
cd /app
git clone https://github.com/owner/repo.git
cd repo
pip install -e .
```

**Download Models/Weights:**
- Place in appropriate directories (e.g., /app/models, /cache)
- Use wget with direct URLs
- Comment out large downloads if pre-downloaded

**Cleanup:**
```bash
python3 -m pip cache purge
apt-get clean
rm -rf /tmp/*
```

#### %environment Section
```bash
export PATH=/usr/local/bin:$PATH
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export PYTHONPATH=/app/tool:$PYTHONPATH
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
```

For conda environments:
```bash
export PATH="/opt/miniforge/bin:$PATH"
. /opt/miniforge/etc/profile.d/conda.sh
conda activate env_name
```

#### %runscript Section
Execute commands with conda environment activated:
```bash
. /opt/miniforge/etc/profile.d/conda.sh
conda activate env_name
exec "$@"
```

---

### Shell Script Guidelines

#### build_all.sh Pattern
- Use `set -e` for error handling
- Color variables: GREEN, YELLOW, RED, NC (No Color)
- Associative array for container definitions: `declare -A CONTAINERS`
- Functions for single and parallel builds
- Help section with usage examples

#### monitor.sh Pattern
- Color output functions
- Associative arrays for container metadata
- Functions: `check_processes`, `check_sif_files`, `show_log_summary`
- Interactive menu with clear/refresh loop
- Log file parsing for errors

#### Error Handling
- Check file existence before operations: `[ -f "${file}" ]`
- Validate commands before execution
- Provide clear error messages with RED color
- Exit on errors: `set -e`

#### Formatting
- Use 4-space indentation (not tabs)
- Use 2-space indentation in %post sections
- Variable names: UPPER_CASE for constants, lower_case for locals
- Quote variables: `"${VAR}"` to prevent word splitting

---

### Naming Conventions

**Container Names:**
- Directory: PascalCase (e.g., LigandMPNN)
- Definition file: lowercase with hyphens (e.g., ligandmpnn.def)
- SIF file: lowercase.sif (e.g., ligandmpnn.sif)

**File Paths:**
- Application directory: `/app`
- Cache directory: `/cache` (for model weights)
- Output directory: `/outputs` or user-specified

**Environment Variables:**
- Python: PYTHONPATH, LC_ALL, LANG
- CUDA: CUDA_HOME, PATH, LD_LIBRARY_PATH
- Package mirrors: PIP_INDEX_URL, conda channels

---

### Import and Installation Patterns

**Python Dependencies:**
```bash
# From requirements.txt
pip3 install -r requirements.txt

# From git repo
pip3 install -e .

# For conda environments
conda env create -f environment.yml
pip install -e .
```

**Model Weights:**
- Download in %post section with wget
- Store in /app/models or /cache
- Use direct URLs from official sources

---

### Common Patterns

**Timezone Setup:**
```bash
export TZ=Etc/UTC
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone
```

**Directory Creation:**
```bash
mkdir -p /app /cache /outputs
```

**Git Clone Pattern:**
```bash
git clone https://github.com/owner/repo.git /app
cd /app/repo
```

**Activation Scripts:**
For conda, use:
```bash
. /opt/miniforge/etc/profile.d/conda.sh
conda activate env_name
```

---

## Running Containers

### Basic Run Command
```bash
singularity run --nv <container>.sif <command>
```

### Bind Directories
```bash
# Single bind
singularity run -B /host/path:/container/path container.sif

# Multiple binds
singularity run -B /data:/data -B /cache:/cache container.sif
```

### GPU Support
Add `--nv` flag for NVIDIA GPU support.

### Interactive Shell
```bash
singularity shell container.sif
```

---

## Troubleshooting

**Build Failures:**
1. Check specific container log: `./monitor.sh --log-<ContainerName>`
2. Look for ERROR/Failed keywords in logs
3. Verify network connectivity (mirror availability)
4. Check disk space: `df -h`

**Runtime Issues:**
1. Verify SIF file integrity: `singularity inspect <container>.sif`
2. Check CUDA driver compatibility
3. Verify directory bindings with `-B`
4. Test in shell mode: `singularity shell <container>.sif`

**Cleanup Failed Builds:**
```bash
# Use monitor script
./monitor.sh  # Select option 4

# Or manually remove small/corrupted SIF files
find . -name "*.sif" -size -10k -delete
```

---

## Verification Checklist

Before marking a task complete:
- [ ] Container builds successfully without errors
- [ ] `singularity inspect` shows correct labels
- [ ] Python version matches specification
- [ ] CUDA/PyTorch can be imported (for GPU containers)
- [ ] Main tool package can be imported
- [ ] Test command runs without errors
- [ ] Output directories bind correctly
- [ ] GPU is accessible with `--nv` flag
