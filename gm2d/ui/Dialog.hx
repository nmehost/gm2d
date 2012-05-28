package gm2d.ui;

import gm2d.events.MouseEvent;
import gm2d.display.DisplayObject;
import gm2d.display.Sprite;
import gm2d.text.TextField;
import gm2d.text.TextFormat;
import gm2d.ui.Layout;
import gm2d.filters.BitmapFilter;
import gm2d.filters.DropShadowFilter;
import gm2d.ui.HitBoxes;
import gm2d.geom.Rectangle;
import gm2d.skin.Skin;
import gm2d.skin.FrameRenderer;


class Dialog extends Window
{
   var mPane:Pane;
   var mChrome:Sprite;
   var mContent:Sprite;
   var mHitBoxes:HitBoxes;
   var mSize:Size;
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

      renderer = inRenderer==null ? Skin.current.dialogRenderer : inRenderer;

      var layout = renderer.createLayout(inPane.itemLayout);
      layout.onLayout = function(inX:Float, inY:Float, inW:Float, inH:Float)
      {
         renderer.render(mChrome,mPane,new Rectangle(inX,inY,inW,inH),mHitBoxes);
      }

      mSize = layout.getBestSize();
      layout.setRect(0,0,mSize.x,mSize.y);

      // TODO - use hit boxes/MouseWatcher
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

   public function center(inWidth:Float,inHeight:Float)
   {
      var p = (parent==null) ? this : parent;
      x = ( (inWidth - mSize.x)/2 )/p.scaleX;
      y = ( (inHeight - mSize.y)/2 )/p.scaleY;
   }

   public dynamic function onClose() { }
 }


