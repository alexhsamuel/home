#!/usr/bin/python

import logging
import os
from   pathlib import Path

logging.basicConfig(level=logging.INFO)

base = (Path(__file__).parent / "dotfiles").absolute()
assert base.is_dir()

home = Path(os.environ["HOME"])

for path in (
        Path(dir) / name
        for dir, _, names in os.walk(base)
        for name in names
):
    link_path = home / path.relative_to(base)
    # logging.info(f"path={path} link_path={link_path}")
    if link_path.is_symlink():
        target = link_path.readlink()
        if target == path:
            logging.debug(f"ok: {link_path}")
            continue
        else:
            logging.warning(f"wrong link: {link_path} → {target}")
            link_path.unlink()
    elif link_path.exists():
        logging.error(f"exists: {link_path}")
        continue

    logging.info(f"creating: {link_path} → {path}")
    link_path.parent.mkdir(parents=True, exist_ok=True)
    link_path.symlink_to(path)

