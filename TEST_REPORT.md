# Obscura Studio — test report

Generated from the last full run on 2026-11-11 02:19 UTC. Every result below comes from a test that was actually executed; nothing is inferred.

| Layer | Tests | Passed | Failed | How it runs |
|---|---:|---:|---:|---|
| Type check | 1 | 1 | 0 | `tsc --strict` over all sources, no errors |
| Unit (engine) | 48 | 48 | 0 | Node v22.23.4, pure pixel/selection/zip/analysis code |
| End-to-end | 205 | 205 | 0 | Google Chrome for Testing 153.0.8010.12, headless, real mouse and keyboard events against `dist/obscura.html` |

Console errors and uncaught exceptions fail any end-to-end test in which they occur (two tests that deliberately provoke an error are exempt). The only messages ignored are failed font downloads, because the test machine has no internet access.

## What the tests cover

| Area you asked for | Where it is tested |
|---|---|
| Image importing | Files: PNG (exact pixels), JPEG, WebP, SVG, drag-and-drop, Place as layer, corrupt file, oversized file |
| Image exporting | Files: PNG pixel-identical with alpha, JPEG quality vs size, WebP, scaled export, Export dialog download |
| Layer creation, deletion, ordering | Layers: panel buttons, drag-and-drop reorder, arrange shortcuts, 60-layer document |
| Opacity changes, blend modes | Layers: opacity slider, 10 separable modes checked against the W3C formulas, 6 more checked for effect |
| Masks | Layers: paint black/grey/white on a mask, disable, invert, delete, from selection, apply; clipping masks |
| Brush operations | Tools: size, hardness, opacity vs flow, pencil, eraser, bucket, gradient, clone, heal, spot heal, blur, sharpen, smudge, dodge, burn |
| Selection operations | Selection: marquees, lasso, polygonal, magnetic, wand, add/subtract/intersect, feather, expand, contract, border, colour range, move, transform |
| Image adjustments | Adjustments: all 17 requested adjustments, each with preview, cancel, apply and undo; curves editor; worker; proxy preview |
| Undo and redo | History: full walk both ways comparing pixel hashes, history panel, structural undo, undo during unfinished interactions |
| Project saving and reopening | Files: 8-layer round trip (text, shapes, path, group, masks, adjustments) compared property by property and pixel hash; ZIP validity; Ctrl+S |
| Keyboard shortcuts | History and others: 24 tool keys, colour keys, brush keys, more than 30 command shortcuts across the suites, and that typing in fields does not trigger them |
| Canvas transformations | History: Image Size, Canvas Size, Trim, Rotate 90/180, Flip, per-layer flip/rotate, Free Transform, Crop |
| Error handling | Files and Interface: corrupt image, corrupt project, oversized image, invalid dialog input, thrown command, uncaught runtime error, locked/hidden/wrong-type layers |
| Broken buttons, missing functionality | Interface: every menu entry resolves to a command; every enabled command is executed; every toolbar button activates its tool |
| State synchronisation | Options bar ↔ Brush panel, colour chips, Properties after undo, tabs with independent sessions |
| Memory leaks | Interface: 43 documents opened, edited and closed; heap, listener count and DOM node count compared |
| Offline desktop use | Desktop: opened from `file://` with the network blocked and zero requests made; embedded fonts; Save/Save As/Open through the system file dialogs (stand-in pickers); autosave recovery from the start screen; 3 seeded 220-action stress runs with invariants and a full history walk |
| Geometry correctness | Audit: every whole-canvas and per-layer flip/rotation compared with transforming the flattened picture, on a document using every layer type |
| Performance | 24 MP document: dirty-rectangle cost vs full composite, brush stroke time, proxy preview; 12 MP blur in the worker with main-thread stall measured |

## Defects found by testing and fixed

These were real faults in the application, found by the tests above or by looking at screenshots taken during the runs. All are fixed and each now has a test that would catch it again.

1. **Magnetic Lasso froze the browser.** The edge-following path search stored distances as 32-bit floats; equal-cost paths then compared as shorter after rounding and were re-queued without end. Distances are now 64-bit.
2. **Gaussian blur slightly brightened images.** Each of the six box passes added 0.5 before a store that already rounds, lifting dark tones. Removed the double rounding.
3. **Double-click to rename a layer (and to edit text from the Layers panel) never worked.** A click re-rendered the row before the browser could deliver the double-click. Double-clicks are now detected by the panel itself.
4. **Brush colour drifted by one level where dabs overlapped.** Strokes now accumulate coverage and are coloured once, so the painted colour is exactly the chosen one.
5. **Sharpen tool rang and inverted edges when passed over an area repeatedly.** It now sharpens against the pixels as they were before the stroke, once per stroke.
6. **Space-to-pan did nothing right after clicking a tool button**, because the button kept keyboard focus. Mouse clicks on tools now return focus to the canvas.
7. **Tall dialogs (Keyboard Shortcuts) pushed their buttons off-screen.** Dialogs are now capped to the window height and scroll inside.
8. **Select Subject included a band of sky on graded backgrounds.** The colour model was replaced: every colour found along the border is background, and thin bands are removed.
9. **Overlays ignored `hidden` in the standalone file**, dimming the whole window; the toolbar overflowed on short windows. Both fixed (the toolbar switches to two columns when needed).
10. **Controls in a short Properties panel were squashed** instead of scrolling; **panel resize handles jumped a few pixels on grab**; **the phone layout forced a single tool column**. All three fixed.
11. **A save inside the hosted viewer could be reported as successful when it was not**, if the viewer's save service was unavailable. It now reports the failure.

12. **Flipping or rotating the canvas left text shadows pointing the old way**, and vertical flips drew stars and polygons upside-down wrong. Shadows are now kept in document space and turn with the artwork.
13. **Flip/Rotate on a single layer was not a true mirror for rotated text and shapes, pivoted on the canvas centre, and turned each member of a group separately.** A layer now turns in place about its own content, a group turns as a whole, and masks follow.
14. **Text and shapes could differ by a shade along their edges between a partial and a full redraw.** Each text/shape layer is now rasterised once per change and reused, so the screen always equals a fresh full render (checked after every tool and at every stress-test checkpoint).
15. **Escape did not cancel a drag in progress** (move, text box, pen anchor, zoom). It now puts everything back with no history step.
16. **The first letters typed after starting a layer rename or a text box could be lost or fire tool shortcuts**, because focus arrived a frame late. Focus is now immediate.
17. **Colour chips faded between colours** and could briefly show a colour that was neither; **Polygonal Lasso corners were not pixel-aligned**, giving soft straight edges. Both fixed.

Mistakes in the tests themselves (wrong expectations, a helper that did not press modifier keys, fixtures that bypassed history) were corrected in the tests and are not counted above.

## What was not tested

- **Browsers other than Chrome.** Firefox and Safari were not available here. The code avoids Chrome-only APIs where there is a standard alternative and has fallbacks for canvas letter-spacing and rounded rectangles, but those fallbacks have not been run.
- **The real hosted save prompt.** Saving inside the hosted page was tested against a stand-in that follows the documented contract, not the live service.
- **Real pen and touch hardware.** Touch painting and pinch zoom were tested with synthetic pointer events; pen pressure was not exercised.
- **The launcher scripts and real system file dialogs.** The `.bat`, `.command` and `.sh` launchers were written but could not be run here (Linux test machine, headless). Saving through the system dialog was tested against stand-in pickers that follow the browser API.
- **A real generative-fill service.** The provider adapter was tested against a stand-in endpoint at the network boundary.
- **Images near the size limit.** The largest document tested was 24 megapixels (6000 × 4000). The 120 MP ceiling is enforced but was only tested for refusal, not for editing.
- **Subject detection on real photographs.** It was measured on synthetic scenes with known ground truth. Expect weaker results on busy backgrounds.

## End-to-end results

### Adjustments (24/24)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | brightnessContrast: brighter — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | brightnessContrast: more contrast — preview, cancel restores, apply commits, undo reverts | 0.8 s |  |
| pass | exposure: +1 EV doubles — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | hueSaturation: saturation −100 is grey — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | hueSaturation: hue +120° turns red to green — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | temperatureTint: temperature warms — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | temperatureTint: tint shifts green–magenta — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | levels: input range remapped — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | curves: midpoint lifted to 200 — preview, cancel restores, apply commits, undo reverts | 0.8 s |  |
| pass | colorBalance: midtones toward red — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | blackWhite: all patches neutral — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | vibrance: muted colour boosted — preview, cancel restores, apply commits, undo reverts | 0.8 s |  |
| pass | shadowsHighlights: shadows lifted, highlights kept — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | vignette: corners darkened — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | gaussianBlur: edge softened — preview, cancel restores, apply commits, undo reverts | 1.0 s |  |
| pass | motionBlur: horizontal smear only — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | sharpen: edge contrast raised — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | noiseReduction: noise reduced, edge kept — preview, cancel restores, apply commits, undo reverts | 0.9 s |  |
| pass | filter dialog sliders drive the live preview | 0.7 s |  |
| pass | the Curves editor adds, drags and removes points | 0.9 s |  |
| pass | a filter applied with a selection changes only the selected pixels | 0.6 s |  |
| pass | filters refuse non-pixel layers with guidance; Repeat Last Filter re-applies | 0.8 s |  |
| pass | heavy filters run in a Web Worker and the interface keeps responding | 2.2 s | 12 MP Gaussian blur: 1671 ms in worker, 165 UI ticks meanwhile, longest stall 29 ms |
| pass | large-image filter dialog shows a fast proxy preview, then the exact result on Apply | 1.7 s | dialog and first preview in 256 ms on a 6 MP layer |

### Audit (18/18)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | image.flipH on a document with every layer type equals transforming the flattened image | 0.6 s | mean 0.09 levels, 0.00% outliers |
| pass | image.flipV on a document with every layer type equals transforming the flattened image | 0.6 s | mean 0.14 levels, 0.03% outliers |
| pass | image.rotCW on a document with every layer type equals transforming the flattened image | 0.6 s | mean 0.30 levels, 0.03% outliers |
| pass | image.rotCCW on a document with every layer type equals transforming the flattened image | 0.6 s | mean 0.30 levels, 0.02% outliers |
| pass | image.rot180 on a document with every layer type equals transforming the flattened image | 0.6 s | mean 0.13 levels, 0.02% outliers |
| pass | crop and Canvas Size on the mixed document equal cropping or padding the flattened image exactly | 0.6 s |  |
| pass | Image Size on the mixed document matches resampling the flattened image | 0.6 s | mean 1.34 levels, 0.18% outliers |
| pass | the project round trip of the mixed document is pixel-identical after every geometric operation | 0.5 s |  |
| pass | Gradient and Paint Bucket work on a layer mask | 0.8 s |  |
| pass | Clone Stamp can sample all layers and paint onto an empty layer; non-aligned mode restarts from the source | 0.5 s |  |
| pass | copy in one document, paste into another; hidden layers are left out of exports and Copy Merged | 0.8 s |  |
| pass | Escape abandons a marquee, lasso, gradient or shape drag in progress without leaving a trace | 1.2 s |  |
| pass | Flip and Rotate on one layer mirror or turn it in place, for pixel, masked, text, shape and group layers alike | 1.5 s | 30 layer turns checked, worst mean difference 1.17 levels |
| pass | Escape during a Move, text-box resize, Pen anchor, Hand or Zoom drag puts everything back | 1.8 s |  |
| pass | typing straight after starting a rename or a text box loses no keystrokes and triggers no shortcuts | 0.8 s |  |
| pass | the scripting interface runs a list of steps, reports failures plainly, and each step is one undo | 0.5 s |  |
| pass | shapes drawn in any direction, and click-without-drag, produce sane layers | 0.7 s |  |
| pass | the on-screen composite always equals a fresh full render (dirty-rectangle audit across every paint tool) | 6.5 s | 18 operations checked against a full re-render |

### Desktop and offline (18/18)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | opened as a local file with no network: starts cleanly and makes no network requests | 2.0 s |  |
| pass | interface and text use the embedded fonts offline; web fonts are not offered without a connection | 0.9 s | 15 fonts listed offline (3 bundled, 12 detected on this machine) |
| pass | web fonts are offered when online and requested only when chosen | 0.6 s |  |
| pass | settings and autosave persist on a local file across a restart | 0.9 s |  |
| pass | Save writes to a file chosen in the system dialog, then saves in place without asking again | 0.9 s |  |
| pass | Save As picks a new file and renames the document; cancelling keeps it unsaved; a lost permission asks again | 1.0 s |  |
| pass | Open through the system dialog keeps the file, so Save updates that same project; Export asks where to put the image | 1.2 s |  |
| pass | window title follows the active document and its unsaved state | 0.5 s |  |
| pass | display scaling 125%: pointer positions, selections and canvas sharpness hold | 0.6 s |  |
| pass | display scaling 150%: pointer positions, selections and canvas sharpness hold | 0.7 s |  |
| pass | display scaling 200%: pointer positions, selections and canvas sharpness hold | 0.8 s |  |
| pass | undoing a crop or resize brings the whole canvas back into view | 0.7 s |  |
| pass | a click that only dismisses a menu or colour popover does not paint | 0.6 s |  |
| pass | text layers mirror and rotate correctly with the canvas and on their own | 0.5 s |  |
| pass | text editing overlay sits exactly on the rendered text, including when zoomed and rotated | 0.4 s |  |
| pass | stress run 1 (seed 20261110): 220 random edits, selections, commands, undos and redos leave a consistent, error-free document | 16.7 s | {"drag":78,"cmd":65,"undo":35,"redo":6,"select":12,"option":10,"text":7,"transform":7}; 60 history states re-verified both ways, 12 MB history |
| pass | stress run 2 (seed 7): 220 random edits, selections, commands, undos and redos leave a consistent, error-free document | 14.7 s | {"drag":82,"cmd":75,"undo":20,"redo":8,"select":13,"option":10,"text":7,"transform":5}; 58 history states re-verified both ways, 3 MB history |
| pass | stress run 3 (seed 99991): 220 random edits, selections, commands, undos and redos leave a consistent, error-free document | 13.6 s | {"drag":65,"cmd":57,"undo":29,"redo":10,"select":20,"option":16,"text":9,"transform":14}; 60 history states re-verified both ways, 12 MB history |

### Edge cases (14/14)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | tiny and odd-sized documents (1×1, 1×300, 3×2) open, paint, filter, save and export | 1.5 s |  |
| pass | extreme zoom (1% to 6400%) keeps painting accurate and shows the pixel grid | 0.5 s |  |
| pass | dragging far outside the canvas and releasing outside the window still finishes cleanly | 1.4 s |  |
| pass | switching tools or documents in the middle of a drag does not corrupt anything | 0.9 s |  |
| pass | resizing the window during a stroke and with a dialog open keeps everything aligned | 1.0 s |  |
| pass | rotated and mirrored vector layers: handles, hit-testing and Free Transform cancel all behave | 0.8 s |  |
| pass | masks and clipping inside groups, and a mask on the group itself | 5.4 s |  |
| pass | pasting an image from another app adds it as a layer; pasting into an empty workspace opens it | 0.5 s |  |
| pass | Layers panel works from the keyboard: arrows, Enter, F2 rename, Delete | 0.3 s |  |
| pass | deleting every layer leaves a usable empty document | 0.7 s |  |
| pass | typing values: out-of-range numbers are clamped, empty and invalid input is ignored | 0.9 s |  |
| pass | dialogs: Enter confirms, Escape cancels, focus returns, and shortcuts are inert while one is open | 0.5 s |  |
| pass | history limit: the oldest steps drop off but the document and redo stay intact | 2.8 s |  |
| pass | a project saved by a newer version, or with missing parts, opens with clear warnings instead of failing | 0.3 s |  |

### Files (22/22)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | app starts with the sample document, a background worker and no console errors | 0.5 s |  |
| pass | empty state offers open/new/sample; New Document dialog creates the requested canvas | 0.5 s |  |
| pass | New Document rejects invalid dimensions with an explanation | 0.4 s |  |
| pass | imports a PNG through the file picker with exact pixels | 0.3 s |  |
| pass | imports JPEG and WebP with correct size and colours within codec tolerance | 0.5 s |  |
| pass | imports SVG by rasterising it at a workable size | 0.4 s |  |
| pass | drag-and-drop onto the window opens the file | 0.4 s |  |
| pass | Place Image adds the file as a new centred layer in the open document | 0.4 s |  |
| pass | a corrupt image shows an error and leaves the app usable | 0.3 s |  |
| pass | a corrupt or foreign project archive is rejected with a specific message | 0.2 s |  |
| pass | an oversized image is refused before allocating memory | 0.3 s |  |
| pass | PNG export is pixel-identical to the canvas and keeps transparency | 0.3 s |  |
| pass | JPEG export flattens onto the matte and quality controls file size | 0.5 s | q30 25 KB, q95 418 KB |
| pass | WebP export encodes as WebP, and export scale resamples the output | 0.3 s |  |
| pass | Export As dialog shows a live size estimate and downloads the chosen format | 1.1 s | downloaded Test.jpg (881 B) |
| pass | project save → reopen restores every layer type, property and pixel | 0.5 s | 8 layers incl. text, shapes, group, masks, 2 adjustments; 47 KB project |
| pass | the project file is a standard ZIP with a readable manifest | 0.3 s |  |
| pass | Ctrl+S downloads the project and clears the unsaved marker | 0.6 s |  |
| pass | autosave stores changed documents in IndexedDB and Recover reopens them | 2.9 s |  |
| pass | closing an edited document asks before discarding it | 0.6 s |  |
| pass | inside a hosted viewer, saving goes through the viewer's save service and handles decline and absence | 0.8 s |  |
| pass | Document Info reports dimensions, layers and source metadata | 1.5 s |  |

### Layers (24/24)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | create, delete and undo a layer from the panel buttons | 0.4 s |  |
| pass | rename inline by double-click, duplicate with Ctrl+J | 0.4 s |  |
| pass | visibility toggle removes the layer from the composite and is undoable | 0.4 s |  |
| pass | a locked layer refuses paint, move and delete, and says why | 0.8 s |  |
| pass | opacity slider blends the layer and commits one history step | 0.4 s |  |
| pass | blend modes match the W3C compositing formulas (all 7 required, plus 3 more) | 0.5 s | max deviation per mode (levels): {"normal":0,"multiply":1,"screen":0,"overlay":1,"soft-light":0,"hard-light":1,"difference":0,"darken":0,"lighten":0,"exclusion":2} |
| pass | blend mode with partial opacity interpolates toward the backdrop | 0.3 s |  |
| pass | drag-and-drop in the Layers panel reorders the stack | 0.5 s |  |
| pass | arrange shortcuts move the active layer through the stack | 0.5 s |  |
| pass | group with Ctrl+G, group opacity applies to the whole group, drag into group, ungroup | 0.6 s |  |
| pass | a group cannot be dropped inside itself | 0.3 s |  |
| pass | layer mask: painting black hides non-destructively, white restores, disable/delete work | 1.1 s |  |
| pass | mask from selection, then Apply Mask bakes it into pixels | 0.5 s |  |
| pass | clipping mask confines a layer to the alpha of the layer below, with and without a blend mode | 0.5 s |  |
| pass | adjustment layer is non-destructive: edit, hide, re-edit and undo | 0.8 s |  |
| pass | dragging an adjustment slider previews live and records a single step | 0.5 s |  |
| pass | an adjustment created with a selection only affects that area; clipped adjustment only its base | 0.5 s |  |
| pass | spatial adjustment layers (blur) render identically for partial and full redraws | 0.4 s |  |
| pass | editing one layer never alters another (brush, eraser, filter, transform) | 1.0 s |  |
| pass | Move tool moves one layer independently; arrow keys nudge; auto-select picks by click | 0.7 s |  |
| pass | Free Transform scales and rotates one layer; Esc cancels, Enter applies | 0.8 s |  |
| pass | rasterize converts text to pixels; Merge Down, Merge Visible and Flatten combine correctly | 0.6 s |  |
| pass | layer context menu opens on right-click and runs its commands | 0.4 s |  |
| pass | 60 layers stay responsive: add, composite and reorder | 0.5 s | 61 layers: full composite 48 ms, 64×64 dirty-rect 1.5 ms |

### Selection (19/19)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | Rectangular Marquee selects exact pixels; painting is confined to the selection | 0.7 s |  |
| pass | Shift adds, Alt subtracts, Shift+Alt intersects; clicking outside deselects | 1.3 s |  |
| pass | Elliptical Marquee selects an anti-aliased ellipse of the right area | 0.4 s |  |
| pass | dragging inside a selection with a marquee tool moves the outline, not the pixels | 0.6 s |  |
| pass | Lasso makes a freehand selection matching the traced shape | 1.1 s |  |
| pass | Polygonal Lasso closes with Enter, by clicking the start point, and supports Backspace | 0.6 s |  |
| pass | Magnetic Lasso snaps a rough trace onto a high-contrast edge | 0.6 s | IoU 0.972 |
| pass | Magic Wand selects by colour: contiguous, non-contiguous and tolerance | 0.5 s |  |
| pass | Select All, Deselect and Inverse (menu and shortcuts) | 0.8 s |  |
| pass | Feather, Expand, Contract and Border reshape the selection through their dialogs | 1.9 s |  |
| pass | a feathered selection fades edits smoothly | 0.5 s |  |
| pass | Color Range previews live and selects by similarity to the foreground colour | 0.7 s |  |
| pass | Delete clears the selection to transparency; Fill and Stroke use it | 1.1 s |  |
| pass | Move tool cuts and moves the selected pixels; the selection follows | 0.7 s |  |
| pass | Copy and Paste put the selection on a new layer in place; Cut removes the source | 0.8 s |  |
| pass | transforming a selection scales just the selected pixels and the outline | 0.7 s |  |
| pass | Load Layer Transparency and Crop to Selection | 0.5 s |  |
| pass | selection history: undo and redo restore earlier selections | 0.8 s |  |
| pass | the marching-ants outline is drawn on screen | 0.7 s |  |

### Smart features (11/11)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | Select Subject isolates the subject on a plain backdrop (on-device) | 0.6 s | IoU 0.914 against ground truth |
| pass | Select Subject on the sample scene finds the balloon | 0.8 s | IoU 0.968 on a graded sky with ridgelines, 0.967 with a contrast curve added (heuristic, not a neural model) |
| pass | Select Subject reports honestly when there is nothing to find | 0.4 s |  |
| pass | Remove Background hides the backdrop with an editable mask and keeps the pixels | 0.6 s |  |
| pass | Object Select finds the object inside a dragged box and ignores others | 0.8 s |  |
| pass | Auto Colour adds an editable Curves layer that neutralises a cast and stretches tone | 0.4 s |  |
| pass | Auto Enhance adds separate adjustment layers; Editing Suggestions reflect measured problems | 0.9 s | dark image: 4 suggestions; balanced image: 1 |
| pass | Smart Crop proposes a frame around the detail at the chosen ratio, applied with Enter | 0.6 s |  |
| pass | Content-Aware Fill removes a selected object using its surroundings | 0.7 s |  |
| pass | Generative Fill is not faked: it names the missing dependency and offers configuration | 0.6 s |  |
| pass | the provider interface calls a configured endpoint and places the result as a masked layer | 1.0 s |  |

### Tools (24/24)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | every toolbar button activates its tool, shows options and a usage hint | 1.7 s |  |
| pass | Brush paints the foreground colour with the set size; undo removes the stroke | 0.6 s |  |
| pass | Brush opacity caps a whole stroke (no build-up within it), flow builds up, soft edges fade | 1.0 s |  |
| pass | Pencil draws hard, unantialiased pixels | 0.5 s |  |
| pass | Eraser clears to transparency on a layer and reveals the layer below | 0.5 s |  |
| pass | Paint Bucket fills the contiguous region only, respecting tolerance | 0.4 s |  |
| pass | Gradient runs from foreground to background along the drag, linear and radial | 0.6 s |  |
| pass | Eyedropper picks foreground on click and background with Alt; averages when asked | 0.4 s |  |
| pass | Clone Stamp copies pixels from the Alt-clicked source | 0.6 s |  |
| pass | Healing Brush transfers texture but matches the destination colour | 0.5 s |  |
| pass | Spot Healing removes a blemish using its surroundings | 0.5 s |  |
| pass | Blur softens and Sharpen strengthens an edge under the brush | 1.9 s | edge step 255 → 84 (blur) → 178 (sharpen) |
| pass | Smudge drags colour along the stroke | 0.7 s |  |
| pass | Dodge lightens and Burn darkens the painted area | 0.7 s |  |
| pass | Text tool creates an editable text layer; typing, restyling and re-editing all work | 1.1 s |  |
| pass | an empty text box leaves no layer behind | 0.4 s |  |
| pass | Shape tool draws rectangle, ellipse, polygon, star and line as editable vector layers | 1.2 s |  |
| pass | shape properties stay editable: fill, gradient, border, corner radius, geometry | 0.9 s |  |
| pass | vector layers resize and rotate with on-canvas handles (Move tool) | 0.8 s |  |
| pass | Pen tool draws a custom path and edits its anchor points afterwards | 0.8 s |  |
| pass | Crop tool trims the canvas with Enter and Undo restores the original | 0.7 s |  |
| pass | Crop honours a fixed aspect ratio and can keep hidden pixels | 0.4 s |  |
| pass | Zoom tool, wheel zoom, Hand tool, Space-drag and Fit all navigate the view | 0.9 s |  |
| pass | paint tools explain themselves on text, group and hidden layers instead of failing silently | 0.7 s |  |

### Interface (18/18)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | every menu item is wired to a registered command (no dead entries) | 2.8 s | 147 menu entries, all bound to commands |
| pass | every enabled command with no dialog runs on the sample document without throwing | 16.9 s | 80 commands executed directly, 25 filter commands opened |
| pass | dark and light themes switch, restyle the workspace and keep text readable | 1.2 s |  |
| pass | the hosting page can request the light theme; an in-app choice overrides it | 0.6 s |  |
| pass | panels: resize the dock and splitter, switch tabs, hide/restore, reset; layout persists | 1.4 s |  |
| pass | the canvas view follows panel resizing and window resizing without distortion | 0.5 s |  |
| pass | colour panel: picker, hex field, swatches, swap and the foreground/background targets | 0.4 s |  |
| pass | brush panel and options bar stay in sync and drive the tool | 0.6 s |  |
| pass | tooltips name each tool with its shortcut and what it does | 1.3 s |  |
| pass | canvas context menu adapts to the selection and runs commands | 0.3 s |  |
| pass | menus are keyboard-navigable and close on Escape or outside click | 0.6 s |  |
| pass | multiple documents: tabs switch independent sessions with their own history and view | 0.6 s |  |
| pass | busy indicator appears during long operations and errors surface as toasts | 1.7 s |  |
| pass | phone width (400 px): no sideways page scroll, tools reachable, panels open as a drawer | 0.7 s |  |
| pass | touch: one finger paints, two fingers pinch-zoom and cancel the stroke | 0.3 s |  |
| pass | performance on a 24-megapixel document: strokes use dirty rectangles and stay interactive | 3.2 s | full composite 105 ms; 80×80 dirty-rect 1.4 ms; 40-step brush stroke 1773 ms; proxy preview 19 ms at 23% scale |
| pass | memory: opening, editing and closing 20 documents does not leak | 3.9 s | JS heap 2.3 → 2.4 → 2.4 MB after 3 / 23 / 43 documents; 26 bus listeners, 336 DOM nodes (unchanged) |
| pass | unexpected runtime errors are caught and reported instead of breaking the app | 0.5 s |  |

### History, shortcuts and canvas (13/13)

| Result | Test | Time | Measured |
|---|---|---:|---|
| pass | undo/redo walk the whole history with keyboard shortcuts and return identical pixels | 1.5 s |  |
| pass | History panel: click to jump, later states grey out, a new edit discards the redo branch | 1.3 s |  |
| pass | undo restores structure too: layer order, names, masks, selection and canvas size | 0.6 s |  |
| pass | history shares unchanged layers between states and stays within its limits | 1.6 s | 36 states of a 6-layer 3 MP document: 412 MB (naive 2472 MB); capped at 60 states / 744 MB |
| pass | undo during an unfinished interaction is safe (stroke in progress, text being typed, transform open) | 1.1 s |  |
| pass | tool shortcuts select tools; X/D manage colours; brackets and digits adjust the brush | 1.4 s | 24 tool shortcuts verified |
| pass | command shortcuts: layers, selection, view, fill, panels, fullscreen fallback | 1.2 s |  |
| pass | shortcuts do not fire while typing in a field | 0.4 s |  |
| pass | Image Size resamples every layer and keeps proportions | 0.6 s |  |
| pass | Canvas Size extends or trims around an anchor without scaling | 0.6 s |  |
| pass | Rotate Canvas and Flip Canvas map pixels, vector layers and masks correctly | 0.5 s |  |
| pass | per-layer Flip and Rotate act about the layer centre and leave others alone | 0.7 s |  |
| pass | full workflow: open photo → adjust → retouch → mask → text → save project → reopen → export | 2.5 s | 10 history steps; project 41 KB; exported photo.png 13 KB |

## Unit results (48/48)

- pass — brush tip falloff: solid core, smooth rim, zero outside
- pass — dodge lightens, burn darkens, range targets the right tones
- pass — blur patch lowers variance and is stable under repetition
- pass — smudge carries colour from where the brush has been
- pass — heal copies source texture but shifts it to the destination colour
- pass — inpaint fills a hole from its surroundings
- pass — inpaint interpolates a gradient across the hole
- pass — subject detection isolates an object from a plain background
- pass — subject detection reports nothing on a featureless image and honours a search box
- pass — auto colour stretches a flat, tinted image toward full range and neutral
- pass — suggestions respond to measured problems and stay quiet on a balanced image
- pass — smart crop keeps the detailed region and matches the requested aspect
- pass — zip: CRC-32 reference value, store/unzip round trip, unicode names
- pass — zip: garbage and truncated archives are rejected with a clear error
- pass — exif reader ignores non-JPEG and malformed input
- pass — colour: hex round trip and shorthand
- pass — colour: HSV and HSL round trips are lossless within 1 level
- pass — brightness/contrast: brightness shifts, contrast pivots on mid grey
- pass — exposure: +1 EV doubles linear values and clips at white
- pass — hue/saturation: -100 saturation is grey, 180° hue turns red to cyan, alpha untouched
- pass — vibrance: muted colours gain more saturation than vivid ones
- pass — temperature/tint: warm raises red and lowers blue; tint moves green against magenta
- pass — levels: input range remaps to full range, output range limits it, single channel works
- pass — curves: identity is a no-op; the curve passes through its control points and is monotone
- pass — colour balance: pushing midtones to red raises red; preserve-luminosity keeps luma
- pass — black & white: output is neutral, channel weights change tone
- pass — shadows/highlights: shadows lift dark areas and leave bright ones nearly alone
- pass — vignette: corners darken, centre does not, and tiles agree with a full render
- pass — gaussian blur: keeps a flat field flat, spreads an impulse symmetrically, conserves energy
- pass — gaussian blur: transparent neighbours do not bleed dark fringes (premultiplied)
- pass — motion blur: spreads along its angle only
- pass — unsharp mask raises edge contrast; noise reduction lowers variance but keeps a strong edge
- pass — invert twice is identity; threshold is two-valued; posterize limits levels
- pass — mosaic: cells are uniform and aligned to document coordinates across tiles
- pass — every filter runs on its defaults without NaN and leaves opaque alpha opaque
- pass — unknown filter throws a descriptive error
- pass — blendThroughMask mixes original and filtered by coverage
- pass — histogram and percentile
- pass — combine: add, subtract, intersect and replace
- pass — invert, bounds, emptiness, area
- pass — feather produces a soft edge and keeps the centre solid
- pass — flood select: contiguous stops at borders, global mode finds all matches, tolerance widens
- pass — flood select treats fully transparent pixels as one region
- pass — grow: expand and contract by Euclidean distance; border is a band around the edge
- pass — translate shifts and clips
- pass — outline of a rectangle is four merged edge segments
- pass — colour range is soft and centred on the target colour
- pass — largest component keeps the biggest blob and fills enclosed holes
