package gm2d.skin;

import gm2d.text.TextField;
import gm2d.text.TextFormat;
import gm2d.ui.Layout;

import gm2d.ui.HitBoxes;
import gm2d.ui.Button;
import gm2d.ui.IDockable;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.display.Shape;
import gm2d.display.Graphics;
import gm2d.text.TextField;
import gm2d.text.TextFieldAutoSize;
import gm2d.geom.Point;
import gm2d.geom.Rectangle;
import gm2d.geom.Matrix;


class TabRenderer
{
   public function new() { }

   public dynamic function renderBackground(bitmap:BitmapData)
   {
      var skin = Skin.current;
      var shape = skin.mDrawing;
      var gfx = shape.graphics;
      var w = bitmap.width;
      var tabHeight = bitmap.height;
      gfx.clear();

      var mtx = new gm2d.geom.Matrix();

      mtx.createGradientBox(tabHeight,tabHeight,Math.PI * 0.5);

      var cols:Array<Int> = [ skin.guiDark, skin.tabGradientColor];
      var alphas:Array<Float> = [1.0, 1.0];
      var ratio:Array<Int> = [0, 255];
      gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,w,tabHeight);
      bitmap.draw(shape);
   }

   public dynamic function renderTabs(inTabContainer:Sprite,
                              inRect:Rectangle,
                              inPanes:Array<IDockable>,
                              inCurrent:IDockable,
                              outHitBoxes:HitBoxes,
                              inShowRestore:Bool  )
   {
      var skin = Skin.current;
      var tabHeight = skin.tabHeight;
      var tmpText = skin.mText;
      var shape = skin.mDrawing;

      var w = inRect.width;
      var bitmap = new BitmapData(Std.int(w), tabHeight ,true, #if neko { a:0, rgb:0 } #else 0 #end );
      var display = new Bitmap(bitmap);
      var boxOffset = outHitBoxes.getHitBoxOffset(inTabContainer,inRect.x,inRect.y);
      display.x = inRect.x;
      display.y = inRect.y;
      inTabContainer.addChild(display);

      renderBackground(bitmap);
      var gfx = shape.graphics;
      gfx.clear();


      var buts = [ MiniButton.POPUP ];
      if (inShowRestore)
         buts.push( MiniButton.RESTORE );
      var x = bitmap.width - 4;
      for(but in buts)
      {
         var bmp = skin.getButtonBitmapData(but,HitBoxes.BUT_STATE_UP);
         if (bmp!=null) 
         {
            x-= bmp.width;
            var y = (tabHeight-bmp.height)/2;

            bitmap.copyPixels( bmp, new Rectangle(0,0,bmp.width,bmp.height), new Point(x,y), null, null, true );

            outHitBoxes.add( new Rectangle(boxOffset.x + x,boxOffset.y +  y,bmp.width,bmp.height), HitAction.BUTTON(null,but) );
         }
      }

      var trans = new gm2d.geom.Matrix();
      trans.tx = 1;
      trans.ty = 2;

      var cx = trans.tx;
      var text_offset = 4-2;
      var extra_width = 8;
      var gap = 2;
      for(pane in inPanes)
      {
         tmpText.text = pane.getShortTitle();
         var tw = tmpText.textWidth + extra_width;
         var icon = pane.getIcon();
         var iconWidth = 0;
         if (icon!=null)
            iconWidth = icon.width + gap;
         tw += iconWidth;


         var r = new Rectangle(trans.tx,0,tw,tabHeight);
         outHitBoxes.add(new Rectangle(trans.tx+boxOffset.x,boxOffset.y,tw,tabHeight), TITLE(pane) );

         if (pane==inCurrent)
         {
            cx = trans.tx;
            trans.tx+=tw+gap;
         }
         else
         {
            gfx.clear();
            gfx.lineStyle(1,0x404040);
            gfx.beginFill(skin.guiDark);
            gfx.drawRoundRect(0.5,0.5,tw,tabHeight+2,6,6);
            bitmap.draw(shape,trans);
            trans.tx+=text_offset;
            if (icon!=null)
            {
               var bmp = new Bitmap(icon);
               bitmap.draw(bmp,trans);
               trans.tx+=iconWidth;
            }
            bitmap.draw(tmpText,trans);
            trans.tx+=tw-text_offset+gap-iconWidth;
         }
      }
      if (inCurrent!=null)
      {
         cx -=2;
         text_offset += 2;
         extra_width += 4;
 
         tmpText.text = inCurrent.getShortTitle();
         var tw = tmpText.textWidth + extra_width;

         var icon = inCurrent.getIcon();
         var iconWidth = 0;
         if (icon!=null)
            iconWidth = icon.width + gap;
         tw+=iconWidth;
         trans.ty = 0;

         trans.tx = 0;
         gfx.clear();
         gfx.lineStyle(1,0x404040);
         gfx.beginFill(skin.guiMedium);
         gfx.moveTo(-1,tabHeight-4);
         gfx.lineTo(cx,tabHeight-4);
         gfx.lineTo(cx,6);
         gfx.curveTo(cx,2,cx+5,1);
         gfx.lineTo(cx+tw-5,1);
         gfx.curveTo(cx+tw,1,cx+tw,6);
         gfx.lineTo(cx+tw,tabHeight-4);
         gfx.lineTo(w+2,tabHeight-4);
         gfx.lineTo(w+2,tabHeight);
         gfx.lineTo(-2,tabHeight);
         bitmap.draw(shape,trans);
         trans.tx = cx+text_offset;
         trans.ty = 2;

         if (icon!=null)
         {
            var bmp = new Bitmap(icon);
            bitmap.draw(bmp,trans);
            trans.tx+=iconWidth;
         }
         bitmap.draw(tmpText,trans);
      }

      gfx.clear();
      gfx.beginFill(skin.guiMedium);
      gfx.drawRect(0,tabHeight-2,w,8);
      bitmap.draw(shape);
   }
}




