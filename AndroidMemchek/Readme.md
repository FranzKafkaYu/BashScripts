# 使用说明

1.  使用该脚本前需保证无adb验证密码，且车机OS非user版本

2.  在保证adb正常可以使用的情况下，点击bat脚本run_memory_check.bat

3.  观察屏幕输出，提示”按任意键继续时表明执行完成“

4.  run_memory_check.bat执行完成后，可将adb模式切换为usb模式，进行常规测试

# 注意事项

1.  测试过程中如发现系统卡顿，可以执行pull_memory_log.bat拉出相关信息，请及时将拉取出的文件传递给相关方
