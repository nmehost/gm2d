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
   public var index(default,null):Int;
   public var onPopup:ComboBox->Void;
   public var selectOnMove = true;
   public var indexHandler(default,set):AdoHandler<Int>;

   public function new(inVal="", ?inOptions:Array<String>, ?inDisplay:Array<Dynamic>,
       ?inOnSelectIndex:Int->Void, ?inOnSelectString:String->Void, ?inLineage:Array<String>, ?inAttribs:{})
   {
       index = -1;
       onItem = inOnSelectIndex;
       onText = inOnSelectString;

       if (mBMP==null)
       {
          mBMP = new BitmapData(Skin.scale(22),Skin.scale(22));
          var shape = new nme.display.Shape();
          var gfx = shape.graphics;
          gfx.beginFill(0xffffff);
          gfx.drawRect(Skin.scale(-2),Skin.scale(-2),Skin.scale(28),Skin.scale(28));

          gfx.beginFill(0xf0f0f0);
          gfx.lineStyle(1,0x808080);
          gfx.drawRoundRect(0.5,0.5,Skin.scale(22)-1,Skin.scale(22)-1,3);
          gfx.lineStyle();

          gfx.beginFill(0x000000);
          gfx.moveTo(Skin.scale(8),Skin.scale(8));
          gfx.lineTo(Skin.scale(8),Skin.scale(8));
          gfx.lineTo(Skin.scale(16),Skin.scale(8));
          gfx.lineTo(Skin.scale(12),Skin.scale(14));
          gfx.lineTo(Skin.scale(8),Skin.scale(8));
          mBMP.draw(shape);
       }

       super(inVal, inOnSelectString, Widget.addLine(inLineage,"ComboBox"), inAttribs);

       selectOnMove = attribBool("selectOnMove",true);

       mOptions = inOptions==null ? null : inOptions.copy();
       mDisplay = inDisplay==null ? null : inDisplay.copy();
       //addChild(mText);
       addEventListener(MouseEvent.CLICK, onClick );
       updateIndex();
   }

   function onClick(event:MouseEvent)
   {
      // TODO - position
      if (event.target==this || event.target==mChrome)
          doPopup();
   }

   public function set_indexHandler(inHandler:AdoHandler<Int>)
   {
      indexHandler = inHandler;
      onItem = function(value:Int) indexHandler.onValue(value,Phase.ALL);
      indexHandler.updateGui = setIndex;
      return indexHandler;
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
      index = inIndex;
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
         onPopup(this);
      var w = mRect.width;
      var pop = mDisplay != null ?
            new ComboList(this, w, mDisplay,selectOnMove) :
            new ComboList(this, w, mOptions,selectOnMove);

      var pos = this.localToGlobal( new nme.geom.Point(0,0) );
      var h = pop.getControlHeight();
      var w = pop.getControlWidth();
      var offset = Skin.scale(22);
      var max = Std.int(stage.stageHeight/2);
      var below = Math.min(max,stage.stageHeight - (pos.y+offset));
      var above = Math.min(max,pos.y);
      if (h+pos.y+22 < stage.stageHeight)
      {
         pop.getLayout().setRect(pop.x,pop.y,w,h);
         gm2d.Game.popup(pop,pos.x,pos.y+offset);
      }
      else if (below>=above)
      {
         pop.getLayout().setRect(pop.x,pop.y,w,below);
         gm2d.Game.popup(pop,pos.x,pos.y+offset);
      }
      else
      {
         pop.getLayout().setRect(pop.x,pop.y,w,above);
         gm2d.Game.popup(pop,pos.x,pos.y-above);
      }
   }

   public function setIndex(inIndex:Int) : Void
   {
      index = inIndex;
      mText.text = mOptions[index];
   }


   override public function setText(inText:String)
   {
       mText.text = inText;
       updateIndex();
   }

   function updateIndex()
   {
      if (mOptions==null)
         index = -1;
      else if (index<0 || mText.text != mOptions[index])
         index = mOptions.indexOf(mText.text);
   }

}


