package gm2d.ui;

import nme.events.MouseEvent;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.text.TextField;
import nme.text.TextFormat;
import gm2d.ui.Layout;
import nme.filters.BitmapFilter;
import nme.filters.DropShadowFilter;
import gm2d.ui.HitBoxes;
import nme.geom.Rectangle;
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
   public var shouldConsumeEvent : MouseEvent -> Bool;


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
      layout.includeBorderOnLayout = true;

      mSize = layout.getBestSize();
      layout.setRect(0,0,mSize.x,mSize.y);

      // TODO - use hit boxes/MouseWatcher
      mChrome.addEventListener(nme.events.MouseEvent.MOUSE_DOWN, doDrag);

      if (gm2d.Lib.isOpenGL)
         cacheAsBitmap = true;
   }

   function doneDrag(_)
   {
      stopDrag();
      stage.removeEventListener(nme.events.MouseEvent.MOUSE_UP, doneDrag);
   }

   function doDrag(_)
   {
      startDrag();
      stage.addEventListener(nme.events.MouseEvent.MOUSE_UP, doneDrag);
   }

   public function goBack() { Game.closeDialog(); }

   function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      switch(inAction)
      {
         case BUTTON(_,id):
            if (id==MiniButton.CLOSE)
               goBack();
         default:
      }
   }

   public function center(inWidth:Float,inHeight:Float)
   {
      var p = (parent==null) ? this : parent;
      x = ( (inWidth - mSize.x)/2 )/p.scaleX;
      y = ( (inHeight - mSize.y)/2 )/p.scaleY;
   }

   public dynamic function onClose() { }
 }


