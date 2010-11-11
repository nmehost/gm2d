package gm2d.ui;

import gm2d.text.TextField;
import gm2d.display.BitmapData;
import gm2d.events.MouseEvent;
import gm2d.ui.Button;
import gm2d.blit.Viewport;
import gm2d.blit.Layer;


class BitmapText extends Base
{
   var mViewport:Viewport;
   var mLayer:Layer;
   var mOnChange:String->Void;
   var mFont:BitmapFont;
   var mText:String;
   var text(getText,setText):String;

   public function new(inFont:BitmapFont, inVal="", ?onUpdate:String->Void)
   {
      super();
      mViewport = Viewport.create(50,50, true, 0xffffff, false );
      mLayer = mViewport.createLayer();
      mFont = inFont;
      mOnChange = onUpdate;

      addChild(mViewport);

      setText(inVal);
   }

   public function setText(inText:String)
   {
      mText = inText;
      mLayer.clear();
      var x = 0.0;
      for(i in 0...mText.length)
      {
         var code = mText.charCodeAt(i);
         var tile = mFont.getGlyph(code);
         if (tile!=null)
            mLayer.addTile(tile,x,0);
         x += mFont.getAdvance(code);
      }
      return mText;
   }
   public function getText() { return mText; }

   public override function layout(inW:Float, inH:Float)
   {
       mViewport.resize(Std.int(inW),Std.int(inH));
       var gfx = graphics;
       gfx.clear();
       gfx.lineStyle(1,0x808080);
       gfx.beginFill(0xf0f0ff);
       gfx.drawRect(0.5,0.5,inW-1,23);
       gfx.lineStyle();
   }

}


