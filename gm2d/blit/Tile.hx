package gm2d.blit;
import gm2d.geom.Rectangle;

class Tile
{
   public var rect(default,null):Rectangle;
   public var id(default,null):Int;
   public var sheet:Tilesheet;
   public var hotX:Float;
   public var hotY:Float;

   public function new(inSheet:Tilesheet, inRect:Rectangle)
   {
      sheet = inSheet;
      rect = inRect.clone();
      id = sheet.gm2dAllocTile(this);
      hotX = hotY = 0;
   }

   public function alignLeft() { hotX = 0; return this; }
   public function alignCenterX() { hotX = rect.width/2; return this; }
   public function alignRight() { hotX = rect.width; return this; }

   public function alignTop() { hotY = 0; return this; }
   public function alignCenterY() { hotY = rect.height/2; return this; }
   public function alignBottom() { hotY = rect.height; return this; }

   public function alignCenter() { alignCenterX();  alignCenterY(); return this; }
}
