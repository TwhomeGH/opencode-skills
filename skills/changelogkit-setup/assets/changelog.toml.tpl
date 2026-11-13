# changelogkit 設定模板：變更歷史、主待辦與文件分組。
# 用法：複製到目標 repo 根目錄，替換 <...> 佔位符；既有檔案請合併，不要覆寫。
# 文件分組的路徑不得重疊，否則 docs --check 會回 ERROR。
[tool.changelog]
title    = "<專案名> 變更歷史"
project  = "<專案名>"
history  = "Docs/ChangeHistory.md"
todo     = "TODO.md"
# 排除 vendor／建置產物；依 references/vendor-noise.md 量測後調整。
exclude  = ["<vendor-dir>/**"]

# 專案文件分組（可選；沒有合適目錄就整段刪除）。
# paths 是 glob，必須互不重疊；改完跑 docs --check。
[[tool.changelog.docs.groups]]
id    = "guide"
title = "使用指南"
color = "green"
order = 10
paths = ["Docs/guide/**"]

[[tool.changelog.docs.groups]]
id    = "design"
title = "設計與限制"
color = "violet"
order = 20
paths = ["Docs/design/**", "Docs/architecture/**"]
