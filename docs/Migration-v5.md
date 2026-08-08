# gm2d v5 Migration Guide

This guide tracks breaking changes being made to `gm2d/ui` (see [`Layout.md`](Layout.md) for the
design background) as they're decided, so downstream consumers — human or an automated coding
agent — can update their code mechanically instead of re-deriving what changed.

**Status of this document:** living draft. Entries are added as design decisions in the v5 layout
rework are finalized. Each entry's `Status` says whether it's `planned` (decided, not yet
implemented in gm2d) or `shipped` (implemented on the `master` branch — no formal v5 release has
been tagged yet, so "shipped" here means "in the source now," not "in a published haxelib
version").

## How to use this guide (for an agent)

For each entry below:

1. Run the command in **Detect** against the target codebase to find candidate sites. If an entry
   has no reliable detect pattern (marked `manual`), it's a behavior change, not an API change —
   flag it for human review instead of attempting an automatic edit.
2. For each match, apply the transform described in **Fix** — it's written to be followed
   mechanically (exact substitution, not "roughly like this").
3. Do not apply a `planned` entry's fix until its `Status` says `shipped` in the gm2d version you're
   actually depending on — check the entry's **Shipped in** field.

| ID | Title | Kind | Status | Auto-fixable |
|---|---|---|---|---|
| [LAY-001](#lay-001--layoutonlayout-renamed-to-layononinnerrect) | `Layout.onLayout` → `Layout.onInnerRect` | rename | shipped | yes |
| [LAY-002](#lay-002--addingchild-no-longer-mutates-alignmentstretch) | `add()` no longer mutates alignment/stretch | behavior | shipped | no (manual audit) |
| [LAY-003](#lay-003--layouthx-split-into-one-file-per-class-import-gm2duilayout-no-longer-reaches-sibling-types) | `Layout.hx` split into one file per class — `import gm2d.ui.Layout` no longer reaches sibling types | import breakage | shipped | yes |
| [LAY-004](#lay-004--mbleftmbtopmbrightmbbottom-renamed-to-borderleftbordertopborderrightborderbottom) | `mBLeft`/`mBTop`/`mBRight`/`mBBottom` → `borderLeft`/`borderTop`/`borderRight`/`borderBottom`, now read-only | rename | shipped | yes |
| [LAY-005](#lay-005--buttonhx-restructured-static-factories-removed-bmpbutton-renamed-textbutton-promoted) | `Button.hx` restructured: static factories removed, `BmpButton`→`BitmapButton`, `TextButton` promoted to a real class | rename + removal | shipped | yes |
| [SKIN-001](#skin-001--skin-construction-always-fully-initializes-named-colour-fields-replaced-by-a-palette-map) | `Skin` construction always fully initializes; named colour fields (`guiLight` etc.) replaced by a palette map | removal + rename | shipped | partial (see below) |
| [SKIN-002](#skin-002--attribset-values-are-now-dpi-independent-logical-units-resolved-once-at-renderer-construction) | `attribSet`/custom skin attribs values are now DPI-independent logical units, not pre-scaled pixels | behavior | shipped | partial (see below) |
| [SKIN-003](#skin-003--skinscale-renamed-to-skintopixels-new-widgetonscalechanged-hook) | `Skin.scale()` → `Skin.toPixels()`; new `Widget.onScaleChanged()` hook | rename + new hook | shipped | yes (rename) / no (hook) |
| [SKIN-004](#skin-004--attribstextcolor-retyped-int--textcolour) | `Attribs.textColor` retyped `Int` → `TextColour` | retype | shipped | no (manual — pick the matching role) |
| [SKIN-005](#skin-005--skinshadowfilterscurrentfilters-replaced-by-a-named-filterset-palette) | `Skin.shadowFilters`/`currentFilters` replaced by a named `FilterSet` palette (`Attribs.filters`/`chromeFilters` retyped) | removal + retype | shipped | no (manual — describe the filter, don't construct one) |
| [SKIN-006](#skin-006--default-menubar-is-now-theme-following-light-instead-of-a-fixed-dark-bar) | Default `Menubar`/`MenubarItem` now use theme-following colours instead of a fixed dark bar | behavior | shipped | no (visual re-check) |
| [SKIN-007](#skin-007--live-skin-propagation-widgetsetskin-gamesetskin) | Live skin propagation: new `Widget.setSkin()`/`Window.setSkin()`/`Game.setSkin()` | new API | shipped | n/a (additive) |
| [SKIN-008](#skin-008--progressstyle-retyped-to-fillstylelinestyle-margin-and-shaperoundrectrads-radius-now-auto-scaled) | `ProgressStyle` retyped to `FillStyle`/`LineStyle`; `margin` and `ShapeRoundRectRad`'s radius now auto-scaled | retype + behavior | shipped | partial (see below) |
| [SKIN-009](#skin-009--skincreatebitmapdatas-inwidth-is-now-a-logical-unit-fixes-a-uiscale²-double-scale-on-svg-backed-icons) | `Skin.createBitmapData`'s `inWidth` is now a logical unit — fixes a `uiScale²` double-scale on SVG-backed icons | bugfix + behavior | shipped | yes |

---

## LAY-001 — `Layout.onLayout` renamed to `Layout.onInnerRect`

- **Kind:** rename
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** yes — v5 will ship the old `onLayout` field as a `@:deprecated`
  property that forwards to `onInnerRect`, so old code keeps compiling (with a warning) for one
  release before the shim is removed. If your build treats compiler warnings as errors, this will
  behave as a hard break instead — check that setting before upgrading.

**Detect:**

```sh
grep -rn '\.onLayout\s*=' --include='*.hx' .
```

**Old:**

```haxe
someLayout.onLayout = myHandler;
```

**New:**

```haxe
someLayout.onInnerRect = myHandler;
```

**Why:** `Layout.setRect(x,y,w,h)` always insets by the layout's own border/margin before invoking
this callback (see [`Layout.md` §5](Layout.md)) — the rect delivered is the *inner/content* box,
never the rect that was actually passed to `setRect()`. The name `onLayout` didn't communicate
that, and every real caller in gm2d itself already renamed the *handler function* it assigned
(`setClientRect`, `setClientSize`, `layoutTabs`, ...) to compensate. `onInnerRect` makes the
contract explicit at the field itself.

**Fix (agent instructions):** For every assignment matching `<expr>.onLayout = <handler>;`,
replace `.onLayout` with `.onInnerRect`. Do not change `<expr>` or `<handler>` — the handler's
signature (`Float->Float->Float->Float->Void`, args are `x,y,w,h` of the inner/content rect) and
runtime semantics are unchanged; this is a pure rename. This includes inline function literals
assigned directly, e.g.:

```haxe
// old
layout.onLayout = function(x,y,w,h) { ... };
// new
layout.onInnerRect = function(x,y,w,h) { ... };
```

If the codebase also *reads* `onLayout` anywhere (not just assigns it) — e.g.
`if (widget.getLayout().onLayout != null)` — rename that reference too; the getter shim covers
reads as well as writes, but there's no reason to keep depending on the deprecated name once it's
been found.

**Caveat found while applying this:** the Detect pattern also matches `gm2d.ui.Pane.onLayout` —
an unrelated, still-current setter property declared on `Pane` itself (`public var
onLayout(never,set):Void->Void`) that just forwards internally to `getLayout().onInnerRect` on
Pane's behalf. It is not the field this entry renames. Renaming a `pane.onLayout = handler;` site
to `pane.onInnerRect` breaks the build (`gm2d.ui.Pane has no field onInnerRect`) since `Pane` never
had (and doesn't need) that field. Before applying the rename to a match, check what the receiver
actually is: only rename it if the receiver's static type is `Layout` (e.g. `someLayout.onLayout =
...`, or `widget.getLayout().onLayout = ...`) — leave `somePane.onLayout = ...` alone whenever the
receiver is a `Pane` (or anything else that isn't `Layout`).

---

## LAY-002 — Adding a child no longer mutates alignment/stretch

- **Kind:** behavior change (no API rename — same method names, different runtime behavior)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** none possible — this is a silent behavior change, not a renamed or
  removed symbol.

**Detect:** `manual` — there is no reliable textual pattern. You have to identify call sites where
the *previous* implicit-mutation behavior was actually relied upon, which requires either visual
regression testing or knowledge of which layouts were built assuming it.

**Old behavior:**

- `GridLayout.add(child)`: if `child`'s alignment requested `AlignStretch` on an axis the grid
  didn't already have an explicit stretch for, the grid would infer `mStretch = 1` for that
  row/column **and**, if the grid's alignment hadn't been explicitly set yet, silently clear the
  **grid's own** alignment bit on that axis too (affecting how the grid itself behaves when it's
  later added to some other container).
- `VerticalLayout.add(child)` / `HorizontalLayout.add(child)`: if the target row/column had
  already been marked stretch via `setRowStretch`/`setColStretch`, the **child's** alignment bits
  on the matching axis were forcibly cleared at insertion time — overriding whatever alignment the
  child itself had requested.

**New behavior:** `add()` never mutates `mAlign` on anything, in either direction. Stretch is only
ever set explicitly:

- On a widget/layout itself: `.stretch()` or `.setAlignment(Layout.AlignStretch)` (or
  `.setHorizontalAlignment`/`.setVerticalAlignment`).
- On a container's row/column: `.setRowStretch(row, amount)` / `.setColStretch(col, amount)` /
  `.rowStretch([...])` / `.colStretch([...])`.

**Why:** the old behavior meant "will this widget stretch?" depended on insertion order (whether
`setRowStretch`/`setColStretch`/`setAlignment` was called before or after `add()`), and on two
different, contradictory directions of implicit inference (see [`Layout.md` §3](Layout.md)). That
made it impossible to answer by reading construction code top-to-bottom.

**Fix:** if, after upgrading, something that used to fill its cell now shrinks to its best size (or
vice versa), it was relying on the old implicit inference. Add the explicit call that expresses the
intent:

```haxe
// container side — this row/column should stretch
grid.setRowStretch(rowIndex, 1);      // or setColStretch
// or, on the widget/layout being added — this item should stretch
widget.stretch();                      // or widget.setAlignment(Layout.AlignStretch)
```

**Fix (agent instructions):** this cannot be found or fixed by pattern matching — it's a rendering
behavior change with no textual signature. Do not attempt an automatic transform. Instead:

1. Flag this entry to the user as requiring visual re-verification of any screen using
   `GridLayout`/`VerticalLayout`/`HorizontalLayout` after upgrading.
2. If the user reports a specific widget/container that changed appearance, diagnose by checking
   whether that widget or its container previously relied on the old inference (i.e., neither side
   called `stretch()`/`setAlignment()`/`setRowStretch()`/`setColStretch()` explicitly), and add the
   explicit call shown above to restore the intended layout.

---

## LAY-003 — `Layout.hx` split into one file per class; `import gm2d.ui.Layout` no longer reaches sibling types

- **Kind:** import breakage (compile error, not a rename of anything you're using)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** yes, indirectly — this fails as a normal Haxe "type not found"
  compile error at each affected reference, so every break surfaces immediately at build time; it
  is not a silent behavior change.

**Background:** today, `Layout`, `BorderLayout`, `DisplayLayout`, `TextLayout`,
`AutoTextLayout`, `StackLayout`, `PagedLayout`, `ChildStackLayout`, `ColInfo`, `RowInfo`,
`GridLayout`, `VerticalLayout`, `HorizontalLayout`, and `FlowLayout` are all declared in the one
module `gm2d/ui/Layout.hx`. v5 splits this into one file per class. A bare
`import gm2d.ui.Layout;` in external code may currently be enough to also reach the sibling
classes declared in that same module; after the split, each type lives in its own module and must
be reached via its own import (or a wildcard).

**Detect:**

```sh
grep -rln '^import gm2d\.ui\.Layout;[[:space:]]*$' --include='*.hx' .
```

For each matching file, check whether it references any of the other names from the list above as
a bare (unqualified) identifier — those references are the ones at risk.

**Old:**

```haxe
import gm2d.ui.Layout;
...
var g = new GridLayout(2);
g.add(new BorderLayout(itemLayout, true));
```

**New (two options — pick based on how many sibling types are actually used):**

```haxe
// broad — restores "everything from gm2d.ui" reach, closest to old behavior
import gm2d.ui.*;
```

```haxe
// narrow — only the specific types this file actually references
import gm2d.ui.Layout;
import gm2d.ui.GridLayout;
import gm2d.ui.BorderLayout;
```

**Fix (agent instructions):** for each file found by **Detect**:

1. Search the file for bare references to any of: `BorderLayout`, `DisplayLayout`, `TextLayout`,
   `AutoTextLayout`, `StackLayout`, `PagedLayout`, `ChildStackLayout`, `ColInfo`, `RowInfo`,
   `GridLayout`, `VerticalLayout`, `HorizontalLayout`, `FlowLayout` (as type usages — `new X(...)`,
   `:X`, `X.someStatic`, etc., not inside strings/comments).
2. If none are found, no change is needed for this file (it only ever used `Layout` itself).
3. If one or two are found, add an explicit `import gm2d.ui.<Name>;` line for each, next to the
   existing `import gm2d.ui.Layout;`.
4. If three or more are found, replace `import gm2d.ui.Layout;` with `import gm2d.ui.*;` instead
   of adding many individual lines — simpler and matches the pre-split reach most closely. **Before
   doing this, check the same file for any bare (unqualified) reference to a class also named `App`
   (or another common/generic name that also exists somewhere in `gm2d.ui`, e.g. `Widget`, `Size`,
   `Button`).** A wildcard import doesn't error at the import line if such a collision exists — it
   silently shadows the consuming codebase's own type with the `gm2d.ui` one, and the resulting
   errors show up far from the actual cause and look unrelated (e.g. `gm2d.ui.App has no field
   projectAdd`, or `gm2d.ui.App should be ed.App`). If a same-named type is referenced bare anywhere
   in the file, use explicit per-type imports instead of the wildcard even when three or more
   sibling types are used.
5. After editing, recompile — any remaining "Type not found" errors for these names point at a
   file this grep-based sweep missed (e.g. types referenced only inside a macro or via
   `Type.resolveClass`), and should be fixed the same way by hand.

**One extra wrinkle found while implementing this:** `LayoutList` (the `typedef LayoutList =
Array<Layout>` declared alongside `Layout` itself) is a typedef, not a class — `import
gm2d.ui.LayoutList;` does **not** resolve for a typedef the way it does for a secondary class.
Use the submodule form instead: `import gm2d.ui.Layout.LayoutList;`. If your sweep finds bare
`LayoutList` references failing to resolve after adding what looks like the right import, this is
why — swap to the dotted form.

---

## LAY-004 — `mBLeft`/`mBTop`/`mBRight`/`mBBottom` renamed to `borderLeft`/`borderTop`/`borderRight`/`borderBottom`

- **Kind:** rename (also: read-only from outside `Layout` itself)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** yes — this fails as a normal "Unknown identifier" compile error at
  every reference, so nothing silently keeps using the old names.

**Detect:**

```sh
grep -rnE '\b(mBLeft|mBTop|mBRight|mBBottom)\b' --include='*.hx' .
```

**Old:**

```haxe
layout.mBLeft; layout.mBTop; layout.mBRight; layout.mBBottom
```

**New:**

```haxe
layout.borderLeft; layout.borderTop; layout.borderRight; layout.borderBottom
```

**Why:** camelCase, consistent with the rest of the renamed API, and the new names are properties
with a read-only public accessor (`(default,null)`) — only `Layout` itself (which declares them)
can assign them; use `setBorders()`/`setPadding()`/`setIndent()`/`setOffset()` to change them
from outside.

**Fix (agent instructions):** for each match, replace the old identifier with the new one
1:1 — `mBLeft`→`borderLeft`, `mBTop`→`borderTop`, `mBRight`→`borderRight`,
`mBBottom`→`borderBottom`. Pure rename, no signature or semantic change for reads. If a match is
an *assignment* (`layout.mBLeft = x;`) from code outside the `Layout` class hierarchy, that
assignment is no longer possible at all post-rename (the property is read-only) — flag it for
human review rather than rewriting it, since there's no mechanical equivalent (the nearest
built-in setters change all four sides together via padding/borders, not one side in isolation
the way `setIndent()` does only for the left side).

---

## LAY-005 — `Button.hx` restructured: static factories removed, `BmpButton`→`BitmapButton`, `TextButton` promoted

- **Kind:** removal + rename (constructors replace static factory methods)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** yes — each removed method fails as "Class<gm2d.ui.Button> has no
  field ..." at every call site.

**Detect:**

```sh
grep -rnE 'Button\.(create|BMPButton|BitmapButton|TextButton|BMPTextButton)\(' --include='*.hx' .
```

**Old → New**, per removed static method:

| Old | New |
|---|---|
| `Button.create(?lineage, ?attribs, ?onClick)` | `new Button(null, onClick, lineage, attribs)` |
| `Button.BMPButton(bmp, ?onClick, ?lineage, ?attribs)` | `new BitmapButton(bmp, onClick, lineage, attribs)` |
| `Button.BitmapButton(bmp, ?onClick, ?lineage, ?attribs)` | `new BitmapButton(bmp, onClick, lineage, attribs)` |
| `Button.TextButton(?skin, text, onClick, ?lineage, ?attribs)` | `new TextButton(skin, text, onClick, lineage, attribs)` |
| `Button.BMPTextButton(bmp, text, ?onClick, ?lineage, ?attribs)` | `new Button(null, onClick, Widget.addLine(lineage,"BMPTextButton"), Widget.addAttribs(attribs, {icon:bmp, text:text}))` |

Also: the class `BmpButton` (the concrete bitmap-button subclass `Button.BMPButton`/
`Button.BitmapButton` used to construct) is renamed `BitmapButton`, and moved to its own file —
any direct reference to the type name `BmpButton` (not just the removed static wrapper) needs the
same rename.

**Why:** `Button.BMPButton()` and `Button.BitmapButton()` had *identical* bodies — both just
forwarded to `new BmpButton(...)` — and `Button.create()`/`Button.TextButton()`/
`Button.BMPTextButton()` were all thin wrappers around a constructor call too. Since v5 is already
breaking the API, these were removed in favor of calling the constructors directly (`BitmapButton`
and the new `TextButton` class now do their own setup work in a real constructor, the same pattern
`BmpButton` already used). Note `Button`'s icon+text composite-construction *capability* (passing
`{icon:..., text:...}` attribs to a plain `new Button(...)`) still exists and is unchanged — only
the thin `BMPTextButton` wrapper around it was removed.

**Fix (agent instructions):** for each match from **Detect**, apply the corresponding row's
transform from the table above verbatim, preserving argument values and order. Separately, run:

```sh
grep -rnE '\bBmpButton\b' --include='*.hx' .
```

and rename every match to `BitmapButton`.

**On omitted optional arguments (e.g. `?skin`, `?lineage`):** old calls frequently omit one or more
leading/middle optional parameters to reach a later one positionally, e.g.
`Button.TextButton("From Ed", onClick, attribs)` (skipping both `?skin` and `?lineage` to supply
`attribs`). Haxe resolves this by matching the given arguments against the remaining parameter
types — which is exactly why it compiled before without an explicit `null`. That type-directed
matching is not something to rely on when converting to the constructor call: it's only as safe as
the parameter types are mutually exclusive, and several of these constructors accept a generic
`Attribs`/`Dynamic`-shaped object (`attribs`) alongside other optional parameters, so a skipped slot
and a supplied one can occasionally be structurally compatible enough for Haxe to bind the argument
to the wrong parameter without a compile error. Passing an explicit `null` for every optional
parameter the old call skipped removes this ambiguity — it costs nothing at the call site and is
never wrong, so do it unconditionally rather than trying to determine case-by-case whether the
implicit match would have been safe. For the example above:

```haxe
// old
Button.TextButton("From Ed", onClick, attribs);
// new
new TextButton(null, "From Ed", onClick, null, attribs);
```

**New-module imports:** `TextButton` and `BitmapButton` are now their own modules (see
[LAY-003](#lay-003--layouthx-split-into-one-file-per-class-import-gm2duilayout-no-longer-reaches-sibling-types)
for the same concern applied to `Layout`'s siblings) — rewriting the call site is not sufficient by
itself. Every file that ends up with a bare `new TextButton(...)` or `new BitmapButton(...)` after
this transform also needs `import gm2d.ui.TextButton;` / `import gm2d.ui.BitmapButton;` (or an
existing `import gm2d.ui.*;`) — otherwise it fails as "Type not found" on a second compile pass
after the call-site rewrite already looked complete. Check for this in the same pass as the call
transform rather than waiting to discover it as a follow-up error.

---

## SKIN-001 — `Skin` construction always fully initializes; named colour fields replaced by a palette map

- **Kind:** removal + rename (constructor signature change; ~13 fields removed in favor of a map)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** yes — every break here is a normal compile error (wrong argument
  count, unknown identifier, or missing private field), nothing is a silent behavior change.

**Background:** this is the first step of a larger live-reskin/DPI-propagation rework (the design
isn't public yet). Two related changes shipped together:

1. `Skin`'s constructor no longer takes an `andInit` flag — it always fully initializes
   (`init()` always runs, and is now a private method, not independently callable). The old
   pattern of `new Skin(false)`, mutating fields, then calling `init()` explicitly no longer
   compiles.
2. The ~13 individually-named colour fields (`guiLight`, `guiMedium`, `guiTrim`, `guiHighlight`,
   `guiDark`, `guiVeryDark`, `guiLightText`, `guiButton`, `guiDisabled`, `guiBorder`,
   `rowSelectColour`, `rowEvenColour`, `rowOddColour`) are removed, replaced by a single
   `colours:Map<String,Int>` accessed via `getColour(key)`/`setColour(key,rgb)`, plus
   strongly-typed wrappers `setFillColor(FillStyle,rgb)`/`setLineColour(LineStyle,rgb)`. Map keys
   are the `FillStyle`/`LineStyle` constructor names (`FillLight` → `"FillLight"`,
   `LineBorder` → `"LineBorder"`, etc.) — `setColour`/`setFillColor`/`setLineColour` all reject
   unknown keys, so the set stays closed. Two new `FillStyle` cases, `FillMax` and `FillInv`, were
   added at the same time to close two raw-literal escape hatches (`FillSolid(0xffffff,1)` and
   `FillSolid(guiVeryDark,1)`) that used to appear in `gm2d`'s own skin definitions.

**Detect:**

```sh
grep -rn 'new Skin(\|\.init()\b' --include='*.hx' .
grep -rnE '\.(guiLight|guiMedium|guiTrim|guiHighlight|guiDark|guiVeryDark|guiLightText|guiButton|guiDisabled|guiBorder|rowSelectColour|rowEvenColour|rowOddColour)\b' --include='*.hx' .
```

**Old:**

```haxe
class AppSkin extends Skin
{
   public function new()
   {
      super(false);
      shadowFilters = [ new DropShadowFilter(...) ];
      menuHeight = scale(48);
      init();
      addAttribs("ProgressBar", { progressStyle: ProgressRoundRect(0x000000, guiHighlight, guiLight, ...) });
   }
}
```

**New:**

```haxe
class AppSkin extends Skin
{
   public function new()
   {
      super();
      addAttribs("ProgressBar", {
         progressStyle: ProgressRoundRect(0x000000, getColour("FillHighlight"), getColour("FillLight"), ...)
      });
   }
}
```

**Why:** this is laying the groundwork for `Skin` becoming copy-on-write (a later step adds a
`mutable` flag and `copyWithScale`/`copyWithPalette` factories for live DPI/palette changes). A
`Skin` that can be constructed, mutated, and re-initialized in two steps can't safely support an
identity-based "has this widget already seen this skin?" check. Collapsing the colour fields into
one map also means the whole customizable palette can be guarded and cloned with one check/one
copy, instead of needing a guarded property per field.

**Fix (agent instructions):**

1. For every `new Skin(false)` (or any subclass `super(false)`), remove the `false` argument, and
   remove the subsequent explicit `init()` call — construction now does that automatically.
2. Any field mutation that used to happen *between* `super(false)` and `init()` (so it would be
   picked up while `attribSet` was being built) needs to move to *after* `super()` returns, and
   for colours specifically, use `setColour`/`setFillColor`/`setLineColour` instead of direct field
   assignment (the fields no longer exist). **Caveat:** a handful of `attribSet` entries capture a
   colour's value only once, at construction time (e.g. `chromeFilters: shadowFilters` on
   `"Dialog"`/`"PopupMenu"`/`"PopupComboBox"`) — mutating after `super()` returns will not
   retroactively fix those entries. This is a known, temporary gap that a later step (moving
   filters to lazy/deferred resolution) closes properly; if you hit it, override the affected
   `attribSet` entry explicitly via `addAttribs()` after construction as a workaround, the same way
   `"Menubar"` already gets fully overridden in the old `AppSkin` example above.
3. For every `skin.guiXxx`/`skin.rowXxxColour` reference (external, qualified access), replace with
   `skin.getColour("FillXxx")` using this mapping: `guiLight`→`"FillLight"`,
   `guiMedium`→`"FillMedium"`, `guiButton`→`"FillButton"`, `guiDark`→`"FillDark"`,
   `guiHighlight`→`"FillHighlight"` (or `"LineHighlight"` if the call is a line/stroke operation,
   not a fill — both keys hold the same value today but are semantically distinct), `guiDisabled`→
   `"FillDisabled"`, `guiTrim`→`"LineTrim"`, `guiBorder`→`"LineBorder"`, `guiVeryDark`→`"FillInv"`,
   `guiLightText`→`"TextColInverse"`, `rowSelectColour`→`"FillRowSelect"`,
   `rowEvenColour`→`"FillRowEven"`, `rowOddColour`→`"FillRowOdd"`.
4. If the call site is setting rather than reading a colour, use `skin.setColour("FillXxx", rgb)`
   (or `setFillColor(FillLight, rgb)`/`setLineColour(LineBorder, rgb)` if a `FillStyle`/`LineStyle`
   value is already in hand) instead of the old direct field assignment.
5. Recompile and fix any remaining "Unknown identifier" on one of the removed field names the same
   way — the compiler will find every remaining site.

**Also in this step:** symmetric getters `getFillColour(FillStyle):Int`/`getLineColour(LineStyle):Int`
were added alongside `setFillColor`/`setLineColour` (same `Type.enumConstructor`/
`Type.enumParameters` mechanism). `Renderer.setFill`/`setLine`'s big per-role switch cases collapsed
to a single `default: inGraphics.beginFill(skin.getFillColour(inFillStyle));` (payload-carrying
cases like `FillSolid`/`FillRowOdd`/gradients still get their own explicit case; only the plain
named-role cases collapsed) — adding a new named role no longer requires touching `Renderer.hx` at
all. A new `LineStyle.LineSolidFill(width:Float, fill:FillStyle, a:Float)` case was added for
solid lines that need a custom width but a deferred (not baked) colour — e.g. `"DocumentFrame"`'s
border used to bake `LineSolid(scale(2), skin.getColour("FillLight"), 1)` at construction time,
which defeats live re-resolution the same way the removed raw fields did; it's now
`LineSolidFill(scale(2), FillLight, 1)`, resolved live at draw time. **General rule going forward:**
never call `getColour`/`getFillColour`/`getLineColour` inside an `attribSet` literal to bake a
value into a `FillSolid`/`LineSolid` payload — if the color should just be a named role, use the
bare case (`fill: FillLight`, not `fill: FillSolid(skin.getColour("FillLight"),1)`); if it needs a
custom width, use `LineSolidFill`. `getColour`/`getFillColour`/`getLineColour` are for genuinely
immediate/live uses (inside a function that runs at draw time, like `Renderer.setFill` itself, or a
bitmap factory), not for values captured once when `attribSet` is built.

**Not yet enforced:** `Skin` also gained a `mutable:Bool` field and a guarded `uiScale` property in
this step, plus `copyWithScale`/`copyWithPalette` factories — but nothing yet flips `mutable` to
`false` (that happens when the not-yet-built `setSkin()` propagation mechanism lands). Until then,
every `Skin` stays mutable for its whole lifetime; the guard exists but is dormant.

---

## SKIN-002 — `attribSet` values are now DPI-independent logical units, resolved once at `Renderer` construction

- **Kind:** behavior change (no field renamed or removed; values that used to be pre-scaled pixels
  are now logical units, resolved once when a `Renderer` is built from combined attribs)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** none — this is a silent behavior/appearance change for any custom skin
  code that still wraps a value in `scale()` before putting it in an attribs literal.

**Background:** `Skin.hx`'s default `attribSet` used to call `scale(N)` inline wherever a size
appeared (`padding: new Rectangle(scale(2),scale(2),scale(4),scale(4))`, `fontSize: scale(16)`,
etc.) — baking the *current* DPI-scaled pixel value into the attribs literal at construction time.
That's gone: every number in the default `attribSet` is now a bare logical unit (e.g.
`new Rectangle(2,2,4,4)`, `fontSize: 16`). Resolution to real pixels happens exactly once, later,
either in `Renderer`'s constructor (for `offset`, `padding`, `minSize`, `minItemSize`, `fontSize` —
the fields it extracts into its own typed members) or, for the handful of fields read ad-hoc via
`Renderer.getDefaultFloat`/`Widget.attribFloat` instead of through `Renderer`'s constructor
(`buttonGap`/`buttonSpacing` in `Panel.hx`, `rowHeight` in `PopupMenu.hx`), at the point those
values are actually read.

**Detect:**

```sh
grep -rn 'padding:.*scale(\|minSize:.*scale(\|minItemSize.*scale(\|fontSize:.*scale(\|offset:.*scale(\|buttonGap:.*scale(\|buttonSpacing:.*scale(\|rowHeight:.*scale(' --include='*.hx' .
```

Run this against any custom `Skin` subclass or code that builds an `Attribs`/attribs-literal value
by hand (`addAttribs(...)`, `replaceAttribs(...)`, or a raw `{ ... }` passed as a widget's
`inAttribs`) — not just against `gm2d` itself.

**Old:**

```haxe
addAttribs("ProgressBar", {
   padding: new Rectangle(skin.scale(2), skin.scale(2), skin.scale(4), skin.scale(4)),
   fontSize: skin.scale(14),
});
```

**New:**

```haxe
addAttribs("ProgressBar", {
   padding: new Rectangle(2, 2, 4, 4),
   fontSize: 14,
});
```

**Why:** this is the sizing half of the live-reskin/DPI-propagation groundwork ([SKIN-001](#skin-001--skin-construction-always-fully-initializes-named-colour-fields-replaced-by-a-palette-map)
started the colour half). A value baked into `attribSet` at construction time can never respond to
a later DPI/`uiScale` change — the whole point of resolving it live, once, at the point it leaves
`Skin`'s logical-unit domain and enters `Layout`'s pixel domain, is what makes that eventually
possible. `Layout.hx` itself is unaffected — this is entirely a `Skin`/`Renderer` boundary concern.

**Fix (agent instructions):**

1. For every attribs literal field matching `padding`, `minSize`, `minItemSize`, `fontSize`, or
   `offset` that wraps its value(s) in `scale(...)`/`skin.scale(...)`, remove the wrapping call and
   leave the bare number. `Renderer`'s constructor now resolves these itself — leaving the old
   `scale()` call in place double-scales the value (renders roughly `uiScale` times too large).
2. `margin` is **not** resolved yet (still read as a raw, unscaled `Rectangle`/number, matching its
   pre-existing behavior) — do not strip `scale()` from a `margin` field, and do not add one if it's
   currently bare; leave it exactly as found. This is an inconsistency carried over from before this
   change, not something this step fixes.
3. For `buttonGap`/`buttonSpacing`/`rowHeight` specifically — these aren't read through `Renderer`'s
   constructor at all, so removing `scale()` from their `attribSet` value only half-fixes them; the
   *consuming* code needs to scale the result instead. Two new helpers exist for exactly this:
   `Renderer.getDefaultScaled(name, default)` (replaces `skin.scale(renderer.getDefaultFloat(name,
   default))`) and `Widget.getAttribScaled(name, ?default)` (replaces
   `skin.scale(widget.attribFloat(name, default))`) — both scale the result once, whether it came
   from the map or the fallback default, so the default you pass should also be a bare logical
   number now, not pre-scaled. If your codebase does not use `Panel`/`PopupMenu`'s stock consumption
   of these fields (i.e. you're not calling `getDefaultFloat("buttonGap"/"buttonSpacing", ...)` or
   `attribFloat("rowHeight")` yourself), you likely have nothing to do here beyond step 1. If you
   have your own similar ad-hoc-read logical-unit attrib, prefer `getDefaultScaled`/
   `getAttribScaled` over hand-writing `skin.scale(...getDefaultFloat/attribFloat...)`.
4. Any other attribs field not in the list above (`step`, `arrowStep`, `columnWidth`, `itemHeight`,
   `bmpScale`, `width`, `height`, `xgap`, ...) is **not** affected by this step and should be left
   exactly as-is — these are read via the generic `Widget.attribFloat`/`Renderer.getDefaultFloat`
   helpers at scattered call sites across `gm2d/ui`, and haven't been individually triaged yet for
   whether they need the same treatment. Do not "helpfully" strip `scale()` from these; that would
   silently unscale them with no corresponding fix, which is worse than leaving them alone.
5. This is a **silent** behavior change with no compile-time signal — after applying the fix, visually
   re-check anything using a custom skin with its own `attribSet`/`addAttribs` sizing overrides.

---

## SKIN-003 — `Skin.scale()` renamed to `Skin.toPixels()`; new `Widget.onScaleChanged()` hook

- **Kind:** rename + new overridable hook
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** full for the rename — every remaining call site becomes
  `gm2d.skin.Skin has no field scale` (or `Unknown identifier : scale` inside a `Skin` subclass).
  None for the hook, which is additive.

**Background:** `Skin.scale(v:Float):Int` converts a logical unit into a device pixel using the
skin's `uiScale`. The name collided with the unrelated `scaleX`/`scaleY`/`Matrix.scale` sense of
"scale" everywhere it appeared, and read as "make this bigger" rather than "resolve this to
pixels". It is now `Skin.toPixels(v:Float):Int`. `Skin.uiScale`, `Skin.scaleBitmap()` and
`Skin.size()` are unchanged.

The rename is deliberately noisy, because the interesting half of this change is *where* those
calls live. A `toPixels()` result computed inside a widget's constructor and stored in an instance
field (or baked into a cached `BitmapData`, or pushed into a `Layout` once) can never respond to a
later DPI/`uiScale` change. So `Widget` gains:

```haxe
public function onScaleChanged():Void
```

a no-op on the base class, overridden by a widget to recompute **and apply** its own
scale-dependent state.

**Detect:**

```sh
grep -rn '\bscale(' --include='*.hx' .
```

Ignore `Matrix.scale(...)`, `scaleX`/`scaleY`, and `Skin.scaleBitmap(...)` — the real hits are
`skin.scale(...)`, `Skin.getSkin().scale(...)`, and bare `scale(...)` inside a `Skin` subclass.
Or just compile: every one of them is a hard error.

**Old:**

```haxe
class MySlider extends Widget
{
   var thumbSize:Int;
   public function new()
   {
      super();
      thumbSize = skin.scale(20);
      var layout = new Layout();
      layout.setBestSize(thumbSize, thumbSize);
      setItemLayout(layout);
   }
}
```

**New:**

```haxe
class MySlider extends Widget
{
   var thumbSize:Int;
   public function new()
   {
      super();
      var layout = new Layout();
      setItemLayout(layout);
      onScaleChanged();
   }

   override public function onScaleChanged()
   {
      super.onScaleChanged();
      thumbSize = skin.toPixels(20);
      var layout = getItemLayout();
      if (layout!=null)
         layout.setBestSize(thumbSize, thumbSize);
   }
}
```

**`onScaleChanged()` contract:**

- **Self-contained.** It recomputes the widget's scale-dependent state *and applies it* — reaching
  into `getItemLayout()`/`getLayout()` to push updated sizing, and regenerating any cached bitmap
  whose dimensions depend on the scale. It is not a notification that something else acts on.
- **Idempotent.** It is called more than once, and will be called again on every future scale
  change. Check-then-rebuild (compare the cached bitmap's current size against the new target)
  rather than rebuild-unconditionally.
- **Called twice during construction.** `Widget`'s own constructor calls it as its last statement,
  so an override runs **once before the subclass constructor body has executed**. Subclasses that
  set up further scale-dependent state then call `onScaleChanged()` again as the last line of their
  own constructor. This means an override **must tolerate a half-constructed instance**: null-guard
  your own members, and prefer `getItemLayout()` (returns `null` when there is no layout yet) over
  `getLayout()` (which would lazily construct a plain `Layout`, and the subclass's real layout would
  then replace it, discarding whatever the hook just wrote). The usual shape is a single early-out
  guard on the first member the subclass constructor assigns.
- **Nothing calls it automatically yet** beyond those constructor calls. The `setSkin()` / live
  display-list propagation step that will invoke it on a real DPI or skin change is not built. So
  today this change is groundwork: it makes each widget *able* to rescale, without anything yet
  triggering it.

**Fix (agent instructions):**

1. Rename every `scale(` call that resolves to `Skin.scale` to `toPixels(`. This includes bare
   `scale(...)` calls inside your own `Skin` subclass. Leave `uiScale`, `scaleBitmap`, `scaleX`,
   `scaleY` and `Matrix.scale` alone. Compile — the rename is complete when the errors stop.
2. Then classify each renamed call site. This is the part that is **not** mechanical:
   - If the enclosing function re-runs naturally — an event handler, a per-render/per-layout method,
     a lazily-invoked bitmap factory, `Renderer`'s constructor — the rename alone is the whole fix.
   - If it runs once in a widget's constructor and the result is stored in an instance field, baked
     into a cached bitmap, or pushed into a `Layout`, move it into an `onScaleChanged()` override
     per the contract above. Leaving it inline after the rename keeps the value exactly as stuck as
     it was before.
3. If you have a widget that takes a pixel size as a constructor argument and bakes it into its
   graphics or layout, prefer storing the *logical* size and resolving it in `onScaleChanged()`
   (this is what `GradSwatchBox` and `Panel.setSizeHint` now do). Note `Panel.setSizeHint(inPix)`'s
   argument was already interpreted as a logical unit and still is — no call-site change — but it is
   now remembered and re-resolved rather than applied once.
4. `Panel`'s `labelGap`/`lineGap` attribs are now read through `Renderer.getDefaultScaled` rather
   than `getDefaultFloat(name, skin.scale(default))`. Previously only the *fallback default* was
   scaled and a value you supplied was used raw; now a supplied value is scaled too, consistent with
   [SKIN-002](#skin-002--attribset-values-are-now-dpi-independent-logical-units-resolved-once-at-renderer-construction).
   If you set `labelGap`/`lineGap` in a custom attrib set, make it a bare logical unit. Same applies
   to `ListControl`'s `xgap`, now read via `Widget.getAttribScaled`.

**Known remaining bakes (not fixed by this step):** a few scale-dependent values still resolve once
with no way to re-run, because they sit outside a `Widget`'s reach — `SvgSkin`'s
`createButtonRenderer`/`createLabelRenderer` font sizes (resolved when the SVG skin is loaded),
`DocumentParent`'s minimum size (`DocumentParent` is a `Sprite`, not a `Widget`),
`ColourControl`'s `SwatchBox` and `GradientControl.createBmps`'s shared bitmap cache (both bake into
a non-`Widget`'s graphics or a static map). `Skin.bmpCache` also keys cached bitmaps by button and
state only, with no scale awareness, and `Skin.shallowCopy()` shares that cache with the copy — so a
`copyWithScale()` result would serve stale, wrong-size icons. These all need the live-propagation
step before they can be addressed.

---

## SKIN-004 — `Attribs.textColor` retyped `Int` → `TextColour`

- **Kind:** retype (typedef field, not a class field — same enforcement mechanism as the
  `Skin.scale()` rename, applied to a type instead of a symbol name)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** full — every `attribs`/`addAttribs`/`replaceAttribs` literal that sets
  `textColor:` to a raw `Int` fails to compile (`Int should be Null<gm2d.skin.TextColour>`).

**Background:** `fill:FillStyle` and `line:LineStyle` have resolved live, at draw time, against
the skin ever since [SKIN-001](#skin-001--skin-construction-always-fully-initializes-named-colour-fields-replaced-by-a-palette-map)
— `textColor` was the one place a real `Int` still got baked into `attribSet` at construction
time, the same eager-bake problem already fixed once for `FillSolid`/`LineSolid` payloads (see the
"Also in this step" note under SKIN-001). New closed enum:

```haxe
enum TextColour { TextColNormal; TextColMuted; TextColInverse; }
```

Grounded in the 5 actual `textColor:` sites `gm2d`'s own default skin had: `"TextPlaceholder"` →
`TextColMuted`; `"StatusBar"`/`"MenubarItem"`/`"PopupMenuList"`/`"PopupMenuItem"`'s `stateCurrent`
→ `TextColInverse` (all were `guiLightText`/`0xffffff` on a dark fill — same reason, just unnamed
until now). Per the "no case without usage" rule already governing `FillStyle`/`LineStyle`,
nothing else was added — a highlighted/current-state text color that isn't just inverse would earn
its own case only once a real one shows up.

Symmetric accessors added to `Skin`, matching `getFillColour`/`setFillColor`/`getLineColour`/
`setLineColour` exactly: `getTextColour(TextColour):Int` / `setTextColour(TextColour,Int):Void`,
both using `Type.enumConstructor`/`Type.enumParameters` the same way (irrelevant for now since
every `TextColour` case is payload-free, but consistent, and future-proof if that changes).
`Renderer`'s constructor resolves it live: `textFormat.color = skin.getTextColour(map.get("textColor"))`.

**Detect:**

```sh
grep -rn 'textColor\s*:\s*[0-9x]' --include='*.hx' .
```

Catches a hex/decimal literal directly on `textColor:`. It will **not** catch `textColor:
someIntVariable` (e.g. a skin field like `labelColor`) — those only surface as a compile error
(`Int should be Null<gm2d.skin.TextColour>`), which is the more reliable signal; just compiling
finds every real site.

**Old:**

```haxe
addAttribs("MyWidget", { textColor: 0xffffff });
```

**New:**

```haxe
addAttribs("MyWidget", { textColor: TextColInverse });
```

**Why:** picking the matching `TextColour` case isn't mechanical — it requires judgment about
*why* that color was chosen (is it meant to read against a dark background? a muted/placeholder
tone? plain default text?), which is exactly why this entry is marked not auto-fixable. A
mis-picked case still compiles and looks identical today (since it just resolves back to the same
seeded `Int` in `skin.colours`), but will silently pick the wrong color once a real palette/dark-
mode swap exists — pick based on intent, not by matching the current numeric value.

**Fix (agent instructions):**

1. For every `textColor:` set to a raw literal or an `Int`-typed variable/field, replace it with
   the `TextColour` case matching its *intent*: `TextColInverse` if the fill behind it is dark
   (light text on dark), `TextColMuted` if it's a placeholder/secondary/de-emphasized label,
   `TextColNormal` for anything else (plain default text — this is also what happens if `textColor`
   is simply omitted, so an explicit `TextColNormal` is only needed if the lineage would otherwise
   inherit something else).
2. If the color truly doesn't fit any of the three (e.g. a specific brand/accent text color with no
   relationship to inverse/muted/normal), do not force it onto the nearest existing case — flag it
   for a human decision. Per the "no case without usage" rule, a new `TextColour` case should only
   be added once a real, grounded need shows up, the same discipline already applied to `FillStyle`/
   `LineStyle`.
3. If your codebase reads `Attribs.textColor` directly (rather than just setting it), it now reads
   as `TextColour`, not `Int` — resolve to a real color via `skin.getTextColour(...)` at the point
   you need the `Int`, don't compare it to a hex literal directly.

**Follow-up fix (same entry, found via the `Skin.createDark()` test):** the *implicit* default —
any `TextLabel`/attribs entry that never sets `textColor:` at all (most of them; e.g. `"PanelText"`,
`"PopupMenuItem"`'s non-current state) — was still resolving to a hardcoded `Skin.textFormat.color
= 0x000000` set once in `init()`, never through the palette. `Skin.getTextFormat()` now builds its
base colour via `getTextColour(TextColNormal)` instead, so the implicit default is live like
everything else. If you relied on plain text always being exactly `0x000000` regardless of palette
(unlikely, but technically true before this fix), it now correctly follows `TextColNormal` instead.

**Second follow-up: `Skin.getTextFormat()` removed entirely; base `font`/`fontSize` moved into
`attribSet`'s `"*"` lineage.** The first follow-up above fixed `getTextFormat()`'s *colour* to be
live, but its `font`/`size` were still sourced from `Skin.textFormat` — a `TextFormat` object
built once in `init()` (`font:"Arial"`, `size:toPixels(14)`) — which is exactly the "`Skin` has no
business pre-building a base `TextFormat`" case flagged as intentionally deferred back in
[SKIN-001](#skin-001--skin-construction-always-fully-initializes-named-colour-fields-replaced-by-a-palette-map).
Reviewing it now (asked directly: "should we even have a `getTextFormat`? where is this used?")
confirmed only two callers, both now updated to build a fresh `TextFormat` inline instead:
`Renderer`'s constructor (colour from `getTextColour(TextColNormal)`; `font`/`fontSize` come from
the `map.exists("font")`/`("fontSize")` checks that already existed — no longer special-cased,
since `"*"` now unconditionally contributes both) and `SvgSkin.createLabelRenderer` (same colour
fix, `font` hardcoded `"Arial"` inline since SVG text doesn't specify one). **Default base font
size is now `12`, not `14`** — the old `14` read a little large for general body/button text, and
made `"FrameTitle"`'s own explicit `fontSize:14` a no-op (identical to the base, when it's meant
to stand out slightly); `12` also matches every other size-specifying entry
(`DialogTitle`/`TitleBar` at `16`, `FrameTitle` at `14`) actually reading as *larger than base*,
which they're presumably meant to.

`Skin.textFormat` itself (the field) still exists — kept for the separate, still-excluded chrome
path (`styleLabel`/`styleText`, used by `renderMiniWin` and similar raw-`Graphics` drawing code,
same "leave alone for now" scope as `TabRenderer.hx`) — only the *general*, `attribSet`-facing text
path stopped depending on it.

**Fix:** if you called `skin.getTextFormat()` directly, it no longer exists — read
`font`/`fontSize`/`textColor` from your own `attribSet`/`combineAttribs()` result instead (the same
mechanism `Renderer` itself now uses), or build a plain `new TextFormat()` and set what you need.
If you relied on the base font size being `14`, it's `12` now; override `fontSize` explicitly via
`addAttribs("*", { fontSize: 14 })` (or on a narrower lineage) if you want the old value back.

---

## SKIN-005 — `Skin.shadowFilters`/`currentFilters` replaced by a named `FilterSet` palette

- **Kind:** removal + retype (two `Skin` fields removed; `Attribs.filters`/`chromeFilters` retyped)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** full — `skin.shadowFilters`/`skin.currentFilters` fail as "Unknown
  identifier"; a literal `Array<BitmapFilter>` where `Attribs.filters`/`chromeFilters` is now a
  `FilterSet` fails with a type mismatch.

**Background:** `Skin.shadowFilters`/`currentFilters` used to be `Array<BitmapFilter>` fields, set
once when `init()` ran and baked directly into `attribSet` (`chromeFilters: shadowFilters` on
`"Dialog"`/`"PopupMenu"`/`"PopupComboBox"`, `filters: currentFilters` on `"Control"`'s
`stateCurrent`) — the same eager-bake problem already fixed for colours and sizing, just not
reachable until now. Replaced by two named slots, same closed-set shape as the colour palette
(`getColour`/`setColour`):

```haxe
enum FilterSet { FilterSetShadow; FilterSetCurrent; }

enum BitmapFilterStyle
{
   FilterDropShadow(distance:Float, angle:Float, blur:Float, colour:FillStyle, alpha:Float);
   FilterGlow(colour:FillStyle, blur:Float, alpha:Float);
   FilterCustom(filter:BitmapFilter);  // escape hatch - still goes through a named slot
}
```

`skin.filterStyles:Map<String,Array<BitmapFilterStyle>>` holds the *definitions*, keyed by
`FilterSet` constructor name; `skin.getFilterSet(FilterSetShadow)` realizes them to real
`Array<BitmapFilter>` on first access and caches the result (`skin.setFilterStyle(...)` invalidates
that cache). The realized cache is **not** copied by `copyWithScale`/`copyWithPalette` — a copy
starts with an empty cache and lazily rebuilds against its own `uiScale`/`colours`, the same fix
just applied to `Skin.bmpCache` while this was being built (previously shared with the copy,
serving stale wrong-size icons — see the "Known remaining bakes" note under
[SKIN-003](#skin-003--skinscale-renamed-to-skintopixels-new-widgetonscalechanged-hook), now closed).

`Attribs.filters`/`chromeFilters` are retyped `Array<BitmapFilter>` → `FilterSet` — an attribs
literal now names *which slot* it wants (`filters: FilterSetCurrent`), never a concrete filter
array directly. `Renderer` resolves the named slot to real filters live, at construction/render
time (reruns on every `rebuildState()`, same as `padding`/`fill`/etc.).

**A `FillStyle` value can be a bare named role (e.g. `FillHighlight`) or a literal `FillSolid(rgb,a)`
inside a filter definition** — unlike `Skin.getFillColour`, which rejects payload cases, filter
resolution accepts both, since a filter's colour is sometimes deliberately fixed (see below) rather
than theme-relative.

**Default shadow colour is deliberately fixed, not a role:** `FilterSetShadow`'s default is
`FilterDropShadow(3, 45, 3, FillSolid(0,1), 0.5)` — literal near-black, not e.g. `FillDark`/
`FillInv`. A drop shadow is a lighting metaphor, not a surface colour; it shouldn't invert when the
palette does (`FillInv` in particular is defined as "inverse of the current theme," which in a dark
theme could resolve to something *light* — exactly wrong for a shadow). This also means a light/dark
swap is a pure `copyWithPalette()` with no filter change needed for the default shadow. If you
*want* a filter's colour to track the palette, use a named role instead of `FillSolid` — that's a
deliberate per-filter choice, not the default.

**`FilterSetCurrent` is empty by default** — matches the previous behaviour exactly (the old
`currentFilters` glow was already commented-out/dead code); the slot and `FilterGlow` case exist
and are ready to use, but nothing enables them out of the box.

**Naming note:** `gm2d/svg/FilterSet.hx` already exists — an unrelated class (an SVG filter list).
Different package (`gm2d.svg` vs `gm2d.skin`), so no compile conflict, but worth knowing if you
ever see both in the same file's imports.

**Detect:**

```sh
grep -rnE '\.(shadowFilters|currentFilters)\b' --include='*.hx' .
grep -rn 'filters\s*:\s*\[' --include='*.hx' .
```

The second pattern catches an attribs literal handing `filters:`/`chromeFilters:` an array literal
directly — no longer valid now that the field is `FilterSet`.

**Old:**

```haxe
class AppSkin extends Skin
{
   public function new()
   {
      super();
      shadowFilters = [ new DropShadowFilter(distancePx, 45, 0, 0.5, blurPx, blurPx, 1) ];
   }
}
```

**New:**

```haxe
class AppSkin extends Skin
{
   public function new()
   {
      super();
      setFilterStyle(FilterSetShadow, [ FilterDropShadow(distanceLogical, 45, blurLogical, FillSolid(0,1), 0.5) ]);
   }
}
```

Note `distance`/`blur` are logical units now (no `scale()`/`toPixels()` wrapping — `Skin` resolves
them at realization time), matching the convention already established for `attribSet` sizing
([SKIN-002](#skin-002--attribset-values-are-now-dpi-independent-logical-units-resolved-once-at-renderer-construction)).

**Fix (agent instructions):**

1. Replace `skin.shadowFilters = [...]` / `currentFilters = [...]` with
   `skin.setFilterStyle(FilterSetShadow, [...])` / `setFilterStyle(FilterSetCurrent, [...])`,
   translating each concrete `BitmapFilter` construction to the matching `BitmapFilterStyle` case
   — `FilterDropShadow`/`FilterGlow` for the two built-in shapes, `FilterCustom(existingFilter)` if
   you need to keep an arbitrary filter you don't want to (or can't) express declaratively. When
   translating, strip any `scale()`/`toPixels()` wrapping on distance/blur — they're logical units
   now, resolved once by `Skin`.
2. For colour: if the original was a hardcoded literal with no relationship to the active theme
   (like the default shadow), use `FillSolid(rgb, a)`. If it should track light/dark, use the
   matching named `FillStyle` role instead.
3. For any attribs literal setting `filters:`/`chromeFilters:` to a concrete array, replace with
   `FilterSetShadow`/`FilterSetCurrent` (or a new slot if you called `setFilterStyle` with a
   `FilterSet` case that isn't one of the two built-in ones — note `setFilterStyle` **rejects**
   unknown keys today, so a genuinely new named slot isn't self-service yet; flag that case for a
   human rather than guessing at a workaround).
4. Recompile — any remaining "Unknown identifier: shadowFilters/currentFilters" or filter-array
   type mismatch marks a site this sweep missed.

---

## SKIN-006 — Default `Menubar`/`MenubarItem` now use theme-following colours instead of a fixed dark bar

- **Kind:** behavior change (default `attribSet` values only — no renamed/removed symbol)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** none — a visual default change, not an API change.

**Background:** the default skin's `"Menubar"`/`"MenubarItem"` used `FillInv`/`TextColInverse` —
a fixed dark bar with light text, regardless of whether the rest of the skin is light or dark
(the older convention, also still used by `"StatusBar"`, not changed by this entry). Now uses
`FillLight`/`TextColNormal` — the same theme-following roles as the rest of the default chrome
(`Button`, `Dialog`, etc.), so the menubar tracks light/dark like everything else instead of
always being a dark accent bar. `MenubarItem`'s current-item underline is unaffected (`FillHighlight`,
an accent colour — same in light or dark).

**Why:** matches the now-common convention of a menubar that's light in a light theme and dark in
a dark theme, rather than a fixed dark strip. This is specifically a v5 default-content decision,
not a technical requirement of the propagation work — Hugh's call, made because gm2d's own apps are
the primary consumer and a v5 major version is the right point to change defaults like this.

**Fix:** if your custom skin didn't already override `"Menubar"`/`"MenubarItem"`'s `fill`/`textColor`,
your menubar's default appearance changes from dark-with-light-text to light-with-dark-text (in the
default/light palette). If you want the old fixed-dark-bar look back regardless of theme, set it
explicitly: `addAttribs("Menubar", { fill: FillInv }); addAttribs("MenubarItem", { textColor:
TextColInverse });`.

**Related, not changed by this entry:** `"StatusBar"` still uses the same fixed-dark-bar pattern
(`FillInv`/`TextColInverse`) — noted as revisitable when `FillInv` was first introduced, still open.

---

## SKIN-007 — Live skin propagation: `Widget.setSkin()`/`Window.setSkin()`/`Game.setSkin()`

- **Kind:** new API (additive — nothing renamed or removed)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** n/a — nothing breaks, this only adds capability.

**Background:** everything in SKIN-001 through SKIN-006 existed to make a skin change *resolvable
live* (colours, sizes, filters, text colour all resolve at render/combine time against whatever
`skin` a widget currently has) — but nothing actually *triggered* a live change on an
already-built tree. This entry adds that: the actual propagation mechanism.

```haxe
// Widget.hx
public function setSkin(inSkin:Skin):Void
```

Per-widget entry point. Quick-exits on identity (`if (inSkin==skin) return;`) — this is why a
`Skin` is effectively frozen once attached (`skin.mutable=false`, set here): an in-place field
mutation on an already-attached `Skin` would leave the reference unchanged and this check would
silently no-op the whole subtree. Order: `onScaleChanged()` (only if `uiScale` actually changed —
a pure palette swap skips it), `rebuildState()` (already existed — recombines attribs, rebuilds
the `Renderer`, redraws), then pushes the fresh sizing onto this widget's own `Layout`
(`mRenderer.layoutWidget(this)`). Then recurses into the display list looking for further
`Widget`s to propagate to (not the `Layout` tree — a child widget's own subtree needs to move as a
unit, which display-list containment gives for free) — no visibility/focus filtering, an
invisible-but-live dialog still needs restyling. **The recursion walks every
`DisplayObjectContainer`, not just `Widget` children** — some containers in `gm2d/ui` aren't
`Widget`s themselves (e.g. `SideDock extends Layout`, which adds its `DockFrame`s to a plain
`Sprite`), so a `Widget` can sit behind a layer of non-`Widget` chrome; stopping at the first
non-`Widget` child would silently strand everything nested inside it. Same shape as the existing
`Widget.getWidgetsRecurse`, minus its focus/visibility filtering.

```haxe
// Window.hx (shared root for both Screen and Dialog)
public override function setSkin(inSkin:Skin):Void
```

Calls `super.setSkin(inSkin)` (restyles the whole subtree, no relayout), then does exactly **one**
top-down `relayout()` once that's finished. This is the only place a relayout happens — nothing
below `Window` does its own, avoiding a relayout-per-level cascade.

```haxe
// Game.hx
static public function setSkin(inSkin:Skin):Void
```

The "change it everywhere" entry point: updates `Skin.theSkin` (the default new widgets pick up),
then calls `setSkin()` on the current `Screen` and the current `Dialog` if one's open. For a
*scoped* change (e.g. one dialog changing its own effective DPI to fit its content), call
`widget.setSkin(...)` directly instead — `Game.setSkin()` is specifically the global case.

`Screen.makeCurrent()` also gained a catch-up call — `setSkin(Skin.getSkin())` right before its
existing `relayout()` — for a screen that missed a skin change while it wasn't current. Cheap
no-op via the same identity quick-exit when nothing actually changed.

**Not covered by this entry (still manual, per the design's own "escape hatch, not exhaustive"
framing):** a widget added to the display list after a skin change needs `setSkin()` called on it
explicitly at the add site (same place a post-add relayout already happens) — there's no
`ADDED_TO_STAGE` auto-catch-up by design (rejected as an unnecessary leak-surface risk). A
paged/tabbed container activating a child should call `setSkin()` on it when it becomes current.
Neither is retrofitted into existing `gm2d/ui` containers yet.

**Try it:** `samples/06-App/SampleApp.hx` — `Skin > Light`/`Skin > Dark` (`Shift+L`/`Shift+D`)
calls `Game.setSkin(lightSkin)`/`Game.setSkin(darkSkin)`, where `darkSkin` is
`lightSkin.createDark()` — a test/example method added alongside this that mechanically inverts
every entry in `colours` and returns `copyWithPalette(...)` of the result; not a curated dark
theme, just a way to exercise the whole live-propagation path end to end.

---

## SKIN-008 — `ProgressStyle` retyped to `FillStyle`/`LineStyle`; `margin` and `ShapeRoundRectRad`'s radius now auto-scaled

- **Kind:** retype (enum constructor fields) + behavior change (two previously-unscaled `Renderer`
  inputs are now auto-scaled)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** full for the retype — every `ProgressRoundRect`/`ProgressRoundRectBall`
  call passing a raw `Int` fails as "Int should be gm2d.skin.LineStyle" (or `FillStyle`). None for
  the auto-scaling change — a silent visual-size change for anyone who was manually pre-scaling
  `margin` or a `ShapeRoundRectRad` radius before this shipped.

**Background:** this was found while migrating a downstream consumer of LAY/SKIN-001 through 007 —
mechanically applying SKIN-003's rename (`scale()`→`toPixels()`) to `margin:`/`shape:
ShapeRoundRectRad(...)`/`progressStyle:` attribs values initially looked correct (each was baked
once at skin-construction time, matching pre-migration behaviour, and compiled fine), but on
inspection turned out to be preserving a *pre-existing* eager-bake gap rather than actually
finishing the DPI-independence work those other entries did for `padding`/`minSize`/`fontSize`/etc.
Three related gaps closed together:

1. **`Renderer.margin` is now auto-scaled**, the same way `padding` already was
   ([SKIN-002](#skin-002--attribset-values-are-now-dpi-independent-logical-units-resolved-once-at-renderer-construction)
   explicitly called out `margin` as *not yet* resolved at the time — this closes that gap).
2. **`Shape.ShapeRoundRectRad(rad)`'s `rad` payload is now auto-scaled live**, in
   `Renderer.renderRect()` at the point it's drawn (a "reruns naturally" site, same classification
   as the rest of [SKIN-003](#skin-003--skinscale-renamed-to-skintopixels-new-widgetonscalechanged-hook)'s
   fix step 2) — instead of requiring the value to already be in pixels when it reaches the
   `attribSet` literal. Other `Shape` cases with numeric payloads (`ShapeRoundRectFlags`,
   `ShapeShadowRect`, their `ShadowCache`-backed bitmap-caching path) were **not** touched by this
   entry — out of scope, flagged for a future pass.
3. **`ProgressStyle.ProgressRoundRect`/`ProgressRoundRectBall`'s `outlineCol`/`fillCol`/`emptyCol`
   fields are retyped** from raw `Int` to `LineStyle`/`FillStyle`/`FillStyle` respectively, and
   `ProgressBar.hx` now resolves them live (`skin.resolveLineColour`/`skin.resolveFillColour`) and
   scales `lineWidth`/`radius` live (`skin.toPixels(...)`) in its own `redraw()`, rather than the
   caller baking a colour/size once into the `attribSet` literal. This is the same colour-role
   migration [SKIN-001](#skin-001--skin-construction-always-fully-initializes-named-colour-fields-replaced-by-a-palette-map)
   already did elsewhere, applied to the one style enum that still took raw `Int` colours.

Two new public `Skin` methods support case 3 — `resolveFillColour(FillStyle):Int` (already existed,
now widened from private to public) and the new `resolveLineColour(LineStyle):Int` — both accept
either a bare named role (`FillHighlight`, `LineBorder`, ...) *or* a literal `FillSolid`/`LineSolid`/
`LineSolidFill` payload (unlike `getFillColour`/`getLineColour`, which throw on a payload case).
Reach for these (not `getFillColour`/`getLineColour`) whenever a call site needs to accept both a
role and a literal, the same way filter resolution already did
([SKIN-005](#skin-005--skinshadowfilterscurrentfilters-replaced-by-a-named-filterset-palette)).

**Detect:**

```sh
grep -rnE 'ProgressRoundRect(Ball)?\(' --include='*.hx' .
grep -rn 'margin:.*\btoPixels(\|margin:.*\bscale(\|margin\s*=.*\btoPixels(\|margin\s*=.*\bscale(' --include='*.hx' .
grep -rn 'ShapeRoundRectRad(.*\btoPixels(\|ShapeRoundRectRad(.*\bscale(' --include='*.hx' .
```

The first pattern catches every `ProgressRoundRect`/`ProgressRoundRectBall` call site — check each
by hand, since the fix depends on what the old `Int` value actually was (a role vs. a literal
colour). The second and third are the double-scaling risk: any `margin`/`ShapeRoundRectRad` value
that was already being pre-scaled (by a previous, correct application of SKIN-002/SKIN-003's own
guidance to "leave margin scaled") needs that scaling removed now that `Renderer`/`renderRect` do
it — if you already went through the earlier SKIN-002/003 entries and specifically kept `margin`/
`ShapeRoundRectRad` scaled per their notes, this entry reverses that specific guidance.

**Old:**

```haxe
addAttribs("Dialog", {
   shape: ShapeRoundRectRad(skin.toPixels(3)),
   margin: new Rectangle(skin.toPixels(2), skin.toPixels(2), skin.toPixels(4), skin.toPixels(4)),
});
addAttribs("ProgressBar", {
   progressStyle: ProgressRoundRect(0x000000, getColour("FillHighlight"), getColour("FillLight"),
                                     skin.toPixels(1), skin.toPixels(6)),
});
```

**New:**

```haxe
addAttribs("Dialog", {
   shape: ShapeRoundRectRad(3),
   margin: new Rectangle(2, 2, 4, 4),
});
addAttribs("ProgressBar", {
   progressStyle: ProgressRoundRect(LineBorder, FillHighlight, FillLight, 1, 6),
});
```

Note `getColour("FillHighlight")` became the bare role `FillHighlight` too — not part of this
entry's compiler-enforced retype (a raw `Int` still satisfies `Int`, since `getColour` returns
`Int`), but doing this at the same time is strongly recommended: leaving `getColour(...)` inside an
`attribSet` literal is exactly the eager-bake anti-pattern
[SKIN-001](#skin-001--skin-construction-always-fully-initializes-named-colour-fields-replaced-by-a-palette-map)'s
"General rule going forward" already warns against — it happened to still compile here only because
`ProgressStyle`'s colour fields hadn't been retyped away from `Int` yet either.

**Why:** see Background — this closes the same "value baked once at skin-construction time instead
of resolved live" gap [SKIN-001](#skin-001--skin-construction-always-fully-initializes-named-colour-fields-replaced-by-a-palette-map)/[SKIN-002](#skin-002--attribset-values-are-now-dpi-independent-logical-units-resolved-once-at-renderer-construction)/[SKIN-003](#skin-003--skinscale-renamed-to-skintopixels-new-widgetonscalechanged-hook)
already closed for `padding`/`minSize`/`fontSize`/most colours, for the three places it was still
open. Found by actually reading `Renderer.hx`/`ProgressBar.hx` rather than assuming a `scale()` →
`toPixels()` rename was sufficient just because it compiled — a rename compiling is not the same
as a value being resolved at the right time.

**Fix (agent instructions):**

1. For every `ProgressRoundRect(...)`/`ProgressRoundRectBall(...)` call, replace the first
   (`outlineCol`) argument with the matching `LineStyle` (a named role, or `LineSolid(w,rgb,a)`/
   `LineSolidFill(w,fill,a)` if it must stay a literal), and the second/third (`fillCol`/`emptyCol`)
   with the matching `FillStyle` (a named role, or `FillSolid(rgb,a)` for a literal) — same
   role-picking judgment as [SKIN-004](#skin-004--attribstextcolor-retyped-int--textcolour), not
   mechanical. If the old value was already `getColour("FillXxx")`/a raw hex matching a seeded
   role, use the bare role directly.
2. If your own code (not just `gm2d`'s default skin) reads a `ProgressStyle` value (a custom
   `ProgressBar` renderer, say), resolve colours via `skin.resolveLineColour(outline)`/
   `skin.resolveFillColour(fill)` — not `getLineColour`/`getFillColour`, which throw on a literal
   payload — and scale `lineWidth`/`radius` via `skin.toPixels(...)` at the point you draw, not
   once when the style value is constructed.
3. For every `margin:`/`ShapeRoundRectRad(...)` value that is currently wrapped in `scale(...)`/
   `toPixels(...)` (per the second/third **Detect** patterns), remove the wrapper and leave the
   bare logical number — `Renderer`/`renderRect` now resolve both live, and leaving the old
   wrapping in place double-scales (renders roughly `uiScale` times too large).
4. Recompile — any remaining `Int`-vs-`LineStyle`/`FillStyle` mismatch on a `ProgressRoundRect`/
   `ProgressRoundRectBall` call marks a site step 1 missed.
5. This is a **silent** behavior change for steps 3 in particular (no compile-time signal once the
   wrapper is just sitting there unnecessarily rather than causing a type error) — visually
   re-check any custom `Dialog`-shaped chrome or `ProgressBar` after applying.

---

## SKIN-009 — `Skin.createBitmapData`'s `inWidth` is now a logical unit — fixes a `uiScale²` double-scale on SVG-backed icons

- **Kind:** bugfix (the two branches of one function silently disagreed about their shared
  parameter's units) + behavior change (the fix changes what unit callers must now pass)
- **Status:** shipped
- **Shipped in:** `master` (unreleased)
- **Compiler assistance:** none — `inWidth:Int` accepts either a logical or a pre-scaled pixel
  value without complaint; the bug (and the fix) are both invisible to the type system.

**Background:** found while chasing a real symptom — at higher-than-1x `uiScale`, an app's menubar
was rendering taller than expected. `SpriteMenubar.layout()` (`gm2d/ui/Menubar.hx`) grows the bar
to fit the tallest `extraWidget`, and a title-icon `extraWidget` built from an SVG-backed icon was
coming out roughly `uiScale` times too big — invisible at `uiScale=1`, so nobody had hit it before.

The actual bug was in `Skin.createBitmapData(inResoName:String, inWidth:Int)`: its two branches
disagreed about whether `inWidth` was already a real pixel value.

```haxe
public function createBitmapData(inResoName:String,inWidth:Int) : BitmapData
{
   var bmp:BitmapData = null;
   if (Assets.hasBitmapData(inResoName))
   {
      bmp = Assets.getBitmapData(inResoName);
      var extraScale = inWidth/bmp.width;        // treats inWidth as already real pixels
      return scaleBitmap(bmp,extraScale);
   }
   else
   {
      var svg = new SvgRenderer(gm2d.reso.Resources.loadSvg(inResoName));
      var size = toPixels(inWidth);               // treats inWidth as a logical unit
      ...
   }
}
```

Every real call site (there were only two in this codebase) passed an *already-scaled* pixel value
(`skin.createBitmapData("titleIcon", skin.toPixels(32))`) — correct for the bitmap branch, since
that branch does no scaling of its own. For an asset that resolves through the SVG branch instead
(no matching `Assets.hasBitmapData`, so it falls through to load/rasterize an SVG), that same
pre-scaled value then goes through `toPixels()` **a second time** inside the function — `uiScale²`
instead of `uiScale`. Which branch a given `inResoName` takes is an asset-packaging detail invisible
at the call site, so this silently depended on whether `"titleIcon"` happened to be a raw bitmap
asset or an SVG one.

One existing call (`gm2d/ui/MenuGroup.hx`'s `createBitmapData(inKey,16)`) was already passing a bare
logical value with no pre-scaling — accidentally correct for the SVG branch, silently un-scaled for
the bitmap branch. That inconsistency was the tell that the *function's* contract was the bug, not
any individual call site.

**Why fix it this direction (logical unit in, not pixel):** matches the DPI-independent-logical-unit
convention [SKIN-002](#skin-002--attribset-values-are-now-dpi-independent-logical-units-resolved-once-at-renderer-construction)/[SKIN-003](#skin-003--skinscale-renamed-to-skintopixels-new-widgetonscalechanged-hook)
already established everywhere else — a caller should never need to know or care which asset-storage
branch a given `inResoName` will take.

**Detect:** `manual` — no reliable textual pattern distinguishes "a pre-scaled pixel value passed to
`createBitmapData`" from "a correct logical value passed to it"; both are `Int`, and the bug is
silent (no error, just wrong-at-runtime sizing that only shows up away from `uiScale=1`). Grep for
every call site and inspect each by hand:

```sh
grep -rn 'createBitmapData(' --include='*.hx' .
```

**Old:**

```haxe
skin.createBitmapData("titleIcon", skin.toPixels(32));   // now double-scales SVG-backed icons
```

**New:**

```haxe
skin.createBitmapData("titleIcon", 32);   // bare logical unit - scaled internally, once
```

**Fix (agent instructions):** for each call found by **Detect**, check whether the second argument
is wrapped in `toPixels(...)`/`scale(...)` (or is itself a variable that was computed that way). If
so, remove the wrapping and pass the bare logical value instead — the function now resolves it to
pixels internally exactly once, regardless of which branch (bitmap asset vs. SVG asset) the named
resource actually takes. If the argument is already a bare logical number/variable (matching
`MenuGroup.hx`'s existing call), leave it as-is — it was already correct under the new contract, and
is now also correct for a bitmap-backed asset of the same name (previously it wasn't).

---

*(More entries will be appended here as further v5 layout decisions are finalized — see
[`Layout.md`](Layout.md) for the design discussion they come from.)*
