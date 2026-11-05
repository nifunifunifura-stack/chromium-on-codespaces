#!/usr/bin/with-contenv bash
set -Eeuo pipefail

python3 - <<'PY'
import os
import stat
import tempfile
from pathlib import Path

assets = sorted(Path("/usr/share/selkies/web/assets").glob("selkies-core-*.js"))
if len(assets) != 1:
    raise SystemExit(
        f"Expected one Selkies core asset, found {len(assets)}; scroll sensitivity was not changed."
    )

asset = assets[0]
contents = asset.read_text()
replacements = (
    (
        "_fingerScroll(e){let t=this._pointerScale(),n=e.deltaX*t.x,r=e.deltaY*t.y;",
        "_fingerScroll(e){let t=this._pointerScale(),n=e.deltaX*t.x*0.5,r=e.deltaY*t.y*0.5;",
    ),
    (
        "_wheelNotches(e,t){let n=Math.abs(Math.trunc(e));return n===0?0:t===1?(n<this._smallestLineDeltaY&&(this._smallestLineDeltaY=n),n/this._smallestLineDeltaY):t===2?Math.max(1,n):(n<this._smallestDeltaY&&(this._smallestDeltaY=n),this._allowThreshold?n/100:n/this._smallestDeltaY)}",
        "_wheelNotches(e,t){let n=Math.abs(Math.trunc(e));return 0.5*(n===0?0:t===1?(n<this._smallestLineDeltaY&&(this._smallestLineDeltaY=n),n/this._smallestLineDeltaY):t===2?Math.max(1,n):(n<this._smallestDeltaY&&(this._smallestDeltaY=n),this._allowThreshold?n/100:n/this._smallestDeltaY))}",
    ),
    (
        "this._addWheelNotches(n.y,n.x)",
        "this._addWheelNotches(n.y*0.5,n.x*0.5)",
    ),
)

for original, adjusted in replacements:
    occurrences = contents.count(original)
    if occurrences == 1:
        contents = contents.replace(original, adjusted, 1)
    elif occurrences == 0 and contents.count(adjusted) == 1:
        continue
    else:
        raise SystemExit(
            f"Could not safely adjust scroll sensitivity in {asset.name}: "
            f"expected one matching code fragment, found {occurrences}."
        )

mode = stat.S_IMODE(asset.stat().st_mode)
with tempfile.NamedTemporaryFile(
    mode="w", encoding="utf-8", dir=asset.parent, delete=False
) as patched:
    patched.write(contents)
    temporary_path = Path(patched.name)

try:
    os.chmod(temporary_path, mode)
    os.replace(temporary_path, asset)
except Exception:
    temporary_path.unlink(missing_ok=True)
    raise

print("Selkies touchpad and wheel scroll sensitivity set to 50%.")
PY
