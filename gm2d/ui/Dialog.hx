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
import gm2d.skin.Renderer;


class Dialog extends Window
{
   var mPane:Pane;
   var mContent:Sprite;
   var mHitBoxes:HitBoxes;
   var mSize:Size;
   var mouseWatcher:MouseWatcher;
   public var shouldConsumeEvent : MouseEvent -> Bool;


   public function new(inPane:Pane, ?inAttribs:Dynamic)
   {
      super("Dialog", inAttribs);
      mPane = inPane;
      mContent = new Sprite();
      inPane.setDock(null,this);

      //var dbgObject = new nme.display.Shape();
      //addChild(dbgObject);
      //Layout.setDebug(dbgObject);

      mHitBoxes = new HitBoxes(this,onHitBox);

      mLayout = new StackLayout();
      mLayout.add(inPane.itemLayout);
      mLayout.includeBorderOnLayout = true;

      build();

      // TODO - use hit boxes/MouseWatcher
      mChrome.addEventListener(nme.events.MouseEvent.MOUSE_DOWN, doDrag);

      if (gm2d.Lib.isOpenGL)
         cacheAsBitmap = true;
   }

   override public function getHitBoxes() : HitBoxes { return mHitBoxes; }

   override public function getPane() : Pane { return mPane; }


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
      x = ( (inWidth - mRect.width)/2 )/p.scaleX;
      y = ( (inHeight - mRect.height)/2 )/p.scaleY;
   }

   public dynamic function onClose() { }
 }


