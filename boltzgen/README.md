**重要说明：**

1. **下载模型部分已注释**：`boltzgen download all` 命令可能需要很长时间下载大量数据，并且需要大量磁盘空间。我已将其注释掉，您可以在构建完成后手动运行。权重文件默认路径为容器内的/cache，若构建模型时候未把这个取消注释，则务必把一个本地路径绑定到/cache以供程序写入。

2. **构建容器**：
   ```bash
   sudo singularity build boltzgen.sif boltzgen.def
   ```

3. **手动下载模型**（构建完成后）：
   ```bash
   singularity exec -B cache:/cache boltzgen.sif python3.11 -m boltzgen download all --cache /cache --force_download
   ```

4. **使用容器**：
   ```bash
   # 运行 boltzgen
   singularity run boltzgen.sif --help
   
   # 进入交互式 shell
   singularity shell boltzgen.sif
   ```
   
