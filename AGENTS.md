# 协作指引

- 修改 `schema/skin_schema.json`、`tools/skin-editor/schema.js` 或 `mod/scripts/skin_schema.lua` 时，务必通过 `python tools/build_skin_manifest.py` 重新生成同步文件及最新清单。
- 新增或调整 `mod/exported_skins/` 内的示例文件后，也需要运行上述脚本以保持 `skins_manifest.json` 正确。
- 更新皮肤编辑器功能（HTML/JS/CSS）时，请同步更新 README 中的使用说明，并确保新特性在无网络环境下仍可使用。
- `.isaacskin` 数据以 32×32 像素网格为准，缺失帧应通过 schema 中的 alias 自动补全；如需新增动作，请先调研并记录数据来源。
- `schema/skin_schema.json` 里的 `anm2` 映射需保持与原版 `001.000_player.anm2` 一致，并在更新后重新运行构建脚本保证 Lua/JS 端同步。
- 调整 `mod/scripts/character_select.lua`（角色选择面板）时，请同步更新 README 的“自定义皮肤入口操作指南”段落，说明最新的操作方式与快捷键。
