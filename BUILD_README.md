# Apptainer/Singularity 容器构建说明

本文档说明如何构建和使用 apptainer-protein-science 仓库中的容器。

## 已启动的构建

所有5个容器正在后台并行构建中：

- **LigandMPNN** (CUDA 12.2.2, Python 3.11)
- **RFdiffusion** (CUDA 11.1.1, Miniforge/conda)
- **BindCraft** (CUDA 12.4.1, Pyenv/Miniforge)
- **BoltzGen** (CUDA 12.2.2, Python 3.11)
- **Foundry** (CUDA 12.2.2, Python 3.12)

## 监控构建进度

### 实时监控
```bash
cd /home/chief/apptainer-protein-science
./monitor.sh --watch
```

### 交互式监控
```bash
cd /home/chief/apptainer-protein-science
./monitor.sh
```

交互式菜单提供以下选项：
1. 实时监控（自动刷新）
2. 查看主构建日志
3. 查看特定容器日志
4. 清理失败的构建
5. 重试失败的构建
6. 退出

### 查看特定容器的完整日志
```bash
./monitor.sh --log-LigandMPNN
./monitor.sh --log-RFdiffusion
./monitor.sh --log-BindCraft
./monitor.sh --log-BoltzGen
./monitor.sh --log-Foundry
```

### 查看主构建日志
```bash
tail -f build_all.log
```

## 手动重新构建

### 构建单个容器
```bash
cd /home/chief/apptainer-protein-science
./build_all.sh LigandMPNN
./build_all.sh RFdiffusion
./build_all.sh BindCraft
./build_all.sh BoltzGen
./build_all.sh Foundry
```

### 顺序构建所有容器
```bash
./build_all.sh -A
```

### 并行构建所有容器
```bash
./build_all.sh -a
```

## 容器位置

构建完成后，容器文件将位于：
- `/home/chief/apptainer-protein-science/ligandmpnn.sif`
- `/home/chief/apptainer-protein-science/rfdiffusion.sif`
- `/home/chief/apptainer-protein-science/bindcraft.sif`
- `/home/chief/apptainer-protein-science/boltzgen.sif`
- `/home/chief/apptainer-protein-science/foundry.sif`

## 使用容器

### LigandMPNN
```bash
singularity run --nv -B outputs:/outputs ligandmpnn.sif \
  python3 /app/LigandMPNN/run.py \
  --seed 114514 \
  --verbose 1 \
  --pdb_path "/app/LigandMPNN/inputs/1BC8.pdb" \
  --out_folder "/outputs/verbose"
```

### RFdiffusion
```bash
singularity run --nv rfdiffusion.sif python script.py
```

### BindCraft
```bash
singularity run --nv bindcraft.sif python script.py
```

### BoltzGen
```bash
singularity run --nv boltzgen.sif boltzgen generate ...
```

### Foundry
```bash
singularity run --nv foundry.sif python script.py
```

### 交互式shell
```bash
singularity shell <container>.sif
```

### 绑定目录
使用 `-B` 参数绑定主机目录到容器：
```bash
singularity run -B /host/path:/container/path container.sif
```

### GPU支持
添加 `--nv` 参数使用NVIDIA GPU：
```bash
singularity run --nv container.sif
```

## 常见问题

### 构建需要多长时间？
构建时间取决于：
- 网络速度（下载基础镜像和依赖）
- 磁盘I/O速度
- CPU性能

预计每个容器需要 20-60 分钟，并行构建可以节省时间。

### 构建失败怎么办？
1. 查看构建日志：
   ```bash
   ./monitor.sh --log-<容器名>
   ```
2. 清理失败的构建：
   ```bash
   ./monitor.sh
   # 选择选项 4
   ```
3. 重试构建：
   ```bash
   ./monitor.sh
   # 选择选项 5
   # 或手动运行：./build_all.sh <容器名>
   ```

### 查看构建进程
```bash
ps aux | grep singularity
```

### 停止构建
如果需要停止所有构建：
```bash
pkill -f "singularity build"
```

停止特定容器构建：
```bash
ps aux | grep singularity
kill <PID>
```

### 磁盘空间
构建需要大量磁盘空间：
- 每个容器可能 2-5 GB
- 建议至少有 30-50 GB 可用空间

检查磁盘空间：
```bash
df -h
```

## 日志文件

- 主构建日志：`/home/chief/apptainer-protein-science/build_all.log`
- 各容器日志：`/home/chief/apptainer-protein-science/build_logs/<容器名>.log`

## 验证容器

构建完成后，验证容器：
```bash
singularity inspect <container>.sif
singularity exec <container>.sif python --version
singularity exec <container>.sif nvcc --version  # 对于CUDA容器
```

## 获取帮助

查看容器内置帮助：
```bash
singularity run --help <container>.sif
```

查看容器标签和帮助信息：
```bash
singularity inspect --labels <container>.sif
singularity inspect --helpfile <container>.sif
```
