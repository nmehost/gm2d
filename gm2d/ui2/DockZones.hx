package gm2d.ui2;
import nme.geom.Rectangle;
import nme.display.Sprite;

class DockZone
{
   public var rect(default,null):Rectangle;
   public var onDock(default,null):IDockable->Void;
   public function new(inRect:Rectangle, inOnDock:IDockable->Void)
   {
      rect = inRect;
      onDock = inOnDock;
   }
}

class DockZones
{
   public var x(default,null):Float;
   public var y(default,null):Float;
   public var container(default,null):Sprite;

   var zones:Array<DockZone>;

   public function new(inX:Float, inY:Float, inContainer:Sprite)
   {
      x = inX;
      y = inY;
      container = inContainer;
      zones = [];
   }

   public function addRect(inRect:Rectangle, inOnDock:IDockable->Void)
   {
      if (inRect!=null)
         zones.push( new DockZone(inRect, inOnDock) );
   }

   public function test(inX:Float, inY:Float,inDockable:IDockable) : Bool
   {
      for(zone in zones)
      {
         if (zone.rect.contains(inX,inY))
         {
            zone.onDock(inDockable);
            return true;
         }
      }
      return false;
   }
}
