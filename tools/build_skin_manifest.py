#!/usr/bin/env python3
"""Utility to validate exported .isaacskin files and build the manifest used by the mod.

The script also keeps schema artefacts (the web editor schema.js and the Lua schema
module) in sync with the canonical JSON schema.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, List, Tuple

REPO_ROOT = Path(__file__).resolve().parents[1]
SCHEMA_PATH = REPO_ROOT / "schema" / "skin_schema.json"
FRAME_LAYOUTS_PATH = REPO_ROOT / "schema" / "frame_layouts.json"
WEB_SCHEMA_JS_PATH = REPO_ROOT / "tools" / "skin-editor" / "schema.js"
LUA_SCHEMA_PATH = REPO_ROOT / "mod" / "scripts" / "skin_schema.lua"
DEFAULT_EXPORT_DIR = REPO_ROOT / "mod" / "exported_skins"
DEFAULT_MANIFEST_PATH = DEFAULT_EXPORT_DIR / "skins_manifest.json"


def load_schema() -> Dict[str, Any]:
    with SCHEMA_PATH.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def ensure_directory(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def write_schema_js(schema: Dict[str, Any]) -> None:
    ensure_directory(WEB_SCHEMA_JS_PATH)
    payload = "window.ISAAC_SKIN_SCHEMA = " + json.dumps(schema, ensure_ascii=False, indent=2) + ";\n"
    WEB_SCHEMA_JS_PATH.write_text(payload, encoding="utf-8")


def lua_table(value: Any, indent: int = 0) -> str:
    spacer = " " * indent
    if isinstance(value, dict):
        parts = ["{"]
        inner_indent = indent + 2
        inner_spacer = " " * inner_indent
        for key, inner_value in value.items():
            parts.append(f"{inner_spacer}{key} = {lua_table(inner_value, inner_indent)},")
        parts.append(f"{spacer}" + "}")
        return "\n".join(parts)
    if isinstance(value, list):
        parts = ["{"]
        inner_indent = indent + 2
        inner_spacer = " " * inner_indent
        for item in value:
            parts.append(f"{inner_spacer}{lua_table(item, inner_indent)},")
        parts.append(f"{spacer}" + "}")
        return "\n".join(parts)
    if isinstance(value, str):
        escaped = value.replace("\\", "\\\\").replace("\"", "\\\"")
        return f'"{escaped}"'
    if isinstance(value, (int, float)):
        return str(value)
    if value is None:
        return "nil"
    raise TypeError(f"Unsupported value for Lua serialisation: {value!r}")


def build_lua_schema(schema: Dict[str, Any]) -> str:
    groups = schema["groups"]
    required_frames: List[str] = []
    frame_lookup: Dict[str, Dict[str, Any]] = {}
    for group in groups:
        for frame in group["frames"]:
            frame_id = frame["id"]
            required_frames.append(frame_id)
            frame_lookup[frame_id] = frame
    frame_layouts = None
    if FRAME_LAYOUTS_PATH.exists():
        frame_layouts = json.loads(FRAME_LAYOUTS_PATH.read_text(encoding="utf-8"))

    lua_schema = {
        "formatVersion": schema["formatVersion"],
        "gridSize": schema["gridSize"],
        "canvasSize": schema.get("canvasSize"),
        "groups": groups,
        "requiredFrames": required_frames,
        "aliasRules": schema.get("aliases", []),
    }
    lua_schema["frameLookup"] = frame_lookup
    if frame_layouts is not None:
        lua_schema["frameLayouts"] = frame_layouts
    chunks = ["local schema = {}", ""]
    for key, value in lua_schema.items():
        chunks.append(f"schema.{key} = {lua_table(value, 0)}")
        chunks.append("")
    chunks.append("return schema\n")
    return "\n".join(chunks)


def write_schema_lua(schema: Dict[str, Any]) -> None:
    ensure_directory(LUA_SCHEMA_PATH)
    LUA_SCHEMA_PATH.write_text(build_lua_schema(schema), encoding="utf-8")


def slugify(value: str) -> str:
    normalized = re.sub(r"[^0-9A-Za-z_\-]+", "-", value.strip())
    normalized = re.sub(r"-+", "-", normalized)
    normalized = normalized.strip("-")
    return normalized.lower()


def deep_clone(frame: Iterable[Iterable[Any]]) -> List[List[Any]]:
    return [[cell for cell in row] for row in frame]


def normalise_frames(frames: Dict[str, Any], schema: Dict[str, Any]) -> Dict[str, List[List[Any]]]:
    cloned: Dict[str, List[List[Any]]] = {}
    for key, frame in frames.items():
        if isinstance(frame, list):
            cloned[key] = deep_clone(frame)
    for rule in schema.get("aliases", []):
        source_frame = None
        for candidate in rule.get("sources", []):
            if candidate in cloned:
                source_frame = cloned[candidate]
                break
        if source_frame is None:
            continue
        for target in rule.get("targets", []):
            if target not in cloned:
                cloned[target] = deep_clone(source_frame)
        if rule.get("removeSource", True):
            for candidate in rule.get("sources", []):
                cloned.pop(candidate, None)
    return cloned


def validate_frame_dimensions(frame: List[List[Any]], grid_size: int) -> Tuple[bool, str | None]:
    if len(frame) != grid_size:
        return False, f"expected {grid_size} rows, got {len(frame)}"
    for row_index, row in enumerate(frame):
        if not isinstance(row, list):
            return False, f"row {row_index} is not a list"
        if len(row) != grid_size:
            return False, f"row {row_index} expected {grid_size} cols, got {len(row)}"
    return True, None


def validate_skin_file(path: Path, schema: Dict[str, Any]) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if data.get("gridSize") and data["gridSize"] != schema["gridSize"]:
        raise ValueError(f"{path.name}: top-level gridSize mismatch")
    meta = data.get("meta", {})
    grid_size = meta.get("gridSize", schema["gridSize"])
    if grid_size != schema["gridSize"]:
        raise ValueError(f"{path.name}: meta.gridSize mismatch (expected {schema['gridSize']}, got {grid_size})")
    if data.get("formatVersion") not in (None, schema["formatVersion"]):
        raise ValueError(f"{path.name}: unsupported formatVersion {data.get('formatVersion')}")
    frames_raw = data.get("frames")
    if not isinstance(frames_raw, dict):
        raise ValueError(f"{path.name}: frames must be an object")
    frames = normalise_frames(frames_raw, schema)
    required_ids = [frame["id"] for group in schema["groups"] for frame in group["frames"]]
    missing = [frame_id for frame_id in required_ids if frame_id not in frames]
    if missing:
        raise ValueError(f"{path.name}: missing frames: {', '.join(missing)}")
    issues = []
    for frame_id in required_ids:
        ok, message = validate_frame_dimensions(frames[frame_id], schema["gridSize"])
        if not ok:
            issues.append(f"{frame_id}: {message}")
    if issues:
        raise ValueError(f"{path.name}: invalid frame dimensions: {'; '.join(issues)}")
    safe_name = meta.get("name") or path.stem
    skin_id = slugify(safe_name) or slugify(path.stem)
    digest = hashlib.sha1(json.dumps(data, sort_keys=True).encode("utf-8")).hexdigest()
    summary = {
        "file": path.name,
        "id": skin_id,
        "name": meta.get("name", path.stem),
        "author": meta.get("author", "未知"),
        "baseCharacter": meta.get("baseCharacter", "Isaac"),
        "notes": meta.get("notes", ""),
        "hash": digest,
        "formatVersion": data.get("formatVersion", schema["formatVersion"]),
    }
    return summary


def build_manifest(export_dir: Path, schema: Dict[str, Any]) -> Tuple[List[Dict[str, Any]], List[str]]:
    skins: List[Dict[str, Any]] = []
    errors: List[str] = []
    for file_path in sorted(export_dir.glob("*.isaacskin")):
        try:
            skins.append(validate_skin_file(file_path, schema))
        except Exception as error:  # noqa: BLE001
            errors.append(str(error))
    return skins, errors


def write_manifest(manifest_path: Path, schema: Dict[str, Any], skins: List[Dict[str, Any]]) -> None:
    ensure_directory(manifest_path)
    manifest = {
        "formatVersion": schema["formatVersion"],
        "generatedAt": _dt.datetime.utcnow().isoformat(timespec="seconds") + "Z",
        "skins": skins,
    }
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate exported skins and rebuild the manifest.")
    parser.add_argument("--export-dir", type=Path, default=DEFAULT_EXPORT_DIR,
                        help="Directory that contains .isaacskin files (default: mod/exported_skins)")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST_PATH,
                        help="Path to the manifest JSON to generate")
    parser.add_argument("--check-only", action="store_true",
                        help="Validate skins but do not rewrite the manifest")
    return parser.parse_args(argv)


def main(argv: List[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    schema = load_schema()
    write_schema_js(schema)
    write_schema_lua(schema)
    export_dir = args.export_dir if isinstance(args.export_dir, Path) else Path(args.export_dir)
    if not export_dir.exists():
        export_dir.mkdir(parents=True, exist_ok=True)
    skins, errors = build_manifest(export_dir, schema)
    if errors:
        for message in errors:
            print(f"[ERROR] {message}", file=sys.stderr)
    if not args.check_only:
        write_manifest(args.manifest, schema, skins)
        print(f"Wrote manifest with {len(skins)} skins to {args.manifest}")
    else:
        print(f"Validated {len(skins)} skins (no manifest written)")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
