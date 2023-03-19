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
      super(inCombo.skin);
      selectOnMove = inSelectOnMove;
      mCombo = inCombo;
      mList = new ListControl(skin,["PopupComboBox"], { width:inW } );
      mList.variableHeightRows = true;
      mList.addItems(inOptions);
      addChild(mList);
      mList.scrollRect = null;
      mList.onSelectPhase = onSelectPhase;
      mList.onClick = function(e:MouseEvent) {
         windowMouseMove(e);
         gm2d.Game.closePopup();
      }
      setItemLayout(mList.getLayout().setMinWidth(inW).stretch());
      //build();
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
         var pos = mList.toLocal( inEvent.stageX, inEvent.stageY );
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
   public function onSelectPhase(idx:Int,phase:Int)
   {
      if (idx>=0)
         mCombo.onListSelect(idx,phase);
      if (closeLockout==0)
         gm2d.Game.closePopup();
   }
   public function onClosePopup()
   {
      if (closeLockout==0 && !mList.firstSelect)
      {
         var sel = mList.getSelected();
         if (sel>=0)
            mCombo.onListSelect(sel, Phase.END);
      }
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
   public var listOnly:Bool;
   public var onItemPhase:Int->Int->Void;
   public var lastExplicit:String;

   public function new(inVal="", ?inOptions:Array<String>, ?inDisplay:Array<Dynamic>,
       ?inOnSelectIndex:Int->Void, ?inOnSelectString:String->Void, ?inOnTextPhase:String->Int->Void, ?inLineage:Array<String>, ?inAttribs:{})
   {
       index = -1;
       onItem = inOnSelectIndex;
       onText = inOnSelectString;

       super(inVal, inOnSelectString, inOnTextPhase, Widget.addLine(inLineage,"ComboBox"), inAttribs);

       mBMP = getBitmap();

       listOnly = attribBool("listOnly",false);
       selectOnMove = attribBool("selectOnMove",true);

       mOptions = inOptions==null ? null : inOptions.copy();
       mDisplay = inDisplay==null ? null : inDisplay.copy();
       if (listOnly && mOptions==null)
          mOptions = [];
       //addChild(mText);
       addEventListener(MouseEvent.CLICK, onClick );
       updateIndex();
       if (listOnly && index<0)
          setText(inVal);
       lastExplicit = inVal;
   }

   override public function set(inValue:Dynamic) : Void
   {
      if (Std.isOfType(inValue,Int))
         setIndex(inValue);
      else
      {
         setText(inValue);
         lastExplicit = inValue;
      }
   }

   override public function get(inValue:Dynamic) : Void
   {
      if (Reflect.hasField(inValue,name))
      {
         if (Std.isOfType(Reflect.field(inValue,name),Int))
            Reflect.setField(inValue, name, index );
         else
            Reflect.setField(inValue, name, getText() );
      }
   }


   function onClick(event:MouseEvent)
   {
      // TODO - position
      if (event.target==this || event.target==mChrome || (listOnly && event.target==mText) )
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
      if (listOnly)
      {
         if (mOptions==null)
            mOptions = [];
         var idx = mOptions.indexOf(lastExplicit);
         if (idx>=0)
            setText(lastExplicit);
         else
            setText( getText() );
      }
   }

   override public function setList(id:String, values:Array<String>, display:Array<Dynamic>)
   {
      if (id==attribString("optionsId",name) )
         setOptions(values, display);
   }

   public function onListSelect(inIndex:Int,phase:Int)
   {
      index = inIndex;
      if (mOptions!=null)
      {
         setText(lastExplicit = mOptions[inIndex]);
         if (onText!=null)
            onText( mOptions[inIndex]);
         if (onTextPhase!=null)
            onTextPhase( mOptions[inIndex], phase);
         if (onTextEnter!=null)
            onTextEnter(mOptions[inIndex]);
      }
      if (onItem!=null)
         onItem(inIndex);
      if (onItemPhase!=null)
         onItemPhase(inIndex,phase);
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
      var offset = skin.scale(22);
      var max = Std.int(stage.stageHeight/2);
      var below = Math.min(max,stage.stageHeight - (pos.y+offset));
      var above = Math.min(max,pos.y);

      if (h+pos.y+offset < stage.stageHeight)
      {
         pop.getLayout().setRect(0,0,w,h);
         gm2d.Game.popup(pop,pos.x,pos.y+offset, pop.onClosePopup);
      }
      else if (above>h)
      {
         pop.getLayout().setRect(0,0,w,h);
         gm2d.Game.popup(pop,pos.x,pos.y-h, pop.onClosePopup);
      }
      else
      {
         pop.getLayout().setRect(0,0,w,above);
         gm2d.Game.popup(pop,pos.x,pos.y-above, pop.onClosePopup);
      }
   }

   public function setIndex(inIndex:Int) : Void
   {
      index = inIndex;
      mText.text = mOptions[index];
   }


   override public function setText(inText:String)
   {
      if (listOnly)
      {
         if (mOptions!=null)
         {
            var index = mOptions.indexOf(inText);
            if (index<0)
               index = mOptions.indexOf(lastExplicit);
            else
            {
               lastExplicit = inText;
            }

            if (index<0)
               index = 0;

            if (mOptions.length>0)
            {
               mText.text = mOptions[index];
               checkPlaceholder();
            }
         }
      }
      else
      {
         mText.text = inText;
         updateIndex();
      }
   }

   function updateIndex()
   {
      if (mOptions==null)
         index = -1;
      else if (index<0 || mText.text != mOptions[index])
         index = mOptions.indexOf(mText.text);
   }

}


