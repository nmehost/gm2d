package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.Shape;
import gm2d.display.Sprite;
import gm2d.text.TextField;
import gm2d.text.TextFormat;
import gm2d.ui.Layout;


class Panel extends Widget
{
   var mLayout:GridLayout;
   var mItemLayout:Layout;
   var mButtonLayout:Layout;
   var mDebug:Shape;
   var mForceWidth:Null<Float>;
   var mForceHeight:Null<Float>;
   var mLayoutDirty:Bool;
   var mLabelLookup:Hash<TextField>;
   var mButtons:Array<Button>;

   public static var labelColor = 0x000000;
   public static var labelFormat = DefaultTextFormat();
   public static var panelColor = 0xe0e0d0;
   public static var buttonColor = 0xf0f0f0;

   public function new(?inForceWidth:Null<Float>, ?inForceHeight:Null<Float>)
   {
      super();

      mForceWidth = inForceWidth;
      mForceHeight = inForceHeight;
      mButtons = [];
      mLayoutDirty = true;


      mDebug = gm2d.Lib.debug ? new Shape() : null;
      mLayout = new GridLayout(1,"vertical").setColFlags(0,Layout.AlignCenterX);
      mLayout.setSpacing(0,20);
      mItemLayout = new GridLayout(2,"items");
      mButtonLayout = new GridLayout(null,"buttons");
      mButtonLayout.setSpacing(10,0);
      mLayout.add(mItemLayout);
      mLayout.add(mButtonLayout);
      mLayout.setRowStretch(1,0);
      if (mDebug!=null)
         addChild(mDebug);

   }

   public function doLayout()
   {
      mLayoutDirty = false;
      if (mDebug!=null)
         Layout.SetDebug(mDebug.graphics);
      //trace("DoLayout:" + mForceWidth + "," + mForceHeight);
      mLayout.calcSize(mForceWidth,mForceHeight);
      mLayout.setRect(0,0,mLayout.width,mLayout.height);
      onLaidOut();
      Layout.SetDebug(null);
   }
   override public function layout(inX:Float,inY:Float)
   {
      mLayout.setRect(0,0,inX,inY);
      onLaidOut();
      Layout.SetDebug(null);
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


   public function getLayout() { return mLayout; }

   public dynamic function onLaidOut() { }


   public function getLayoutWidth()
   {
      if (mLayoutDirty) doLayout();
      return mLayout.width;
   }
   public function getLayoutHeight()
   {
      if (mLayoutDirty) doLayout();
      return mLayout.height;
   }


   public function setBorders(inL:Float,inT:Float,inR:Float,inB:Float)
   {
      mLayout.setBorders(inL,inT,inR,inB);
   }

   public function addUI(inItem:gm2d.ui.Widget)
   {
      mLayoutDirty = true;
      addChild(inItem);
      mItemLayout.add( new DisplayLayout(inItem) );
   }
   public function addButton(inButton:gm2d.ui.Button)
   {
      mLayoutDirty = true;
      addChild(inButton);
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
      label.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
      label.defaultTextFormat = labelFormat;
      label.text = inText;
      label.setTextFormat(labelFormat);
      label.textColor = labelColor;
      label.selectable = false;
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

   static function DefaultTextFormat()
   {
      var fmt = new gm2d.text.TextFormat();
      fmt.size = 16;
      fmt.font = "Arial";
      return fmt;
   }




}
