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
   var mLayout:BorderLayout;
   var mItemLayout:Layout;

   public var wantFocus:Bool;
   public var mRect : Rectangle;
   public var mChrome : Sprite;
   public var mState(default,null) : WidgetState;
   public var mIsDown : Bool;
   public var mRenderer : Renderer;
   public var mLineage : Array<String>;

   //var highlightColour:Int;

   public function new(?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      super();
      mLineage = addLine(inLineage,"Widget");
      name = mLineage[0];
      mRenderer = Skin.renderer(mLineage, inAttribs);
      mChrome = new Sprite();
      addChild(mChrome);
      wantFocus = false;
      mState = WidgetNormal;
      mIsDown = false;
      mRect = new Rectangle(0,0,0,0);
      //highlightColour = 0x0000ff;
   }

   public static function addLine(inLineage:Array<String>,inClass:String)
   {
      return inLineage==null ? [inClass] : inLineage.concat([inClass]);
   }

   function setItemLayout(inLayout:Layout)
   {
      mItemLayout = inLayout;
      mLayout = new BorderLayout(mItemLayout,true);
      mLayout.onLayout = onLayout;
   }

   public function getLayout() { return mLayout; }

   public function build()
   {
      if (mLayout==null)
      {
         //throw "No layout set";
         setItemLayout( new Layout() );
      }
      if (mRenderer!=null)
         mRenderer.layoutWidget(this);
      var size = mLayout.getBestSize();
      mLayout.setRect(0,0,size.x,size.y);
   }

   public function setState(inState:WidgetState)
   {
      if (inState!=mState)
      {
         mState = inState;
         redraw();
      }
   }

   public function onLayout(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      x = inX;
      y = inY;
      mRect = new Rectangle(0,0,inW,inH);
      redraw();
   }

   public function redraw()
   {
      clearChrome();
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

   public function getItemLayout() : Layout { return mItemLayout; }
 
   public function getHitBoxes() : HitBoxes { return null; }

   public function getPane() : Pane { return null; }

   public function clearChrome()
   {
      mChrome.graphics.clear();
      while(mChrome.numChildren>0)
         mChrome.removeChildAt(0);
   }

   public function onKeyDown(event:nme.events.KeyboardEvent ) : Bool { return false; }

   // public function layout(inW:Float,inH:Float):Void { }

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


