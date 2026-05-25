#!/usr/bin/env python3
"""
Merge per-architecture, push-by-digest images into multi-arch manifest lists.

The publish workflow builds each architecture on its own native runner and
pushes the images by digest (no tags). This script then assembles the final
tags from those per-arch digests:

  - a target built for both arches  -> manifest list with amd64 + arm64
  - a target built for amd64 only    -> single-arch manifest (e.g. steamcmd)
  - each Docker Hub tag is then mirrored to its GHCR equivalent

Usage:
  REGISTRY=didstopia/base \\
    python3 merge-manifests.py <bake-print.json> <amd64-metadata.json> <arm64-metadata.json>

Set DRY_RUN=1 to print the imagetools commands without running them (used by the
local logic test).
"""
import json
import os
import subprocess
import sys

REGISTRY = os.environ["REGISTRY"]
DRY_RUN = os.environ.get("DRY_RUN") == "1"


def load_digests(path):
    """Map target name -> image digest from a bake --metadata-file output."""
    if not path or not os.path.exists(path):
        return {}
    data = json.load(open(path))
    out = {}
    for name, meta in data.items():
        if isinstance(meta, dict) and "containerimage.digest" in meta:
            out[name] = meta["containerimage.digest"]
    return out


def run(cmd):
    print("+ " + " ".join(cmd), flush=True)
    if not DRY_RUN:
        subprocess.run(cmd, check=True)


def main():
    bake_print, amd_meta, arm_meta = sys.argv[1], sys.argv[2], sys.argv[3]
    targets = json.load(open(bake_print)).get("target", {})
    amd = load_digests(amd_meta)
    arm = load_digests(arm_meta)

    hub_prefix = REGISTRY + ":"
    merged = 0
    for name, cfg in targets.items():
        if name not in amd:
            continue  # not built in this run
        tags = cfg.get("tags", []) or []
        hub_tags = [t for t in tags if t.startswith(hub_prefix)]
        other_tags = [t for t in tags if not t.startswith(hub_prefix)]
        if not hub_tags:
            continue
        hub = hub_tags[0]

        sources = ["{}@{}".format(REGISTRY, amd[name])]
        if name in arm:
            sources.append("{}@{}".format(REGISTRY, arm[name]))

        # Assemble the primary Docker Hub tag from the per-arch digests
        run(["docker", "buildx", "imagetools", "create", "-t", hub] + sources)
        # Any additional Docker Hub tags point at the same manifest
        for extra in hub_tags[1:]:
            run(["docker", "buildx", "imagetools", "create", "-t", extra, hub])
        # Mirror to the other registries (GHCR) by copying the assembled manifest
        for ot in other_tags:
            run(["docker", "buildx", "imagetools", "create", "-t", ot, hub])
        merged += 1

    print("Merged {} target(s).".format(merged))
    if merged == 0:
        print("WARNING: nothing merged; check that the build jobs produced metadata.", file=sys.stderr)


if __name__ == "__main__":
    main()
