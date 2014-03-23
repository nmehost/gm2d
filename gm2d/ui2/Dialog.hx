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
import gm2d.ui.SkinItem;


class Dialog extends Window
{
   var mPane:Pane;
   var mContent:Sprite;
   var mHitBoxes:HitBoxes;
   var mSize:Size;
   var mouseWatcher:MouseWatcher;
   var frame:Widget;
   public var shouldConsumeEvent : MouseEvent -> Bool;


   public function new(inPanel:Panel)
   {
      super();
      frame = new Widget( { item:ITEM_LAYOUT(inPanel.widgetLayout), className:"Frame" } );
      addChild(frame);
      mPane = inPanel.getPane();
      mPane.setDock(null,this);
      //addChild(inPane.displayObject);
      mHitBoxes = new HitBoxes(this,onHitBox);

      /*
      var layout = renderer.createLayout(inPane.itemLayout);
      layout.onLayout = function(inX:Float, inY:Float, inW:Float, inH:Float)
      {
         renderer.render(mChrome,mPane,new Rectangle(inX,inY,inW,inH),mHitBoxes);
      }
      */
      frame.widgetLayout.includeBorderOnLayout = true;

      mSize = frame.widgetLayout.getBestSize();
      trace("getBestSize :" + mSize);
      frame.widgetLayout.setRect(0,0,mSize.x,mSize.y);

      // TODO - use hit boxes/MouseWatcher
      frame.addEventListener(nme.events.MouseEvent.MOUSE_DOWN, doDrag);

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
      trace(mSize);
      x = ( (inWidth - mSize.x)/2 )/p.scaleX;
      y = ( (inHeight - mSize.y)/2 )/p.scaleY;
   }

   public dynamic function onClose() { }
 }


