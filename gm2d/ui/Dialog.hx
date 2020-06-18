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


class Dialog extends Window implements IDialog
{
   var mPane:Pane;
   var mSize:Size;
   var mouseWatcher:MouseWatcher;
   var dragStage:nme.display.Stage;
   public var shouldConsumeEvent : MouseEvent -> Bool;


   public function new(inPane:Pane, ?inAttribs:Dynamic, ?inLineage:Array<String>)
   {
      super(Widget.addLines(inLineage,["Dialog","Frame"]), inAttribs);

      mPane = inPane;

      var vlayout = new VerticalLayout([0,1]);

      var title = new TextLabel(inPane.title, ["DialogTitle"]);
      name = "Dialog(" + inPane.title + ")";
      addChild(title);
      vlayout.add(title.getLayout().stretch());

      inPane.setDock(null,this);
      vlayout.add(inPane.itemLayout.stretch());
      setItemLayout(vlayout.stretch());
 
      build();

      title.addEventListener(nme.events.MouseEvent.MOUSE_DOWN, doDrag);
      mChrome.addEventListener(nme.events.MouseEvent.MOUSE_DOWN, doDrag);

      //if (gm2d.Lib.isOpenGL)
      //   cacheAsBitmap = true;
   }

   public function asDialog():Dialog return this;
   public function closeFrame():Void
   {
      onClose();
      if (parent!=null)
         parent.removeChild(this);
   }

   public function close()
   {
      if (gm2d.Game.mCurrentDialog==this)
         gm2d.Game.closeDialog();
   }

   public function setDefaultFocus()
   {
      var w = mPane!=null && mPane.getDefaultWidget!=null ? mPane.getDefaultWidget() : null;
      if (w!=null)
         setCurrentItem(w);
   }

   public static function showMessage(title:String, message:String)
   {
      var panel = new Panel(title);
      panel.addLabel(message);
      panel.addTextButton("Ok", Game.closeDialog );
      new Dialog(panel.getPane()).show();
   }


   public function show(inCentre = true, inAutoClose=true)
   {
      gm2d.Game.doShowDialog(this, inCentre,inAutoClose);
   }

   override public function onChromeMouse(inId:String,inEvent:MouseEvent) : Bool
   {
      if (inId==Skin.Resize)
      {
         return false;
      }
      if (inEvent.type == MouseEvent.CLICK)
      {
         if (inId==Skin.Close)
            goBack();
         else
            trace(inId);
      }
      return true;
   }

   override public function getPane() : Pane { return mPane; }


   function doneDrag(_)
   {
      stopDrag();
      dragStage.removeEventListener(nme.events.MouseEvent.MOUSE_UP, doneDrag);
   }

   function doDrag(me:MouseEvent)
   {
      if ( (mPane.getFlags() & Dock.RESIZABLE) !=0)
      {
      }
      startDrag();
      dragStage = stage;
      dragStage.addEventListener(nme.events.MouseEvent.MOUSE_UP, doneDrag);
   }

   public function goBack()
   {
      onClose();
      if (Game.mCurrentDialog==this)
         Game.closeDialog();
      else if (Game.mCurrentPopup==this)
         Game.closePopup();
   }

   public function center(inWidth:Float,inHeight:Float)
   {
      var p = (parent==null) ? this : parent;
      x = Std.int( (inWidth - mRect.width)/2 )/p.scaleX;
      y = Std.int( (inHeight - mRect.height)/2 )/p.scaleY;
   }

   public dynamic function onClose() { }
 }


