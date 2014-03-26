package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.ui.Keyboard;
import gm2d.ui.Button;
import gm2d.skin.Skin;
import gm2d.ui.Layout;

class TextInput extends Control
{
   public var text(get_text,set_text):String;
   var mText:TextField;
   static var boxHeight = 22;

   public function new(inVal="", ?onUpdate:String->Void)
   {
       super("TextInput");
       mText = new TextField();
       mText.type = nme.text.TextFieldType.INPUT;
       mText.text = inVal;
       mText.x = 0.5;
       mText.y = 0.5;
       mText.height = boxHeight-1;
       mText.border = true;
       mText.borderColor = 0x00ff00;
       addChild(mText);
       mRenderer.renderLabel(mText);

       mLayout = new ChildStackLayout();
       mLayout.add( new DisplayLayout(this) );

       var extra = createExtraWidgetLayout();
       if (extra==null)
          mLayout.add( new TextLayout(mText) );
       else
       {
          var grid = new GridLayout(2,"grid",0);
          grid.setColStretch(0,1);
          grid.add( new TextLayout(mText) );
          grid.add( extra );
          mLayout.add(grid);
       }

       if (onUpdate!=null)
       {
          var t= mText;
          mText.addEventListener(nme.events.Event.CHANGE, function(_) onUpdate(t.text) );
       }
 
       build();
   }

   public function createExtraWidgetLayout() : Layout { return null; }

   public function setTextWidth(inW:Float)
   {
      mText.width = inW;
   }

   public function set_text(inText:String)
   {
       mText.text = inText;
       return inText;
   }
   public function parseInt() : Int
   {
      return Std.parseInt( mText.text );
    }

   override public function onCurrentChanged(inCurrent:Bool)
   {
      super.onCurrentChanged(inCurrent);
      if (stage!=null)
         stage.focus = inCurrent ? mText : null;
   }


   public override function onKeyDown(event:nme.events.KeyboardEvent ) : Bool
   {
      #if flash
      var code:UInt = event.keyCode;
      #else
      var code:Int = event.keyCode;
      #end

      // Let these ones thought to the keeper...
      if (code==Keyboard.DOWN || code==Keyboard.UP || code==Keyboard.TAB)
         return false;
      return true;
   }


   public function get_text() { return mText.text; }

   public override function redraw()
   {
       var gfx = graphics;
       gfx.clear();
       gfx.lineStyle(1,0x808080);
       gfx.beginFill(0xf0f0ff);
       gfx.drawRect(0.5,0.5,mRect.width-1,23);
       gfx.lineStyle();
       mText.width = mRect.width - 2;
       mText.y =  (boxHeight - 2 - mText.textHeight)/2;
       mText.height =  boxHeight-mText.y;
   }

}


