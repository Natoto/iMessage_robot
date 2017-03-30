# iMessage_robot
## 功能：
> 功能前提：`message.app`必须是在Mac上正在后台运行着的

* 当朋友给你发`iMessage`时，自动回复有意思的消息;
* 当前Mac可以执行`iMessage`信息中的`shell` 命令，当然这个有点危险，你可以过滤一些已知的危险命令，比如`rm`、`mv`...最好的方案就是把这个权限只给自己;
* 自己可以通过`iMessage`控制自己的Mac，比如发送`CloseScreen;`消息，当前的Mac会休眠；还有`LockScreen;`->Mac会锁屏;`ShutDown;`-> Mac关机; 当然，你自己也可以通过`AppleScript`添加自己想要的更多的功能。

## 使用步骤：

* 1，下载解压后，移动用户目录`～/`下，并把文件夹`iMessage_robot-master`重命名为`message`。
* 2，复制脚本：「`message.app` - 偏好设置 - 通用 - `AppleScript`处理程序 - 打开`Scripts`文件夹」，此时把目录`message`下文件`iMessage_robot.applescript`复制到刚才打开的`Scripts`文件夹下，并在 `AppleScript`处理程序 中选中`iMessage_robot.applescript `。
* 3，修改一下`iMessage_robot.applescript `中的`senderNumber contains "definemyself"` 把`definemyself`改成你自己的账号。
* 这样，你可以让朋友给你发iMessage测试一下，当然你可以自己给自己发iMessage了。

## 文章
这是我写的关于这个 ***自动回复机器人*** 的两篇文章，有兴趣的同学可以看看。

[让我的iPhone变成Mac的遥控器](https://wangdetong.github.io/2017/03/18/%E8%AE%A9%E6%88%91%E7%9A%84iPhone%E5%8F%98%E6%88%90Mac%E7%9A%84%E9%81%A5%E6%8E%A7%E5%99%A8/)<br/>
[AppleScript让iMessage更好玩](https://wangdetong.github.io/2017/03/20/AppleScript%E8%AE%A9iMessage%E6%9B%B4%E5%A5%BD%E7%8E%A9/)