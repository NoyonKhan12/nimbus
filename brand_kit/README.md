# Nimbus Exact-Fidelity Asset Kit

This version is intentionally different from the previous kit.

The original supplied Nimbus artwork is preserved pixel-for-pixel inside `nimbus-exact.svg`,
with the checkerboard transparency-preview background removed. This is the correct choice
when visual fidelity to the supplied image is more important than converting the artwork into
simplified geometric paths.

Files:
- nimbus-exact.svg — exact supplied artwork with transparent background embedded in SVG
- nimbus-mark-exact.svg — exact mark as SVG
- nimbus-exact-transparent.png — cleaned source
- nimbus-icon-1024.png / 512 / 256 — app icon exports
- nimbus-mark-1024.png / 512.png — transparent mark
- nimbus-favicon-256 / 128 / 64 / 32 / 16.png
- nimbus-splash-1080x1920.png
- nimbus-splash-1242x2688.png

Important:
An SVG containing an embedded raster preserves the exact appearance, but it is not a
mathematical vector redraw. A fully traced vector version cannot reproduce the original
neon glow, brushed-metal texture and tiny raster details exactly. For production branding,
this exact-fidelity SVG is therefore the best match to the supplied artwork; a separate
true-vector redraw can be made if desired.
