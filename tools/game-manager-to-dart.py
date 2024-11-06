from dataclasses import dataclass
from pathlib import Path
import re
from typing import Optional


imports = """
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/generated/api.enums.swagger.dart';
import 'package:mobile/src/models/game_template.dart';
import 'package:mobile/src/models/typedef.dart';

part 'socket_io_events.g.dart';
"""


@dataclass
class EnumData:
    variants: list[str]


@dataclass
class InterfaceData:
    name: str
    fields: list[tuple[str, str]]


def translate(field_name: str, field_type: str) -> tuple[str, str]:
    if field_type == "[Vec2, Vec2]":
        return field_name, "List<Vec2>"
    if field_type == "Record<TeamIndex, Username[]>":
        return field_name, "Map<TeamIndex, List<Username>>"
    if field_type == "[ChangeTemplateDto, ChangeTemplateDto]":
        return field_name[:-1], "List<ChangeTemplateDto>?"

    field_type = field_type.replace("number", "int")
    field_type = field_type.replace("boolean", "bool")
    field_type = field_type.replace("string", "String")
    field_type = field_type.replace("Record", "Map")
    field_type = field_type.replace("GameMode", "HistoryGameMode")

    n = field_type.count("[]")
    if n > 0:
        field_type = "List<" * n + field_type[: -n * 2] + ">" * n

    if field_name.endswith("?"):
        field_name = field_name[:-1]
        field_type += "?"

    return field_name, field_type


def parse_enums(blocks: list[str]) -> Optional[EnumData]:
    variants = []

    for block in blocks:
        if "enum" not in block:
            continue

        matches = re.findall(r".+ = '(.+)'", block)
        variants.extend(matches)

    return EnumData(variants) if len(variants) > 0 else None


def parse_interfaces(blocks: list[str]) -> list[InterfaceData]:
    interfaces_data = []

    # if the interface contains "\[.+\]: .+," it's an EventsMap
    interfaces = [b for b in blocks if "export interface" in b and "]:" not in b]

    for interface in interfaces:
        name = re.findall(r"interface ([a-zA-Z_$0-9]+)", interface)[0]
        fields = re.findall(r"([a-zA-Z_$0-9]+[?]?): (.+);", interface)
        interfaces_data.append(InterfaceData(name, fields))

    return interfaces_data


def parse_files(input_dir: Path) -> tuple[list[EnumData], list[InterfaceData]]:
    enum_variants: list[EnumData] = []
    interfaces_data: list[InterfaceData] = []

    for file in input_dir.iterdir():
        with open(file) as f:
            blocks = re.findall(r"(export [^{]+ {[^}]+})", f.read(), re.DOTALL)

            enums = parse_enums(blocks)
            if enums is not None:
                enum_variants.append(enums)
            interfaces_data.extend(parse_interfaces(blocks))

    return enum_variants, interfaces_data


def generate_enum(enums_data: list[EnumData]) -> str:
    name = "GameManagerEvent"
    variants = "\n\n".join(
        "\n".join(f"  {s}," for s in data.variants) for data in enums_data
    )

    enum = f"""
enum {name} {{
{variants}
}}
"""
    return enum.strip()


def generate_interface(data: InterfaceData) -> str:
    name = data.name
    fields = data.fields

    final_fields = []
    for field_name, field_type in fields:
        field_name, field_type = translate(field_name, field_type)

        final_fields.append(f"final {field_type} {field_name};")

    final_fields_str = "\n  ".join(final_fields)

    constructor_params = ", ".join(
        f'required this.{field[0].strip("?")}' for field in fields
    )

    interface = f"""
@JsonSerializable()
class {name} {{
  {final_fields_str}

  {name}({{{constructor_params}}});

  factory {name}.fromJson(Map<String, dynamic> json) =>
      _${name}FromJson(json);

  Map<String, dynamic> toJson() => _${name}ToJson(this);
}}
"""
    return interface.strip()


def main() -> None:
    project_root = Path(__file__).parent.parent
    input_dir = project_root / "common/websocket"
    enum_output_file = project_root / "mobile/lib/src/models/game_manager_event.dart"
    dto_output_file = project_root / "mobile/lib/src/models/socket_io_events.dart"

    enum_variants, interfaces_data = parse_files(input_dir)

    with open(enum_output_file, "w") as f:
        f.write(generate_enum(enum_variants))
        f.write("\n")

    with open(dto_output_file, "w") as f:
        interfaces = "\n\n".join(generate_interface(data) for data in interfaces_data)
        f.write(imports.strip())
        f.write("\n\n")
        f.write(interfaces)


if __name__ == "__main__":
    main()
