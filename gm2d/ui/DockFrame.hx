package gm2d.ui;

import nme.geom.Rectangle;
import nme.display.Sprite;
import nme.geom.Point;
import nme.events.MouseEvent;
import gm2d.ui.HitBoxes;
import gm2d.ui.Dock;
import gm2d.ui.DockPosition;
import gm2d.ui.IDockable;
import gm2d.skin.Skin;
import gm2d.ui.Layout;


// --- DockFrame ----------------------------------------------------------------------

typedef DockCallbacks =  {
    ?onPaneMaximize:Void->Void,
    ?onPaneMinimize:Void->Void,
    ?onTitleDrag:IDockable->MouseEvent->Void,
}

class DockFrame extends Widget
{
   public var pane(default,null) : IDockable;

   var title:TitleBar;
   var mClientWidth:Int;
   var mClientHeight:Int;
   var mClientOffset:Point;
   var mDragStage:nme.display.Stage;
   var mResizeHandle:Sprite;
   var mSizeX0:Int;
   var mSizeY0:Int;

   public function new(?inSkin:Skin,inPane:IDockable, parentDock:IDock, callbacks:DockCallbacks, ?inAttribs:{ })
   {
      var skin = Skin.getSkin(inSkin);
      var p = inPane.asPane();
      if (p!=null)
      {
         if (inAttribs==null)
            inAttribs = p.frameAttribs;
         else if (p.frameAttribs!=null)
            inAttribs = skin.mergeAttribs(p.frameAttribs,inAttribs);
      }
      super(skin,["DocumentFrame","Dock"],inAttribs);

      this.name = "DockFrame";

      pane = inPane;

      name = pane.getTitle();

      var vlayout = new VerticalLayout([0,1]);

      var chromeButtons:Array<{}> = [
          { id:Skin.Close, onClick:function() pane.closeRequest(false) },
      ];
      if (callbacks!=null && callbacks.onPaneMaximize!=null )
         chromeButtons.push({ id:Skin.Maximize, onClick:callbacks.onPaneMaximize });
      if (callbacks!=null && callbacks.onPaneMinimize!=null )
         chromeButtons.push({ id:Skin.Maximize, onClick:callbacks.onPaneMinimize });

      title = new TitleBar(name,  { chromeButtons: chromeButtons } );
      addChild(title);
      vlayout.add(title.getLayout().stretch());

      inPane.setDock(parentDock,this);
      vlayout.add(inPane.getLayout().stretch());
      setItemLayout(vlayout.stretch());
 
      build();

      var asPane = pane.asPane();
      //if (asPane!=null && asPane.clipped && asPane.displayObject!=null)
      //   getLayout().onLayout = function(_,_,_,_) clipPane(asPane);


      if (callbacks.onTitleDrag!=null)
      {
         var cb = callbacks.onTitleDrag;
         title.addEventListener(nme.events.MouseEvent.MOUSE_DOWN, function(e) cb(inPane,e) );
      }
      else
      {
         title.addEventListener(nme.events.MouseEvent.MOUSE_DOWN, doDrag );
      }
      //mChrome.addEventListener(nme.events.MouseEvent.MOUSE_DOWN, doDrag);

      //pane.setRect(mClientOffset.x, mClientOffset.y, mClientWidth, mClientHeight);
      //redraw();
   }

   function clipPane(p:Pane)
   {
      var r = p.getLayout().getRect();
      trace(r);
      trace(p.displayObject);
      trace(p.displayObject.x + "," + p.displayObject.y);
      p.displayObject.scrollRect = new Rectangle(0,0,r.width,r.height);
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

   public function checkDirty()
   {
      if (name!=pane.getTitle())
      {
         name = pane.getTitle();
         //redraw();
      }
   }

   public function loadLayout(inProperties:Dynamic)
   {
   }

   /*
   public function setClientSize(inW:Int, inH:Int)
   {
      trace("############### setClientSize -> " + inW + " " + inH);
      var minW = Skin.getMinFrameWidth();
      mClientWidth = Std.int(Math.max(inW,minW));
      mClientHeight = Std.int(Math.max(inH,1));
      var size = pane.getLayoutSize(mClientWidth,mClientHeight,true);
      if (size.x<minW)
         size = pane.getLayoutSize(minW,mClientHeight,true);
      mClientWidth = Std.int(size.x);
      mClientHeight = Std.int(size.y);
      mClientOffset = Skin.getFrameClientOffset();
      pane.getLayout().setRect(mClientOffset.x, mClientOffset.y, mClientWidth, mClientHeight);
      redraw();
   }
   (/

   /*
   function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      switch(inAction)
      {
         case DRAG(_pane):
            stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
            mDragStage = stage;
            startDrag();
         case TITLE(pane):
            Dock.raise(pane);
         case BUTTON(pane,id):
            if (id==MiniButton.CLOSE)
               pane.closeRequest(false);
            else if (id==MiniButton.MAXIMIZE)
            {
               trace("->MAXIMIZE");
               docParent.maximize(pane);
            }
            redraw();
         case REDRAW:
            redraw();
         case RESIZE(_pane,_flags):
            stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,onUpdateSize);
            mDragStage = stage;
            mResizeHandle = new Sprite();
            mResizeHandle.name = "Resize handle";
            mSizeX0 = mClientWidth;
            mSizeY0 = mClientHeight;
            addChild(mResizeHandle);
            mResizeHandle.startDrag();
         default:
      }
   }
   */

      /*
   function saveRect()
   {
      //pane.gm2dMDIRect = new Rectangle(x,y,mClientWidth,mClientHeight);
   }

   function onEndDrag(_)
   {
      trace("onEndDrag!!!!!!!!!!!!!!!!!!!!!!!!");
      mDragStage.removeEventListener(MouseEvent.MOUSE_UP,onEndDrag);
      if (mResizeHandle!=null)
      {
         mDragStage.removeEventListener(MouseEvent.MOUSE_MOVE,onUpdateSize);
         removeChild(mResizeHandle);
         mResizeHandle.stopDrag();
         mResizeHandle = null;
      }
      else
         stopDrag();
      var props:Dynamic = pane.getProperties();
      props.mdiX = x;
      props.mdiY = y;
   }

   function onUpdateSize(_)
   {
      if (mResizeHandle!=null)
      {
         var cw = Std.int(mResizeHandle.x + mSizeX0 );
         var ch = Std.int(mResizeHandle.y + mSizeY0  );
         setClientSize(cw,ch);
      }
   }
      */

}



