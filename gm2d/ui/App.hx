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
   var topMenuBar:SpriteMenubar;
   var leftSlider:SlideBar;
   var rightSlider:SlideBar;
   var bottomSlider:SlideBar;
   var dock:TopLevelDock;
   var mMDI:MDIParent;
   var slideBorders:Int;

   public function new()
   {
      super();

      slideBorders = 3;

      mMDI = new MDIParent();

      dock = new TopLevelDock(this,mMDI);

      makeCurrent();

      addEventListener(gm2d.events.Event.RENDER, checkSliderLayouts);

      doLayout();
   }

   public function createMenubar()
   {
      if (topMenuBar==null)
      {
          topMenuBar = new SpriteMenubar(this,Layout.AlignTop);
      }
   }

   override public function getScaleMode():ScreenScaleMode { return ScreenScaleMode.TOPLEFT_UNSCALED; }

   public function createSlider(inPos:DockPosition,
      inMin:Null<Int>, inMax:Null<Int>,
      inSlideOver:Bool, inShowTab:Bool,
      ?inOffset:Null<Int>, inTabPos:Null<Int>) : SlideBar
   {
      switch(inPos)
      {
         case DOCK_LEFT:
            if (leftSlider!=null)
               throw "Left slider already set";
            leftSlider = new SlideBar(this,inPos,inMin,inMax,inSlideOver,inShowTab,inOffset,inTabPos);
            addChild(leftSlider);
            return leftSlider;

         case DOCK_RIGHT:
            if (rightSlider!=null)
               throw "Right slider already set";
            rightSlider = new SlideBar(this,inPos,inMin,inMax,inSlideOver,inShowTab,inOffset,inTabPos);
            addChild(rightSlider);
            return rightSlider;

         case DOCK_BOTTOM:
            if (bottomSlider!=null)
               throw "Bottom slider already set";
            bottomSlider = new SlideBar(this,inPos,inMin,inMax,inSlideOver,inShowTab,inOffset,inTabPos);
            addChild(bottomSlider);
            return bottomSlider;

         default:
            throw "Invalid slider position";
      }
      return null;
   }


   public function checkSliderLayouts(_)
   {
       var dirty = (leftSlider!=null && leftSlider.isDirty() ) ||
                   (rightSlider!=null && rightSlider.isDirty() ) ||
                   (bottomSlider!=null && bottomSlider.isDirty() );
       if (dirty)
          doLayout();
       if (leftSlider!=null) leftSlider.checkChrome();
       if (rightSlider!=null) rightSlider.checkChrome();
       if (bottomSlider!=null) bottomSlider.checkChrome();
   }

   public function addPane(inPane:IDockable, inPos:DockPosition,inSlot:Int=-1)
   {
      dock.addDockable(inPane,inPos,inSlot);
   }

   public function saveLayout(inKey:String)
   {
      var layout = dock.getLayoutInfo();
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
 
      if (topMenuBar!=null)
      {
         var menu_h = topMenuBar.layout(w);
         y0 += menu_h;
         h -= menu_h;
      }
     
      if (_menubar!=null)
      {
         var menu_h = _menubar.layout(w);
         y0 += menu_h;
         h -= menu_h;
      }

      var bottomX = x0;
      var bottomW = w;
      if (leftSlider!=null)
      {
         var size = leftSlider.setRect(x0,y0,w-slideBorders,h);
         x0+=size+slideBorders;
         w -=size+slideBorders;
      }

      if (rightSlider!=null)
      {
         var size = rightSlider.setRect(x0+slideBorders,y0,w-slideBorders,h);
         w -=size+slideBorders;
         bottomW -=size+slideBorders;
      }

      if (bottomSlider!=null)
      {
         //var size = bottomSlider.setRect(x0,y0+slideBorders,w,h-slideBorders);
         //h -=size+slideBorders;
         var size = bottomSlider.setRect(bottomX,y0+slideBorders,bottomW,h-slideBorders);
         h -=size+slideBorders;
      }
 
 
      dock.setRect(x0,y0,w,h);
   }

   override public function scaleScreen(inScale:Float) { doLayout(); }

   public function getMenuBar() : Menubar
   {
      if (topMenuBar!=null)
         return topMenuBar;

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


