package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.Shape;
import gm2d.display.Sprite;
import gm2d.text.TextField;
import gm2d.text.TextFormat;
import gm2d.ui.Layout;


class Panel extends Widget
{
   var mGridLayout:GridLayout;
   var mItemLayout:Layout;
   var mButtonLayout:Layout;
   var mDebug:Shape;
   var mLayoutDirty:Bool;
   var mLabelLookup:Hash<TextField>;
   var mButtons:Array<Button>;
   var mTitle:String;
   var mPane:Pane;

   public function new(inTitle:String = "" )
   {
      super();

      mButtons = [];
      mLayoutDirty = true;
      mTitle = inTitle;

      mDebug = gm2d.Lib.debug ? new Shape() : null;
      mGridLayout = new GridLayout(1,"vertical");
      mGridLayout.setSpacing(0,20);
      mItemLayout = new GridLayout(2,"items");
      mButtonLayout = new GridLayout(null,"buttons");
      mButtonLayout.setSpacing(10,0);
      mGridLayout.add(mItemLayout);
      mGridLayout.add(mButtonLayout);
      mGridLayout.setRowStretch(1,0);
      if (mDebug!=null)
         addChild(mDebug);
   }

   public function getPane()
   {
      if (mPane==null)
      {
         var w = mGridLayout.getBestWidth();
         var h = mGridLayout.getBestHeight(w);
         mPane = new Pane(this, mTitle, 0);
         mPane.setMinSize(w,h);
         layout(w,h);
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
   */

   override public function layout(inX:Float,inY:Float)
   {
      mGridLayout.setRect(0,0,inX,inY);
      onLaidOut();
      Layout.setDebug(null);
   }

   public function setButtonBGs(inRenderer:gm2d.display.Graphics->Float->Float->Void, inExtraX=10.0, inExtraY=5.0)
   {
      var cols = mButtonLayout.getColWidths();
      var h = mButtonLayout.getBestHeight();
      var w = 0.0;
      for(c in cols)
         if (c>w) w=c;
      for(but in mButtons)
      {
          but.setBG(inRenderer,w+inExtraX,h+inExtraY);
      }
   }


   override public function createLayout() : Layout { return mGridLayout; }

   public dynamic function onLaidOut() { }


   /*
   public function getLayoutWidth()
   {
      if (mLayoutDirty) doLayout();
      return mGridLayout.width;
   }
   public function getLayoutHeight()
   {
      if (mLayoutDirty) doLayout();
      return mGridLayout.height;
   }
   */


   public function setBorders(inL:Float,inT:Float,inR:Float,inB:Float)
   {
      mGridLayout.setBorders(inL,inT,inR,inB);
   }

   public function addUI(inItem:gm2d.ui.Widget)
   {
      mLayoutDirty = true;
      addChild(inItem);
      mItemLayout.add( inItem.getLayout() );
   }
   public function addButton(inButton:gm2d.ui.Button)
   {
      mLayoutDirty = true;
      addChild(inButton);
      // inButton.setBG( Skin.current.renderButton, w+inExtraX,h+inExtraY);
      mButtons.push(inButton);
      mButtonLayout.add( inButton.getLayout() );
   }

   public function addObj(inObj:gm2d.display.DisplayObject)
   {
      mLayoutDirty = true;
      addChild(inObj);
      mItemLayout.add( new DisplayLayout(inObj) );
   }

   public function addLabelObj(inLabel:String,inObj:DisplayObject,?inName:String)
   {
      addLabel(inLabel,inName);
      addObj(inObj);
   }
 
   public function addLabel(inText:String,?inName:String)
   {
      mLayoutDirty = true;
      var label = new TextField();
      Skin.current.styleLabelText(label);
      label.text = inText;
      addChild(label);
      mItemLayout.add( new TextLayout(label) );

      if (inName!=null)
      {
          if (mLabelLookup!=null) mLabelLookup = new Hash<TextField>();
          mLabelLookup.set(inName,label);
      }
   }
   public function setLabel(inName:String,inValue:String)
   {
      mLabelLookup.get(inName).text = inValue;
   }



}
