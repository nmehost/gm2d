package gm2d.ui;
import gm2d.skin.Skin;
import wx.NMEStage;
import nme.display.Stage;

class WaxeDialog implements IDialog
{
   var frame:wx.Dialog;
   var nmeStage:NMEStage;
   var stage:Stage;

   public function new(inPane:Pane, ?inAttribs:Dynamic, ?inLineage:Array<String>)
   {
      var w = Std.int(inPane.sizeX);
      var h = Std.int(inPane.sizeY);
      var size = { width:w, height:h };
      frame = wx.Dialog.create(wx.NMEStage.mainWindow,null, inPane.title, null, size);
      nmeStage = NMEStage.create(frame);
      stage = nmeStage.stage;
      stage.color = Skin.dialogColor;
      stage.addChild(inPane.displayObject);
      inPane.getLayout().setRect(0,0,w,h);
   }
   public function show(autoClose:Bool)
   {
      frame.showFrame(wx.TopLevelWindow.MODAL);
   }

   public function closeFrame():Void
   {
      trace("closeFrame");
      frame.destroy();
      trace("dispose");
      //stage.dispose();
   }
   public function asDialog():Dialog return null;


   /*
   public function getDock():IDock { return this; }
   public function canAddDockable(inPos:DockPosition):Bool;
   public function addDockable(child:IDockable,inPos:DockPosition,inSlot:Int):Void;
   public function getDockablePosition(child:IDockable):Int;
   public function removeDockable(child:IDockable):IDockable;
   public function raiseDockable(child:IDockable):Bool;
   public function minimizeDockable(child:IDockable):Bool;
   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition):Void;
   public function getSlot():Int;
   public function setDirty(inLayout:Bool, inChrome:Bool):Void;
   */
}

