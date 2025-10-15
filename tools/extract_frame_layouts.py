import json
import xml.etree.ElementTree as ET
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
ANM2_PATH = REPO_ROOT / "schema" / "templates" / "combined.anm2"
OUTPUT_PATH = REPO_ROOT / "schema" / "frame_layouts.json"


def parse_anm2(path: Path) -> dict:
    tree = ET.parse(path)
    root = tree.getroot()
    content = root.find("Content")
    spritesheet_nodes = content.find("Spritesheets")
    sheet_by_id = {}
    for sheet in spritesheet_nodes.findall("Spritesheet"):
        sheet_id = sheet.get("Id")
        sheet_by_id[sheet_id] = sheet.get("Path")
    layer_nodes = content.find("Layers")
    layer_to_sheet = {}
    for layer in layer_nodes.findall("Layer"):
        layer_id = layer.get("Id")
        sheet_id = layer.get("SpritesheetId")
        layer_to_sheet[layer_id] = {
            "name": layer.get("Name"),
            "sheet": sheet_by_id.get(sheet_id),
            "layerId": int(layer_id),
        }
    animations_node = root.find("Animations")
    animations = {}
    for animation in animations_node.findall("Animation"):
        name = animation.get("Name")
        layer_map = {}
        layer_anims = animation.find("LayerAnimations")
        if layer_anims is None:
            continue
        for layer_anim in layer_anims.findall("LayerAnimation"):
            layer_id = layer_anim.get("LayerId")
            layer_frames = []
            for frame_index, frame in enumerate(layer_anim.findall("Frame")):
                entry = {
                    "index": frame_index,
                    "sheet": layer_to_sheet[layer_id]["sheet"],
                    "layerName": layer_to_sheet[layer_id]["name"],
                    "layerId": int(layer_id),
                    "x": int(frame.get("XCrop", "0")),
                    "y": int(frame.get("YCrop", "0")),
                    "width": int(frame.get("Width", "0")),
                    "height": int(frame.get("Height", "0")),
                    "xScale": int(frame.get("XScale", "100")),
                    "yScale": int(frame.get("YScale", "100")),
                }
                layer_frames.append(entry)
            if layer_frames:
                layer_map[layer_id] = layer_frames
        if layer_map:
            animations[name] = layer_map
    return {
        "sheets": layer_to_sheet,
        "animations": animations,
    }


def main() -> None:
    data = parse_anm2(ANM2_PATH)
    OUTPUT_PATH.write_text(json.dumps(data, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
