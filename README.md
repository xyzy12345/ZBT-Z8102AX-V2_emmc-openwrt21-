# ZBT-Z8102AX-V2 eMMC OpenWrt 21 自动构建

为 ZBT Z8102AX-V2 eMMC 改装版自动编译 OpenWrt 21 版本固件

## 项目说明

本项目使用 GitHub Actions 自动构建 ZBT Z8102AX-V2 eMMC 版本的 OpenWrt 21.02 固件。

## 目录结构

```
.
├── .github/workflows/
│   └── build-openwrt.yml       # GitHub Actions 构建工作流
├── config/
│   └── ZBT-Z8102AX-eMMC.config # OpenWrt 配置文件
├── device/
│   └── mt7981.mk               # 设备定义文件
├── dts/
│   └── ZBT-Z8102AX-eMMC.dts    # 设备树文件
└── README.md
```

## 使用方法

### 自动构建

1. **触发构建**：
   - 推送修改到 `main` 分支会自动触发构建
   - 修改 `config/`、`dts/` 或 `device/` 目录中的文件也会触发构建
   - 在 Actions 页面手动触发工作流

2. **查看进度**：
   - 访问仓库的 "Actions" 标签页
   - 选择最新的工作流运行查看构建进度

3. **下载固件**：
   - 构建成功后，在 "Releases" 页面下载固件
   - 或在 Actions 的 Artifacts 中下载

### 手动构建

如果需要手动编译，请参考以下步骤：

```bash
# 1. 安装依赖
sudo apt update
sudo apt install -y build-essential clang flex bison g++ gawk \
  gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
  python3-distutils rsync unzip zlib1g-dev file wget

# 2. 克隆 OpenWrt 源码
git clone https://git.openwrt.org/openwrt/openwrt.git -b openwrt-21.02
cd openwrt

# 3. 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 4. 复制配置文件
cp ../config/ZBT-Z8102AX-eMMC.config .config
cp ../dts/ZBT-Z8102AX-eMMC.dts target/linux/mediatek/dts/
cat ../device/mt7981.mk >> target/linux/mediatek/image/mt7981.mk

# 5. 配置
make defconfig

# 6. 下载依赖包
make download -j8

# 7. 编译
make -j$(nproc) V=s
```

## 固件刷写

编译完成的固件位于 `bin/targets/mediatek/mt7981/` 目录。

### 刷写方法

1. **Web 界面升级**（推荐）：
   - 登录现有 OpenWrt 管理界面
   - 进入 System -> Backup / Flash Firmware
   - 上传 sysupgrade.bin 固件文件
   - 点击 "Flash image" 并等待完成

2. **命令行升级**：
   ```bash
   scp openwrt-*-sysupgrade.bin root@192.168.1.1:/tmp/
   ssh root@192.168.1.1
   sysupgrade -v /tmp/openwrt-*-sysupgrade.bin
   ```

## 配置说明

- **DTS 文件**：`dts/ZBT-Z8102AX-eMMC.dts` - 包含设备硬件定义
- **Device 文件**：`device/mt7981.mk` - 设备定义，用于将设备添加到 OpenWrt 构建系统
- **Config 文件**：`config/ZBT-Z8102AX-eMMC.config` - OpenWrt 编译配置

## 硬件规格

- **SoC**: MediaTek MT7981B
- **内存**: 256MB
- **存储**: eMMC
- **网络**: 5x Gigabit 端口
- **无线**: 2.4GHz + 5GHz 802.11ax

## 许可证

遵循 OpenWrt 项目许可证（GPL v2）
