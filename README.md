# 以撒的结合自定义皮肤 Mod 项目

本仓库用于制作一个可以在《以撒的结合》中导入自定义皮肤的 Mod。目标是让玩家在角色选择界面中选择一个“自定义角色”入口，然后挑选自己导入的皮肤，再指定实际使用的原版角色（例如以撒、伊甸或犹大等），进入游戏时即可套用自定义外观，同时保持所选原角色的内核与能力。

## 仓库结构

```
.
├── mod/
│   └── exported_skins/      # 放置在网页工具中导出的 .isaacskin 整合文件
└── tools/
    └── skin-editor/         # 自定义皮肤网页工具
        ├── index.html
        ├── script.js
        └── styles.css
```

- `mod/exported_skins/`：为游戏内自定义角色读取皮肤资源预留的目录，可将网页工具导出的 `.isaacskin` 文件放在此处进行测试或随 Mod 一同分发。
- `tools/skin-editor/`：一个独立的 HTML 页面，可以直接在浏览器打开，用于像素风格的皮肤绘制、导入与导出。

## 网页皮肤工作室

打开 `tools/skin-editor/index.html` 即可使用像素绘制工具，特点包括：

- **帧管理**：预置头部静止（每个朝向 2 帧）、身体行走（每个朝向 10 帧）以及射击、受伤、使用道具、药丸动作、跳跃和装扮等分类，帧顺序与游戏 `player.anm2` 动画保持一致（方向顺序为下 → 右 → 上 → 左），并参考了社区维护的 [Isaac Costume Templates](https://github.com/ddeeddii/isaac-costume-templates) 中 `head.anm2`、`body.anm2` 的帧结构。
- **坐标象限**：画布新增中心坐标轴与四象限参考，可在工具栏勾选“显示象限参考”，并结合下方图例判断当前笔触位于 `(+X, -Y)`、`(-X, -Y)`、`(-X, +Y)` 还是 `(+X, +Y)`，以保持角色在 32×32 网格中的重心一致。
- **绘制体验**：支持 Shift 直线填充、橡皮擦、背景开关、水平/垂直镜像与“复制上一帧”等实用功能，可自建调色板并快捷批量调整多帧动画。
- **导入导出**：以 `.isaacskin`（本质为 JSON）文件存储所有帧像素、调色板和元信息，可在网页工具中再次导入编辑，并携带 `formatVersion` 等元数据方便游戏侧进行兼容性校验。
- **实时预览**：右侧提供所有帧的小尺寸预览，方便检查整体效果。

导出后生成的 `.isaacskin` 文件可以直接放入仓库 `mod/exported_skins/` 目录下，供游戏内脚本解析与应用。后续可进一步开发 Lua/ XML 等游戏侧逻辑，读取这些文件并在自定义角色选项中显示与切换。

## 皮肤格式与清单

皮肤帧结构由根目录的 `schema/skin_schema.json` 统一定义，并通过脚本自动同步到：

- `tools/skin-editor/schema.js`（网页工具使用）；
- `mod/scripts/skin_schema.lua`（游戏 Mod 使用）。
- `schema/skin_schema.json` 中的每个帧都带有 `anm2` 元数据，指向原版 `001.000_player.anm2` 中对应的动画与帧序（例如 `WalkDown` 0~9、`HeadRight_Overlay` 0~3），方便网页与 Lua 端在校验时引用统一的官方动画命名。[《IsaacDocs》对 `EntityPlayer` 的说明](https://github.com/wofsauge/IsaacDocs/blob/main/docs/EntityPlayer.md) 同样以这些动画名称为准，可作为进一步扩展 Mod 行为的参考。

为保证药丸操作相关的演出完整，`schema/skin_schema.json` 自 2025 年 10 月起新增 `pill` 分组，覆盖官方动画 `PillEatDown/Right/Up/Left` 的前三帧，以及成功与失败后的 `PillThumbsUp`、`PillThumbsDown` 与负面反应 `PillHoldHead`。网页工具与游戏脚本会同时读取这一分组，确保导入的 `.isaacskin` 在角色吞药、竖起大拇指或抱头难受时均能对应到正确的 `001.000_player.anm2` 帧。

在新增或修改 `.isaacskin` 文件后，请运行：

```bash
python tools/build_skin_manifest.py
python tools/build_skin_textures.py
```

上述脚本会校验 `mod/exported_skins/` 目录下所有皮肤文件、刷新 schema 映射，并生成最新的 `mod/exported_skins/skins_manifest.json`。随后 `build_skin_textures.py` 会根据 `schema/frame_layouts.json` 中的帧布局，把 `.isaacskin` 中的像素自动转换为 `mods/aaa_custom_skin_loader/gfx/custom_skins/<皮肤 ID>/` 下的 PNG 纹理，供游戏内的 `ReplaceSpritesheet` 调用。若仅需校验而不想改写文件，可为清单脚本添加 `--check-only` 选项。仓库附带的 `example_blank.isaacskin` 展示了完整字段和帧清单，可作为创作新皮肤的起点或验证工具链是否运行正常。

## Mod 运行机制

`mod/` 目录下包含完整的游戏端实现：

- `main.lua`：注册 Mod 并在游戏启动时自动扫描皮肤，提供 `skinlist`/`skinreload` 控制台命令用于调试，并在开局或命令热重载后为玩家替换皮肤纹理。
- `scripts/json.lua`：轻量 JSON 解析器，负责读取 `.isaacskin` 与清单文件。
- `scripts/skin_manager.lua`：核心逻辑，校验帧完整性、缓存可用皮肤并对外暴露查询接口。
- `scripts/character_select.lua`：在角色选择界面绘制“自定义皮肤入口”，处理 Tab 聚焦、皮肤与基础角色双层选单，并把结果写入存档。
- `scripts/skin_renderer.lua`：根据生成的 PNG 纹理替换玩家实体的 `ReplaceSpritesheet`，确保游戏内外观与导入皮肤一致。
- `scripts/base_characters.lua`：列出可选基础角色与对应的 `PlayerType`，便于 UI 与保存逻辑复用。
- `metadata.xml`：声明 Mod 元数据，方便在游戏内识别。

在游戏控制台执行 `skinlist` 可以快速确认皮肤是否被正确解析。

### 自定义皮肤入口操作指南

- 首次进入角色选择界面时，右侧的“自定义皮肤入口”会自动弹出皮肤列表，帮助快速确认功能是否生效；按下 <kbd>Tab</kbd> 或 <kbd>Esc</kbd> 即可关闭并返回原版角色网格。
- 在角色选择界面按下 <kbd>Tab</kbd> 可将焦点切换到右侧的“自定义皮肤入口”面板（标题前的 `◈` 图标便于辨识）；再次按 <kbd>Tab</kbd> 或 <kbd>Esc</kbd> 即可回到原版角色网格。
- 焦点处于面板时，使用上下方向键逐项浏览皮肤列表（左右键会以 10 帧为步长翻页）。按一次确认键进入“基础角色选择”子列表，继续使用上下方向键挑选最终希望操控的原版角色，再按确认键即应用皮肤与基础角色；按返回键可退回皮肤列表。若直接选择第一项“默认外观”，会立即还原原版外观并保留最近一次选择的基础角色。
- 面板底部实时显示当前套用的皮肤、作者与基础角色信息，所有选择结果都会写入存档并在下次进入角色选择界面时自动恢复，可配合 `skinreload` 命令热刷新列表。

## 后续开发建议

1. **游戏内逻辑**：使用《以撒的结合》官方 Mod API（Lua）创建自定义角色入口，读取 `exported_skins` 内的文件，完成皮肤应用与原角色映射。
2. **资源转换**：根据游戏需要，将 `.isaacskin` 中的像素数据转换为游戏使用的 SpriteSheet 或动画格式。
3. **多人协作**：通过 Git 版本控制管理不同的皮肤设计，或为不同创作者建立专用文件夹。

欢迎根据需求扩展本项目，丰富以撒的自定义体验！
