package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.ui.Keyboard;
import gm2d.ui.Button;
import gm2d.skin.Skin;
import gm2d.ui.Layout;

class TextLabel extends Control
{
   public var text(get_text,set_text):String;
   var mText:TextField;
   var mTextLayout:Layout;

   public function new(inVal="",?inLineage:Array<String>)
   {
       super(Widget.addLine(inLineage,"TextLabel"));

       mText = new TextField();
       mText.autoSize = nme.text.TextFieldAutoSize.LEFT;
       mText.background = true;
       mText.backgroundColor = 0xffffff;
       addChild(mText);

       if (isInput())
          mText.type = nme.text.TextFieldType.INPUT;
       mText.autoSize = nme.text.TextFieldAutoSize.NONE;
       mRenderer.renderLabel(mText);
       mText.text = inVal;
       mText.x = 0.5;
       mText.y = 0.5;
       mText.border = true;
       mText.borderColor = 0x000000;

       mTextLayout = new TextLayout(mText).setAlignment(Layout.AlignStretch);

       var extra = createExtraWidgetLayout();
       if (extra==null)
          setItemLayout( mTextLayout );
       else
       {
          var grid = new GridLayout(2,"grid",0);
          grid.setColStretch(0,1);
          grid.add( mTextLayout );
          grid.add( extra );
          grid.setAlignment(Layout.AlignStretch  | Layout.AlignCenterY );
          grid.setSpacing(0,0);
          grid.mDbgObj = this;
          setItemLayout(grid);
       }


       mTextLayout.mDebugCol = 0xff00ff;

       build();
   }

   public function isInput() : Bool { return false; }

   public function createExtraWidgetLayout() : Layout { return null; }

   public function setTextWidth(inW:Float)
   {
      mTextLayout.setBestWidth(inW);
      build();
   }

   public function set_text(inText:String)
   {
       mText.text = inText;
       return inText;
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
   }

}


