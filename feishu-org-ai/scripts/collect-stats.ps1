# 重新统计本人在两个仓库的提交量与关键文件行归属
# 用法：pwsh -File scripts\collect-stats.ps1
# 输出：stats\contribution-generated.md（可直接与 stats\contribution.md 对照）

param(
    [string]$MainRepo = "C:\大三上\宣怀\项目1\x-club-ai-feishu",
    [string]$ReimbRepo = "C:\大三上\宣怀\项目1\xclub-reimbursement",
    [string]$Branch = "feature/zhourui-volunteer-web",
    [string]$Author = "周锐"
)

$ErrorActionPreference = "Stop"

# 某些会话里 PATH 不完整，先恢复系统 + 用户 PATH
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    $env:PATH = ([Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User'))
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "找不到 git，请检查安装或手动把 git 目录加入 PATH"
}
foreach ($p in @($MainRepo, $ReimbRepo)) {
    if (-not (Test-Path -LiteralPath $p)) { throw "仓库路径不存在：$p" }
}

function Invoke-Git {
    param([string]$Repo, [string[]]$GitArgs)
    & git -C $Repo @GitArgs
    if ($LASTEXITCODE -ne 0) { throw "git 执行失败：git -C `"$Repo`" $($GitArgs -join ' ')" }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outFile = Join-Path (Split-Path -Parent $scriptRoot) "stats\contribution-generated.md"

# ---------- 1. 志愿分支 ----------
$logLines = @(Invoke-Git -Repo $MainRepo -GitArgs @("log", "--format=%h | %ad | %s", "--date=short", "--author=$Author", "main..$Branch"))
$commitCount = ($logLines | Where-Object { $_ -match '^\w{7} \|' }).Count
$shortstat = (Invoke-Git -Repo $MainRepo -GitArgs @("diff", "--shortstat", "main...$Branch")) -join ""

$files = @(
    "web/src/features/volunteer/VolunteerPanel.tsx",
    "web/src/utils/feishuAuth.ts",
    "docs/volunteer-web-deploy.md",
    "backend/src/xclub/modules/volunteer/bot.py",
    "backend/src/xclub/modules/volunteer/router.py"
)

$blameRows = foreach ($f in $files) {
    $authors = @((Invoke-Git -Repo $MainRepo -GitArgs @("blame", "-w", "--line-porcelain", "--", $f)) |
        Select-String -Pattern '^author ' | ForEach-Object { $_.Line.Substring(7) })
    [pscustomobject]@{
        File  = $f
        Total = $authors.Count
        Mine  = ($authors | Where-Object { $_ -eq $Author }).Count
    }
}

# ---------- 2. 报销仓库 ----------
$reimbLog = @(Invoke-Git -Repo $ReimbRepo -GitArgs @("log", "--author=$Author", "--format=%h | %ad | %s", "--date=short"))
$reimbCommits = ($reimbLog | Where-Object { $_ -match '^\w{7} \|' }).Count

$insertions = 0
$deletions = 0
$changedFiles = 0
$numstat = @(Invoke-Git -Repo $ReimbRepo -GitArgs @("log", "--author=$Author", "--numstat", "--format="))
foreach ($line in $numstat) {
    if ($line -match '^(\d+)\t(\d+)\t') {
        $insertions += [int]$Matches[1]
        $deletions += [int]$Matches[2]
        $changedFiles++
    }
    elseif ($line -match '^-\t-\t') {
        $changedFiles++
    }
}

# ---------- 3. 生成 Markdown ----------
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# 贡献数据（自动生成）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm')　作者：$Author")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 志愿时长网页（主仓库 ``$Branch``）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| 指标 | 数值 |")
[void]$sb.AppendLine("|------|------|")
[void]$sb.AppendLine("| 本人在该分支的提交数 | $commitCount |")
[void]$sb.AppendLine("| 净改动 | $shortstat |")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| 文件 | 总行 | 本人行 | 占比 |")
[void]$sb.AppendLine("|------|------|--------|------|")
foreach ($row in $blameRows) {
    $ratio = if ($row.Total -gt 0) { "{0:P0}" -f ($row.Mine / $row.Total) } else { "n/a" }
    [void]$sb.AppendLine("| ``$($row.File)`` | $($row.Total) | $($row.Mine) | $ratio |")
}
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 报销网页（``xclub-reimbursement``）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| 指标 | 数值 |")
[void]$sb.AppendLine("|------|------|")
[void]$sb.AppendLine("| 本人提交数 | $reimbCommits |")
[void]$sb.AppendLine("| 文件改动次数 | $changedFiles |")
[void]$sb.AppendLine("| 新增 / 删除 | +$insertions / -$deletions |")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 提交明细")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("### 志愿分支")
[void]$sb.AppendLine("")
foreach ($l in $logLines) { [void]$sb.AppendLine("- $l") }
[void]$sb.AppendLine("")
[void]$sb.AppendLine("### 报销仓库")
[void]$sb.AppendLine("")
foreach ($l in $reimbLog) { [void]$sb.AppendLine("- $l") }
[void]$sb.AppendLine("")
[void]$sb.AppendLine("> 口径：提交数与行归属分别统计，二者不可互相换算；不使用全项目百分比。")

$dir = Split-Path -Parent $outFile
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
[IO.File]::WriteAllText($outFile, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))

Write-Host "已生成：$outFile"
Write-Host "志愿提交 $commitCount 个；报销提交 $reimbCommits 个，+$insertions/-$deletions"
