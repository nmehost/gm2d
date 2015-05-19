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
   var mText:TextField;
   var mTextLayout:Layout;
   public var isInput(default,null):Bool;
   public var processSpecial:Bool;

   public function new(inVal="",?inLineage:Array<String>, ?inAttribs:{} )
   {
       super(Widget.addLine(inLineage,"TextLabel"),inAttribs);
       wantFocus = false;

       createUnderlay();

       mText = new TextField();
       //mText.autoSize = nme.text.TextFieldAutoSize.LEFT;
       //mText.background = true;
       //mText.backgroundColor = 0xffffff;
       addChild(mText);

       isInput = attribBool("isInput",false);
       processSpecial = attribBool("processSpecial",false);

       if (isInput)
          mText.type = nme.text.TextFieldType.INPUT;
       else
          mText.mouseEnabled = false;
       if (mRenderer.getDefaultBool("multiline",false))
          mText.multiline = true;
       mText.text = inVal;
       mRenderer.renderLabel(mText);
       mText.x = 0;
       mText.y = 0;
       //mText.border = true;
       //mText.borderColor = 0x000000;

       //mText.autoSize = nme.text.TextFieldAutoSize.LEFT;
       //trace(inVal + ":" + mText.width + "x" + mText.height);

       mTextLayout = new AutoTextLayout(mText).setAlignment(Layout.AlignCenterY);
       //trace("   => " + mTextLayout.getBestWidth() + "x" + mTextLayout.getBestHeight() );

       var extra = createExtraWidgetLayout();
       if (extra==null)
          setItemLayout( mTextLayout );
       else
       {
          var grid = new GridLayout(2,"grid");
          grid.setColStretch(0,1);
          grid.add( mTextLayout );
          grid.add( extra );
          grid.setAlignment(Layout.AlignStretch  | Layout.AlignCenterY );
          grid.setSpacing(0,0);
          grid.mDbgObj = this;
          setItemLayout(grid).setAlignment(Layout.AlignCenterY);
       }


       mTextLayout.mDebugCol = 0xff00ff;

       build();
   }

   override public function setText(inText:String) : Void
   {
      mText.text = inText;
   }

   public function createUnderlay() { }

   override public function getLabel( ) : TextField
   {
      return mText;
   }

   public function createExtraWidgetLayout() : Layout { return null; }

   public function setTextWidth(inW:Float)
   {
      mTextLayout.setBestWidth(inW);
      build();
   }


   override public function set_isCurrent(inVal:Bool) : Bool
   {
      super.set_isCurrent(inVal);
      if (!inVal && stage!=null && stage.focus==mText)
         stage.focus = null;
      return inVal;
   }

   override public function activate()
   {
      super.activate();

      if (isInput && stage!=null)
         stage.focus = mText;
   }


   public override function onKeyDown(event:nme.events.KeyboardEvent ) : Bool
   {
      #if flash
      var code:UInt = event.keyCode;
      #else
      var code:Int = event.keyCode;
      #end

      // Let these ones thought to the keeper...
      if (!processSpecial)
      {
         if (code==Keyboard.DOWN || code==Keyboard.UP || code==Keyboard.TAB)
            return false;
         // Esc/back
         if ( (code==27 || code==Keyboard.ENTER) && stage!=null && mText!=null && stage.focus==mText)
         {
            stage.focus = null;
            return true;
         }
      }

      return stage!=null && stage.focus == mText;
   }



   /*
   public override function redraw()
   {
   }
   */

}


