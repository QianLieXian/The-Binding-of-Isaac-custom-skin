import json
import struct
import zlib
from pathlib import Path
from typing import Dict, List, Tuple

REPO_ROOT = Path(__file__).resolve().parents[1]
SCHEMA_PATH = REPO_ROOT / "schema" / "skin_schema.json"
LAYOUT_PATH = REPO_ROOT / "schema" / "frame_layouts.json"
EXPORT_DIR = REPO_ROOT / "mod" / "exported_skins"
MANIFEST_PATH = EXPORT_DIR / "skins_manifest.json"
OUTPUT_ROOT = REPO_ROOT / "mod" / "gfx" / "custom_skins"


def load_json(path: Path) -> Dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def deep_clone(frame: List[List[str]]) -> List[List[str]]:
    return [row[:] for row in frame]


def normalise_frames(frames: Dict[str, List[List[str]]], aliases: List[Dict]) -> Dict[str, List[List[str]]]:
    cloned = {}
    for key, frame in frames.items():
        if isinstance(frame, list):
            cloned[key] = deep_clone(frame)
    for rule in aliases:
        sources = rule.get("sources", [])
        source_frame = None
        for candidate in sources:
            if candidate in cloned:
                source_frame = cloned[candidate]
                break
        if source_frame is None:
            continue
        for target in rule.get("targets", []):
            if target not in cloned:
                cloned[target] = deep_clone(source_frame)
        if rule.get("removeSource", True):
            for candidate in sources:
                cloned.pop(candidate, None)
    return cloned


def rgba_from_token(token: str) -> Tuple[int, int, int, int]:
    if not token:
        return 0, 0, 0, 0
    token = token.strip()
    if not token:
        return 0, 0, 0, 0
    if token.startswith("#"):
        token = token[1:]
    if len(token) == 6:
        token += "FF"
    if len(token) != 8:
        return 0, 0, 0, 0
    value = int(token, 16)
    r = (value >> 24) & 0xFF
    g = (value >> 16) & 0xFF
    b = (value >> 8) & 0xFF
    a = value & 0xFF
    return r, g, b, a


def compute_sheet_bounds(layout: Dict) -> Dict[str, Tuple[int, int]]:
    bounds: Dict[str, Tuple[int, int]] = {}
    for animation in layout.get("animations", {}).values():
        for layer_id, frames in animation.items():
            layer = layout["sheets"].get(layer_id)
            if layer is None:
                continue
            sheet_name = layer["sheet"]
            width, height = bounds.get(sheet_name, (0, 0))
            for frame in frames:
                width = max(width, frame["x"] + frame["width"])
                height = max(height, frame["y"] + frame["height"])
            bounds[sheet_name] = (width or 32, height or 32)
    return bounds


def chunk(chunk_type: bytes, data: bytes) -> bytes:
    length = struct.pack("!I", len(data))
    crc = struct.pack("!I", zlib.crc32(chunk_type + data) & 0xFFFFFFFF)
    return length + chunk_type + data + crc


def write_png(path: Path, width: int, height: int, pixels: bytes) -> None:
    stride = width * 4
    rows = []
    for y in range(height):
        start = y * stride
        rows.append(b"\x00" + pixels[start : start + stride])
    payload = zlib.compress(b"".join(rows))
    png = [b"\x89PNG\r\n\x1a\n"]
    png.append(chunk(b"IHDR", struct.pack("!IIBBBBB", width, height, 8, 6, 0, 0, 0)))
    png.append(chunk(b"IDAT", payload))
    png.append(chunk(b"IEND", b""))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(b"".join(png))


def build_textures() -> None:
    schema = load_json(SCHEMA_PATH)
    layout_raw = load_json(LAYOUT_PATH)
    manifest = load_json(MANIFEST_PATH)
    lookup = {}
    for group in schema.get("groups", []):
        for frame in group.get("frames", []):
            lookup[frame["id"]] = frame
    alias_rules = schema.get("aliases", [])

    layout = {
        "animations": {},
        "sheets": {},
    }
    for key, info in layout_raw.get("sheets", {}).items():
        layout["sheets"][int(key)] = {
            "sheet": info["sheet"],
            "layerId": info.get("layerId", int(key)),
        }
    for anim_name, layer_map in layout_raw.get("animations", {}).items():
        layout_layer = {}
        for layer_id, frames in layer_map.items():
            layout_layer[int(layer_id)] = frames
        layout["animations"][anim_name] = layout_layer

    bounds = compute_sheet_bounds(layout)

    for entry in manifest.get("skins", []):
        file_name = entry.get("file")
        if not file_name:
            continue
        skin_id = entry.get("id") or Path(file_name).stem
        data = load_json(EXPORT_DIR / file_name)
        frames_raw = data.get("frames", {})
        frames = normalise_frames(frames_raw, alias_rules)
        sheets: Dict[str, bytearray] = {}
        for sheet_name, (width, height) in bounds.items():
            sheets[sheet_name] = bytearray(width * height * 4)
        for frame_id, frame_pixels in frames.items():
            meta = lookup.get(frame_id)
            if not meta or "anm2" not in meta:
                continue
            animation = meta["anm2"]["animation"]
            frame_index = meta["anm2"]["frame"]
            animation_layout = layout["animations"].get(animation)
            if not animation_layout:
                continue
            for layer_id, frames_layout in animation_layout.items():
                if frame_index >= len(frames_layout):
                    continue
                frame_info = frames_layout[frame_index]
                sheet_info = layout["sheets"].get(layer_id)
                if not sheet_info:
                    continue
                sheet_name = sheet_info["sheet"]
                sheet = sheets.get(sheet_name)
                if sheet is None:
                    continue
                width, height = bounds[sheet_name]
                for y, row in enumerate(frame_pixels):
                    for x, token in enumerate(row):
                        if not token:
                            continue
                        r, g, b, a = rgba_from_token(token)
                        dest_x = frame_info["x"] + x
                        dest_y = frame_info["y"] + y
                        if dest_x < 0 or dest_y < 0 or dest_x >= width or dest_y >= height:
                            continue
                        offset = (dest_y * width + dest_x) * 4
                        sheet[offset:offset + 4] = bytes((r, g, b, a))
        for sheet_name, pixels in sheets.items():
            width, height = bounds[sheet_name]
            output_path = OUTPUT_ROOT / skin_id / sheet_name
            write_png(output_path, width, height, bytes(pixels))


if __name__ == "__main__":
    build_textures()
