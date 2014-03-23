package gm2d.ui2;

import nme.display.DisplayObject;
import nme.display.Shape;
import nme.display.Sprite;
import nme.text.TextField;
import nme.text.TextFormat;
import gm2d.ui2.Layout;
import gm2d.ui2.SkinItem;

class Panel extends Widget
{
   var mGridLayout:GridLayout;
   var mItemLayout:GridLayout;
   var mButtonLayout:Layout;
   var mDebug:Shape;
   var mLayoutDirty:Bool;
   var mLabelLookup:Map<String,TextField>;
   var mButtons:Array<Button>;
   var mTitle:String;
   var mPane:Pane;

   public function new(inTitle:String = "")
   {
      mButtons = [];
      mLayoutDirty = true;
      mTitle = inTitle;

      mDebug = gm2d.Lib.debug ? new Shape() : null;
      mGridLayout = new GridLayout(1,"vertical");
      mGridLayout.setSpacing(0,20);
      mItemLayout = new GridLayout(2,"items");
      mButtonLayout = new GridLayout(null,"buttons");
      mButtonLayout.setSpacing(10,0);
      mButtonLayout.setBorders(0,10,0,10);
      mGridLayout.add(mItemLayout);
      mGridLayout.setRowStretch(1,0);

      super( {title:inTitle, item:ITEM_LAYOUT(mGridLayout) } );

      if (mDebug!=null)
         addChild(mDebug);
   }

   override public function getClass() { return "Panel"; }

   public function setItemSize(inSize:Int)
   {
       mItemLayout.setMinColWidth(1,inSize);
   }

   public function setStretchX(inItemStretch:Int=33)
   {
      mGridLayout.mAlign =  Layout.AlignTop;
      mGridLayout.setColStretch(0,1);
      mItemLayout.mAlign =  Layout.AlignTop;
      mItemLayout.setColStretch(0,inItemStretch);
      mItemLayout.setColStretch(1,100);
      return this;
   }

   public function getPane()
   {
      if (mPane==null)
      {
         var w = mGridLayout.getBestWidth();
         var h = mGridLayout.getBestHeight(w);
         mPane = new Pane(this, mTitle, 0);
         mPane.setMinSize(w,h);
         mPane.itemLayout = mGridLayout;
         mPane.setFlags( mPane.getFlags() | Dock.RESIZABLE );
      }
      return mPane;
   }

   /*
   public function doLayout()
   {
      mLayoutDirty = false;
      if (mDebug!=null)
      {
         removeChild(mDebug);
         addChild(mDebug);
         Layout.setDebug(mDebug);
      }
      //trace("DoLayout:" + mForceWidth + "," + mForceHeight);
      mGridLayout.calcSize(mForceWidth,mForceHeight);
      mGridLayout.setRect(0,0,mGridLayout.width,mGridLayout.height);
      onLaidOut();
      Layout.setDebug(null);
   }

   override public function layout(inX:Float,inY:Float)
   {
      mGridLayout.setRect(0,0,inX,inY);
      onLaidOut();
      Layout.setDebug(null);
   }
   */

   public dynamic function onLaidOut() { }

   public function setBorders(inL:Float,inT:Float,inR:Float,inB:Float)
   {
      mGridLayout.setBorders(inL,inT,inR,inB);
   }

   public function addUI(inItem:gm2d.ui2.Widget)
   {
      mLayoutDirty = true;
      addChild(inItem);
      mItemLayout.add( inItem.widgetLayout );
   }
   public function addButton(inButton:gm2d.ui2.Button)
   {
      if (mButtons.length==0)
         mGridLayout.add(mButtonLayout);

      mLayoutDirty = true;
      addChild(inButton);
      // inButton.setBG( Skin.current.renderButton, w+inExtraX,h+inExtraY);
      mButtons.push(inButton);
      mButtonLayout.add( inButton.widgetLayout );
   }

   public function addTextButton(inText:String, inOnClick:Void->Void)
   {
      var button = Button.TextButton(inText,inOnClick);
      addButton(button);
      return this;
   }


   public function addObj(inObj:nme.display.DisplayObject,?inAlign:Null<Int>)
   {
      mLayoutDirty = true;
      addChild(inObj);
      var layout = new DisplayLayout(inObj);
      if (inAlign!=null)
         layout.mAlign = inAlign;
      else
         layout.mAlign = Layout.AlignStretch;
      mItemLayout.add( layout );
   }

   public function addLabelObj(inLabel:String,inObj:DisplayObject,?inName:String,?inAlign:Null<Int>)
   {
      addLabel(inLabel,inName,inAlign);
      addObj(inObj,inAlign);
   }

   
   public function addLabelUI(inLabel:String,inObj:Widget,?inAlign:Null<Int>)
   {
      addLabel(inLabel,null,inAlign);
      addUI(inObj);
   }
 
   public function addLabel(inText:String,?inName:String,?inAlign:Null<Int>)
   {
      if (inText==null)
      {
         mItemLayout.add(null);
         return;
      }
      mLayoutDirty = true;
      var label = new TextField();
      label.text = inText;
      addChild(label);
      var layout = new TextLayout(label);
      if (inAlign!=null)
         layout.mAlign = inAlign;
      else
         layout.mAlign = Layout.AlignRight | Layout.AlignCenterY;
      mItemLayout.add( layout );

      if (inName!=null)
      {
          if (mLabelLookup!=null) mLabelLookup = new Map<String,TextField>();
          mLabelLookup.set(inName,label);
      }
   }
   public function setLabel(inName:String,inValue:String)
   {
      mLabelLookup.get(inName).text = inValue;
   }



}
