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
import gm2d.ui.HitBoxes;
import gm2d.geom.Rectangle;
import gm2d.ui.Skin;



class Dialog extends Window
{
   var mPane:Pane;
   var mChrome:Sprite;
   var mContent:Sprite;
   var mHitBoxes:HitBoxes;
   var mClientRect:Rectangle;
   var mouseWatcher:MouseWatcher;
   var renderer:FrameRenderer;




   public function new(inPane:Pane, ?inRenderer:FrameRenderer)
   {
      super();
      mPane = inPane;
      mChrome = new Sprite();
      mContent = new Sprite();
      addChild(mChrome);
      inPane.setDock(null,this);
      //addChild(inPane.displayObject);
      mHitBoxes = new HitBoxes(this,onHitBox);
      var size = inPane.getBestSize(Dock.DOCK_SLOT_FLOAT);
      mClientRect = new Rectangle(0,0,size.x,size.y);

      renderer = inRenderer==null ? Skin.current.getDialogRenderer() : inRenderer;
      renderer.getRect(mClientRect);

      var layout = inPane.setRect(mClientRect.x,mClientRect.y,mClientRect.width,mClientRect.height);

      renderer.render(mChrome,mPane,mClientRect,mHitBoxes);

      var title_gap = 0;
      //mLayout = mPanel.getLayout().setBorders(10,10+title_gap,10,10);

      var f:Array<BitmapFilter> = [];
      f.push( new DropShadowFilter(5,45,0,0.5,3,3,1) );
      filters = f;

      // TODO - use hit boxes
      mChrome.addEventListener(gm2d.events.MouseEvent.MOUSE_DOWN, doDrag);
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

   function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      /*
      switch(inAction)
      {
         case DRAG(pane):
            doStartDrag(inEvent);
         case BUTTON(_,id):
            if (id==MiniButton.CLOSE)
               pane.closeRequest(false);
            redraw();
         case REDRAW:
            redraw();
         default:
      }
      */
   }

/*
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
      var scale9 = inSVG.GetExtent(null, function(_,groups) { return groups[1]==".scale9"; } );
      if (scale9!=null)
         mBG.scale9Grid = scale9;
      var interior = inSVG.GetExtent(null, function(_,groups) { return groups[1]==".interior"; } );
      if (interior == null)
         interior = scale9;

      if (interior != null && false)
         mPanel.setBorders(interior.left,interior.top, all.right-interior.right,
                    all.bottom-interior.bottom);

      var bg = mBG;
      renderBackground = function(w,h) { bg.width = w; bg.height = h; }
      cacheAsBitmap = gm2d.Lib.isOpenGL;
   }
   */
   public function center(inWidth:Float,inHeight:Float)
   {
      var p = (parent==null) ? this : parent;
      x = ( (inWidth - mClientRect.width)/2 )/p.scaleX;
      y = ( (inHeight - mClientRect.height)/2 )/p.scaleY;
   }

   public dynamic function onClose() { }
 }


