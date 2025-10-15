(() => {
  const GRID_SIZE = 32;
  const PIXEL_SIZE = 16; // 32 * 16 = 512 canvas

  const FRAME_GROUPS = [
    {
      title: "静止 Idle",
      frames: [
        { id: "idle_down", label: "静止 · 面向下" },
        { id: "idle_up", label: "静止 · 面向上" },
        { id: "idle_left", label: "静止 · 面向左" },
        { id: "idle_right", label: "静止 · 面向右" }
      ]
    },
    {
      title: "移动 Move",
      frames: [
        { id: "move_down", label: "移动 · 面向下" },
        { id: "move_up", label: "移动 · 面向上" },
        { id: "move_left", label: "移动 · 面向左" },
        { id: "move_right", label: "移动 · 面向右" }
      ]
    },
    {
      title: "射击 Shoot",
      frames: [
        { id: "shoot_down", label: "射击 · 面向下" },
        { id: "shoot_up", label: "射击 · 面向上" },
        { id: "shoot_left", label: "射击 · 面向左" },
        { id: "shoot_right", label: "射击 · 面向右" }
      ]
    },
    {
      title: "受伤 Hurt",
      frames: [
        { id: "hurt_down", label: "受伤 · 面向下" },
        { id: "hurt_up", label: "受伤 · 面向上" },
        { id: "hurt_side", label: "受伤 · 侧身" }
      ]
    },
    {
      title: "使用道具 Item",
      frames: [
        { id: "item_use", label: "使用主动道具" },
        { id: "item_charge", label: "主动道具蓄力" }
      ]
    },
    {
      title: "跳跃 Jump",
      frames: [
        { id: "jump_start", label: "跳跃开始" },
        { id: "jump_land", label: "落地" }
      ]
    },
    {
      title: "道具装扮 Cosmetics",
      frames: [
        { id: "item_hat", label: "头部装扮" },
        { id: "item_body", label: "身体装扮" }
      ]
    }
  ];

  const frameCanvas = document.getElementById("skinCanvas");
  const ctx = frameCanvas.getContext("2d");

  const colorPicker = document.getElementById("colorPicker");
  const bgColorPicker = document.getElementById("backgroundColor");
  const eraserToggle = document.getElementById("eraserToggle");
  const toggleGrid = document.getElementById("toggleGrid");
  const previewBackground = document.getElementById("previewBackground");

  const clearFrameBtn = document.getElementById("clearFrame");
  const mirrorHorizontalBtn = document.getElementById("mirrorHorizontal");
  const mirrorVerticalBtn = document.getElementById("mirrorVertical");

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
  let currentFrameId = FRAME_GROUPS[0].frames[0].id;
  let isDrawing = false;
  let lastPixel = null;
  let lastDrawnPixel = null;

  function createEmptyFrame() {
    return Array.from({ length: GRID_SIZE }, () => Array(GRID_SIZE).fill(null));
  }

  function initFrames() {
    FRAME_GROUPS.forEach(group => {
      group.frames.forEach(frame => {
        if (!frames.has(frame.id)) {
          frames.set(frame.id, createEmptyFrame());
        }
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
  }

  function clearCurrentFrame() {
    frames.set(currentFrameId, createEmptyFrame());
    drawCanvas();
    updatePreviewCell(currentFrameId);
  }

  function mirrorFrame(horizontal = true) {
    const frameData = getCurrentFrame();
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

  [colorPicker, bgColorPicker, toggleGrid, previewBackground].forEach(input => {
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
    frames.forEach((value, key) => {
      framesObject[key] = value;
    });

    return {
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
      }
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

    const gridSize = data?.meta?.gridSize || GRID_SIZE;
    if (gridSize !== GRID_SIZE) {
      throw new Error(`网格尺寸不匹配：期望 ${GRID_SIZE}，收到 ${gridSize}`);
    }

    frames.clear();
    Object.keys(data.frames).forEach(frameId => {
      const frameData = data.frames[frameId];
      if (!Array.isArray(frameData)) return;
      frames.set(frameId, frameData.map(row => row.slice()));
    });

    FRAME_GROUPS.forEach(group => {
      group.frames.forEach(frame => {
        if (!frames.has(frame.id)) {
          frames.set(frame.id, createEmptyFrame());
        }
      });
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
      currentFrameId = FRAME_GROUPS[0].frames[0].id;
    }

    renderFrameList();
    drawCanvas();
    updateAllPreviews();
  }

  function init() {
    initFrames();
    renderFrameList();
    buildPreviewGrid();
    drawCanvas();
    updateAllPreviews();
  }

  init();
})();
