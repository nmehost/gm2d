package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.events.MouseEvent;
import nme.geom.Point;
import gm2d.ui.Button;
import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;

class ComboList extends Window
{
   var mList:ListControl;
   var mCombo:ComboBox;
   var closeLockout = 0;
   var selectOnMove:Bool;

   public function new(inCombo:ComboBox, inW:Float, inOptions:Array<Dynamic>,inSelectOnMove:Bool)
   {
      super();
      selectOnMove = inSelectOnMove;
      mCombo = inCombo;
      mList = new ListControl(["PopupComboBox"], { width:inW } );
      mList.variableHeightRows = true;
      mList.addItems(inOptions);
      addChild(mList);
      mList.scrollRect = null;
      mList.onSelect = onSelect;
      mList.onClick = function(_)  gm2d.Game.closePopup();
      setItemLayout(mList.getLayout().setMinWidth(inW).stretch());
      build();
   }

   public function getControlHeight() { return mList.getControlHeight(); }
   public function getControlWidth() { return mList.getControlWidth(); }
   override public function getWindowWidth()
   {
      if (mList.scrollRect!=null)
         return mList.scrollRect.width;
      return mLayout.getBestWidth();
   }
   override public function getWindowHeight()
   {
      if (mList.scrollRect!=null)
         return mList.scrollRect.height;
      return mLayout.getBestHeight();
   }

   override function windowMouseMove(inEvent:MouseEvent)
   {
      //if (selectOnMove)
      {
         closeLockout++;
         var pos = mList.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
         mList.selectByY(pos.y, selectOnMove ? 0 : ListControl.SELECT_NO_CALLBACK );
         closeLockout--;
      }
   }


/*
   override public function redraw()
   {
      var gfx = graphics;
      gfx.lineStyle(1,0x000000);
      gfx.beginFill(0xffffff);
      gfx.drawRect(-0.5,-0.5,mRect.width+2, mRect.height+2);

      mList.redraw();
   }
*/
   public function onSelect(idx:Int)
   {
      if (idx>=0)
         mCombo.onListSelect(idx);
      if (closeLockout==0)
         gm2d.Game.closePopup();
   }

   override public function destroy()
   {
      super.destroy();
   }
}



class ComboBox extends TextInput
{
   var mButtonX:Float;
   var mOptions:Array<String>;
   var mDisplay:Array<Dynamic>;
   static var mBMP:BitmapData;
   var onText:String->Void;
   var onItem:Int->Void;
   var onPopup:Void->Void;
   public var selectOnMove = true;

   public function new(inVal="", ?inOptions:Array<String>, ?inDisplay:Array<Dynamic>,
       ?inOnSelectIndex:Int->Void, ?inOnSelectString:String->Void, ?inLineage:Array<String>)
   {
       onItem = inOnSelectIndex;
       onText = inOnSelectString;

       //mRenderer.renderLabel(mText);
       //mText.text = inVal;
       //mText.x = 0.5;
       //mText.y = 0.5;
       //mText.height = 21;
       ////mText.autoSize = nme.text.TextFieldAutoSize.NONE;
       //mText.type = nme.text.TextFieldType.INPUT;
 
       if (mBMP==null)
       {
          mBMP = new BitmapData(22,22);
          var shape = new nme.display.Shape();
          var gfx = shape.graphics;
          gfx.beginFill(0xffffff);
          gfx.drawRect(-2,-2,28,28);

          gfx.beginFill(0xf0f0f0);
          gfx.lineStyle(1,0x808080);
          gfx.drawRoundRect(0.5,0.5,21,21,3);
          gfx.lineStyle();

          gfx.beginFill(0x000000);
          gfx.moveTo(8,8);
          gfx.lineTo(8,8);
          gfx.lineTo(16,8);
          gfx.lineTo(12,14);
          gfx.lineTo(8,8);
          mBMP.draw(shape);
       }

       super(inVal, inOnSelectString, Widget.addLine(inLineage,"ComboBox"));

       mOptions = inOptions==null ? null : inOptions.copy();
       mDisplay = inDisplay==null ? null : inDisplay.copy();
       //addChild(mText);
       addEventListener(MouseEvent.CLICK, onClick );
   }

   function onClick(event:MouseEvent)
   {
      // TODO - position
      if (event.target==this || event.target==mChrome)
          doPopup();
   }

   override public function createExtraWidgetLayout() : Layout
   {
      var bitmap = new Bitmap(mBMP);
      addChild(bitmap);
      return new DisplayLayout(bitmap);
   }

   public function setOptions(inOptions:Array<String>,?inDisplay:Array<Dynamic>)
   {
      mOptions = inOptions==null ? null : inOptions.copy();
      mDisplay = inDisplay==null ? null : inDisplay.copy();
   }


   public function onListSelect(inIndex:Int)
   {
      if (mOptions!=null)
      {
         setText(mOptions[inIndex]);
         if (onText!=null)
            onText( mOptions[inIndex]);
      }
      if (onItem!=null)
         onItem(inIndex);
   }

   function doPopup()
   {
      if (onPopup!=null)
         onPopup();
      var w = mRect.width;
      var pop = mDisplay != null ?
            new ComboList(this, w, mDisplay,selectOnMove) :
            new ComboList(this, w, mOptions,selectOnMove);

      var pos = this.localToGlobal( new nme.geom.Point(0,0) );
      var h = pop.getControlHeight();
      var w = pop.getControlWidth();
      var max = Std.int(stage.stageHeight/2);
      var below = Math.min(max,stage.stageHeight - (pos.y+22));
      var above = Math.min(max,pos.y);
      if (h+pos.y+22 < stage.stageHeight)
      {
         pop.getLayout().setRect(pop.x,pop.y,w,h);
         gm2d.Game.popup(pop,pos.x,pos.y+22);
      }
      else if (below>=above)
      {
         pop.getLayout().setRect(pop.x,pop.y,w,below);
         gm2d.Game.popup(pop,pos.x,pos.y+22);
      }
      else
      {
         pop.getLayout().setRect(pop.x,pop.y,w,above);
         gm2d.Game.popup(pop,pos.x,pos.y-above);
      }
   }


   public function setText(inText:String)
   {
       mText.text = inText;
   }

   /*
   public override function redraw()
   {
       var gfx = graphics;
       gfx.clear();
       gfx.lineStyle(1,0x808080);
       gfx.beginFill(0xf0f0ff);
       gfx.drawRect(0.5,0.5,mRect.width-1,23);
       gfx.lineStyle();
       var mtx = new nme.geom.Matrix();
       mtx.tx = mRect.width-mBMP.width-1;
       mtx.ty = 1;
       gfx.beginBitmapFill(mBMP,mtx);
       mButtonX = mRect.width-mBMP.width-1+0.5;
       gfx.drawRect(mButtonX,1.5,mBMP.width,mBMP.height);
       mText.width = mRect.width - mBMP.width - 2;
       mText.y =  (mBMP.height - 2 - mText.textHeight)/2;
       mText.height =  mBMP.height-mText.y;
   }
   */

}


