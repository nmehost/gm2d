package gm2d.icons;

import gm2d.gfx.GfxBytes;
import gm2d.gfx.GfxGraphics;
import gm2d.display.Graphics;


class EastWest extends Icon
{
static var data = "eNpjdGJgYABhOYcDDAyOBQwMXP///7dvYGAQARFAAKUYHByQFMk7AnmOBjBGAoixApkBlroBUwwSmQFjNMB0wRkgKZjJPKIMAKURGc4";
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
