package gm2d.ui;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.skin.Skin;
import gm2d.ui.Layout;
import gm2d.ui.Dock;
import gm2d.ui.IDockable;
import gm2d.ui.Menubar;
import gm2d.ui.SlideBar;
import gm2d.ui.TopLevelDock;
import gm2d.ui.DocumentParent;
import gm2d.ui.Widget;
import gm2d.ui.DockPosition;
import nme.events.KeyboardEvent;
import nme.text.TextField;

import nme.net.SharedObject;


class App extends Screen
{
   var _menubar:Menubar;
   public var menubar(get_menubar,null):Menubar;
   var spriteMenuBar:SpriteMenubar;
   var leftSlider:SlideBar;
   var rightSlider:SlideBar;
   var bottomSlider:SlideBar;
   var dock:TopLevelDock;
   var docParent:DocumentParent;
   var slideBorders:Int;
   var statusBar:Widget;
   var statusHeight:Int;

   public function new(inSingleDocument=false)
   {
      super();

      slideBorders = 0;

      //widgets = new WidgetManager();

      docParent = new DocumentParent(inSingleDocument);

      dock = new TopLevelDock(this,docParent);

      makeCurrent();

      addEventListener(nme.events.Event.RENDER, checkSliderLayouts);

      relayout();
   }

   override public function goBack( ) :Bool
   {
      trace("goBack");
      return false;
   }

   public function createStatusBar(inText="",?inAttribs)
   {
      statusBar = new TextLabel(inText,["StatusBar"],inAttribs);
      statusHeight = Std.int(statusBar.getLayout().getBestHeight());
      addChild(statusBar);
   }

   public function createMenubar(useSpriteBar = false)
   {
      #if (waxe && !nme_menu)
      if (_menubar==null)
         _menubar = new WxMenubar(this);
      #else
      if (spriteMenuBar==null)
      {
         spriteMenuBar = new SpriteMenubar(this,Layout.AlignTop);
         _menubar = spriteMenuBar;
      }
      #end

      if (useSpriteBar && spriteMenuBar==null)
         spriteMenuBar = new SpriteMenubar(this,Layout.AlignTop);

      return _menubar;
   }

   public function setMenuWidgets(inWidgets:Array<Widget>)
   {
      if (spriteMenuBar!=null)
         spriteMenuBar.setWidgets(inWidgets);
      relayout();
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
          relayout();
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


   override function relayout()
   {
      var x0 = 0.0;
      var y0 = 0.0;
      var w:Float = stage.stageWidth;
      var h:Float = stage.stageHeight;

      if (_menubar!=null && _menubar!=spriteMenuBar)
      {
         var menu_h = _menubar.layout(w);
         y0 += menu_h;
         h -= menu_h;
      }

      if (statusBar!=null)
      {
         statusBar.setRect(0,h-statusHeight,w,statusHeight);
         h -= statusHeight;
      }

      var bottomX = x0;

 
      if (spriteMenuBar!=null)
      {
         var topMenuHeight = spriteMenuBar.layout(w);
         y0 += topMenuHeight;
         h -= topMenuHeight;
      }

      if (rightSlider!=null)
      {
         var size = rightSlider.setRect(x0+slideBorders,y0,w-slideBorders,h);
         w -=size+slideBorders;
      }

      var bottomOffset = 0;
      if (leftSlider!=null)
      {
         var size = leftSlider.setRect(x0,y0,w-slideBorders,h);
         bottomOffset = Std.int(leftSlider.getBarHeight());
         x0+=size+slideBorders;
         w -=size+slideBorders;
      }

      if (bottomSlider!=null)
      {
         //var size = bottomSlider.setRect(x0,y0+slideBorders,w,h-slideBorders);
         //h -=size+slideBorders;
         var size = bottomSlider.setRect(x0-bottomOffset,y0+slideBorders,w+bottomOffset,h-slideBorders);
         h -=size+slideBorders;
      }
 
 
      dock.setRect(x0,y0,w,h);

      if (leftSlider!=null) leftSlider.checkChrome();
      if (rightSlider!=null) rightSlider.checkChrome();
      if (bottomSlider!=null) bottomSlider.checkChrome();

   }

   override public function scaleScreen(inScale:Float)
   {
      relayout();
   }

   public function get_menubar() : Menubar
   {
      if (_menubar==null)
      {
         createMenubar();
         relayout();
      }
      return _menubar;
   }


   public function sendMenuKey(event:KeyboardEvent ) : Bool
   {
      if (spriteMenuBar!=null && spriteMenuBar==_menubar)
         return spriteMenuBar.onKeyDown(event);
      return false;
   }

   override public function onKeyDown(event:KeyboardEvent ) : Bool
   {
      var focusElem = stage.focus;
      if (focusElem==null && !Std.is(focusElem,TextField))
         return sendMenuKey(event);
      return false;
   }

   public function setStatus(s:String)
   {
      if (setStatus==null)
         throw "setStatus - no statusBar";
      statusBar.setText(s);
   }


}



