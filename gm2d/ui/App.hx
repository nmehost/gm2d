package gm2d.ui;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.ui.Skin;
import gm2d.ui.Layout;
import gm2d.ui.Dock;
import gm2d.ui.IDockable;


class App extends Screen
{
   public var menubar(getMenuBar,null):Menubar;
   var dock:Dock;
   var mMDI:MDIParent;

   public function new()
   {
      super();

      mMDI = new MDIParent(this);

      dock = mMDI.dock;

      //mLayout = new DisplayLayout( mMDI, Layout.AlignStretch );

      makeCurrent();
      doLayout();
   }

   override public function getScaleMode():ScreenScaleMode { return ScreenScaleMode.TOPLEFT_UNSCALED; }

   public function addPane(inPane:Pane, inPos:DockPosition,inSlot:Int=-1)
   {
      dock = dock.add(inPane,inPos,inSlot);
   }

   function doLayout()
   {
      var x0 = 0.0;
      var y0 = 0.0;
      var w:Float = stage.stageWidth;
      var h:Float = stage.stageHeight;
      if (menubar!=null)
      {
         var menu_h = menubar.layout(w);
         y0 += menu_h;
         h -= menu_h;
      }

      dock.setRect(x0,y0,w,h);
   }

   override public function scaleScreen(inScale:Float) { doLayout(); }

   public function getMenuBar() : Menubar
   {
      if (menubar==null)
      {
         menubar = new Menubar(this);
         doLayout();
      }
      return menubar;
   }


}


