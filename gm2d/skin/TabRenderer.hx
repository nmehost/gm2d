package gm2d.skin;

import nme.text.TextField;
import nme.text.TextFormat;
import gm2d.ui.Layout;

import nme.display.Shape;
import gm2d.ui.HitBoxes;
import gm2d.ui.Button;
import gm2d.ui.IDockable;
import gm2d.ui.Widget;
import gm2d.ui.Pane;
import nme.display.Sprite;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Graphics;
import nme.events.MouseEvent;
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


   public static inline var SHOW_RESTORE  = 0x0001;
   public static inline var SHOW_TEXT     = 0x0002;
   public static inline var SHOW_ICON     = 0x0004;
   public static inline var SHOW_PIN      = 0x0008;
   public static inline var SHOW_POPUP    = 0x0010;
   public static inline var SHOW_CLOSE    = 0x0020;
   public static inline var SHOW_GRIP     = 0x0040;

   public static inline var IS_OVERLAPPED = 0x0100;

   static var gripBmp:BitmapData = null;

   var attribs:Map<String,Dynamic>;
   var currentAttribs:Map<String,Dynamic>;

   var buts:Array<Widget>;

   public function new(inLineage:Array<String>, inAttribs:{})
   {
      attribs = Skin.combineAttribs(inLineage, 0, inAttribs);
      currentAttribs = Skin.combineAttribs(inLineage, Widget.CURRENT, inAttribs);
   }


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
   public function renderGripBackground(bitmap:BitmapData)
   {
      var shape = Skin.mDrawing;
      var gfx = shape.graphics;
      var w = bitmap.width;
      var tabHeight = bitmap.height;
      gfx.clear();

      gfx.beginFill(Skin.guiDark);
      gfx.drawRect(0,0,w,tabHeight);

      if (gripBmp==null)
         gripBmp = DefaultBitmaps.factory("#grip",0);

      var by = Std.int( (tabHeight-gripBmp.height) * 0.5 );
      var bx = w - gripBmp.width - by;
      var matrix = new Matrix();
      matrix.tx = bx;
      matrix.ty = by;
      gfx.beginBitmapFill(gripBmp,matrix);
      gfx.drawRect(bx,by, gripBmp.width, gripBmp.height);

      bitmap.draw(shape);
   }


   public function getHeight()
   {
      return  Skin.scale(Skin.tabHeight);
   }

   public function createTabButton(inId:String, forTab = false,?pane:Pane,hitBoxes:HitBoxes)
   {
      var cb = hitBoxes.mCallback;
      var but =  Button.create([forTab ? "TabButton" : "TabBarButton","ChromeButton"], { id:inId },
                    () ->  cb( HitAction.BUTTON(pane,inId), null) );
      //but.addEventListener(MouseEvent.MOUSE_DOWN, function(e) cb( HitAction.BUTTON(pane,inId), e) );
      //but.addEventListener(MouseEvent.MOUSE_UP, function(e) cb( HitAction.BUTTON(pane,inId), e) );
      buts.push(but);
      return but;
   }

   public function renderTabs(inTabContainer:Sprite,
                              inRect:Rectangle,
                              inPanes:Array<IDockable>,
                              inCurrent:IDockable,
                              outHitBoxes:HitBoxes,
                              inSide:Int,
                              inFlags:Int,
                              ?inTabPos:Null<Int> ) : Rectangle
   {
      //var tabHeight = Skin.tabHeight;
      var tmpText = Skin.mText;
      var shape = Skin.mDrawing;

      var borderLeft = Skin.scale(4);
      var borderRight = Skin.scale(4);
      var bmpPad = Skin.scale(2);
      var tabGap = 0;
      var tabX = new Array<Float>();

      if (buts!=null)
         for(but in buts)
            inTabContainer.removeChild(but);
      buts = [];


      var w = inSide==TOP || inSide==BOTTOM ? inRect.width : inRect.height;
      var right = w;
      var tabHeight = Std.int(inSide==TOP || inSide==BOTTOM ? inRect.height : inRect.width);

      if ((inFlags & SHOW_POPUP) > 0)
         createTabButton( MiniButton.POPUP,outHitBoxes );
      if ((inFlags & SHOW_RESTORE) > 0)
         createTabButton( MiniButton.RESTORE,outHitBoxes );

      var pinBut =  ((inFlags & SHOW_PIN) > 0) ? createTabButton( MiniButton.PIN,outHitBoxes ) : null;

      var forceText = (inFlags & SHOW_TEXT) != 0;
      var showGrip = (inFlags & SHOW_GRIP) != 0;

      if ((inFlags & IS_OVERLAPPED)>0)
      {
         // Calculate actual width
         var tx = 1.0;
         for(pane in inPanes)
         {
            tabX.push(tx);
            var icon = pane.getIcon();
            tx += borderLeft + borderRight;
            if (icon==null || forceText)
            {
               var text = pane.getShortTitle();
               if (text=="") text="Tab";
               tmpText.text = text;
               tx += tmpText.textWidth;
            }
            if (icon!=null)
               tx += icon.width + bmpPad*2;
            tx+=tabGap;
         }
         tabX.push(tx);
         if (buts.length>0)
            tx+= 6;
         for(but in buts)
         {
            var s = but.getLayout().getBestSize();
            but.getLayout().setRect(tx,(Std.int(tabHeight-s.y)>>1),tx+s.x,tabHeight);
            tx+=s.x;
         }

         w = tx + 3;
      }

      var limit = inRect.width;

      var bitmap = new BitmapData(Std.int(Math.min(limit,w)), tabHeight ,true, gm2d.RGB.CLEAR );
      var display = new Bitmap(bitmap);
      var boxOffset = outHitBoxes.getHitBoxOffset(inTabContainer,inRect.x,inRect.y);
      display.x = inRect.x;
      display.y = inRect.y;
      inTabContainer.addChild(display);
      for(but in buts)
         inTabContainer.addChild(but);

      var gripClip:BitmapData = null;
      if (showGrip)
      {
         renderGripBackground(bitmap);
         outHitBoxes.add(new Rectangle(bitmap.width-tabHeight,boxOffset.y,tabHeight,tabHeight), GRIP );
         limit -= tabHeight;
         gripClip = new BitmapData(tabHeight,tabHeight,true,0);
         gripClip.copyPixels(bitmap, new Rectangle(bitmap.width-tabHeight,0,tabHeight,tabHeight), new Point(0,0) );
      }
      else
         renderBackground(bitmap);
      var gfx = shape.graphics;
      gfx.clear();


      var x = limit - 4.0;
      if ((inFlags & IS_OVERLAPPED)==0)
      {
         for(b in 0...buts.length)
         {
            var but = buts[b];
            if (but!=pinBut)
            {
               var size = but.getLayout().getBestSize();
               x-= size.x;
               var y = Std.int((tabHeight-size.y)/2);

               if ((inFlags & IS_OVERLAPPED)==0)
               {
                  var s = but.getLayout().getBestSize();
                  but.getLayout().setRect(x,y,s.x,s.y);
               }
            }
         }
         right = x;
      }

      var trans = new nme.geom.Matrix();
      var y0 = (inFlags & IS_OVERLAPPED)>0 ? 4 : 2;
      trans.tx = 1;
      trans.ty = y0;

      var cx = trans.tx;
      var closeBut = null;
      for(pane in inPanes)
      {
         var tx0 = trans.tx;
         var icon = pane.getIcon();

         var tw:Float = borderLeft;
         if (icon==null || forceText)
         {
            var text = pane.getShortTitle();
            if (text=="") text="Tab";
            tmpText.text = text;
            tw += tmpText.textWidth;
         }
         var iconWidth = 0;
         if (icon!=null)
         {
            tw += icon.width + bmpPad*2;
         }

         tw += borderRight;


         var r = new Rectangle(trans.tx,0,tw,tabHeight);
         if ((inFlags & IS_OVERLAPPED)==0)
         {
            outHitBoxes.add(new Rectangle(trans.tx+boxOffset.x,boxOffset.y,tw,tabHeight), TITLE(pane) );
         }

         if (pane==inCurrent)
         {
            cx = tx0;
            if ((inFlags & SHOW_CLOSE)!=0)
            {
               closeBut = createTabButton( MiniButton.CLOSE, true, pane.asPane(), outHitBoxes ) ;
               inTabContainer.addChild(closeBut);
               var size = closeBut.getLayout().getBestSize();
               tw += size.x+bmpPad;
            }
         }
         else
         {
            gfx.clear();
            if (!showGrip)
            {
               gfx.lineStyle(1,0x404040);
               gfx.beginFill(Skin.guiTrim);
               gfx.drawRoundRect(0.5,0.5,tw,tabHeight+2,6,6);
            }
            trans.ty = y0;
            bitmap.draw(shape,trans);
            trans.tx+=borderLeft;
            if (icon!=null)
            {
               var bmp = new Bitmap(icon);
               trans.tx+=bmpPad;
               trans.ty = Std.int( (tabHeight - bmp.height)* 0.5 );
               bitmap.draw(bmp,trans);
               trans.tx+=icon.width+bmpPad;
            }

            if (icon==null || forceText)
            {
               trans.ty = Std.int( (tabHeight - tmpText.textHeight)*0.5 );
               bitmap.draw(tmpText,trans);
            }
         }
         trans.tx = tx0 + tw+tabGap;
      }
      var lastTab = trans.tx;

      var tabs = attribs.get("tab");
      var tabShape = tabs==null ? null:tabs.shape;
      var round = tabShape!=gm2d.skin.Shape.ShapeRect;
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
         var icon = inCurrent.getIcon();
 
         var tw:Float = borderLeft;
         if (icon==null || forceText)
         {
            var text = inCurrent.getShortTitle();
            if (text=="") text="Tab";
            tmpText.text = text;

            tw += tmpText.textWidth;
         }

         if (icon!=null)
         {
            tw += icon.width + bmpPad*2;
         }
         if (closeBut!=null)
            tw += closeBut.getLayout().getBestWidth() + bmpPad;

         tw += borderRight;

         trans.ty = y0-1;
         trans.tx = 0;


         var rad0 = Skin.roundRectRad;
         var rad1 = rad0 * 0.55228;
         gfx.clear();
         gfx.lineStyle(1,0x404040);
         gfx.beginFill(Skin.guiMedium);
         gfx.moveTo(-1,tabHeight-4);
         gfx.lineTo(cx,tabHeight-4);
         if (round)
         {
            gfx.lineTo(cx,1+rad0);
            gfx.cubicTo(cx,1+rad0-rad1, cx+rad1,1, cx+rad0,1);
            gfx.lineTo(cx+tw-rad0,1);
            gfx.cubicTo(cx+tw-rad0+rad1,1, cx+tw,1+rad1, cx+tw,1+rad0);
         }
         else
         {
            gfx.lineTo(cx,1);
            gfx.lineTo(cx+tw,1);
         }
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
            trans.tx+=icon.width+bmpPad;
         }

         if (icon==null || forceText)
         {
            trans.ty = Std.int( (tabHeight - tmpText.textHeight)*0.5 );
            bitmap.draw(tmpText,trans);
            trans.tx += tmpText.textWidth;
         }

         if (closeBut!=null)
         {
            var size = closeBut.getLayout().getBestSize();
            closeBut.getLayout().setRect(trans.tx + bmpPad,Std.int((tabHeight-size.y)/2),size.x,size.y);
         }
      }

      if (pinBut!=null)
      {
         lastTab += tabGap + bmpPad;
         var s = pinBut.getLayout().getBestSize();
         pinBut.setRect(Std.int(lastTab), Std.int((tabHeight-s.y)/2), s.x, s.y );
         lastTab += s.x;
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

            case BOTTOM:
               display.y += inRect.height;

            case RIGHT:
               display.rotation = 90;
               display.x = inRect.x + tabHeight;
               display.y = inRect.y;


            case LEFT:
               display.rotation = -90;
               display.x -= tabHeight;

               if (inTabPos!=null)
                  display.y += w + inTabPos;
               else
                  display.y += Std.int((inRect.height+w)*0.5);
         }

          for(i in 0...tabX.length-1)
          {
             var rect = displayRect(display, tabX[i], 0, tabX[i+1]-tabX[i],tabHeight);
             outHitBoxes.add(rect,TITLE(inPanes[i]));
          }
          for(but in buts)
          {
             but.x += display.x;
             but.y += display.y;
          }

      }

      // Rather than clipping the tab drawing, we will just past the grip back over the top
      if (gripClip!=null)
         bitmap.copyPixels(gripClip, new Rectangle(0,0,tabHeight,tabHeight), new Point(bitmap.width-tabHeight,0) );

      return new Rectangle(lastTab, 0, right-lastTab, tabHeight);
   }

   function displayRect(display:Bitmap, inX:Float, inY:Float, inW:Float, inH:Float)
   {
      if (display.rotation==-90)
      {
         var w = inW;
         inW = inH;
         inH = w;
         var y = inY;
         inY = -inX - inH;
         inX = y ;
      }
      else if (display.rotation==90)
      {
         var w = inW;
         inW = inH;
         inH = w;
         var y = inY;
         inY = inX;
         inX = -y - inW;
      }

      var result = new Rectangle(inX + display.x, inY+display.y, inW, inH);
      return result;
   }
}




