package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.geom.Rectangle;
import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;

class Button extends Control
{
   var mDisplayObj : DisplayObject;
   var mStateBitmap : Bitmap;

   public var isToggle:Bool;
   public var noFocus:Bool;
   public var mCallback : Void->Void;
   public var mouseHandler : String->MouseEvent->Bool;
   public var mDownDX:Float;
   public var mDownDY:Float;
   public var iconWidget:Image;
   var mCurrentDX:Float;
   var mCurrentDY:Float;
   //public var onCurrentChangedFunc:Bool->Void;

   public function new(?inObject:DisplayObject,?inOnClick:Void->Void, ?inLineage:Array<String>, ?inAttribs:{})
   {
      super( Widget.addLine(inLineage,"Button"), inAttribs);
      var offset = mRenderer.offset;
      mDownDX = offset.x;
      mDownDY = offset.y;

      mCallback = inOnClick;
      if (mCallback==null)
         mCallback = mRenderer.getDynamic("onClick");

      mDisplayObj = inObject;
      mCurrentDX = mCurrentDY = 0;
      noFocus = false;
      mouseChildren = false;
      isToggle = attribBool("toggle",false);
      addEventListener(MouseEvent.MOUSE_DOWN, onDown );
      addEventListener(MouseEvent.MOUSE_OUT, onOut );
      addEventListener(MouseEvent.MOUSE_UP, onUp );

      if (mDisplayObj!=null)
      {
         var layout:Layout = null;
         addChild(mDisplayObj);
         if (Std.isOfType(mDisplayObj,Widget))
         {
            var widget:Widget = cast mDisplayObj;
            layout = widget.getLayout();
         }
         else
         {
            var objSize:Dynamic = attrib("objectSize");
            if (objSize!=null)
            {
               if (Std.isOfType(objSize,Float))
               {
                   mDisplayObj.width = mDisplayObj.height = (objSize:Float);
               }
               else
               {
                  var s:Size = cast objSize;
                  if (s!=null)
                  {
                     mDisplayObj.width = s.x;
                     mDisplayObj.height = s.y;
                  }
               }
            }
            if ( Std.isOfType(mDisplayObj,TextField))
            {
               var tf = cast mDisplayObj;
               layout = new AutoTextLayout(tf);
               name += " " +tf.text;
            }
            else
            {
               layout = new DisplayLayout(mDisplayObj);
            }
         }
         layout.mDebugCol = 0x00ff00;
         layout.name = "ButtonInner";
         setItemLayout(layout);
         getLayout().name="Button Outer";
      }
      else
      {
         var contents:String = attribString("contents","icon-text");
         var icon:BitmapData = contents.indexOf("icon")>=0 ? getBitmap(0) : null;
         var text:String = contents.indexOf("text")>=0 ? attrib("text") : null;
         var items = (icon!=null ? 1:0) + (text!=null ? 1:0);
         if (items>0)
         {
            var textStyle = attribDynamic("textStyle",{});
            var textLineage = attribDynamic("textLineage",[]);
            var textWidget = (text==null) ? null : new TextLabel(text,textLineage,textStyle);
            iconWidget = (icon==null) ? null : new Image(icon);
            if (items==1)
            {
               addChild(mDisplayObj = (textWidget!=null ? textWidget : iconWidget) );
               setItemLayout((textWidget!=null ? (textWidget:Widget) : (iconWidget:Widget)).getLayout());
            }
            else
            {
               addChild(iconWidget);
               addChild(textWidget);
               var layout = contents.indexOf("-") >= 0 ? new HorizontalLayout() : new VerticalLayout();
               if (contents.indexOf("icon")<contents.indexOf("text"))
               {
                  layout.add(iconWidget.getLayout().setAlignment(Layout.AlignCenter));
                  layout.add(textWidget.getLayout().setAlignment(Layout.AlignCenter));
               }
               else
               {
                  layout.add(textWidget.getLayout().setAlignment(Layout.AlignCenter));
                  layout.add(iconWidget.getLayout().setAlignment(Layout.AlignCenter));
               }
               setItemLayout(layout);
            }
         }
      }

      //build();

      applyStyles();
      if (isToggle && attribBool("down",false))
         down = true;
   }

   override public function redraw()
   {
      var bmpName = attribString("bitmapId",name);
      if (mStateBitmap!=null)
         mStateBitmap.bitmapData = mRenderer.getBitmap(bmpName,state);
      else if (iconWidget!=null)
         iconWidget.bitmapData = mRenderer.getBitmap(bmpName,state);
      super.redraw();
   }


   public static function create(?inLineage:Array<String>, ?inAttribs:Dynamic,?inOnClick:Void->Void)
   {
      return new Button(null,inOnClick,inLineage,inAttribs);
   }

   override function widgetClick(e:MouseEvent)
   {
      if (mouseHandler!=null && !mouseHandler(name,e))
         return;
      if (mCallback!=null && !isToggle)
         mCallback();
      e.stopImmediatePropagation();
   }


   function onOut(e:MouseEvent)
   {
      if (!isToggle)
         set_down(false);
   }

   function onDown(e:MouseEvent)
   {
      if (mouseHandler!=null && !mouseHandler(name,e))
         return;
      if (disabled)
         return;
      if (isToggle)
      {
         set_down(!get_down());
         if (mCallback!=null)
            mCallback();
      }
      else
         set_down(true);

     //e.stopImmediatePropagation();
   }
   function onUp(e:MouseEvent)
   {
      // Mouse left, and came back
      if (!isToggle && !get_down())
      {
         e.stopImmediatePropagation();
         e.cancelClick = true;
         return;
      }
      if (mouseHandler!=null && !mouseHandler(name,e))
         return;
      if (!isToggle)
         set_down(false);
   }

   public function getInnerLayout()
   {
      getLayout();
      return mItemLayout;
   }

   override public function getLabel() : TextField
   { 
      if (mDisplayObj!=null && Std.isOfType(mDisplayObj,TextField))
         return cast mDisplayObj;
      return null;
   }

   override public function set_down(inDown:Bool) : Bool
   {
      if (inDown!=down)
      {
         state = state ^ Widget.DOWN;

         if (mDisplayObj!=null)
         {
            var dx = inDown ? mDownDX : 0;
            var dy = inDown ? mDownDY : 0;
            if (dx!=mCurrentDX)
            {
               mDisplayObj.x += dx-mCurrentDX;
               mCurrentDX = dx;
            }
            if (dy!=mCurrentDY)
            {
               mDisplayObj.y += dy-mCurrentDY;
               mCurrentDY = dy;
            }
         }

         if (inDown && attribBool("raiseOnDown") && parent!=null)
            parent.addChild(this);
      }
      return inDown;
   }

   public function scaleDisplayObject(scale:Float)
   {
      mDisplayObj.scaleX = mDisplayObj.scaleY = scale;
   }

   override public function setBitmap(inBmp:BitmapData)
   {
      setIcon(inBmp);
   }

   public function setIcon(inBmp:BitmapData)
   {
      if (Std.isOfType(mDisplayObj,Bitmap))
      {
         var bitmap : Bitmap = cast mDisplayObj;
         bitmap.bitmapData = inBmp;
      }
      else
      {
         setAttrib("icon",inBmp);
         redraw();
      }
   }


   public static function BMPButton(inBitmapData:BitmapData,?inOnClick:Void->Void, ?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      var bmp = new Bitmap(inBitmapData);
      var result = new Button(bmp,inOnClick,Widget.addLine(inLineage,"BitmapButton"), inAttribs);
      bmp.smoothing = result.attribBool("smooth",false);
      return result;
   }

   public static function BitmapButton(inBitmapData:BitmapData,?inOnClick:Void->Void, ?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      var bmp = new Bitmap(inBitmapData);
      var result = new Button(bmp,inOnClick, Widget.addLine(inLineage,"BitmapButton"), inAttribs);
      bmp.smoothing = result.attribBool("smooth",false);
      return result;
   }


   public static function TextButton(?inSkin:Skin, inText:String,inOnClick:Void->Void,?inLineage:Array<String>, ?inArrtibs:Dynamic)
   {
      var skin = Skin.getSkin(inSkin);
      //var label = new TextLabel(inText, ["ButtonText","StaticText","Text"]);
      var renderer = skin.renderer(Widget.addLines(inLineage,["ButtonText","Button","StaticText","Text"]),0,inArrtibs);
      var label = new TextField();
      label.text = inText;
      renderer.renderLabel(label);
      label.selectable = false;
      //label.border = true;
      //label.borderColor = 0x0000ff;
      var result =  new Button(label,inOnClick,Widget.addLine(inLineage,"TextButton"),inArrtibs);
      return result;
   }

   public static function BMPTextButton(inBitmapData:BitmapData,inText:String, ?inOnClick:Void->Void,?inLineage:Array<String>,?attribs:{})
   {
      var result = new Button(null,inOnClick,Widget.addLine(inLineage,"BMPTextButton"),
          Widget.addAttribs(attribs,{icon:inBitmapData, text:inText}) );
      return result;
   }

/*
   override public function onCurrentChanged(inCurrent:Bool)
   {
      if (onCurrentChangedFunc!=null)
         onCurrentChangedFunc(inCurrent);
      else
         super.onCurrentChanged(inCurrent);
   }
*/

   override public function activate()
   {
      if (isToggle)
         set_down(!get_down());
      if (mCallback!=null)
      {
         mCallback();
      }
      if (mouseHandler!=null)
      {
         var fakeEvent = new MouseEvent(MouseEvent.CLICK,true,false,0,0,this);
         #if !flash
         fakeEvent.target = this;
         #end
         mouseHandler(name,fakeEvent);
      }
   }
}

class BmpButton extends Button
{
   public var bitmap(default,null):Bitmap;
   public var normal:BitmapData;
   public var disabledBmp:BitmapData;
   var wasEnabled = true;

   public function new(inBitmapData:BitmapData,?inOnClick:Void->Void,?inLineage:Array<String>,?inAttribs:Dynamic)
   {
      normal = inBitmapData;
      bitmap = new Bitmap(normal);
      super(bitmap,inOnClick,inLineage,inAttribs);
      bitmap.name="BmpButton";
   }

   public function createDisabled(inBmp:BitmapData)
   {
      var w = inBmp.width;
      var h = inBmp.height;
      var result = new BitmapData(w,h,true,gm2d.RGB.CLEAR);

      for(y in 0...h)
         for(x in 0...w)
         {
            var pix:Int = inBmp.getPixel32(x,y);
            var val:Int = (pix&0xff) + ( (pix>>8)&0xff ) + ( (pix>>16)&0xff ); 
            if (val<255) val=0;
            else if (val>512) val = 255;
            else val = 128;
            val = (val * 0x10101) | (pix&0xff000000);
            result.setPixel32(x,y,val);
         }

      return result;
   }

   override function rebuildState(?wasCurrent:Bool)
   {
      if (wasEnabled!=enabled)
      {
         wasEnabled = enabled;
         mouseEnabled = enabled;

         if (enabled)
            bitmap.bitmapData = normal;
         else
         {
            if (disabledBmp==null)
               disabledBmp = createDisabled(normal);
            bitmap.bitmapData = disabledBmp;
         }
      }
      super.rebuildState(wasCurrent);
   }

   public function enable(inEnable:Bool)
   {
      enabled = inEnable;
   }
}

