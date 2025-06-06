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

   var mLayout:BorderLayout;
   var mItemLayout:Layout;

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

   //var highlightColour:Int;

   public function new(?inSkin:Skin, ?inLineage:Array<String>, ?inAttribs:{})
   {
      super();
      skin = inSkin==null ? Skin.getSkin() : inSkin;
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


   public function setItemLayout(inLayout:Layout)
   {
      mItemLayout = inLayout;
      //if (inStretch) mItemLayout.stretch();
      if (mLayout==null)
      {
         mLayout = new BorderLayout(mItemLayout,true);
         mLayout.onLayout = onLayout;
      }
      else
      {
         mLayout.setItemLayout(mItemLayout);
      }
      if (!styled)
         applyStyles();

      return mLayout;
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
            return factory(bmpName,inState);
         case BitmapAndDisable(bmp,bmpDisabled):
            return ( (inState&Widget.DISABLED>0) ? bmpDisabled : bmp );
      }
 
      return null;
   }


   public function getLayout() : Layout
   {
      if (!styled)
         applyStyles();

      if (mLayout==null)
      {
         setItemLayout( new Layout() );
         mLayout.onLayout = onLayout;
      }

      return mLayout;
   }

   public function setAlignment(inAlign:Int)
   {
      getLayout().setAlignment(inAlign);
   }

   public function build() { applyStyles(); return this; }

   public function applyStyles()
   {
      styled = true;
      if (mLayout==null)
      {
         //throw "No layout set";
         setItemLayout( new Layout() );
         mLayout.onLayout = onLayout;
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
            var textLayout = alternate==null ? null : mItemLayout.findTextLayout();
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

      var size = mLayout.getBestSize();
      mLayout.setRect(0,0,size.x,size.y);
   }

   public function setRect(inX:Float, inY:Float, inW:Float, inH:Float) : Widget
   {
      getLayout().setRect(inX,inY,inW,inH);
      return this;
   }


   public function setPosition(inX:Float, inY:Float)
   {
      var layout = getLayout();
      var size = mLayout.getBestSize();
      layout.setRect(inX,inY,size.x,size.y);
   }

   function rebuildState(?wasCurrent:Bool)
   {
      if (wasCurrent==null)
         wasCurrent = isCurrent;
      combinedAttribs = skin.combineAttribs(mLineage, state, mAttribs);
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

   public function getItemLayout() : Layout { return mItemLayout; }

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


