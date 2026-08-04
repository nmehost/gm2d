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
   of adding many individual lines — simpler and matches the pre-split reach most closely.
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
transform from the table above verbatim, preserving argument values and order (only `?skin`,
if omitted in the old call, should be passed as `null` in the new positional constructor call).
Separately, run:

```sh
grep -rnE '\bBmpButton\b' --include='*.hx' .
```

and rename every match to `BitmapButton`.

---

*(More entries will be appended here as further v5 layout decisions are finalized — see
[`Layout.md`](Layout.md) for the design discussion they come from.)*
