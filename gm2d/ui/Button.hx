package gm2d.ui;

import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.display.DisplayObject;
import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.events.MouseEvent;
import gm2d.text.TextField;
import gm2d.ui.Layout;

class Button extends Base
{
   var mDisplayObj : DisplayObject;
   public var mBG : Sprite;
   var mCallback : Void->Void;

   public function new(inObject:DisplayObject,inOnClick:Void->Void)
   {
      super();
      mCallback = inOnClick;
      mBG = new Sprite();
      mDisplayObj = inObject;
      addChild(mBG);
      addChild(mDisplayObj);
      addEventListener(MouseEvent.CLICK, function(_) { inOnClick(); } );
   }

   public function setBackground(inSVG:gm2d.svg.SVG2Gfx, inW:Float, inH:Float)
   {
      inSVG.RenderSprite(mBG);
      mBG.width = inW;
      mBG.height = inH;
   }


   public static function BMPButton(inBitmapData:BitmapData,inX:Float, inY:Float,inOnClick:Void->Void)
   {
      var bmp = new Bitmap(inBitmapData);
      bmp.x = inX;
      bmp.y = inY;
      return new Button(bmp,inOnClick);
   }

   public static function TextButton(inText:String,inOnClick:Void->Void)
   {
      var label = new TextField();
      label.text = inText;
      label.setTextFormat( Dialog.labelFormat );
      label.textColor = Dialog.labelColor;
      label.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
      label.selectable = false;
      return new Button(label,inOnClick);
   }


   public function getLayout() : Layout
   {
      var layout = new ChildStackLayout( );
      layout.add( new DisplayLayout(this) );
      layout.add( new DisplayLayout(mBG) );

      if ( Std.is(mDisplayObj,TextField))
      {
         layout.add( new TextLayout(cast mDisplayObj) );
      }
      else
      {
         layout.add( new DisplayLayout(mDisplayObj) );
      }
      layout.mDebugCol = 0x00ff00;
      return layout;
   }



   override public function activate(inDirection:Int)
   {
      if (inDirection>=0)
        mCallback();
   }
}

