# ZBT Z8102AX-V2 eMMC OpenWrt 编译指南

## GitHub Actions 自动构建

### 工作流触发方式

1. **自动触发**：
   - 推送到 `main` 或 `master` 分支
   - 修改 `config/` 目录中的配置文件
   - 修改 `dts/` 目录中的设备树文件
   - 修改 `.github/workflows/build-openwrt.yml` 工作流文件

2. **手动触发**：
   - 访问仓库的 Actions 页面
   - 选择 "Build OpenWrt for ZBT Z8102AX-V2 eMMC" 工作流
   - 点击 "Run workflow" 按钮
   - 可选择启用 SSH 调试功能

### 构建流程

工作流会自动执行以下步骤：

1. **环境初始化**：
   - 清理磁盘空间
   - 安装必要的编译依赖
   - 设置时区为 Asia/Shanghai

2. **源码准备**：
   - 克隆 OpenWrt 21.02 官方源码
   - 更新并安装 feeds

3. **配置加载**：
   - 复制 DTS 文件到 `target/linux/mediatek/dts/`
   - 加载 `.config` 配置文件
   - 执行 `make defconfig`

4. **编译**：
   - 下载依赖包
   - 多线程编译固件
   - 如果失败，自动重试单线程编译

5. **发布**：
   - 整理编译产物
   - 上传固件到 Artifacts
   - 创建 Release 并上传固件

### 查看构建结果

#### 方式 1: GitHub Releases
1. 访问仓库的 "Releases" 页面
2. 找到最新的发布版本（格式：YYYY.MM.DD-HHMM）
3. 在 Assets 区域下载固件文件

#### 方式 2: GitHub Actions Artifacts
1. 访问仓库的 "Actions" 页面
2. 选择完成的工作流运行
3. 在 "Artifacts" 区域下载固件

### 固件文件说明

- `openwrt-mediatek-mt7981-*.bin` - 固件镜像
- `openwrt-mediatek-mt7981-*-sysupgrade.bin` - 系统升级固件（推荐）
- `sha256sums` - 校验和文件

## 配置文件说明

### DTS 文件 (dts/ZBT-Z8102AX-eMMC.dts)

设备树文件定义了硬件配置：

- **内存配置**：256MB RAM
- **GPIO 按键**：Reset、Mesh 按钮
- **LED 指示灯**：红、绿、蓝、4G 指示灯
- **GPIO 导出**：看门狗、4G 模块控制
- **存储**：eMMC 支持
- **网络**：5 个千兆以太网口
- **无线**：双频 WiFi (2.4GHz + 5GHz)
- **USB**：USB 3.0 支持

### Config 文件 (config/ZBT-Z8102AX-eMMC.config)

OpenWrt 编译配置，包含：

- **目标平台**：MediaTek MT7981
- **核心包**：基础系统、网络服务
- **驱动**：eMMC、WiFi、USB 等
- **应用程序**：LuCI、网络工具
- **语言包**：中文支持

## 自定义配置

### 修改 Config

1. 克隆仓库到本地
2. 编辑 `config/ZBT-Z8102AX-eMMC.config`
3. 添加或修改配置项：
   ```
   CONFIG_PACKAGE_<包名>=y
   ```
4. 提交并推送到 main 分支
5. GitHub Actions 自动开始构建

### 修改 DTS

1. 编辑 `dts/ZBT-Z8102AX-eMMC.dts`
2. 修改硬件定义（GPIO、LED、按钮等）
3. 提交并推送
4. 自动重新编译

### 使用 OpenWrt 配置工具

如果需要使用 `make menuconfig` 自定义配置：

```bash
# 1. 克隆 OpenWrt
git clone https://git.openwrt.org/openwrt/openwrt.git -b openwrt-21.02
cd openwrt

# 2. 初始化
./scripts/feeds update -a
./scripts/feeds install -a

# 3. 加载现有配置
cp ../config/ZBT-Z8102AX-eMMC.config .config
make defconfig

# 4. 打开配置界面
make menuconfig

# 5. 保存配置
cp .config ../config/ZBT-Z8102AX-eMMC.config
```

## 故障排除

### 构建失败

1. **查看日志**：
   - 在 Actions 页面点击失败的工作流
   - 查看具体失败的步骤和错误信息

2. **常见问题**：
   - 磁盘空间不足：工作流会自动清理
   - 网络下载失败：重新运行工作流
   - 编译错误：检查 config 配置是否有误

### SSH 调试

如果需要在构建过程中进行调试：

1. 手动触发工作流时选择 "ssh_debug = true"
2. 等待工作流执行到 SSH 步骤
3. 按照日志中的说明连接到构建环境
4. 手动执行命令进行调试

### 固件刷写失败

1. **检查固件完整性**：
   - 下载 `sha256sums` 文件
   - 验证固件文件的校验和

2. **使用正确的刷写方法**：
   - eMMC 版本需要特定的刷写流程
   - 参考设备说明文档

## 高级用法

### 添加自定义软件包

1. 在 config 文件中添加：
   ```
   CONFIG_PACKAGE_<your-package>=y
   ```

2. 如果包不在标准 feeds 中：
   - Fork 本仓库
   - 修改工作流添加自定义 feed
   - 在 "Update feeds" 步骤前添加：
     ```yaml
     - name: Add custom feeds
       run: |
         cd openwrt
         echo "src-git custom https://github.com/your/feed.git" >> feeds.conf.default
     ```

### 构建其他目标

如需为其他设备编译：

1. 修改 `config/` 目录中的配置文件
2. 修改或添加对应的 DTS 文件
3. 更新工作流中的环境变量

### 缓存优化

为加速构建，可以在工作流中添加缓存：

```yaml
- name: Cache
  uses: actions/cache@v3
  with:
    path: |
      openwrt/dl
      openwrt/staging_dir
    key: ${{ runner.os }}-openwrt-${{ hashFiles('config/*') }}
    restore-keys: |
      ${{ runner.os }}-openwrt-
```

## 参考资源

- [OpenWrt 官方文档](https://openwrt.org/docs/start)
- [MediaTek MT7981 支持](https://openwrt.org/toh/hwdata/mediatek/mediatek_mt7981)
- [设备树文档](https://www.kernel.org/doc/Documentation/devicetree/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)

## 技术支持

如有问题，请在仓库中创建 Issue，并提供：
- 详细的问题描述
- 相关的日志输出
- 构建环境信息
