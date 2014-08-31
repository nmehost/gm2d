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
   var mHitBoxes:HitBoxes;
   var mSize:Size;
   var mouseWatcher:MouseWatcher;
   public var shouldConsumeEvent : MouseEvent -> Bool;


   public function new(inPane:Pane, ?inAttribs:Dynamic, ?inLineage:Array<String>)
   {
      super(Widget.addLines(inLineage,["Dialog","Frame"]), inAttribs);

      mPane = inPane;

      mHitBoxes = new HitBoxes(this,onHitBox);

      var vlayout = new VerticalLayout([0,1]);

      var title = new TextLabel(inPane.title, ["DialogTitle"]);
      addChild(title);
      vlayout.add(title.getLayout());

      inPane.setDock(null,this);
      vlayout.add(inPane.itemLayout);
      setItemLayout(vlayout);
 

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
      x = Std.int( (inWidth - mRect.width)/2 )/p.scaleX;
      y = Std.int( (inHeight - mRect.height)/2 )/p.scaleY;
   }

   public dynamic function onClose() { }
 }


