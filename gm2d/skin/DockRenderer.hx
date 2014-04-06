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

   public function new(inVariableWidths:Bool)
   {
      variableWidths = inVariableWidths;
      gripperTop = inVariableWidths;
   }

   public function getResizeBarWidth() : Float { return Skin.getResizeBarWidth(); }
   public function getChromeRect(inDocked:IDockable) : Rectangle
   {
      return Skin.getChromeRect(inDocked,gripperTop);
   }
   public function renderResizeBar(outDisplay:Sprite, inRect:Rectangle, inPos:Float)
   {
      var gfx = outDisplay.graphics;
      var gap = getResizeBarWidth();
      var extra = 2;
      gfx.beginFill(Skin.panelColor);
      //gfx.beginFill(0x000000);
      if (!variableWidths)
         gfx.drawRect(inRect.x, inRect.y+inPos,inRect.width,gap);
      else
         gfx.drawRect(inRect.x+inPos, inRect.y,gap,inRect.height);
   }
   public function renderPaneChrome(outDisplay:Sprite, inPane:Pane, inRect:Rectangle,
                outHitBoxes:HitBoxes )
   {
      Skin.renderPaneChrome(inPane,outDisplay,outHitBoxes,inRect,
              gripperTop?Skin.TOOLBAR_GRIP_TOP:0);
   }
   public function renderToolbarGap(outDisplay:Sprite, x:Float, y:Float, w:Float, h:Float)
   {
      Skin.renderToolbarGap(outDisplay,x,y,w,h);
   }

}

