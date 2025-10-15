(() => {
  const schema = window.ISAAC_SKIN_SCHEMA;
  if (!schema) {
    throw new Error("未找到皮肤帧定义，请确认 schema.js 是否正确加载。");
  }

  const GRID_SIZE = schema.gridSize;
  const CANVAS_SIZE = schema.canvasSize || 512;
  const PIXEL_SIZE = CANVAS_SIZE / GRID_SIZE;
  const FRAME_GROUPS = schema.groups || [];
  const FRAME_ALIAS_RULES = schema.aliases || [];
  const FRAME_IDS = FRAME_GROUPS.flatMap(group => group.frames.map(frame => frame.id));
  const FRAME_LABELS = {};
  FRAME_GROUPS.forEach(group => {
    group.frames.forEach(frame => {
      FRAME_LABELS[frame.id] = frame.label;
    });
  });

  const frameCanvas = document.getElementById("skinCanvas");
  const ctx = frameCanvas.getContext("2d");
  frameCanvas.width = CANVAS_SIZE;
  frameCanvas.height = CANVAS_SIZE;

  const colorPicker = document.getElementById("colorPicker");
  const bgColorPicker = document.getElementById("backgroundColor");
  const eraserToggle = document.getElementById("eraserToggle");
  const toggleGrid = document.getElementById("toggleGrid");
  const previewBackground = document.getElementById("previewBackground");
  const toggleQuadrants = document.getElementById("toggleQuadrants");

  const clearFrameBtn = document.getElementById("clearFrame");
  const mirrorHorizontalBtn = document.getElementById("mirrorHorizontal");
  const mirrorVerticalBtn = document.getElementById("mirrorVertical");
  const copyPreviousBtn = document.getElementById("copyPrevious");

  const frameListEl = document.getElementById("frameList");
  const paletteEl = document.getElementById("customPalette");
  const addPaletteColorBtn = document.getElementById("addPaletteColor");

  const exportBtn = document.getElementById("exportSkin");
  const importBtn = document.getElementById("importSkin");
  const importInput = document.getElementById("importInput");
  const exportStatus = document.getElementById("exportStatus");

  const previewGrid = document.getElementById("previewGrid");

  const skinNameInput = document.getElementById("skinName");
  const skinAuthorInput = document.getElementById("skinAuthor");
  const baseCharacterSelect = document.getElementById("baseCharacter");
  const skinNotesInput = document.getElementById("skinNotes");

  const frames = new Map();
  let currentFrameId = FRAME_IDS[0] || null;
  let isDrawing = false;
  let lastPixel = null;
  let lastDrawnPixel = null;

  function createEmptyFrame() {
    return Array.from({ length: GRID_SIZE }, () => Array(GRID_SIZE).fill(null));
  }

  function cloneFrameData(frameData) {
    return frameData.map(row => row.slice());
  }

  function normaliseImportedFrames(importedFrames) {
    const normalised = new Map();
    if (importedFrames && typeof importedFrames === "object") {
      Object.entries(importedFrames).forEach(([frameId, frameData]) => {
        if (Array.isArray(frameData)) {
          normalised.set(frameId, cloneFrameData(frameData));
        }
      });
    }

    FRAME_ALIAS_RULES.forEach(rule => {
      const sourceId = (rule.sources || []).find(candidate => normalised.has(candidate));
      if (!sourceId) return;
      const sourceFrame = normalised.get(sourceId);
      (rule.targets || []).forEach(targetId => {
        if (!normalised.has(targetId)) {
          normalised.set(targetId, cloneFrameData(sourceFrame));
        }
      });
      if (rule.removeSource !== false) {
        (rule.sources || []).forEach(candidate => normalised.delete(candidate));
      }
    });

    const ordered = new Map();
    FRAME_IDS.forEach(frameId => {
      if (normalised.has(frameId)) {
        ordered.set(frameId, normalised.get(frameId));
      }
    });
    return ordered;
  }

  function initFrames() {
    frames.clear();
    FRAME_GROUPS.forEach(group => {
      group.frames.forEach(frame => {
        frames.set(frame.id, createEmptyFrame());
      });
    });
  }

  function renderFrameList() {
    frameListEl.innerHTML = "";
    FRAME_GROUPS.forEach(group => {
      const wrapper = document.createElement("section");
      wrapper.className = "frame-group";

      const title = document.createElement("h3");
      title.className = "frame-group__title";
      title.textContent = group.title;
      wrapper.appendChild(title);

      const body = document.createElement("div");
      body.className = "frame-group__body";

      group.frames.forEach(frame => {
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "frame-button";
        btn.dataset.frameId = frame.id;
        btn.textContent = frame.label;
        if (frame.id === currentFrameId) {
          btn.classList.add("active");
        }
        btn.addEventListener("click", () => {
          setCurrentFrame(frame.id);
        });
        body.appendChild(btn);
      });

      wrapper.appendChild(body);
      frameListEl.appendChild(wrapper);
    });
  }

  function setCurrentFrame(frameId) {
    if (!frames.has(frameId)) return;
    currentFrameId = frameId;
    lastDrawnPixel = null;
    renderFrameList();
    drawCanvas();
  }

  function getCurrentFrame() {
    return frames.get(currentFrameId);
  }

  function getPixelFromEvent(event) {
    const rect = frameCanvas.getBoundingClientRect();
    const scaleX = frameCanvas.width / rect.width;
    const scaleY = frameCanvas.height / rect.height;
    const x = Math.floor((event.clientX - rect.left) * scaleX / PIXEL_SIZE);
    const y = Math.floor((event.clientY - rect.top) * scaleY / PIXEL_SIZE);
    if (x < 0 || y < 0 || x >= GRID_SIZE || y >= GRID_SIZE) {
      return null;
    }
    return { x, y };
  }

  function drawPixel(frameData, x, y, color) {
    if (!frameData || x < 0 || y < 0 || x >= GRID_SIZE || y >= GRID_SIZE) return;
    frameData[y][x] = color;
  }

  function drawLine(frameData, from, to, color) {
    const dx = Math.abs(to.x - from.x);
    const dy = Math.abs(to.y - from.y);
    const sx = from.x < to.x ? 1 : -1;
    const sy = from.y < to.y ? 1 : -1;
    let err = dx - dy;

    let x = from.x;
    let y = from.y;

    while (true) {
      drawPixel(frameData, x, y, color);
      if (x === to.x && y === to.y) break;
      const e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x += sx;
      }
      if (e2 < dx) {
        err += dx;
        y += sy;
      }
    }
  }

  function handlePointerDraw(event) {
    const pixel = getPixelFromEvent(event);
    if (!pixel) return;
    const frameData = getCurrentFrame();
    if (!frameData) {
      ctx.clearRect(0, 0, frameCanvas.width, frameCanvas.height);
      return;
    }
    const color = eraserToggle.checked ? null : colorPicker.value;

    if (event.shiftKey && lastDrawnPixel) {
      drawLine(frameData, lastDrawnPixel, pixel, color);
    } else {
      drawPixel(frameData, pixel.x, pixel.y, color);
    }

    lastDrawnPixel = pixel;
    drawCanvas();
    updatePreviewCell(currentFrameId);
  }

  frameCanvas.addEventListener("mousedown", event => {
    event.preventDefault();
    lastPixel = getPixelFromEvent(event);
    isDrawing = true;
    handlePointerDraw(event);
  });

  frameCanvas.addEventListener("mousemove", event => {
    if (!isDrawing) return;
    const pixel = getPixelFromEvent(event);
    if (!pixel || (lastPixel && pixel.x === lastPixel.x && pixel.y === lastPixel.y)) return;
    handlePointerDraw(event);
    lastPixel = pixel;
  });

  ["mouseup", "mouseleave", "mouseout"].forEach(evt => {
    frameCanvas.addEventListener(evt, () => {
      isDrawing = false;
      lastPixel = null;
    });
  });

  document.addEventListener("mouseup", () => {
    isDrawing = false;
    lastPixel = null;
  });

  function drawLabel(text, x, y, align = "left") {
    const padding = 4;
    ctx.save();
    ctx.font = "12px 'Segoe UI', 'Microsoft YaHei', sans-serif";
    ctx.textBaseline = "top";
    ctx.textAlign = align;
    const metrics = ctx.measureText(text);
    const width = (metrics.width || text.length * 7) + padding * 2;
    const height = ((metrics.actualBoundingBoxAscent || 8) + (metrics.actualBoundingBoxDescent || 3)) + padding * 2;
    let rectX = x;
    if (align === "center") {
      rectX -= width / 2;
    } else if (align === "right") {
      rectX -= width - padding;
    } else {
      rectX -= padding;
    }
    const rectY = y - padding;
    ctx.fillStyle = "rgba(10, 14, 24, 0.68)";
    ctx.fillRect(rectX, rectY, width, height);
    ctx.fillStyle = "rgba(255, 235, 160, 0.95)";
    ctx.fillText(text, x, y);
    ctx.restore();
  }

  function drawQuadrantOverlay() {
    if (!toggleQuadrants || !toggleQuadrants.checked) {
      return;
    }
    const half = GRID_SIZE / 2;
    const centerX = half * PIXEL_SIZE;
    const centerY = half * PIXEL_SIZE;

    ctx.save();
    ctx.strokeStyle = "rgba(255, 211, 92, 0.6)";
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    ctx.moveTo(centerX + 0.5, 0);
    ctx.lineTo(centerX + 0.5, GRID_SIZE * PIXEL_SIZE);
    ctx.moveTo(0, centerY + 0.5);
    ctx.lineTo(GRID_SIZE * PIXEL_SIZE, centerY + 0.5);
    ctx.stroke();
    ctx.restore();

    ctx.save();
    drawLabel("QⅠ (+X, -Y)", centerX + 14, centerY - 30, "left");
    drawLabel("QⅡ (-X, -Y)", centerX - 14, centerY - 30, "right");
    drawLabel("QⅢ (-X, +Y)", centerX - 14, centerY + 12, "right");
    drawLabel("QⅣ (+X, +Y)", centerX + 14, centerY + 12, "left");
    drawLabel("原点 (0, 0)", centerX + 14, centerY - 8, "left");
    ctx.restore();

    ctx.save();
    ctx.fillStyle = "rgba(255, 211, 92, 0.85)";
    ctx.beginPath();
    ctx.arc(centerX + 0.5, centerY + 0.5, 3, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  function drawCanvas() {
    const frameData = getCurrentFrame();
    ctx.clearRect(0, 0, frameCanvas.width, frameCanvas.height);

    if (previewBackground.checked) {
      ctx.fillStyle = bgColorPicker.value;
      ctx.fillRect(0, 0, frameCanvas.width, frameCanvas.height);
    } else {
      ctx.fillStyle = "rgba(0,0,0,0)";
      ctx.clearRect(0, 0, frameCanvas.width, frameCanvas.height);
    }

    for (let y = 0; y < GRID_SIZE; y++) {
      for (let x = 0; x < GRID_SIZE; x++) {
        const color = frameData[y][x];
        if (!color) continue;
        ctx.fillStyle = color;
        ctx.fillRect(x * PIXEL_SIZE, y * PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE);
      }
    }

    if (toggleGrid.checked) {
      ctx.strokeStyle = "rgba(255, 255, 255, 0.08)";
      ctx.lineWidth = 1;
      ctx.beginPath();
      for (let i = 0; i <= GRID_SIZE; i++) {
        ctx.moveTo(i * PIXEL_SIZE + 0.5, 0);
        ctx.lineTo(i * PIXEL_SIZE + 0.5, GRID_SIZE * PIXEL_SIZE);
        ctx.moveTo(0, i * PIXEL_SIZE + 0.5);
        ctx.lineTo(GRID_SIZE * PIXEL_SIZE, i * PIXEL_SIZE + 0.5);
      }
      ctx.stroke();
    }

    drawQuadrantOverlay();
  }

  function clearCurrentFrame() {
    if (!currentFrameId) return;
    frames.set(currentFrameId, createEmptyFrame());
    drawCanvas();
    updatePreviewCell(currentFrameId);
  }

  function mirrorFrame(horizontal = true) {
    const frameData = getCurrentFrame();
    if (!frameData) return;
    const mirrored = createEmptyFrame();

    for (let y = 0; y < GRID_SIZE; y++) {
      for (let x = 0; x < GRID_SIZE; x++) {
        const targetX = horizontal ? GRID_SIZE - 1 - x : x;
        const targetY = horizontal ? y : GRID_SIZE - 1 - y;
        mirrored[targetY][targetX] = frameData[y][x];
      }
    }

    frames.set(currentFrameId, mirrored);
    drawCanvas();
    updatePreviewCell(currentFrameId);
  }

  clearFrameBtn.addEventListener("click", clearCurrentFrame);
  mirrorHorizontalBtn.addEventListener("click", () => mirrorFrame(true));
  mirrorVerticalBtn.addEventListener("click", () => mirrorFrame(false));

  [colorPicker, bgColorPicker, toggleGrid, previewBackground, toggleQuadrants].forEach(input => {
    if (!input) return;
    input.addEventListener("input", () => {
      drawCanvas();
      updatePreviewCell(currentFrameId);
    });
  });

  addPaletteColorBtn.addEventListener("click", () => {
    const color = colorPicker.value;
    const btn = document.createElement("button");
    btn.style.background = color;
    btn.title = color;
    btn.addEventListener("click", () => {
      colorPicker.value = color;
      eraserToggle.checked = false;
    });
    paletteEl.appendChild(btn);
  });

  copyPreviousBtn.addEventListener("click", () => {
    const index = FRAME_IDS.indexOf(currentFrameId);
    if (index <= 0) {
      showStatus("当前帧没有可复制的上一帧。", "error");
      return;
    }
    const sourceId = FRAME_IDS[index - 1];
    const sourceFrame = frames.get(sourceId);
    if (!sourceFrame) {
      showStatus("上一帧为空，已保持当前帧不变。", "info");
      return;
    }
    frames.set(currentFrameId, cloneFrameData(sourceFrame));
    drawCanvas();
    updatePreviewCell(currentFrameId);
    const label = FRAME_LABELS[sourceId] || sourceId;
    showStatus(`已从 ${label} 复制像素数据。`, "success");
  });

  function buildPreviewGrid() {
    previewGrid.innerHTML = "";
    FRAME_GROUPS.forEach(group => {
      group.frames.forEach(frame => {
        const cell = document.createElement("div");
        cell.className = "preview-cell";

        const canvas = document.createElement("canvas");
        canvas.width = GRID_SIZE;
        canvas.height = GRID_SIZE;
        canvas.dataset.frameId = frame.id;
        const label = document.createElement("span");
        label.textContent = frame.label;

        cell.appendChild(canvas);
        cell.appendChild(label);
        previewGrid.appendChild(cell);
      });
    });
  }

  function updatePreviewCell(frameId) {
    const canvas = previewGrid.querySelector(`canvas[data-frame-id="${frameId}"]`);
    if (!canvas) return;
    const context = canvas.getContext("2d");
    const frameData = frames.get(frameId);
    if (!frameData) {
      context.clearRect(0, 0, canvas.width, canvas.height);
      return;
    }
    context.clearRect(0, 0, canvas.width, canvas.height);
    for (let y = 0; y < GRID_SIZE; y++) {
      for (let x = 0; x < GRID_SIZE; x++) {
        const color = frameData[y][x];
        if (!color) continue;
        context.fillStyle = color;
        context.fillRect(x, y, 1, 1);
      }
    }
  }

  function updateAllPreviews() {
    FRAME_GROUPS.forEach(group => {
      group.frames.forEach(frame => updatePreviewCell(frame.id));
    });
  }

  function buildExportPayload() {
    const framesObject = {};
    FRAME_IDS.forEach(frameId => {
      const frameData = frames.get(frameId) || createEmptyFrame();
      framesObject[frameId] = cloneFrameData(frameData);
    });

    return {
      formatVersion: schema.formatVersion,
      meta: {
        name: skinNameInput.value || "未命名皮肤",
        author: skinAuthorInput.value || "匿名",
        baseCharacter: baseCharacterSelect.value,
        notes: skinNotesInput.value,
        createdAt: new Date().toISOString(),
        gridSize: GRID_SIZE
      },
      frames: framesObject,
      colors: {
        palette: Array.from(paletteEl.querySelectorAll("button")).map(btn => btn.title),
        background: bgColorPicker.value
      },
      gridSize: GRID_SIZE
    };
  }

  function downloadSkin(payload) {
    const json = JSON.stringify(payload, null, 2);
    const blob = new Blob([json], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");

    const safeName = (payload.meta.name || "custom-skin")
      .replace(/[^a-zA-Z0-9\u4e00-\u9fa5_-]+/g, "-")
      .slice(0, 40) || "custom-skin";

    anchor.href = url;
    anchor.download = `${safeName}.isaacskin`;
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
    URL.revokeObjectURL(url);
  }

  function showStatus(message, type = "info") {
    exportStatus.textContent = message;
    exportStatus.dataset.type = type;
  }

  exportBtn.addEventListener("click", () => {
    try {
      const payload = buildExportPayload();
      downloadSkin(payload);
      showStatus(`已导出：${payload.meta.name}.isaacskin`, "success");
    } catch (error) {
      console.error(error);
      showStatus("导出失败，请查看控制台信息。", "error");
    }
  });

  importBtn.addEventListener("click", () => importInput.click());
  importInput.addEventListener("change", event => {
    const file = event.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = e => {
      try {
        const content = e.target?.result;
        if (typeof content !== "string") {
          throw new Error("无法读取文件内容");
        }
        const data = JSON.parse(content);
        applyImportedData(data);
        showStatus(`已导入皮肤：${data?.meta?.name || file.name}`, "success");
      } catch (error) {
        console.error(error);
        showStatus("导入失败，文件格式不正确。", "error");
      }
    };
    reader.readAsText(file);
    importInput.value = "";
  });

  function applyImportedData(data) {
    if (!data || typeof data !== "object") throw new Error("无效数据");
    if (!data.frames) throw new Error("缺少帧信息");

    const formatVersion = data?.formatVersion ?? data?.meta?.formatVersion;
    if (formatVersion != null && formatVersion !== schema.formatVersion) {
      throw new Error(`格式版本不匹配：期望 ${schema.formatVersion}，收到 ${formatVersion}`);
    }

    const gridSize = data?.gridSize || data?.meta?.gridSize || GRID_SIZE;
    if (gridSize !== GRID_SIZE) {
      throw new Error(`网格尺寸不匹配：期望 ${GRID_SIZE}，收到 ${gridSize}`);
    }

    const normalised = normaliseImportedFrames(data.frames || {});
    initFrames();
    normalised.forEach((value, key) => {
      if (frames.has(key)) {
        frames.set(key, cloneFrameData(value));
      }
    });

    skinNameInput.value = data?.meta?.name || "";
    skinAuthorInput.value = data?.meta?.author || "";
    baseCharacterSelect.value = data?.meta?.baseCharacter || "Isaac";
    skinNotesInput.value = data?.meta?.notes || "";
    if (data?.colors?.background) {
      bgColorPicker.value = data.colors.background;
    }

    paletteEl.innerHTML = "";
    const palette = data?.colors?.palette || [];
    palette.forEach(color => {
      if (typeof color !== "string") return;
      const btn = document.createElement("button");
      btn.style.background = color;
      btn.title = color;
      btn.addEventListener("click", () => {
        colorPicker.value = color;
        eraserToggle.checked = false;
      });
      paletteEl.appendChild(btn);
    });

    if (!frames.has(currentFrameId)) {
      currentFrameId = FRAME_IDS[0] || null;
    }

    renderFrameList();
    drawCanvas();
    updateAllPreviews();
  }

  function init() {
    initFrames();
    if (!currentFrameId && FRAME_IDS.length > 0) {
      currentFrameId = FRAME_IDS[0];
    }
    renderFrameList();
    buildPreviewGrid();
    drawCanvas();
    updateAllPreviews();
  }

  init();
})();
