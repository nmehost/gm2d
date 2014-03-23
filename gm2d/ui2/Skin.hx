package gm2d.ui;

import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldAutoSize;

import gm2d.Gradient;
import gm2d.ui.SkinFill;
import gm2d.ui.SkinLine;
import gm2d.ui.SkinShape;
import gm2d.ui.SkinItem;
import gm2d.ui.SkinFont;
import gm2d.ui.SkinStyle;
import gm2d.ui.SkinTitle;
import gm2d.ui.Layout;




class Skin
{
   public static var uiScale = 1.0;

   static var sStyleList:Array<SkinStyle> = [];

   public var active:Active;
   public var enabled:Enabled;
   public var down:Bool;

   var styles:Array<SkinStyle>;
   var attribs:Map<String,Dynamic>;
   var className:String;
   var id:String;


   public function new(inClassName:String, inId:String, inStyles:Array<SkinStyle>,?inAttribs:Map<String,Dynamic>)
   {
      className = inClassName;
      id = inId;
      attribs = inAttribs;
      styles = new Array<SkinStyle>();
      for(s in 0...inStyles.length)
         styles[ inStyles.length-s-1 ] = inStyles[s];
      enabled = ENABLED;
      active = DORMANT;
   }

   public static function create(inWidget:String, ?inAttribs:Dynamic, inContext:String="")
   {
      if (sStyleList.length==0)
         initDefaults();

      var attribMap:Map<String,Dynamic> = createAttribMap(inAttribs,false);

      var id = attribMap==null ? "" : attribMap.get("id");
      if (id==null)
         id = "";

      var styleName = attribMap==null ? "" : attribMap.get("styleName");
      if (styleName==null)
         styleName = "";


      var matching = new Array<SkinStyle>();
      for(style in sStyleList)
      {
         if (style.widget!=null && style.widget!=inWidget)
            continue;
         if (style.styleName!=null && style.styleName!=styleName)
            continue;
         if (style.id!=null && style.id!=id)
            continue;
         if (style.idMatch!=null && !style.idMatch.match(id))
            continue;
         if (style.contextMatch!=null && !style.contextMatch.match(inContext))
            continue;

         matching.push(style);
      }

      return new Skin(inWidget, id, matching, attribMap);
   }

   public function getAttribute(inName:String)
   {
      if (attribs!=null && attribs.exists(inName))
         return attribs.get(inName);

      for(style in styles)
      {
         if ( (style.active==null || style.active==active) &&
              (style.down==null || style.down==down) &&
              (style.enabled==null || style.enabled==enabled) )
         {
            if (style.attribs.exists(inName))
               return style.attribs.get(inName);
         }
      }
      return null;
   }

   public function getTitle() : String { return getAttribute("title"); }

   public function styleText(text:TextField)
   {
      var font:SkinFont = getAttribute("font");
      if (font!=null)
      {
         var format = font.getFormat();
         text.defaultTextFormat = format;
         text.setTextFormat(format);
      }
      var colour = getAttribute("fontColor");
      if (Std.is(colour,Int))
         text.textColor = colour;
   }


   // TODO - if string, substitute {ID} {CLASS} {ENABLED} {ACTIVE}
   public function render(gfx:Graphics, x:Float, y:Float, w:Float, h:Float)
   {
      var shape:SkinShape = getAttribute("shape");
      if (shape!=null)
      {
         var fill:SkinFill = getAttribute("fill");
         var filled = false;
         if (fill!=null)
         {
            filled = true;
            switch(fill)
            {
               case SF_SOLID(rgb,a) : gfx.beginFill(rgb,a);
               //case SF_GRAD(grad) : grad.beginFill(gfx);
               //case SF_BITMAP(bitmap:BitmapData);
               //case SF_SCALE9(bitmap:BitmapData,strectArea:Rectangle);
               //case SF_FUNC(filler:Graphics->Void);
               //case SF_BITMAP_REF(bitmapName:String);
               //case SF_SCALE9_REF(bitmapName:String,strectArea:Rectangle);
               default: filled = false;
            }
         }
         var stroked = false;
         var line:SkinLine = getAttribute("line");
         if (line!=null)
         {
            var stroked = true;
            switch(line)
            {
               case SL_SOLID(rgb,a,width) : gfx.lineStyle(width,rgb,a);
               //case SL_GRAD(grad:Gradient,vertical,width);
               default: stroked = false;
            }
         }

         switch(shape)
         {
            case SS_RECT:
               gfx.drawRect(x,y,w,h);
            case SS_ROUND_RECT(rad):
               gfx.drawRoundRect(x,y,w,h,rad,rad);
            case SS_CUSTOM(render):
               render(gfx, this, new Rectangle(x,y,w,h) );
         }
 
         if (stroked)
            gfx.lineStyle();
         if (filled)
            gfx.endFill();
      }
   }

   public function createBitmap(inName:String)
   {
      var bitmapData = gm2d.reso.Resources.loadBitmap(inName);
      var result = new Bitmap(bitmapData);
      result.scaleX = result.scaleY = uiScale;
      return result;
   }

   public function getItem() : DisplayObject
   {
      var item:SkinItem = getAttribute("item");
      if (item==null || !Std.is(item,SkinItem))
         return null;

      switch(item)
      {
         // TODO - substiture name?
         case ITEM_BITMAP(name): return createBitmap(name);
         case ITEM_BITMAPDATA(data):
            var result = new Bitmap(data);
            result.scaleX = result.scaleY = uiScale;
            return result;

         case ITEM_ICON(icon,scale): return new Bitmap( icon.toBitmap(uiScale*scale) );
         case ITEM_OBJECT(object): return object;
         case ITEM_CUSTOM(factory) : return factory(this);
         case ITEM_LAYOUT(_) : return null;
      }
   }

   public function getIntAttribute(name:String) : Null<Int>
   {
      var result = getAttribute(name);
      if (Std.is(result,Int))
         return result;
      return null;
   }

   public function getIntDefault(name:String,inDefault:Int) : Int
   {
      var result = getIntAttribute(name);
      return result==null ? inDefault : result;
   }

   public function getFloatAttribute(name:String) : Null<Float>
   {
      var result = getAttribute(name);
      if (Std.is(result,Float))
         return result;
      return null;
   }


   public function getBoolAttribute(name:String) : Null<Bool>
   {
      var result = getAttribute(name);
      if (Std.is(result,Bool))
         return result;
      return null;
   }


   public function getScaledFloatAttribute(name:String) : Null<Float>
   {
      var result = getAttribute(name);
      if (Std.is(result,Float))
         return result * uiScale;
      return null;
   }


   public function getAttributeDefault<T>(name:String,inDefault:T,clazz:Class<T>) : T
   {
      var result = getAttribute(name);
      if (result!=null && Std.is(result,clazz))
         return result;
      return inDefault;
   }

   public function getEnumDefault<T>(name:String,inDefault:T,enumm:Enum<T>) : T
   {
      var result = getAttribute(name);
      if (result!=null && Std.is(result,enumm))
         return result;
      return inDefault;
   }




   public function getScaledFloatDefault(name:String,inDefault:Float) : Float
   {
      var result = getScaledFloatAttribute(name);
      if (result!=null)
         return result;
      return inDefault * uiScale;
   }

   public function getFloatDefault(name:String,inDefault:Float) : Float
   {
      var result = getFloatAttribute(name);
      if (result!=null)
         return result;
      return inDefault;
   }

   public function getBoolDefault(name:String,inDefault:Bool) : Bool
   {
      var result = getBoolAttribute(name);
      if (result!=null)
         return result;
      return inDefault;
   }



   public function getTitleLayout(title:TextField) : TextLayout
   {
      var align:Int = getIntDefault("titleAlign",Layout.AlignCenterX|Layout.AlignCenterY);
      var width:Null<Float> = getScaledFloatAttribute("titleWidth");
      var height:Null<Float> = getScaledFloatAttribute("titleHeight");

      var result = new TextLayout(title,align,width,height);
      result.setBorders( getScaledFloatDefault("titlePaddingLeft",0),
                         getScaledFloatDefault("titlePaddingTop",0),
                         getScaledFloatDefault("titlePaddingRight",0),
                         getScaledFloatDefault("titlePaddingBottom",0) );
      return result;
   }

   public function getItemLayout(?object:DisplayObject) : Layout
   {
      var result:Layout = null;

      var align:Int = getIntDefault("itemAlign",Layout.AlignCenterX|Layout.AlignCenterY);
      var width:Null<Float> = getScaledFloatAttribute("itemWidth");
      var height:Null<Float> = getScaledFloatAttribute("itemHeight");

      if (object==null)
      {
         var item:SkinItem = getAttribute("item");
         if (item!=null || Std.is(item,SkinItem))
         {
            switch(item)
            {
               case ITEM_LAYOUT(layout) : result = layout;
               default: 
            }
         }
      }
      else
      {
         result = Std.is(object,TextField) ?
                         new TextLayout(cast object,align,width,height) :
                         new DisplayLayout(object,align,width,height);
      }

      if (result!=null)
         result.setBorders( getScaledFloatDefault("itemPaddingLeft",0),
                            getScaledFloatDefault("itemPaddingTop",0),
                            getScaledFloatDefault("itemPaddingRight",0),
                            getScaledFloatDefault("itemPaddingBottom",0) );
      return result;
   }

   public function setTitleBarLayoutAttribs(layout:Layout) : Layout
   {
      var height:Null<Float> = getScaledFloatAttribute("itemHeight");

      var width:Null<Float> = getScaledFloatAttribute("width");
      if (width!=null)
         layout.setMinWidth(width);
      var height:Null<Float> = getScaledFloatAttribute("height");
      if (height!=null)
         layout.setMinHeight(height);
      layout.setBorders( getScaledFloatDefault("paddingLeft",0),
                         getScaledFloatDefault("paddingTop",0),
                         getScaledFloatDefault("paddingRight",0),
                         getScaledFloatDefault("paddingBottom",0) );
      return layout;
   }

   public function setLayoutAttribs(layout:Layout) : Layout
   {
      var align:Int = getIntDefault("itemAlign",Layout.AlignCenterX|Layout.AlignCenterY);
      var height:Null<Float> = getScaledFloatAttribute("itemHeight");

      var width:Null<Float> = getScaledFloatAttribute("width");
      if (width!=null)
         layout.setMinWidth(width);
      var height:Null<Float> = getScaledFloatAttribute("height");
      if (height!=null)
         layout.setMinHeight(height);
      layout.setBorders( getScaledFloatDefault("paddingLeft",0),
                         getScaledFloatDefault("paddingTop",0),
                         getScaledFloatDefault("paddingRight",0),
                         getScaledFloatDefault("paddingBottom",0) );
      return layout;
   }


   public static function pushStyle(inStyle:SkinStyle)
   {
      sStyleList.push(inStyle);
   }

   static function createAttribMap(inAttribs:Dynamic, inCreateEmpty:Bool) : Map<String, Dynamic>
   {
      if (!inCreateEmpty && inAttribs==null)
         return null;
      var result = new Map<String,Dynamic>();
      if (inAttribs!=null)
         for(key in Reflect.fields(inAttribs))
             result.set(key, Reflect.field(inAttribs,key));
      return result;
   }

   public static function addStyle( filter:StyleFilter, inAttribs:Dynamic )
   {
      sStyleList.push(new SkinStyle( filter, createAttribMap(inAttribs,false) ) );
   }

   public static function initDefaults()
   {
      // Defaults for all....
      addStyle( null, {
         fill:SF_SOLID(0xffffff,1.0),
         line:SL_SOLID(0x000000,1,1),
         shape:SS_ROUND_RECT(3),
         font:new SkinFont("_sans",18,false),
         fontColor:0x000000,
         titlePosition:TITLE_RIGHT,
         gap:3,
         titlePaddingLeft:0,
         titlePaddingRight:0,
         titlePaddingTop:0,
         titlePaddingBottom:0,
         itemPaddingLeft:0,
         itemPaddingRight:0,
         itemPaddingTop:0,
         itemPaddingBottom:0,
         paddingLeft:3,
         paddingRight:3,
         paddingTop:3,
         paddingBottom:3
         } );

      // Defaults for down
      addStyle( {down:true},  {
          fill:SF_SOLID(0x808080,1.0),
          fontColor:0xffffff,
          paddingLeft:5,
          paddingRight:1,
          paddingTop:5,
          paddingBottom:1
          } );

      addStyle(  { widget:"Panel" }, {
         fill:SF_SOLID(0xf0f0ff,1.0),
         width:400
         } );

      addStyle(  { widget:"Dialog" }, {
         titleStyle:TITLE_BAR("TitleBar",["close","close","close"]),
         width:300,
         height:400
         } );


      // HDockSpacer or VDockSpacer
      addStyle( { widget:"DockSpacer" }, {
         fill:SF_SOLID(0xff0000,1.0),
         shape:SS_RECT,
         line:null
         } );

      addStyle( { widget:"TitleBar" } , {
         fill:SF_SOLID(0x202060,1.0),
         fontColor:0xffffff,
         height:32,
         gap:0,
         titleAlign:Layout.AlignLeft | Layout.AlignCenterY,
         titlePaddingLeft:10,
         line:null
         } );

      addStyle( { id:"close" } , {
         fill:SF_SOLID(0xff0000,1.0),
         width:16,
         height:16,
         line:null
         } );
   }

}


