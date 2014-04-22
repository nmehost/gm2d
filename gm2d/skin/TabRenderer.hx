package gm2d.skin;

import nme.text.TextField;
import nme.text.TextFormat;
import gm2d.ui.Layout;

import gm2d.ui.HitBoxes;
import gm2d.ui.Button;
import gm2d.ui.IDockable;
import gm2d.ui.Widget;
import nme.display.Sprite;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Shape;
import nme.display.Graphics;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import gm2d.CInt;


class TabRenderer
{
   public static inline var TOP = 0;
   public static inline var LEFT = 1;
   public static inline var RIGHT = 2;
   public static inline var BOTTOM = 3;

   public function new() { }

   public static inline var SHOW_RESTORE  = 0x0001;
   public static inline var SHOW_TEXT     = 0x0002;
   public static inline var SHOW_ICON     = 0x0004;
   public static inline var SHOW_PIN      = 0x0008;
   public static inline var SHOW_POPUP    = 0x0010;

   public static inline var IS_OVERLAPPED = 0x0020;

   public dynamic function renderBackground(bitmap:BitmapData)
   {
      var shape = Skin.mDrawing;
      var gfx = shape.graphics;
      var w = bitmap.width;
      var tabHeight = bitmap.height;
      gfx.clear();

      var mtx = new Matrix();

      mtx.createGradientBox(tabHeight,tabHeight,Math.PI * 0.5);

      var cols:Array<CInt> = [ Skin.guiDark, Skin.tabGradientColor];
      var alphas:Array<Float> = [1.0, 1.0];
      var ratio:Array<Int> = [0, 255];
      gfx.beginGradientFill(nme.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,w,tabHeight);
      bitmap.draw(shape);
   }

   public function getHeight()
   {
      return  Skin.tabHeight;
   }

   public function createTabButton(inId:String)
   {
      return Button.create(["TabButton", "UiButton"], { id:inId });
   }

   public function renderTabs(inTabContainer:Sprite,
                              inRect:Rectangle,
                              inPanes:Array<IDockable>,
                              inCurrent:IDockable,
                              outHitBoxes:HitBoxes,
                              inSide:Int,
                              inFlags:Int,
                              ?inTabPos:Null<Int> )
   {
      var tabHeight = Skin.tabHeight;
      var tmpText = Skin.mText;
      var shape = Skin.mDrawing;

      var borderLeft = 2;
      var borderRight = 8;
      var bmpPad = 2;
      var tabGap = 0;
      var tabX = new Array<Float>();

      var w = inSide==TOP || inSide==BOTTOM ? inRect.width : inRect.height;

      var buts = new Array<Widget>();
      var butPos = new Array<Int>();
      var butWidth = new Array<Int>();

      if ((inFlags & SHOW_POPUP) > 0)
         buts.push( createTabButton( MiniButton.POPUP )  );
      if ((inFlags & SHOW_RESTORE) > 0)
         buts.push( createTabButton( MiniButton.RESTORE ) );
      if ((inFlags & SHOW_PIN) > 0)
         buts.push( createTabButton( MiniButton.PIN ) );

      if ((inFlags & IS_OVERLAPPED)>0)
      {
         // Calculate actual width
         var tx = 1.0;
         for(pane in inPanes)
         {
            tabX.push(tx);
            var text = pane.getShortTitle();
            if (text=="") text="Tab";
            tmpText.text = text;
            tx += borderLeft + tmpText.textWidth + borderRight;
            var icon = pane.getIcon();
            if (icon!=null)
               tx += icon.width + bmpPad*2;
            tx+=tabGap;
         }
         tabX.push(tx);
         if (buts.length>0)
            tx+= 6;
         for(but in buts)
            tx+=but.getLayout().getBestSize().x;

         w = tx + 3;
      }

      var bitmap = new BitmapData(Std.int(w), tabHeight ,true, gm2d.RGB.CLEAR );
      var display = new Bitmap(bitmap);
      var boxOffset = outHitBoxes.getHitBoxOffset(inTabContainer,inRect.x,inRect.y);
      display.x = inRect.x;
      display.y = inRect.y;
      inTabContainer.addChild(display);

      renderBackground(bitmap);
      var gfx = shape.graphics;
      gfx.clear();


      var x = bitmap.width - 4.0;
      for(b in 0...buts.length)
      {
         var but = buts[b];
         var size = but.getLayout().getBestSize();
         x-= size.x;
         var y = (tabHeight-size.y)/2;

         var mtx = new Matrix();
         mtx.tx = x;
         mtx.ty = y;
         bitmap.draw( but, mtx );

         if ((inFlags & IS_OVERLAPPED)==0)
            outHitBoxes.add( new Rectangle(boxOffset.x + x,boxOffset.y +  y,size.x,size.y), HitAction.BUTTON(null,but.name) );
         else
         {
            butPos[b] = Std.int(x);
            butWidth[b] = Std.int(size.x);
         }
      }

      var trans = new nme.geom.Matrix();
      var y0 = (inFlags & IS_OVERLAPPED)>0 ? 4 : 2;
      trans.tx = 1;
      trans.ty = y0;

      var cx = trans.tx;
      for(pane in inPanes)
      {
         var text = pane.getShortTitle();
         if (text=="") text="Tab";
         tmpText.text = text;
         var tw = borderLeft + tmpText.textWidth + borderRight;
         var icon = pane.getIcon();
         var iconWidth = 0;
         if (icon!=null)
            iconWidth = icon.width + bmpPad*2;
         tw += iconWidth;


         var r = new Rectangle(trans.tx,0,tw,tabHeight);
         if ((inFlags & IS_OVERLAPPED)==0)
            outHitBoxes.add(new Rectangle(trans.tx+boxOffset.x,boxOffset.y,tw,tabHeight), TITLE(pane) );

         if (pane==inCurrent)
         {
            cx = trans.tx;
            trans.tx+=tw+tabGap;
         }
         else
         {
            gfx.clear();
            gfx.lineStyle(1,0x404040);
            gfx.beginFill(Skin.guiDark);
            gfx.drawRoundRect(0.5,0.5,tw,tabHeight+2,6,6);
            trans.ty = y0;
            bitmap.draw(shape,trans);
            trans.tx+=borderLeft;
            if (icon!=null)
            {
               var bmp = new Bitmap(icon);
               trans.tx+=bmpPad;
               trans.ty = Std.int( (tabHeight - bmp.height)* 0.5 );
               bitmap.draw(bmp,trans);
               trans.tx+=iconWidth-bmpPad;
            }
            trans.ty = Std.int( (tabHeight - tmpText.textHeight)*0.5 );
            bitmap.draw(tmpText,trans);
            trans.tx += tw-borderLeft+tabGap-iconWidth;
         }
      }
      if (inCurrent!=null)
      {
         if (inCurrent!=inPanes[0])
         {
            cx -=2;
            borderLeft += 2;
         }
         else
         {
            cx -=1;
            borderLeft += 1;
         }
         borderRight += 2;
 
         var text = inCurrent.getShortTitle();
         if (text=="") text="Tab";
         tmpText.text = text;

         var tw = borderLeft + tmpText.textWidth + borderRight;

         var icon = inCurrent.getIcon();
         var iconWidth = 0;
         if (icon!=null)
            iconWidth = icon.width + bmpPad*2;
         tw+=iconWidth;
         trans.ty = y0-1;
         trans.tx = 0;

         gfx.clear();
         gfx.lineStyle(1,0x404040);
         gfx.beginFill(Skin.guiMedium);
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
         trans.tx = cx+borderLeft;

         if (icon!=null)
         {
            var bmp = new Bitmap(icon);
            trans.tx += bmpPad;
            trans.ty = (tabHeight - icon.height) >> 1;
            bitmap.draw(bmp,trans);
            trans.tx+=bmpPad;
            trans.tx+=iconWidth-bmpPad;
         }
         trans.ty = Std.int( (tabHeight - tmpText.textHeight)*0.5 );
         bitmap.draw(tmpText,trans);
      }

      if ((inFlags & IS_OVERLAPPED) == 0)
      {
         gfx.clear();
         gfx.beginFill(Skin.guiMedium);
         gfx.drawRect(0,tabHeight-2,w,8);
         bitmap.draw(shape);
      }
      else
      {
         switch(inSide)
         {
            case TOP:
               display.y -= tabHeight-2;
               if (inTabPos==null)
                  display.x += Std.int((inRect.width-w)*0.5);
               else
                  display.x += inTabPos;
               for(i in 0...tabX.length-1)
                  outHitBoxes.add(new Rectangle(display.x+boxOffset.x+tabX[i],boxOffset.y+display.y,
                           tabX[i+1]-tabX[i],tabHeight), TITLE(inPanes[i]) );
               for(b in 0...buts.length)
                  outHitBoxes.add(new Rectangle(display.x+boxOffset.x+butPos[b],boxOffset.y+display.y,
                           butWidth[b],tabHeight),  HitAction.BUTTON(null,buts[b].name));

            case BOTTOM:
               display.y += inRect.height;

            case RIGHT:
               display.rotation = 90;
               display.x += inRect.width + tabHeight;

            case LEFT:
               display.rotation = -90;
               display.x -= tabHeight;

               if (inTabPos!=null)
                  display.y += w + inTabPos;
               else
                  display.y += Std.int((inRect.height+w)*0.5);

               for(i in 0...tabX.length-1)
               {
                  outHitBoxes.add(new Rectangle(display.x+boxOffset.x,
                           boxOffset.y+display.y - tabX[i+1],
                           tabHeight,tabX[i+1]-tabX[i]), TITLE(inPanes[i]) );
               }
               for(b in 0...buts.length)
                  outHitBoxes.add(new Rectangle(display.x+boxOffset.x,boxOffset.y+display.y-butPos[b]-butWidth[b],
                           tabHeight, butWidth[b]),  HitAction.BUTTON(null,buts[b].name));

         }
      }
   }
}




