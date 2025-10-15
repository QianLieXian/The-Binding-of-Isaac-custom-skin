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

- **帧管理**：预置静止、移动、射击、受伤、使用道具、跳跃以及道具装扮等动作帧分类，每个帧都可独立绘制，并与游戏内角色的标准动画方向保持一致（顺序为下 → 右 → 上 → 左）。
- **绘制体验**：支持 Shift 直线填充、橡皮擦、背景开关、水平/垂直镜像等实用功能，可自建调色板。
- **导入导出**：以 `.isaacskin`（本质为 JSON）文件存储所有帧像素、调色板和元信息，可在网页工具中再次导入编辑，并携带 `formatVersion` 等元数据方便游戏侧进行兼容性校验。
- **实时预览**：右侧提供所有帧的小尺寸预览，方便检查整体效果。

导出后生成的 `.isaacskin` 文件可以直接放入仓库 `mod/exported_skins/` 目录下，供游戏内脚本解析与应用。后续可进一步开发 Lua/ XML 等游戏侧逻辑，读取这些文件并在自定义角色选项中显示与切换。

## 皮肤格式与清单

皮肤帧结构由根目录的 `schema/skin_schema.json` 统一定义，并通过脚本自动同步到：

- `tools/skin-editor/schema.js`（网页工具使用）；
- `mod/scripts/skin_schema.lua`（游戏 Mod 使用）。

在新增或修改 `.isaacskin` 文件后，请运行：

```bash
python tools/build_skin_manifest.py
```

该脚本会校验 `mod/exported_skins/` 目录下所有皮肤文件、刷新上述 schema 映射，并生成最新的 `mod/exported_skins/skins_manifest.json` 供游戏读取。若仅需校验而不想改写文件，可添加 `--check-only` 选项。

## Mod 运行机制

`mod/` 目录下包含完整的游戏端实现：

- `main.lua`：注册 Mod 并在游戏启动时自动扫描皮肤，提供 `skinlist`/`skinreload` 控制台命令用于调试。
- `scripts/json.lua`：轻量 JSON 解析器，负责读取 `.isaacskin` 与清单文件。
- `scripts/skin_manager.lua`：核心逻辑，校验帧完整性、缓存可用皮肤并对外暴露查询接口。
- `metadata.xml`：声明 Mod 元数据，方便在游戏内识别。

在游戏控制台执行 `skinlist` 可以快速确认皮肤是否被正确解析。

## 后续开发建议

1. **游戏内逻辑**：使用《以撒的结合》官方 Mod API（Lua）创建自定义角色入口，读取 `exported_skins` 内的文件，完成皮肤应用与原角色映射。
2. **资源转换**：根据游戏需要，将 `.isaacskin` 中的像素数据转换为游戏使用的 SpriteSheet 或动画格式。
3. **多人协作**：通过 Git 版本控制管理不同的皮肤设计，或为不同创作者建立专用文件夹。

欢迎根据需求扩展本项目，丰富以撒的自定义体验！
