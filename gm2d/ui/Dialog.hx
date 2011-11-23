package gm2d.ui;

import gm2d.events.MouseEvent;
import gm2d.display.DisplayObject;
import gm2d.display.Sprite;
import gm2d.text.TextField;
import gm2d.text.TextFormat;
import gm2d.ui.Layout;
import gm2d.svg.SVG2Gfx;
import gm2d.filters.BitmapFilter;
import gm2d.filters.DropShadowFilter;



class Dialog extends Window
{
   var mPanel:Panel;
   var mTitle:TextField;
   var mBG:Sprite;

   public var panel(getPanel,null):Panel;


   public function new(inTitle:String="",?inForceWidth:Null<Float>, ?inForceHeight:Null<Float>)
   {
      super();
      mBG = new Sprite();
      addChild(mBG);
      var title_gap = 0;
      if (inTitle!="")
      {
         mTitle = new TextField();
         mTitle.mouseEnabled = false;
         mTitle.defaultTextFormat = Panel.labelFormat;
         mTitle.textColor = 0x000000;
         mTitle.selectable = false;
         mTitle.text = inTitle;
         mTitle.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
         mTitle.y = 2;
         title_gap = 24;

         var f:Array<BitmapFilter> = [];
         f.push( new DropShadowFilter(2,45,0xffffff,1,0,0,1) );
         mTitle.filters = f;

         addChild(mTitle);
      }
      mPanel = new Panel(inForceWidth,inForceHeight);
      addChild(mPanel);
      mLayout = mPanel.getLayout().setBorders(10,10+title_gap,10,10);

      var f:Array<BitmapFilter> = [];
      f.push( new DropShadowFilter(5,45,0,0.5,3,3,1) );
      filters = f;

      mBG.addEventListener(gm2d.events.MouseEvent.MOUSE_DOWN, doDrag);
   }

   function doneDrag(_)
   {
      stopDrag();
      stage.removeEventListener(gm2d.events.MouseEvent.MOUSE_UP, doneDrag);
   }

   function doDrag(_)
   {
      startDrag();
      stage.addEventListener(gm2d.events.MouseEvent.MOUSE_UP, doneDrag);
   }

   public function goBack() { Game.closeDialog(); }

   public function getBackground() { return mBG.graphics; }
   public function getPanel() { return mPanel; }
   public dynamic function renderBackground(inW:Float,inH:Float)
   {
      var gfx = getBackground();
      Skin.current.renderDialog(gfx,inW,inH);
   }

   public function doLayout()
   {
      panel.doLayout();
      if (mTitle!=null)
        mTitle.x = (mLayout.width - mTitle.textWidth)/2 - 2;
      if (renderBackground!=null)
         renderBackground(mLayout.width,mLayout.height);
   }
   public function SetSVGBackground(inSVG:SVG2Gfx)
   {
      var gfx = getBackground();
      inSVG.Render(gfx,null,null);

      var all  = inSVG.GetExtent(null, null);
      var scale9 = inSVG.GetExtent(null, function(_,groups) { return groups[0]==".scale9"; } );
      if (scale9!=null)
         mBG.scale9Grid = scale9;
      var interior = inSVG.GetExtent(null, function(_,groups) { return groups[0]==".interior"; } );
      if (interior == null)
         interior = scale9;

      if (interior != null && false)
         mPanel.setBorders(interior.left,interior.top, all.right-interior.right,
                    all.bottom-interior.bottom);

      var bg = mBG;
      renderBackground = function(w,h) { bg.width = w; bg.height = h; }
      cacheAsBitmap = gm2d.Lib.isOpenGL;
   }
   public function center(inWidth:Float,inHeight:Float)
   {
      var p = (parent==null) ? this : parent;
      x = ( (inWidth - mPanel.getLayoutWidth())/2 )/p.scaleX;
      y = ( (inHeight - mPanel.getLayoutHeight())/2 )/p.scaleY;
   }

   public dynamic function onClose() { }
 }


