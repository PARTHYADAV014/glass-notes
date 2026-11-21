#!/usr/bin/env python3
"""Generate the Android platform folder (if needed) and pin minSdk to 21."""

import pathlib
import re
import subprocess
import sys

root = pathlib.Path(__file__).resolve().parent.parent
android = root / 'android'

if not (android / 'app').is_dir():
    subprocess.run(
        [
            'flutter', 'create',
            '--platforms=android',
            '--project-name', 'glass_notes',
            '.',
        ],
        cwd=root,
        check=True,
    )

build_files = sorted((android / 'app').glob('build.gradle*'))
if not build_files:
    sys.exit('Could not find android/app/build.gradle after flutter create.')

for path in build_files:
    original = path.read_text(encoding='utf-8')
    patched = re.sub(r'minSdkVersion[ \t]+[^\r\n]+', 'minSdkVersion 21', original)
    patched = re.sub(r'minSdk[ \t]*=[ \t]*[^\r\n]+', 'minSdk = 21', patched)
    if 'minSdk' not in patched:
        patched = re.sub(
            r'(defaultConfig\s*\{)',
            r'\1\n        minSdk = 21',
            patched,
            count=1,
        )
    if patched != original:
        path.write_text(patched, encoding='utf-8')
        print(f'Patched {path.relative_to(root)}')

print('Android platform ready (minSdk 21).')
