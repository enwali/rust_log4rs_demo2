# iOS集成Rust库配置指南

在M2芯片Mac上为iOS模拟器配置Rust库需要特别注意，本指南提供配置步骤。

## 必要步骤

1. 首先运行项目根目录下的脚本来构建Rust库：
```bash
./build_rust.sh
./setup_ios.sh
```

2. 在Xcode中打开iOS项目：
```bash
cd ios
open Runner.xcworkspace
```

3. 在Xcode中添加静态库文件：
   - 选择项目导航中的"Runner"项目
   - 选择"Build Phases"标签
   - 展开"Link Binary With Libraries"部分
   - 点击"+"按钮
   - 点击"Add Other..."，然后选择"Add Files..."
   - 导航到项目的`ios/libs`目录
   - 添加以下文件：
     - 对于模拟器：`librust_log4rs_demo2_simulator.a`
     - 对于真机：`librust_log4rs_demo2.a`
     - 或者通用库：`librust_log4rs_demo2_universal.a`

4. 添加头文件搜索路径：
   - 选择"Build Settings"标签
   - 搜索"Header Search Paths"
   - 添加`$(PROJECT_DIR)/libs`和`$(PROJECT_DIR)/Runner`路径

5. 确保"Bridging-Header"正确配置：
   - 搜索"Objective-C Bridging Header"
   - 设置为`Runner/Runner-Bridging-Header.h`

6. 添加链接器标志：
   - 搜索"Other Linker Flags"
   - 添加`-lc++`和`-lstdc++`

## 模拟器特殊配置

如果在模拟器上遇到函数符号未找到的问题（例如`init_logger: symbol not found`），尝试以下操作：

1. 确保在"Build Settings"中设置了正确的架构：
   - 对于模拟器：`arm64`和`x86_64`
   - 对于真机：`arm64`

2. 使用正确的库文件：
   - 对于M2芯片的模拟器，需要使用`librust_log4rs_demo2_simulator.a`
   - 确保在不同的运行配置中使用正确的库文件

3. 在"Build Phases"中添加"Run Script"阶段：
   - 点击"+"，选择"New Run Script Phase"
   - 添加以下脚本来检查当前使用的是哪个SDK：
```bash
echo "当前使用的SDK: $SDKROOT"
echo "目标架构: $ARCHS"
```

## 验证集成

配置完成后，启动应用程序。如果日志系统成功初始化，您应该能在Xcode控制台中看到Rust日志记录成功的消息，而不是符号查找失败的错误。 