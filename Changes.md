

5.0
-------------
**Breaking changes**
* `Layout.onLayout` renamed to `onInnerRect` — it always delivered the inner/content rect, never the rect passed to `setRect()`; the old name is kept as a deprecated alias for one release
* Adding a child to `GridLayout`/`VerticalLayout`/`HorizontalLayout` no longer mutates the child's or the container's alignment as a side effect — request stretch explicitly (`stretch()`, `setAlignment(Layout.AlignStretch)`, `setRowStretch`, `setColStretch`)
* `Layout.mBLeft`/`mBTop`/`mBRight`/`mBBottom` renamed to `borderLeft`/`borderTop`/`borderRight`/`borderBottom`, and are now read-only outside `Layout` itself
* `Layout.hx` split into one file per class — code relying on a bare `import gm2d.ui.Layout` to also reach `BorderLayout`, `GridLayout`, `StackLayout`, etc. needs its own import per type (or `import gm2d.ui.*`)
* `Button.create()`/`BMPButton()`/`BitmapButton()`/`TextButton()`/`BMPTextButton()` static factories removed — construct `Button`, `BitmapButton` (renamed from `BmpButton`), or the new `TextButton` class directly instead
* Waxe IDE integration (`WaxeDialog`) removed
* See `docs/Migration-v5.md` for a detailed, mechanical migration guide (entries LAY-001 through LAY-005)

**New features**
* `getMinSize()` is now width-aware (optional `inWidth` argument), giving wrapped/multiline text a real reflowed minimum height instead of a fixed heuristic
* `getBestWidth()`/`getBestHeight()` now guarantee `best >= min` for every built-in layout, regardless of whether the value came from an explicit override or a computed default

**Other notable fixes**
* Button text now stretches to fill its box by default, so `textAlign` (left/center/right) actually has an effect instead of being overridden by a hardcoded center alignment
* The layout cache is now exception-safe — an error mid-layout no longer permanently corrupts later layout calls for the rest of the process

4.4
-------------
**Breaking changes**
* `Skin` converted from a static-based class to an instance-based class — code that accesses `Skin` members statically must be updated to use a skin instance
* `DialogScreen` parameter order corrected — callers of `DialogScreen` should verify argument order
* Edge line width no longer automatically sets widget margin/padding — set these explicitly if your layout relied on that behaviour

**New features**
* `Game.isMainWindow` — query whether the current window is the main application window
* `Game` now has an over-all overlay and a `Timeline`
* `Ado` watchers — observe value changes reactively
* `Ado.setDo` extend mode for composing undo actions
* `autoKeyboard` mode — automatically highlights the current focusable element
* Space bar activates the focused control; arrow keys work in `NumericInput`
* Esc closes popup menus
* Ctrl-H mapped to delete in keyboard shortcut handling
* `FillBitmapStretch` fill style added to skin
* `ComboBox` supports `DisplayObject` items (renders graphics in the drop-down)
* Sub-menu popup logic for `SpriteMenuBar`; widgets can be added directly to `SpriteMenuBar`
* RadioBox style for `MenuGroup` items
* `textRotation` attribute for text widgets
* `columnWidth:Float` attribute
* `textBorder` property for layout debugging
* `undoNoReturns` helper on `Ado`
* `ProgressDialog` shows optional time-to-completion / time-remaining estimate
* Indeterminate progress bar (total time unknown)
* `Skin.Renderer.setFill` now receives explicit width/height
* `ScrollWindow` layout: `setScrollRange`, `getBestWidth/getBestHeight` overrides, better list integration

**Other notable fixes**
* Mouse events on a different window are now filtered out
* Click events on different windows filtered; `CheckButton` rendering deferred to skin
* `ListControl` clears scroll state on list clear
* `NumericInput` quantizes value to step size; slider rounds to nearest value
* `BmpButton` respects widget disabled state
* `DocumentParent` can have no background
* `DisplayLayout.setBestSizes` now includes borders
* Multiline text layout recalculated correctly on width change

4.3
-------------

* Haxe 4 property fixes
* Propagate activate messages to parents

4.0.21
-------------
* Move some skin classes around, including renaming Style -> Shape
* Widget states are now sub-attributes rather than their own thing.
* Bunch of other stuff
* Added wwx2015 sample

3.4
-------------
* Added scaling and end condition to Tilemap example
* Improved Svg parsing
* More keyboard navigation
* Added ShadowRect fill type
* Added TileControl
* Allow labels inside numeric controls
* Animate the scrollTo position

-------------
* Better integration with waxe
* Added Undo class
* Reworked the ui system completely

-------------
* Removed the typedefs - let nme do this now

Version 3.1.0
-------------
Imported from google code

