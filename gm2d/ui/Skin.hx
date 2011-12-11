package gm2d.ui;

import gm2d.filters.BitmapFilter;
import gm2d.filters.BitmapFilterType;
import gm2d.filters.DropShadowFilter;
import gm2d.filters.GlowFilter;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.display.Shape;
import gm2d.display.Graphics;
import gm2d.text.TextField;
import gm2d.geom.Point;
import gm2d.geom.Rectangle;
import gm2d.geom.Matrix;
import gm2d.ui.HitBoxes;

class Skin
{
   public static var current:Skin = new Skin();

   public var textFormat:gm2d.text.TextFormat;
   public var menuHeight:Float;
   public var mBitmaps:Array< Array<BitmapData> >;
   public var centerTitle:Bool;
   public var buttonBorderX:Float;
   public var buttonBorderY:Float;

   var mDrawing:Shape;
   var mText:TextField;

   public function new()
   {
      textFormat = new gm2d.text.TextFormat();
      textFormat.size = 12;
      textFormat.font = "Arial";
      menuHeight = 22;
      mBitmaps = [];
      centerTitle = true;
      buttonBorderX = 10;
      buttonBorderY = 5;
      for(state in  HitBoxes.BUT_STATE_UP...HitBoxes.BUT_STATE_DOWN+1)
         mBitmaps[state] = [];
   }

   public function renderCurrent(inWidget:Widget)
   {
      var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 3, 3, false, false);
      inWidget.filters = [ glow ];
   }
   public function clearCurrent(inWidget:Widget)
   {
      inWidget.filters = null;
   }

   public function renderMenubar(inObject:gm2d.display.Sprite,inW:Float, inH:Float)
   {
      var gfx = inObject.graphics;
      gfx.clear();
      var mtx = new gm2d.geom.Matrix();
      mtx.createGradientBox(inH,inH,Math.PI * 0.5);
      var cols:Array<Int> = [0xf0f0e0, 0xe0e0d0, 0xa0a090];
      var alphas:Array<Float> = [1.0, 1.0, 1.0];
      var ratio:Array<Int> = [0, 128, 255];
      gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,inW,inH);
   }

   public function styleMenu(inItem:Button)
   {
      inItem.getLabel().backgroundColor = 0x4040a0;
      inItem.getLabel().textColor = 0x000000;
      inItem.onCurrentChangedFunc = function(_) { };
   }

   public function styleLabelText(label:TextField)
   {
      label.defaultTextFormat = textFormat;
      label.textColor = Panel.labelColor;
      label.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
      label.selectable = false;
      label.mouseEnabled = false;
  }

   public function styleButtonText(label:TextField)
   {
      styleLabelText(label);
      label.mouseEnabled = true;
      //label.border = true;
      //label.borderColor = 0x000000;
   }


   public function styleText(inText:gm2d.text.TextField)
   {
      inText.defaultTextFormat = textFormat;
   }


   public function renderButton(inGfx:Graphics, inWidth:Float, inHeight:Float)
   {
      inGfx.clear();
      inGfx.beginFill(0xf0f0e0);
      inGfx.lineStyle(1,0x000000);
      inGfx.drawRoundRect(0.5,0.5,inWidth,inHeight,6,6);
   }

    public function renderProgressBar(inGfx:Graphics, inWidth:Float, inHeight:Float, inFraction:Float)
   {
      inGfx.clear();
      inGfx.beginFill(0xffffff);
      inGfx.lineStyle(1,0x000000);
      inGfx.drawRoundRect(0.5,0.5,inWidth,inHeight,6,6);
      inGfx.lineStyle();
      inGfx.beginFill(0x2020ff);
      inGfx.drawRoundRect(0.5,0.5,inWidth*inFraction,inHeight,6,6);
   }


   public function renderDialog(inGfx:Graphics, inWidth:Float, inHeight:Float)
   {
      renderButton(inGfx,inWidth,inHeight);
   }

   public function renderMDI(inMDI:Sprite)
   {
      var gfx = inMDI.graphics;
      gfx.clear();
      var rect = inMDI.scrollRect;
      if (rect!=null)
      {
         gfx.beginFill(0x404040);
         gfx.drawRect(rect.x, rect.y, rect.width, rect.height );
      }
   }

   function createButtonBitmap(inButton:Int, inState:Int) : BitmapData
   {
      var bmp = new BitmapData(16,16,true, gm2d.RGB.CLEAR );
      var shape = new gm2d.display.Shape();
      var gfx = shape.graphics;
      gfx.lineStyle(1,0xffffff);
      var matrix = new Matrix();
      if (inButton==MiniButton.CLOSE)
      {
         gfx.moveTo(3,3);
         gfx.lineTo(12,12);
         gfx.moveTo(12,3);
         gfx.lineTo(3,12);
      }
      if (inButton==MiniButton.MINIMIZE)
      {
         gfx.moveTo(3,12);
         gfx.lineTo(12,12);
      }
      else if (inButton==MiniButton.MAXIMIZE)
      {
         gfx.drawRect(3,3,11,11);
      }
      else if (inButton==MiniButton.RESTORE)
      {
         gfx.drawRect(3,3,6,6);
         gfx.drawRect(8,8,6,6);
      }
      else if (inButton==MiniButton.POPUP)
      {
         gfx.beginFill(0xffffff);
         gfx.moveTo(5,7);
         gfx.lineTo(11,7);
         gfx.lineTo(8,10);
         gfx.lineTo(5,7);
      }
      if (inState==HitBoxes.BUT_STATE_DOWN)
      {
         matrix.tx = matrix.ty = 1;
      }

      if (inState!=HitBoxes.BUT_STATE_UP)
      {
         // todo: why does this not work in flash
         var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 1, 1, 3, 3, false, false);
         shape.filters = [ glow ];
      }
        
      bmp.draw(shape,matrix);
      return bmp;
   }

   function getButtonBitmap(inButton:Int, inState:Int) : BitmapData
   {
      if (mBitmaps[inState][inButton]==null)
         mBitmaps[inState][inButton]=createButtonBitmap(inButton,inState);
      return mBitmaps[inState][inButton];
   }

   static var title_h = 22;
   static var borders = 3;

   public function getFrameClientOffset() : Point
   {
      return new Point(borders,borders+title_h);
   }
   public function getMiniWinClientOffset() : Point
   {
      return new Point(borders,borders);
   }
   public function getMinFrameWidth() : Float
   {
      return 80;
   }

   public function renderFrame(inObj:Sprite, pane:IDockable, inW:Float, inH:Float,
             outHitBoxes:HitBoxes,inIsCurrent:Bool)
   {
      outHitBoxes.clear();

      var gfx = inObj.graphics;
      gfx.clear();

      var w = inW+borders*2;
      var h = inH+borders*2+title_h;


		if (inIsCurrent)
		{
         var mtx = new gm2d.geom.Matrix();
         mtx.createGradientBox(title_h+borders,title_h+borders,Math.PI * 0.5);
         var cols:Array<Int> = [0xf0f0e0, 0xe0e0d0, 0xa0a090];
         var alphas:Array<Float> = [1.0, 1.0, 1.0];
         var ratio:Array<Int> = [0, 128, 255];
         gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
         gfx.lineStyle(1,0xf0f0e0);
		}
		else
		{
		   gfx.beginFill(0xa0a090);
         gfx.lineStyle(1,0xa0a090);
		}

      gfx.drawRoundRect(0.5,0.5,w, h, 3,3 );

      if ( Dock.isResizeable(pane) )
      {
         gfx.endFill();
         for(o in 0...4)
         {
            var dx = (o+2)*3;
            gfx.moveTo(w-dx,h);
            gfx.lineTo(w,h-dx);
         }
         outHitBoxes.add( new Rectangle(w-12,h-12,12,12), HitAction.RESIZE(pane, ResizeFlag.S|ResizeFlag.E) );
      }

		gfx.beginFill(0xffffff);
      gfx.drawRect(borders-0.5,title_h+borders-0.5,inW+1, inH+1 );


      var x = inW - borders;
      for(but in [ MiniButton.CLOSE, MiniButton.MINIMIZE, MiniButton.MAXIMIZE ] )
      {
         var bmp = getButtonBitmap(but,pane.buttonStates()[but]);
         if (bmp!=null) 
         {
            var bitmap = outHitBoxes.bitmaps[but];
            if (bitmap==null)
            {
               bitmap = new Bitmap(bmp);
               outHitBoxes.bitmaps[but]=bitmap;
               inObj.addChild(bitmap);
               bitmap.y = Std.int( (title_h - bmp.height)/2 );
            }
            else if ( bitmap.bitmapData != bmp )
            {
               bitmap.bitmapData = bmp;
            }

            x-= bitmap.width;
            bitmap.x = x;

            outHitBoxes.add( new Rectangle(bitmap.x,bitmap.y,bmp.width,bmp.height),
                     HitAction.BUTTON(pane,but) );
         }
      }

      var titleBmp = outHitBoxes.bitmaps[MiniButton.TITLE];
      if (titleBmp==null)
      {
         titleBmp = new Bitmap();
         titleBmp.x = borders;
         titleBmp.y = borders;
         inObj.addChild(titleBmp);
         outHitBoxes.bitmaps[MiniButton.TITLE] = titleBmp;
      }

      titleBmp.bitmapData = renderText(pane.getTitle(),pane.getShortTitle(),x-borders,  title_h-borders*2);

      if (centerTitle)
         titleBmp.x = Std.int((x-borders-titleBmp.width)/2);

      outHitBoxes.add( new Rectangle(0,0,inW,title_h), TITLE(pane) );
   }

   public function renderText(inText:String, inAltText:String,inWidth:Float, inHeight:Float)
   {
      mText.text = inText;
      var text_size = mText.textWidth;
      if (text_size>inWidth)
      {
         mText.text = inAltText;
         text_size = mText.textWidth;
      }

      var tw = Std.int(Math.min(text_size+0.99,inWidth));
      if (inText=="" || tw<1)
         return null;
      var bmp = new BitmapData(tw,Std.int(inHeight),true, #if neko { a:0, rgb:0 } #else 0 #end );

      var mtx = new Matrix();
      mtx.tx = -2;
      mtx.ty = -2;

      if (tw>=text_size)
      {
         bmp.draw(mText,mtx);
      }
      else
      {
         mText.text = "...";
         var space = inWidth-mText.textWidth;

         var text = inAltText;
         var len = text.length;
         
         // Left align...
         var min=0;
         /*
         var min = 1;
         var max = text.length-1;
         while(min+1<max)
         {
            var mid = (min+max)>>1;
            mText.text = text.substr(mid);
            var diff =  mText.textWidth-space;
            if (diff==0)
            {
               min = mid;
               break;
            }
            else if (diff<0)
               max = mid;
            else
               min = mid;
         }
         */
         mText.text = "..." + text.substr(min);
         
         bmp.draw( mText, mtx );
      }

      return bmp;
   }
   

   public function renderMiniWin(inObj:Sprite, pane:Pane, inW:Float, inH:Float,outHitBoxes:HitBoxes)
   {
      var gfx = inObj.graphics;
      gfx.clear();

      gfx.beginFill(0xa0a090);
      gfx.lineStyle(1,0xa0a090);

      gfx.drawRoundRect(0.5,0.5,inW+borders*2, inH+borders*2, 3,3 );
      gfx.endFill();
      gfx.drawRect(borders-0.5,borders-0.5,inW+1, inH+1 );

      outHitBoxes.clear();
   }


   static var tab_height = 24;

   function initGfx()
   {
      if (mDrawing==null)
         mDrawing = new Shape();
      if (mText==null)
      {
         mText = new TextField();
         styleLabelText(mText);
      }
   }

   public function getTabHeight() { return tab_height; }
   public function renderTabs(inArea:BitmapData,
                              inPanes:Array<IDockable>,
                              inCurrent:IDockable,
                              outHitBoxes:HitBoxes,
                              inIsMaximized:Bool  )
   {
      initGfx();
      var w = inArea.width;
      var gfx = mDrawing.graphics;
      gfx.clear();
      var mtx = new gm2d.geom.Matrix();

      mtx.createGradientBox(tab_height,tab_height,Math.PI * 0.5);

      //var cols:Array<Int> = [ 0xe0e0d0, 0xa0a090];
      var cols:Array<Int> = [ 0xa0a090, 0x909080];
      var alphas:Array<Float> = [1.0, 1.0];
      var ratio:Array<Int> = [0, 255];
      gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,w,tab_height);
      inArea.draw(mDrawing);

      outHitBoxes.clear();


      var buts = [ MiniButton.POPUP ];
      if (inIsMaximized)
         buts.push( MiniButton.RESTORE );
      var x = inArea.width - 4;
      for(but in buts)
      {
         var bmp = getButtonBitmap(but,outHitBoxes.buttonState[but]);
         if (bmp!=null) 
         {
            x-= bmp.width;
            var y = (tab_height-bmp.height)/2;

            inArea.copyPixels( bmp, new Rectangle(0,0,bmp.width,bmp.height), new Point(x,y), null, null, true );

            outHitBoxes.add( new Rectangle(x,y,bmp.width,bmp.height), HitAction.BUTTON(null,but) );
         }
      }

      var trans = new gm2d.geom.Matrix();
      trans.tx = 2;
      trans.ty = 2;
      for(pane in inPanes)
      {
         mText.text = pane.getShortTitle();
         var tw = mText.textWidth + 4;
         gfx.clear();
         //gfx.lineStyle(1,0xf0f0e0);
         gfx.lineStyle(1,0x404040);
         gfx.beginFill(pane==inCurrent ? 0xe0e0d0 : 0xa0a090);
         gfx.drawRoundRect(0.5,0.5,tw,tab_height+2,3,3);
         inArea.draw(mDrawing,trans);
         outHitBoxes.add(new Rectangle(trans.tx,0,tw,tab_height), TITLE(pane) );
         inArea.draw(mText,trans);
         trans.tx+=tw+4;
      }

      gfx.clear();
      gfx.beginFill(0xe0e0d0);
      gfx.drawRect(0,tab_height-2,w,8);
      inArea.draw(mDrawing);
   }
}

