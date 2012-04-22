package gm2d.icons;

import gm2d.gfx.GfxBytes;
import gm2d.gfx.GfxGraphics;
import gm2d.display.Graphics;


class NorthSouth extends Icon
{
static var data = "eNpjdGJgYABhOccWBgaHCQwMXP///7dvYGAQARFAAKUYHByQFMk7LmFgcNQAMXqQGXNgUmAGULHjGRDDAyZSgczQgElpQBWDTOYRZQAAtXkZgg";
var gfx:GfxBytes;

public function new()
{
   super();
   gfx = GfxBytes.fromString(data);
}

public override function render(g:Graphics)
{
   gfx.iterate(new GfxGraphics(g));
}

}
