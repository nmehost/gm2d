package gm2d.icons;

import gm2d.gfx.GfxBytes;
import gm2d.gfx.GfxGraphics;
import gm2d.display.Graphics;


class NSEW extends Icon
{
static var data = "eNpjdGJgYABhOccWBgaHCQwMXP///7dvYGAQARFAAKUYHByQFMk7ejAwOGqAGBXIjAQQwwGZYQBkOBwAMgpgIjNgjAaYLjhjDsxkMANol+MZEGMJTKQHmQHWtQKZATb5BsyuFVDbwYwEmC44QwNmsgbULoi/oAweUQYACQgxMw";
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
