"""
Transforms Google Takeout's Keep format to something more useful.
"""

import argparse
import itertools
import json
import logging
import os
from   pathlib import Path

#-------------------------------------------------------------------------------

def list_to_md(doc):
    return "\n".join(
        f"- [{'x' if i['isChecked'] else ' '}] {i['text']}"
        for i in doc
    ) + "\n"


def get_tags(doc):
    tags = [ l["name"].replace(" ", "_") for l in doc.get("labels", []) ]
    if doc["color"] != "DEFAULT":
        tags.append(doc["color"])
    return tags


def make_unique(path):
    if not path.exists():
        return path
    for i in itertools.count():
        new_path = (path.parent / (path.with_suffix("").name + f" {i}")).with_suffix(path.suffix)
        if not new_path.exists():
            return new_path


#-------------------------------------------------------------------------------

logging.basicConfig(level=logging.INFO)

parser = argparse.ArgumentParser()
parser.add_argument("in_dir", metavar="DIR", type=Path, help="takeout directory")
parser.add_argument("out_dir", metavar="DIR", type=Path, help="output directory")
args = parser.parse_args()

keep_dir = args.in_dir / "Keep"
if not keep_dir.is_dir():
    parser.error(f"not a directory: {keep_dir}")

out_dir = args.out_dir
out_dir.mkdir()
(out_dir / "archive").mkdir()
(out_dir / "pinned").mkdir()
(out_dir / "trash").mkdir()

json_paths = ( p for p in keep_dir.iterdir() if p.suffix == ".json" )
for path in json_paths:
    logging.info(f"processing: {path}")
    with path.open("r") as file:
        doc = json.load(file)

    title = doc["title"] or "untitled"
    try:
        body = list_to_md(doc["listContent"])
    except KeyError:
        try:
            body = doc["textContent"]
        except KeyError:
            body = ""
    assert isinstance(body, str)

    tags = get_tags(doc)
    if len(tags) > 0:
        body += "\n" + " ".join( "#" + t for t in tags ) + "\n"

    mtime = doc["userEditedTimestampUsec"] * 1000

    out_path = ((
        out_dir / "trash" if doc["isTrashed"]
        else out_dir / "archive" if doc["isArchived"]
        else out_dir / "pinned" if doc["isPinned"]
        else out_dir
    ) / title.replace("/", "-")).with_suffix(".md")
    out_path = make_unique(out_path)
    
    logging.info(f"writing: {out_path}")
    with out_path.open("w") as file:
        file.write(body)
    os.utime(out_path, ns=(mtime, mtime))


