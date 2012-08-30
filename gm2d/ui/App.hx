package gm2d.ui;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.skin.Skin;
import gm2d.ui.Layout;
import gm2d.ui.Dock;
import gm2d.ui.IDockable;
import gm2d.ui.Menubar;

import nme.net.SharedObject;


class App extends Screen
{
   var _menubar:Menubar;
   public var menubar(getMenuBar,null):Menubar;
   var topSlideBar:SlideBar;
   var dock:TopLevelDock;
   var mMDI:MDIParent;

   public function new()
   {
      super();

      mMDI = new MDIParent();

      dock = new TopLevelDock(this,mMDI);

      makeCurrent();

      doLayout();
   }

   public function createTopSlideBar()
   {
      if (topSlideBar==null)
      {
          topSlideBar = new SlideBar(this,Layout.AlignTop);
      }
   }

   override public function getScaleMode():ScreenScaleMode { return ScreenScaleMode.TOPLEFT_UNSCALED; }

   public function addPane(inPane:IDockable, inPos:DockPosition,inSlot:Int=-1)
   {
      dock.addDockable(inPane,inPos,inSlot);
   }

   public function saveLayout(inKey:String)
   {
      var layout = dock.getLayoutInfo();
      trace(layout);
      var def = SharedObject.getLocal("layout");
      if (def!=null)
      {
         Reflect.setField(def.data,inKey, layout);
         def.flush();
      }
   }

   public function loadLayout(inKey:String)
   {
      var def = SharedObject.getLocal("layout");
      if (def!=null)
      {
         var layout = Reflect.field(def.data,inKey);
         if (layout!=null)
         {
            trace(layout);
            dock.setLayoutInfo(layout);
         }
      }
   }


   function doLayout()
   {
      var x0 = 0.0;
      var y0 = 0.0;
      var w:Float = stage.stageWidth;
      var h:Float = stage.stageHeight;
 
      if (topSlideBar!=null)
      {
         var menu_h = topSlideBar.layout(w);
         y0 += menu_h;
         h -= menu_h;
      }
     
      if (_menubar!=null)
      {
         var menu_h = _menubar.layout(w);
         y0 += menu_h;
         h -= menu_h;
      }

      dock.setRect(x0,y0,w,h);
   }

   override public function scaleScreen(inScale:Float) { doLayout(); }

   public function getMenuBar() : Menubar
   {
      if (topSlideBar!=null)
         return topSlideBar;

      if (_menubar==null)
      {
         #if (waxe && !nme_menu)
         _menubar = new WxMenubar(this);
         #else
         _menubar = new SpriteMenubar(this);
         #end
         doLayout();
      }
      return _menubar;
   }
}


