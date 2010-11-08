package gm2d.ui;

import gm2d.events.MouseEvent;
import gm2d.display.DisplayObject;
import gm2d.display.Shape;
import gm2d.text.TextField;
import gm2d.text.TextFormat;
import gm2d.ui.Layout;
import gm2d.svg.SVG2Gfx;


class Dialog extends Window
{
   var mPanel:Panel;
   var mLayout:Layout;
   var mBG:Shape;

   public var panel(getPanel,null):Panel;


   public function new(?inForceWidth:Null<Float>, ?inForceHeight:Null<Float>)
   {
      super();
      mBG = new Shape();
      addChild(mBG);
      mPanel = new Panel(inForceWidth,inForceHeight);
      addChild(mPanel);
      mLayout = mPanel.getLayout();
     }

   public function getBackground() { return mBG.graphics; }
   public function getPanel() { return mPanel; }
   public dynamic function renderBackground(inW:Float,inH:Float)
   {
      //trace("renderBackground " + inW + "," + inH);
      var gfx = getBackground();
      gfx.beginFill(0xffffff);
      gfx.lineStyle(2,0x000000);
      gfx.drawRoundRect(0,0,inW,inH,10,10);
   }
   public function doLayout()
   {
      panel.doLayout();
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


