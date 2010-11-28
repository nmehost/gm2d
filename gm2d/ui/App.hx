package gm2d.ui;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.ui.Skin;
import gm2d.ui.Layout;


class App extends Screen
{
   public var menubar(getMenuBar,null):Menubar;
   var mLayout:Layout;
   var mMDI:MDIParent;

   public function new()
   {
      super();

      mMDI = new MDIParent();
      addChild(mMDI);
      mLayout = new DisplayLayout( mMDI, Layout.AlignStretch );

      makeCurrent();
      doLayout();
   }

   override public function getScaleMode():ScreenScaleMode { return ScreenScaleMode.PIXEL_PERFECT; }

   public function addPane(inPane:Pane, inPos:Int)
   {
      if (inPos==Pane.POS_OVER)
         mMDI.addPane(inPane);
      else
      {
      }
   }

   function doLayout()
   {
      var x0 = 0.0;
      var y0 = 0.0;
      var w:Float = stage.stageWidth;
      var h:Float = stage.stageHeight;
      if (menubar!=null)
      {
         var menu_h = Skin.current.menuHeight;
         menubar.layout(w,menu_h);
         y0 += menu_h;
         h -= menu_h;
      }

      mLayout.setRect(x0,y0,w,h);
   }

   override public function scaleScreen(inScale:Float) { doLayout(); }

   public function getMenuBar() : Menubar
   {
      if (menubar==null)
      {
         menubar = new Menubar();
         addChild(menubar);
         doLayout();
      }
      return menubar;
   }


}


