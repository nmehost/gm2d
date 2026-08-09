package gm2d.ui;

import nme.display.Sprite;
import nme.display.DisplayObjectContainer;
import nme.display.DisplayObject;
import nme.display.BitmapData;
import nme.text.TextField;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.events.MouseEvent;
import nme.events.Event;
import gm2d.ui.Layout;
import gm2d.ui.HitBoxes;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;
import gm2d.skin.BitmapStyle;


class Widget extends Sprite
{
   public static inline var NORMAL     = 0x0000;
   public static inline var CURRENT    = 0x0001;
   public static inline var DOWN       = 0x0002;
   public static inline var DISABLED   = 0x0004;
   public static inline var MULTIVALUE = 0x0008;
   public static inline var ALTERNATE  = 0x0010;
   public static inline var SELECTED   = 0x0020;

   public static var keyboardNavigation:Bool = true;

   var outerLayout:BorderLayout;
   var contentLayout:Layout;

   //public static var showCurrent = true;
   //public static var autoShowCurrent = true;

   public var state(default,set) : Int;
   public var onState:Int->Void;
   public var disabled(get,set) : Bool;
   public var enabled(get,set) : Bool;
   public var selected(get,set) : Bool;
   public var down(get,set):Bool;
   public var isCurrent(get,set):Bool;
   public var layoutWidth(get,null):Int;
   public var layoutHeight(get,null):Int;


   var styled:Bool;

   public var text(get,set):String;


   public var wantFocus:Bool;
   public var mRect : Rectangle;
   public var mChrome : Sprite;
   public var mRenderer : Renderer;
   public var mLineage : Array<String>;
   public var mAttribs : Dynamic;
   public var combinedAttribs : Map<String,Dynamic>;
   public var skin : Skin;
   var scaleCallbacks:Array<Void->Void>;

   //var highlightColour:Int;

   public function new(?inLineage:Array<String>, ?inAttribs:Attribs)
   {
      super();
      skin = Skin.getSkin();
      styled = false;
      mAttribs = inAttribs;
      Reflect.setField(this,"state",0);
      mLineage = addLine(inLineage,"Widget");
      combinedAttribs = skin.combineAttribs(mLineage, state, inAttribs);
      if (combinedAttribs.exists("id"))
         name = combinedAttribs.get("id");
      else
         name = mLineage[0];

      mRenderer = new Renderer(skin,combinedAttribs);
      mChrome = new Sprite();
      addChild(mChrome);
      wantFocus = attribBool("wantsFocus",false);
      mRect = new Rectangle(0,0,0,0);
      addEventListener( MouseEvent.CLICK, widgetClick );
      onState = attribDynamic("onState",null);
   }

   // Recompute and apply this widget's scale-dependent local state - sizes in logical units
   // resolved via skin.toPixels, layout sizing, cached bitmaps whose dimensions depend on the
   // scale.  Overrides must be self-contained (apply the result, don't just compute it) and
   // must be safe to call repeatedly.
   //
   // Not called automatically during construction - prefer addScaleChanged() for scale-dependent
   // construction-time setup (it applies immediately, once everything it closes over already
   // exists, and needs no null-guarding). Overriding onScaleChanged() directly is still fine for
   // genuine ongoing per-instance state read by other methods; just call it yourself at the right
   // point in your own constructor - nothing calls it for you there any more.
   //
   // setSkin() calls this (via the most-derived override, so a direct override or any
   // addScaleChanged callbacks registered so far both still run) whenever the ui scale actually
   // changes on an already-constructed widget - eg the dpi changing as a window moves between
   // monitors, or Game.setSkin() applying a new skin globally.
   public function onScaleChanged():Void
   {
      if (scaleCallbacks!=null)
         for (cb in scaleCallbacks)
            cb();
   }

   // Registers a scale-dependent callback and applies it immediately, then replays it on every
   // future onScaleChanged() (a live rescale via setSkin() - see onScaleChanged's contract above).
   // Meant for scale-dependent construction-time setup - a Layout, a cached size, a
   // locally-scoped variable - without needing a null-guarded onScaleChanged() override plus an
   // explicit duplicate call at the end of the constructor. Call it once, after the locals it
   // closes over exist; no guard needed inside the callback, since registration itself only
   // happens once, after they're already in scope.
   //
   // If a subclass overrides onScaleChanged() instead of using this, it must call
   // super.onScaleChanged() (directly or transitively) or registered callbacks stop firing.
   public function addScaleChanged(cb:Void->Void):Void
   {
      if (scaleCallbacks==null)
         scaleCallbacks = [];
      scaleCallbacks.push(cb);
      cb();
   }

   // Propagates a skin change through this widget and its whole subtree (display-list scan, not
   // the Layout tree - a child widget's own subtree needs to be walked as a unit, which the
   // display list encodes directly). Per-widget: onScaleChanged() (only if uiScale actually
   // changed - a pure palette swap skips it), then rebuildState() (recombines attribs, rebuilds
   // the Renderer, redraws - already correct for a palette swap since Fill/Line/TextColour all
   // resolve live against skin), then push the fresh sizing onto this widget's own Layout.
   // Freezes the incoming skin (Skin.mutable=false) - every widget that attaches a skin does
   // this, idempotently.
   //
   // No separate relayout here by design - Window overrides this to do exactly one top-down
   // relayout once its whole subtree is restyled, so nothing else needs to.
   public function setSkin(inSkin:Skin):Void
   {
      if (inSkin==skin)
         return;
      var rescale = skin==null || skin.uiScale!=inSkin.uiScale;
      skin = inSkin;
      skin.mutable = false;
      if (rescale)
         onScaleChanged();
      rebuildState();
      mRenderer.layoutWidget(this);

      setSkinChildren(this, inSkin);
   }

   // Recurses through every DisplayObjectContainer child looking for Widgets, not just direct
   // Widget children - eg. SideDock is a Layout (not a Widget) and adds its DockFrames to a
   // plain Sprite container, so a Widget can sit behind non-Widget chrome. Same shape as
   // getWidgetsRecurse, minus its focus/visibility filtering (an invisible-but-live dialog still
   // needs restyling).
   static function setSkinChildren(inParent:DisplayObjectContainer, inSkin:Skin):Void
   {
      for(i in 0...inParent.numChildren)
      {
         var child = inParent.getChildAt(i);
         if (Std.isOfType(child,Widget))
            cast(child,Widget).setSkin(inSkin);
         else if (Std.isOfType(child,DisplayObjectContainer))
            setSkinChildren(cast child, inSkin);
      }
   }

   function widgetClick(e:MouseEvent)
   {
      var target:DisplayObject = e.target;
      if (target==this || target==mChrome)
      {
         activate();
      }
   }

   public function addWidget(inWidget:Widget) : Widget
   {
      addChild(inWidget);
      inWidget.applyStyles();
      var layout = getItemLayout();
      if (layout!=null)
         layout.add(inWidget.getLayout());
      else
         setItemLayout(inWidget.getLayout());
      return this;
   }

   public function onChildLayoutChanged()
   {
      var obj:DisplayObject = parent;
      while(obj!=null)
      {
         if (Std.isOfType(obj,Widget))
         {
            cast(obj,Widget).onChildLayoutChanged();
            return;
         }
         obj = obj.parent;
      }
      relayout();
   }

   public static function addLine(inLineage:Array<String>,inClass:String)
   {
      return inLineage==null ? [inClass] : inLineage.concat([inClass]);
   }
   public static function addLines(inLineage:Array<String>,inClasses:Array<String>)
   {
      return inLineage==null ? inClasses : inClasses==null ? inLineage : inLineage.concat(inClasses);
   }
   public static function addAttribs(inAttribs0:Dynamic,inAttribs1:Dynamic)
   {
      if (inAttribs0==null)
         return inAttribs1;
      var result:Dynamic = {};
      for(field in Reflect.fields(inAttribs0))
         Reflect.setField(result, field, Reflect.field(inAttribs0,field));
      for(field in Reflect.fields(inAttribs1))
         Reflect.setField(result, field, Reflect.field(inAttribs1,field));

      return result;
   }
 
   public static function createVLine(?inParent:DisplayObjectContainer,?inLineage:Array<String>,?inAttribs:Dynamic)
   {
      var result =  new Widget(addLines(inLineage,["VLine","Line"]), inAttribs);
      //result.build();
      if (inParent!=null)
         inParent.addChild(result);
      return result;
   }

   public static function createHLine(?inParent:DisplayObjectContainer,?inLineage:Array<String>,?inAttribs:Dynamic)
   {
      var result =  new Widget(addLines(inLineage,["HLine","Line"]), inAttribs);
      //result.build();
      if (inParent!=null)
         inParent.addChild(result);
      return result;
   }

   public function align(x:Float, y:Float, w:Float, h:Float)
   {
      getLayout().align(x,y,w,h);
   }

   public function stretch()
   {
      return getLayout().stretch();
   }

   public function createLayout() return new BorderLayout(contentLayout,true);

   public function setItemLayout(inLayout:Layout)
   {
      contentLayout = inLayout;
      //if (inStretch) contentLayout.stretch();
      if (outerLayout==null)
      {
         outerLayout = createLayout();
         outerLayout.onInnerRect = onLayout;
      }
      else
      {
         outerLayout.setItemLayout(contentLayout);
      }
      if (!styled)
         applyStyles();

      return outerLayout;
   }

   public function getId() : String
   {
      return name;
   }

   public function attrib(inName:String) : Dynamic
   {
      return combinedAttribs.get(inName);
   }

   public function setAttrib(inName:String,inValue:Dynamic) :Void
   {
      if (mAttribs==null)
         mAttribs = {};
      Reflect.setField(mAttribs,inName,inValue);
      combinedAttribs.set(inName,inValue);
   }

   public function attribDynamic(inName:String,inDefault:Dynamic) : Dynamic
   {
      var result = combinedAttribs.get(inName);
      if (result!=null)
         return result;
      return inDefault;
   }

   public function attribAttribs(inName:String,inDefault:Attribs) : Attribs
   {
      var result = combinedAttribs.get(inName);
      if (result!=null)
         return result;
      return inDefault;
   }


   public function hasAttrib(inName:String) : Bool
   {
      return combinedAttribs.exists(inName);
   }

   public function attribBool(inName:String, inDefault=false) : Bool
   {
      var val = combinedAttribs.get(inName);
      return val==null ? inDefault : val;
   }

   public function attribInt(inName:String, inDefault=0) : Int
   {
      var val = combinedAttribs.get(inName);
      return val==null ? inDefault : val;
   }


   public function attribString(inName:String, inDefault="") : String
   {
      var val = combinedAttribs.get(inName);
      return val==null ? inDefault : val;
   }


   public function attribFloat(inName:String, inDefault=0.0) : Float
   {
      var val = combinedAttribs.get(inName);
      return val==null ? inDefault : val;
   }

   // Like attribFloat, but for a logical-unit attrib - scales the result (attrib value or
   // default, either way) once, here, at the point of use.
   public function getAttribScaled(inName:String, inDefault=0.0) : Float
   {
      return skin.toPixels(attribFloat(inName, inDefault));
   }

   public function setBitmap(inBmp:BitmapData)  { }


   public function getBitmap(inState:Int=0) : BitmapData
   {
      var bitmapData:BitmapData = attrib("bitmapData");
      if (bitmapData!=null)
         return bitmapData;

      bitmapData = attrib("icon");
      if (bitmapData!=null)
         return bitmapData;


      var resourceName:String = attrib("resource");
      if (resourceName!=null)
         return nme.Assets.getBitmapData(attrib("resource"));


      var bitmapStyle : BitmapStyle = attrib("bitmap");
      if (bitmapStyle==null)
         return null;

      var bmpName = attribString("bitmapId",name);
      switch(bitmapStyle)
      {
         case BitmapBitmap(bmBitmapData):
            // TODO - disable
            return bmBitmapData;
         case BitmapFactory(factory):
            return factory(skin,bmpName,inState);
         case BitmapAndDisable(bmp,bmpDisabled):
            return ( (inState&Widget.DISABLED>0) ? bmpDisabled : bmp );
         default:
            // BitmapResource/BitmapRender are size-keyed (resolved via skin.renderBitmapStyle
            // through the "bitmapStyle" attrib, not "bitmap") - not valid here.
            return null;
      }

      return null;
   }


   public function getLayout() : Layout
   {
      if (!styled)
         applyStyles();

      if (outerLayout==null)
      {
         setItemLayout( new Layout() );
         outerLayout.onInnerRect = onLayout;
      }

      return outerLayout;
   }

   public function setAlignment(inAlign:Int)
   {
      getLayout().setAlignment(inAlign);
   }

   public function build() { applyStyles(); return this; }

   public function applyStyles()
   {
      styled = true;
      if (outerLayout==null)
      {
         //throw "No layout set";
         setItemLayout( new Layout() );
         outerLayout.onInnerRect = onLayout;
      }
      if (mRenderer!=null)
      {
         mRenderer.layoutWidget(this);
         var tf = getLabel();
         if (tf!=null)
         {
            var alternate:Dynamic = mRenderer.getDynamic("alternateText");
            if (alternate==null)
               alternate =  mRenderer.getDynamic("placeholder");
            var textLayout = alternate==null ? null : contentLayout.findTextLayout();
            if (textLayout!=null)
            {
               mRenderer.renderLabel(tf);

               var t0 = tf.text;
               var w = tf.width;

               var strs:Array<String> = Std.isOfType(alternate,Array) ? alternate :
                        [ Std.string(alternate) ];
               for(str in strs)
               {
                  tf.text = str;
                  w = tf.width + textLayout.getBordersX();
                  var s = textLayout.getMinSize();
                  if (w>s.x)
                     textLayout.setMinWidth(w);
               }
               tf.text = t0;
            }
         }
      }

      var size = outerLayout.getBestSize();
      outerLayout.setRect(0,0,size.x,size.y);
   }

   public function setRect(inX:Float, inY:Float, inW:Float, inH:Float) : Widget
   {
      getLayout().setRect(inX,inY,inW,inH);
      return this;
   }


   public function setPosition(inX:Float, inY:Float)
   {
      var layout = getLayout();
      var size = outerLayout.getBestSize();
      layout.setRect(inX,inY,size.x,size.y);
   }

   function rebuildState(?wasCurrent:Bool)
   {
      if (wasCurrent==null)
         wasCurrent = isCurrent;
      var renderState = state;
      if (isCurrent && !keyboardNavigation && attribBool("autoCurrent",false))
         renderState &= ~CURRENT;
      combinedAttribs = skin.combineAttribs(mLineage, renderState, mAttribs);
      mRenderer = new Renderer(skin,combinedAttribs);
      redraw();
      if (isCurrent && !wasCurrent && attribBool("raiseCurrent",true) && parent!=null)
         parent.setChildIndex(this, parent.numChildren-1 );
   }

   public function set_state(inState:Int) : Int
   {
      if (inState!=state)
      {
         var wasCurrent = isCurrent;
         state = inState;
         if (onState!=null)
            onState(state);
         stage?.invalidate();
         rebuildState(wasCurrent);
      }
      return inState;
   }

   public function setList(id:String, values:Array<String>, display:Array<Dynamic>) { }

   public function set(inValue:Dynamic) : Void
   {
      if ( (inValue!=null && inValue!="") )
         setText(inValue);
   }

   public function get(inValue:Dynamic) : Void
   {
      if (Reflect.hasField(inValue,name))
         Reflect.setField(inValue, name, getText() );
   }


   public function setText(inText:String) : Void
   {
      var label = getLabel();
      if (label!=null)
         label.text = inText;
   }

   function set_text(inText:String) : String
   {
      setText(inText);
      return inText;
   }

   public function getText() : String
   {
      var label = getLabel();
      if (label!=null)
         return label.text;
      return null;
   }
   inline function get_text() : String
   {
      return getText();
   }

   public function showTextEnd()
   {
      var text = getLabel();
      if (text!=null && !text.multiline)
      {
         text.scrollH = 0;
         var t = text.text;
         text.caretIndex = t.length;
         //text.scrollH = text.maxScrollH;
      }
   }

   public function onLayout(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      x = inX;
      y = inY;
      mRect = new Rectangle(0,0,inW,inH);
      redraw();
   }

   public function getLayoutRect() return mRect.clone();

   public function invalidate()
   {
      var s = stage;
      if (s!=null)
         s.invalidate();
   }

   public function onWidgetDrawn() { }

   public function redraw()
   {
      clearChrome();
      if (mRenderer!=null)
      {
         mRenderer.renderWidget(this);
      }
      onWidgetDrawn();
   }

   public function get_layoutWidth():Int return Std.int(mRect.width);
   public function get_layoutHeight():Int return Std.int(mRect.height);

   public function relayout()
   {
      getLayout().relayout();
      //getLayout().setBorderRect( mRect.x, mRect.y, mRect.width, mRect.height );
   }

   static public function getWidgetsRecurse(inParent:DisplayObjectContainer,outList : Array<Widget>)
   {
      if (!inParent.mouseEnabled || !inParent.visible) return;

      for(i in 0...inParent.numChildren)
      {
         var child = inParent.getChildAt(i);
         if (!child.visible)
            continue;
         if (Std.isOfType(child,Widget))
         {
            var child:Widget = cast child;
            if (child.wantsFocus())
               outList.push(child);
         }
         if (Std.isOfType(child,DisplayObjectContainer))
           getWidgetsRecurse(cast child, outList);
      }
   }

   public function getLabel( ) : TextField { return null; }

   public function wantsFocus() { return wantFocus; }

   public function getItemLayout() : Layout { return contentLayout; }

   public function getItemRect(inner=false) : Rectangle
   {
      var l = getItemLayout().getRect();
      if (l==null)
         return mRect;
      if (inner)
         return getItemLayout().getInnerRect(l);
      return l;

   }
 
   public function onChromeMouse(inId:String,inEvent:MouseEvent) : Bool
   {
      var p = parent;
      while(p!=null)
      {
         if (Std.isOfType(p,Widget))
         {
            var widget : Widget = cast p;
            return widget.onChromeMouse(inId,inEvent);
         }
         p = p.parent;
      }
      return true;
   }



/*
   public function getHitBoxes() : HitBoxes
   {
      var p = parent;
      while(p!=null)
      {
         if (Std.isOfType(p,Widget))
         {
            var widget : Widget = cast p;
            return widget.getHitBoxes();
         }
         p = p.parent;
      }
 
      return null;
   }
*/
   public function getPane() : Pane { return null; }

   public function clearChrome()
   {
      mChrome.graphics.clear();
      while(mChrome.numChildren>0)
         mChrome.removeChildAt(0);
   }

   public function onKeyUp(event:nme.events.KeyboardEvent ) : Bool {
      return false;
   }
   public function onKeyDown(event:nme.events.KeyboardEvent ) : Bool {
      return false;
   }

   public function activateCallback() : Bool
   {
      var callback : Void->Void = attrib("onEnter");
      if (callback!=null)
      {
         callback();
         return true;
      }
      return false;
   }

   // public function layout(inW:Float,inH:Float):Void { }

   public function activate()
   {
      if (!activateCallback())
      {
         var obj:DisplayObject = parent;
         while(obj!=null)
         {
            if (Std.isOfType(obj,Widget))
            {
               cast(obj,Widget).activate();
               return;
            }
            obj = obj.parent;
         }
      }
   }

   public function popup(inPopup:Window,inX:Float,inY:Float)
   {
      var pos = localToGlobal( new Point(inX,inY) );
      gm2d.Game.popup(inPopup,pos.x,pos.y);
   }

   public function get_enabled() return (state & DISABLED) == 0;
   public function set_enabled(inVal:Bool)
   {
      var setDisabled = !inVal;
      if (disabled != setDisabled)
         state = state ^ DISABLED;
      return inVal;
   }

   public function get_selected() return (state & SELECTED) > 0;
   public function set_selected(inVal:Bool)
   {
      if (selected != inVal)
         state = state ^ SELECTED;
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
         state = state ^ CURRENT;

         var lastChild:Widget = this;
         var p = parent;
         while(p!=null)
         {
            if (Std.isOfType(p,ScrollWidget))
            {
               var scroll : ScrollWidget = cast p;
               scroll.showChild( lastChild );
            }

            if (Std.isOfType(p,Window))
            {
               var window : Window = cast p;
               window.setCurrentItem( inVal ? this : null );
               return inVal;
            }

            if (Std.isOfType(p,Widget))
               lastChild = cast p;

            p = p.parent;
         }
      }
      return inVal;
   }

}


