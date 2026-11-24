# 贡献量化数据

统计时间：2026-11-24。所有数字由 git 命令直接从仓库历史算出，可用 [`../scripts/collect-stats.ps1`](../scripts/collect-stats.ps1) 重跑复核。

## 1. 志愿时长网页（主仓库 `feature/zhourui-volunteer-web`）

| 指标 | 数值 |
|------|------|
| 提交数（`main..feature/zhourui-volunteer-web`，作者=本人） | 11 |
| 净改动 | 6 files changed, +590, −204 |

按文件的行级归属（`git blame -w --line-porcelain`）：

| 文件 | 总行 | 本人行 | 占比 |
|------|------|--------|------|
| `web/src/features/volunteer/VolunteerPanel.tsx` | 708 | 429 | 61% |
| `web/src/utils/feishuAuth.ts` | 59 | 59 | 100% |
| `docs/volunteer-web-deploy.md` | 49 | 49 | 100% |
| `backend/src/xclub/modules/volunteer/bot.py` | 600 | 11 | 2% |
| `backend/src/xclub/modules/volunteer/router.py` | 103 | 16 | 16% |

## 2. 报销网页（独立仓库 `xclub-reimbursement`）

| 指标 | 数值 |
|------|------|
| 提交数（作者=本人） | 7 |
| 文件改动次数 | 10 |
| 新增行 / 删除行 | +182 / −52 |

## 3. 口径说明（重要）

- **提交数占比不等于代码占比**。主仓库里队友存在一次性导入既有系统的大提交（单次 139 文件、25,949 行），按提交数统计会严重高估个人代码份额。
- 本文只给"本人提交的改动量"和"关键文件的行归属"，**不推导全项目百分比**。简历与面试表述也用功能口径（"独立完成志愿网页前端与飞书入口"），不说"我写了全项目百分之多少"。
- 行归属用 `blame -w`（忽略纯空白改动），避免格式化提交把归属搅乱。

## 4. 复核命令

```powershell
# 志愿分支提交清单
git -C "C:\大三上\宣怀\项目1\x-club-ai-feishu" log --format="%h | %ad | %s" --date=short "main..feature/zhourui-volunteer-web"

# 志愿分支净改动
git -C "C:\大三上\宣怀\项目1\x-club-ai-feishu" diff --shortstat "main...feature/zhourui-volunteer-web"

# 单文件行归属
git -C "C:\大三上\宣怀\项目1\x-club-ai-feishu" blame -w --line-porcelain -- "web/src/features/volunteer/VolunteerPanel.tsx"

# 报销仓库本人提交
git -C "C:\大三上\宣怀\项目1\xclub-reimbursement" log --author="周锐" --format="%h | %ad | %s" --date=short
```
