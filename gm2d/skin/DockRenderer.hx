package gm2d.skin;

import gm2d.ui.Widget;
import gm2d.ui.WidgetState;
import gm2d.ui.IDockable;
import gm2d.ui.Pane;
import gm2d.ui.HitBoxes;
import nme.geom.Rectangle;
import nme.display.Sprite;
import nme.display.Graphics;


class DockRenderer
{
   public var gripperTop:Bool;
   public var variableWidths:Bool;
   var skin:Skin;

   public function new(inSkin:Skin, inVariableWidths:Bool)
   {
      skin = inSkin;
      variableWidths = inVariableWidths;
      gripperTop = inVariableWidths;
   }

   public function getResizeBarWidth() : Float { return skin.getResizeBarWidth(); }
   public function getChromeRect(inDocked:IDockable) : Rectangle
   {
      return skin.getChromeRect(inDocked,gripperTop);
   }
   public function renderResizeBar(outDisplay:Sprite, inRect:Rectangle)
   {
      var gfx = outDisplay.graphics;
      gfx.beginFill(skin.resizeBarColor);
      gfx.drawRect(inRect.x, inRect.y,inRect.width,inRect.height);
   }
   public function renderPaneChrome(outDisplay:Sprite, inPane:Pane, inRect:Rectangle,
                outHitBoxes:HitBoxes )
   {
      skin.renderPaneChrome(inPane,outDisplay,outHitBoxes,inRect,
              gripperTop?Skin.TOOLBAR_GRIP_TOP:0);
   }
   public function renderToolbarGap(outDisplay:Sprite, x:Float, y:Float, w:Float, h:Float)
   {
      skin.renderToolbarGap(outDisplay,x,y,w,h);
   }

}

