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
   public static inline var NORMAL     = 0x0000;
   public static inline var CURRENT    = 0x0001;
   public static inline var DOWN       = 0x0002;
   public static inline var DISABLED   = 0x0004;
   public static inline var MULTIVALUE = 0x0008;

   var mLayout:BorderLayout;
   var mItemLayout:Layout;

   public var state(default,set) : Int;
   public var disabled(get,set) : Bool;
   public var enabled(get,set) : Bool;
   public var down(get,set):Bool;
   public var isCurrent(get,set):Bool;

   public var text(get_text,set_text):String;


   public var wantFocus:Bool;
   public var mRect : Rectangle;
   public var mChrome : Sprite;
   public var mRenderer : Renderer;
   public var mLineage : Array<String>;
   public var mAttribs : Dynamic;

   //var highlightColour:Int;

   public function new(?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      super();
      mAttribs = inAttribs;
      Reflect.setField(this,"state",0);
      mLineage = addLine(inLineage,"Widget");
      if (mAttribs!=null && Reflect.hasField(inAttribs,"id"))
         name = Reflect.field(inAttribs,"id");
      else
         name = mLineage[0];

      mRenderer = Skin.renderer(mLineage, state, inAttribs);
      mChrome = new Sprite();
      addChild(mChrome);
      wantFocus = false;
      mRect = new Rectangle(0,0,0,0);
   }

   public static function addLine(inLineage:Array<String>,inClass:String)
   {
      return inLineage==null ? [inClass] : inLineage.concat([inClass]);
   }
   public static function addLines(inLineage:Array<String>,inClasses:Array<String>)
   {
      return inLineage==null ? inClasses : inLineage.concat(inClasses);
   }
   public static function addAttribs(inAttribs0:Dynamic,inAttribs1:Dynamic)
   {
      if (inAttribs0==null)
         return inAttribs1;
      var result:Dynamic = [];
      for(field in Reflect.fields(inAttribs0))
         Reflect.setField(result, field, Reflect.field(inAttribs0,field));
      for(field in Reflect.fields(inAttribs1))
         Reflect.setField(result, field, Reflect.field(inAttribs0,field));

      return result;
   }
 

   function setItemLayout(inLayout:Layout)
   {
      mItemLayout = inLayout.stretch();
      mLayout = new BorderLayout(mItemLayout,true);
      mLayout.onLayout = onLayout;
      return mLayout;
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
      {
         mRenderer.layoutWidget(this);

         var tf = getLabel();
         if (tf!=null)
         {
            var alternate = mRenderer.getDynamic("alternateText");
            var textLayout = alternate==null ? null : mItemLayout.findTextLayout();
            if (textLayout!=null)
            {
               var t0 = tf.text;
               var w = tf.width;
               var rebuild = false;

               var strs:Array<String> = Std.is(alternate,Array) ? alternate :
                        [ Std.string(alternate) ];
               for(str in strs)
               {
                  tf.text = str;
                  w = tf.width;
                  if (w>textLayout.minWidth)
                  {
                     rebuild = true;
                     textLayout.setMinWidth(w);
                  }
               }

               tf.text = t0;
               if (rebuild)
                  mRenderer.layoutWidget(this);
            }
         }
      }

      var size = mLayout.getBestSize();
      mLayout.setRect(0,0,size.x,size.y);
   }

   public function set_state(inState:Int) : Int
   {
      if (inState!=state)
      {
         state = inState;
         mRenderer = Skin.renderer(mLineage, state, mAttribs);
         redraw();
      }
      return inState;
   }

   public function set_text(inText:String) : String
   {
      var label = getLabel();
      if (label!=null)
         label.text = inText;
      return inText;
   }

   public function get_text() : String
   {
      var label = getLabel();
      if (label!=null)
         return label.text;
      return null;
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
      {
         mRenderer.renderWidget(this);
      }
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

   public function get_enabled() return (state & DISABLED) == 0;
   public function set_enabled(inVal:Bool)
   {
      var setDisabled = !inVal;
      if (disabled != setDisabled)
         state = state ^ DISABLED;
      return inVal;
   }


   public function get_disabled() return (state & DISABLED) > 0;
   public function set_disabled(inVal:Bool)
   {
      if (disabled != inVal)
         state = state ^ DISABLED;
      return inVal;
   }

   public function get_down()  return (state & DOWN) > 0;
   public function set_down(inVal:Bool)
   {
      if (down != inVal)
         state = state ^ DOWN;
      return inVal;
   }

   public function get_isCurrent()  return (state & CURRENT) > 0;
   public function set_isCurrent(inVal:Bool) : Bool
   {
      if (isCurrent != inVal)
      {
         var p = parent;
         while(p!=null)
         {
            if (Std.is(p,Window))
            {
               var window : Window = cast p;
               window.setCurrentItem( inVal ? this : null );
               return inVal;
            }
            p = p.parent;
         }
 
         state = state ^ CURRENT;
      }
      return inVal;
   }

}


