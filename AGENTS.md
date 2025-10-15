# 协作指引

- 修改 `schema/skin_schema.json`、`tools/skin-editor/schema.js` 或 `mod/scripts/skin_schema.lua` 时，务必通过 `python tools/build_skin_manifest.py` 重新生成同步文件及最新清单。
- 新增或调整 `mod/exported_skins/` 内的示例文件后，也需要运行上述脚本以保持 `skins_manifest.json` 正确。
- 更新皮肤编辑器功能（HTML/JS/CSS）时，请同步更新 README 中的使用说明，并确保新特性在无网络环境下仍可使用。
- `.isaacskin` 数据以 32×32 像素网格为准，缺失帧应通过 schema 中的 alias 自动补全；如需新增动作，请先调研并记录数据来源。
