package gm2d.ui;

import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFormat;
import gm2d.ui.ItemList;
import gm2d.ui.Layout;
import gm2d.svg.SVG2Gfx;


class Dialog extends flash.display.Sprite
{
   var mItems:ItemList;
   var mLayout:GridLayout;
   var mItemLayout:Layout;
   var mButtonLayout:Layout;
   var mBG:Shape;
   var mDebug:Shape;
   var mForceWidth:Null<Float>;
   var mForceHeight:Null<Float>;
   var mLayoutDirty:Bool;

   public static var labelColor = 0x000000;
   public static var labelFormat = new TextFormat();

   public function new(?inForceWidth:Null<Float>, ?inForceHeight:Null<Float>)
   {
      super();
      mItems = new ItemList(this);
      mBG = new Shape();
      mDebug = neash.Lib.debug ? new Shape() : null;
      mLayout = new GridLayout(1,"vertical").setColFlags(0,Layout.AlignCenterX);
      mItemLayout = new GridLayout(2,"items");
      mButtonLayout = new GridLayout(null,"buttons");
      mLayout.add(mItemLayout);
      mLayout.add(mButtonLayout);
      mLayout.setRowStretch(1,0);
      addChild(mBG);
      if (mDebug!=null)
         addChild(mDebug);
      mForceWidth = inForceWidth;
      mForceHeight = inForceHeight;
      mLayoutDirty = true;
   }

   public function setBorders(inL:Float,inT:Float,inR:Float,inB:Float)
   {
      mLayout.setBorders(inL,inT,inR,inB);
   }
   public function getBackground() { return mBG.graphics; }
   public function DoLayout()
   {
      mLayoutDirty = false;
      if (mDebug!=null)
         Layout.SetDebug(mDebug.graphics);
      //trace("DoLayout:" + mForceWidth + "," + mForceHeight);
      mLayout.calcSize(mForceWidth,mForceHeight);
      //trace("Done:" + mLayout.width + "," + mLayout.height);
      mLayout.setRect(0,0,mLayout.width,mLayout.height);
      onLaidOut();
      if (renderBackground!=null)
         renderBackground(mLayout.width,mLayout.height);

      Layout.SetDebug(null);
   }
   public dynamic function renderBackground(inW:Float,inH:Float)
   {
      var gfx = getBackground();
      gfx.beginFill(0xffffff);
      gfx.lineStyle(2,0x000000);
      gfx.drawRoundRect(0,0,inW,inH,10,10);
   }
   public function SetSVGBackground(inSVG:SVG2Gfx)
   {
      inSVG.Render(getBackground(),null,null);
      var all  = inSVG.GetExtent(null, null);
      var scale9 = inSVG.GetExtent(null, function(_,groups) { return groups[0]==".scale9"; } );
      if (scale9!=null)
         mBG.scale9Grid = scale9;
      var interior = inSVG.GetExtent(null, function(_,groups) { return groups[0]==".interior"; } );
      if (interior == null)
         interior = scale9;

      if (interior != null)
         setBorders(interior.left,interior.top, all.right-interior.right,
                    all.bottom-interior.bottom);

      var bg = mBG;
      renderBackground = function(w,h) { bg.width = w; bg.height = h; }
      #if !flash
      mBG.cacheAsBitmap = neash.Lib.IsOpenGL();
      #end
   }
   public function getLayoutWidth()
   {
      if (mLayoutDirty) DoLayout();
      return mLayout.width;
   }
   public function getLayoutHeight()
   {
      if (mLayoutDirty) DoLayout();
      return mLayout.height;
   }
   public function center(inWidth:Float,inHeight:Float)
   {
      x = (inWidth - getLayoutWidth())/2;
      y = (inHeight - getLayoutHeight())/2;
   }

   public dynamic function onLaidOut() { }
   public dynamic function onAdded() { }
   public dynamic function onClose() { }

   public function OnKeyDown(event:flash.events.KeyboardEvent ) : Bool
      { return mItems.OnKeyDown(event); }


   public function setCurrent(inItem:gm2d.ui.Base) { mItems.setCurrent(inItem); }

   public function addUI(inItem:gm2d.ui.Base)
   {
      mLayoutDirty = true;
      mItems.addUI(inItem);
      mItemLayout.add( new DisplayLayout(inItem) );
   }
   public function addButton(inButton:gm2d.ui.Button)
   {
      mLayoutDirty = true;
      mItems.addUI(inButton);
      mButtonLayout.add( inButton.getLayout() );
   }

   public function addObj(inObj:flash.display.DisplayObject)
   {
      mLayoutDirty = true;
      addChild(inObj);
      mItemLayout.add( new DisplayLayout(inObj) );
   }
   public function addLabel(inText:String)
   {
      mLayoutDirty = true;
      var label = new TextField();
      label.text = inText;
      label.setTextFormat( labelFormat );
      label.textColor = labelColor;
      label.autoSize = flash.text.TextFieldAutoSize.LEFT;
      addChild(label);
      mItemLayout.add( new TextLayout(label) );
   }
}


