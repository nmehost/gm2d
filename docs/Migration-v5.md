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

*(More entries will be appended here as further v5 layout decisions are finalized — see
[`Layout.md`](Layout.md) for the design discussion they come from.)*
