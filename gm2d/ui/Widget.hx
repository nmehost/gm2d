package gm2d.ui;

import nme.display.Sprite;
import nme.display.DisplayObjectContainer;
import nme.text.TextField;
import nme.geom.Point;
import nme.geom.Rectangle;
import gm2d.ui.Layout;
import gm2d.ui.HitBoxes;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;


class Widget extends Sprite
{
   public var wantFocus:Bool;
   var mLayout:Layout;
   public var mRect : Rectangle;
   public var mChrome : Sprite;
   public var mState : WidgetState;
   public var mIsDown : Bool;
   public var mRenderer : Renderer;

   //var highlightColour:Int;

   public function new(inClass:String="Widget", ?inAttribs:Dynamic)
   {
      super();
      mRenderer = Skin.renderer(inClass, inAttribs);
      mChrome = new Sprite();
      addChild(mChrome);
		wantFocus = false;
      mState = WidgetNormal;
      mIsDown = false;
      //highlightColour = 0x0000ff;
   }

   public function build()
   {
      var layout = getLayout();
      layout.onLayout = renderBackground;
      if (mRenderer!=null)
         mRenderer.layoutWidget(this);
      var size = layout.getBestSize();
      layout.setRect(0,0,size.x,size.y);
   }


   function renderBackground(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      clearChrome();
      mRect = new Rectangle(inX-x,inY-y,inW,inH);
      if (mRenderer!=null)
         mRenderer.renderWidget(this);
   }


   static public function getWidgetsRecurse(inParent:DisplayObjectContainer,outList : Array<Widget>)
   {
      if (!inParent.mouseEnabled || !inParent.visible) return;

      for(i in 0...inParent.numChildren)
      {
         var child = inParent.getChildAt(i);
         if (Std.is(child,Widget))
         {
            var child:Widget = cast child;
            if (child.wantsFocus())
               outList.push(child);
         }
         if (Std.is(child,DisplayObjectContainer))
           getWidgetsRecurse(cast child, outList);
      }
   }

   public function getLabel( ) : TextField { return null; }

   public function wantsFocus() { return wantFocus; }

   public function getInnerLayout() : Layout { return null; }
 
   public function getHitBoxes() : HitBoxes { return null; }

   public function getPane() : Pane { return null; }

   public function clearChrome()
   {
      mChrome.graphics.clear();
      while(mChrome.numChildren>0)
         mChrome.removeChildAt(0);
   }


   public function createLayout() : Layout
   {
      return new DisplayLayout(this);
   }

   public function getLayout() : Layout
   {
      if (mLayout==null)
         mLayout = createLayout();
      return mLayout;
   }

   public function onKeyDown(event:nme.events.KeyboardEvent ) : Bool { return false; }

   public function layout(inW:Float,inH:Float):Void { }

   public function activate(inDirection:Int) { }

   public function onCurrentChanged(inCurrent:Bool) { }

   public function popup(inPopup:Window,inX:Float,inY:Float,inShadow:Bool=true)
   {
	   var pos = localToGlobal( new Point(inX,inY) );
		gm2d.Game.popup(inPopup,pos.x,pos.y,inShadow);
   }

   public function clearCurrent()
   {
      var p = parent;
      while(p!=null)
      {
         if (Std.is(p,Window))
         {
            var window : Window = cast p;
            window.setCurrentItem(null);
            return;
         }
         p = p.parent;
      }
   }



   public function setCurrent()
   {
      var p = parent;
      while(p!=null)
      {
         //trace(p);
         if (Std.is(p,Window))
         {
            var window : Window = cast p;
            window.setCurrentItem(this);
            return;
         }
         p = p.parent;
      }
   }

}


