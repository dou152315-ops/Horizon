# Horizon GitHub 部署说明

这份说明是给本机部署用的。当前项目已经放在：

`G:\codex\Horizon`

## 已经帮你准备好的内容

1. 已下载 `Thysrael/Horizon` 项目源码。
2. 已安装 `uv` 和项目依赖。
3. 已把 `data/config.github.json` 调整成新手版：
   - 关闭 LWN 私有订阅，避免缺少 `LWN_KEY` 失败。
   - 关闭飞书 Webhook，避免缺少飞书机器人地址失败。
4. 已通过本地测试。

## 你还需要准备的东西

只需要先准备一个 DeepSeek API Key：

`DEEPSEEK_API_KEY`

没有这个 Key，Horizon 可以抓新闻，但不能让 AI 打分和生成摘要。

## 第一步：登录 GitHub

打开 PowerShell，运行：

```powershell
gh auth login
```

按提示操作：

1. 选择 `GitHub.com`
2. 选择 `HTTPS`
3. 选择用浏览器登录
4. 浏览器里确认授权

## 第二步：继续部署

GitHub 登录完成后，在 PowerShell 运行：

```powershell
cd G:\codex\Horizon
powershell -ExecutionPolicy Bypass -File .\scripts\deploy-github.ps1
```

脚本会做这些事：

1. fork 一份 Horizon 到你的 GitHub 账号下。
2. 把本地部署配置推送到你的 GitHub 仓库。
3. 提示你输入 `DEEPSEEK_API_KEY`，并保存到 GitHub Secrets。
4. 启用并手动运行每日新闻任务。

## 第三步：打开 GitHub Pages

第一次运行完 GitHub Actions 后，到你的 GitHub 仓库页面：

`Settings` -> `Pages`

选择：

- Source: `Deploy from a branch`
- Branch: `gh-pages`
- Folder: `/`

保存后，网页地址通常是：

`https://你的GitHub用户名.github.io/Horizon/`

## 以后怎么用

GitHub Actions 会每天北京时间 08:00 自动运行一次。

如果想手动更新：

1. 打开你的 GitHub 仓库。
2. 点 `Actions`。
3. 点 `Daily Horizon Summary`。
4. 点 `Run workflow`。
