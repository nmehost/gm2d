package gm2d.skin;

import gm2d.ui.HitBoxes;
import gm2d.ui.Widget;
import gm2d.ui.Button;
import gm2d.ui.IDockable;
import gm2d.ui.Size;
import gm2d.ui.Pane;
import gm2d.ui.Dock;
import gm2d.ui.MultiDock;
import gm2d.ui.SideDock;
import gm2d.ui.DockZones;
import gm2d.ui.DockPosition;
import gm2d.ui.WidgetState;
import nme.filters.BitmapFilter;
import nme.filters.BitmapFilterType;
import nme.filters.DropShadowFilter;
import nme.filters.GlowFilter;
import nme.display.Sprite;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Shape;
import nme.display.Graphics;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.text.TextFormat;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import gm2d.ui.Layout;
import gm2d.ui.Slider;
import gm2d.ui.Widget;

import gm2d.skin.FillStyle;
import gm2d.skin.LineStyle;
import gm2d.skin.BitmapStyle;
import gm2d.skin.Style;

import nme.display.SimpleButton;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;
import gm2d.CInt;



typedef AttribSet = Array<RenderAttribs>;

class Skin
{
   // You can use these to set the defaults before you create a Widget
   public static var roundRectRad = 6.0;
   public static var guiLight = 0xf0f0e0;
   public static var guiMedium = 0xe0e0d0;
   public static var guiDark = 0xa0a090;
   public static var guiDisabled = 0x808080;
   public static var guiBorder = 0x000000;
   public static var textFormat:nme.text.TextFormat;


   public static var controlBorder = 0x000000;
   public static var centerTitle = true;
   public static var buttonBorderX = 10;
   public static var buttonBorderY = 5;
   public static var mdiBGColor = 0x404040;
   public static var labelColor = 0x000000;
   public static var panelColor = guiMedium;
   public static var controlColor = guiLight;
   public static var disableColor = 0x808080;
   public static var tabGradientColor = 0x909080;
   public static var menuHeight:Float = 22;


   public static var mBitmaps:Map<String,BitmapData>;


   public static var sliderRenderer:SliderRenderer;
   public static var defaultTabRenderer:TabRenderer;

   public static var tabHeight:Int = 24;
   public static var title_h:Int = 22;
   public static var borders:Int = 3;

   public static var mDrawing:Shape;
   public static var mText:TextField;

   public static inline var TOOLBAR_GRIP_TOP = 0x0001;
   public static inline var SHOW_COLLAPSE    = 0x0002;
   public static inline var SHOW_EXPAND      = 0x0004;

   public static var attribSet:AttribSet;
   public static var idAttribs:Map<String,AttribSet>;

   public static var doInit:Dynamic = init();
   public static function init()
   {
      menuHeight = 22;
      var titleHeight = 26;

      mBitmaps = new Map<String, BitmapData>();
      textFormat = new TextFormat();
      textFormat.size = 14;
      textFormat.font = "Arial";
      textFormat.color = 0x000000;


      initGfx();

      idAttribs = new Map<String,AttribSet>();
      attribSet = [];
      addAttribs("Button", null, {
          style: StyleRoundRect,
          fill: FillLight,
          line: LineBorder,
          padding: new Rectangle(buttonBorderX,buttonBorderY,buttonBorderX*2,buttonBorderY*2),
          offset: new Point(1,1),
        });
      addAttribs("ToggleButton", null, {
         offset: new Point(0,0)
        });
      addAttribs("SimpleButton", null, {
          offset: new Point(0,0),
          line: LineNone,
          fill: FillNone,
          style: StyleRect,
          padding: new Rectangle(2,2,4,4),
        });
      addAttribs("SimpleButton", Widget.DOWN, {
          line: LineBorder,
        });
      addAttribs("Dock", null, {
          style: StyleRect,
          fill: FillMedium,
          padding: null,
        });
      addAttribs("UiButton", null, {
          style: StyleNone,
          bitmap: BitmapFactory(DefaultBitmaps.factory),
        });
      addAttribs("Frame", null, {
          style: Style.StyleCustom(renderDialog),
          padding: new Rectangle(borders, borders+titleHeight, borders*2, borders*2+titleHeight),
        });
      addAttribs(null, Widget.DOWN, {
          fill: FillMedium,
        });
      addAttribs(null, Widget.DISABLED, {
          fill: FillDisabled,
        });


      sliderRenderer = createSliderRenderer();
      defaultTabRenderer = createTabRenderer();

      return null;
   }

   public static function addId(inId:String, inState:Null<Int>, inAttribs:Dynamic)
   {
      var attribs = idAttribs.get(inId);
      if (attribs==null)
         idAttribs.set( inId, attribs = new AttribSet() );
      
      attribs.push( new RenderAttribs(null, inState, inAttribs) );
   }

   public static function addAttribs(inLine:String, inState:Null<Int>, inAttribs:Dynamic)
   {
      attribSet.push( new RenderAttribs(inLine, inState, inAttribs) );
   }

   public static function replaceAttribs(inLine:String, inState:Null<Int>, inAttribs:Dynamic)
   {
      var idx = 0;
      for(idx in 0...attribSet.length)
      {
         if (attribSet[idx].line == inLine && attribSet[idx].state==inState)
         {
            attribSet[idx] = new RenderAttribs(inLine,inState,inAttribs);
            return;
         }
      }
      addAttribs(inLine,inState,inAttribs);
   }



   public static function hasLineage(inLineage:Array<String>, inClassName)
   {
      for(line in inLineage)
         if (inClassName==line)
            return true;
      return false;
   }

   public static function dockRenderer(inLineage:Array<String>, ?inAttribs:Dynamic) : DockRenderer
   {
      return new DockRenderer(hasLineage(inLineage,"VariableWidth"));
   }

   public static function tabRenderer(inLineage:Array<String>, ?inAttribs:Dynamic) : TabRenderer
   {
      return defaultTabRenderer;
   }

   public static function renderer(inLineage:Array<String>,inState:Int=0, ?inAttribs:Dynamic) : Renderer
   {
       var map = new Map<String,Dynamic>();
       for(attrib in attribSet)
          if (attrib.matches(inLineage,inState))
             attrib.merge(map);
       if (inAttribs!=null && Reflect.hasField(inAttribs,"id"))
       {
          var id = Reflect.field(inAttribs,"id");
          var attribs = idAttribs.get(id);
          if (attribs!=null)
             for(attrib in attribs)
                if (attrib.matches(inLineage,inState))
                   attrib.merge(map);
       }
       mergeAttribMap(map,inAttribs);

       return new Renderer(map);
   }


   public static function createSliderRenderer()
   {
      var result = new SliderRenderer();
      result.onCreate = onCreateSlider;
      result.onRender = onRenderSlider;
      return result;
   }
   public static function createTabRenderer()
   {
      var result = new TabRenderer();
      return result;
   }



/*
   static public function renderBmpBackground(widget:Widget, up:BitmapData, down:BitmapData)
   {
      var bmp = widget.down ? down : up;
      if (bmp!=null)
      {
          var gfx = widget.mChrome.graphics;
          gfx.beginBitmapFill(bmp,null,true,true);
          gfx.drawRect(0,0,bmp.width,bmp.height);
      }
   }

   static public function layoutBmpBackground(widget:Widget, up:BitmapData, down:BitmapData)
   {
      var w = up!=null ? up.width : down==null? down.width : 32;
      var h = up!=null ? up.height : down==null? down.height : 32;
      var layout = widget.getLayout();
      layout.setMinSize(w,h);
      widget.getItemLayout().setAlignment(Layout.AlignCenter);
   }
*/

   public static function onCreateSlider(inSlider:Slider):Void
   {
      var layout = inSlider.getItemLayout();
      layout.setMinSize(120,20);

      inSlider.mThumb = new Sprite();
      var gfx = inSlider.mThumb.graphics;
      gfx.beginFill(controlColor);
      gfx.lineStyle(1,controlBorder);
      gfx.drawRect(-10,0,20,20);
      inSlider.getItemLayout().onLayout = function(inX:Float,inY:Float,inW:Float,inH:Float)
      {
          inSlider.mSliderRenderer.onRender( inSlider, new Rectangle(inX,inY,inW,inH) );
          inSlider.mSliderRenderer.onPosition(inSlider);
      };
   }

   public static function onRenderSlider(inSlider:Slider, inRect:Rectangle):Void
   {
      inSlider.mX0 = 10;
      inSlider.mX1 = inRect.width-10;

      var gfx = inSlider.mTrack.graphics;
      gfx.clear();
      gfx.beginFill(disableColor);
      gfx.lineStyle(1,controlBorder);
      gfx.drawRect(10,0,inRect.width-20,inRect.height);

      var gfx = inSlider.mThumb.graphics;
      gfx.clear();
      gfx.beginFill(controlColor);
      gfx.lineStyle(1,controlBorder);
      gfx.drawRect(-inRect.height/2,0,inRect.height,inRect.height);
   }


   public static function fromSvg(inSvg:Svg)
   {
      if (inSvg.hasGroup("dialog"))
         replaceAttribs("Frame", null, SvgSkin.createFrameRenderer(inSvg,"dialog") );
      if (inSvg.hasGroup("slider"))
         sliderRenderer = SvgSkin.createSliderRenderer(inSvg,"slider");
      if (inSvg.hasGroup("button"))
         replaceAttribs("Button", null, SvgSkin.createButtonRenderer(inSvg,"button") );
   }


   public static function getTextFormat()
   {
      var fmt = new TextFormat();
      fmt.size = textFormat.size;
      fmt.font = textFormat.font;
      fmt.color = textFormat.color;
      return fmt;
   }


   public static function renderCurrent(inWidget:Widget)
   {
      var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 3, 3, false, false);
      inWidget.filters = [ glow ];
   }
   public static function clearCurrent(inWidget:Widget)
   {
      inWidget.filters = null;
   }

   public static function renderMenubar(inObject:Sprite,inW:Float, inH:Float)
   {
      var gfx = inObject.graphics;
      gfx.clear();
      var mtx = new nme.geom.Matrix();
      mtx.createGradientBox(inH,inH,Math.PI * 0.5);
      var cols:Array<CInt> = [guiLight, guiMedium, guiDark];
      var alphas:Array<Float> = [1.0, 1.0, 1.0];
      var ratio:Array<Int> = [0, 128, 255];
      gfx.beginGradientFill(nme.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,inW,inH);
   }

   public static function styleMenu(inItem:Button)
   {
      inItem.getLabel().backgroundColor = 0x4040a0;
      inItem.getLabel().textColor = 0x000000;
      inItem.onCurrentChangedFunc = function(_) { };
   }

   public static function styleLabel(label:TextField)
   {
      label.defaultTextFormat = textFormat;
      label.textColor = labelColor;
      if (label.type != nme.text.TextFieldType.INPUT)
      {
         label.autoSize = TextFieldAutoSize.LEFT;
         label.selectable = false;
      }
      //label.mouseEnabled = false;
   }

/*
   public function stylePane(inGfx:Graphics, inRect:Rectangle)
   {
      inGfx.clear();
      inGfx.beginFill(panelColor);
      inGfx.drawRect(inRect.x, inRect.y, inRect.w, inRect.h );
   }
*/

   public static function styleText(inText:nme.text.TextField)
   {
      inText.defaultTextFormat = textFormat;
   }

   public static function getChromeRect(inDocked:IDockable,inTopGrip:Bool) : Rectangle
   {
      var pane = inDocked.asPane();
      if (pane!=null)
      {
         if (Dock.isToolbar(pane))
         {
            if (inTopGrip)
               return new Rectangle(2,8,4,10);
            else
               return new Rectangle(8,2,10,4);
         }
         else
            return new Rectangle(2,22,4,24);
      }
      return new Rectangle(0,0,0,0);
   }

   public static function getMultiDockChromePadding(inN:Int,tabStyle:Bool) : Size
   {
      return new Size(0,tabStyle ? tabHeight : inN*24);
   }


   public static function renderToolbarGap(inContainer:Sprite,inX:Float, inY:Float, inW:Float, inH:Float)
   {
      var gfx = inContainer.graphics;
      gfx.lineStyle();
      gfx.beginFill(panelColor);
      gfx.drawRect(inX,inY,inW,inH);
      gfx.endFill();
   }

   public static function renderPaneChrome(inPane:Pane,inContainer:Sprite,outHitBoxes:HitBoxes,inRect:Rectangle,inFlags:Int):Void
   {
      var gfx = inContainer.graphics;
      gfx.lineStyle();
      gfx.beginFill(panelColor);
      gfx.drawRect(inRect.x,inRect.y,inRect.width,inRect.height);
      gfx.endFill();
      gfx.lineStyle(1,0x000000);
      if (Dock.isToolbar(inPane))
      {
         var px = inPane.sizeX;
         var py = inPane.sizeY;
         if ( (inFlags & TOOLBAR_GRIP_TOP) != 0 )
         {
            outHitBoxes.add(new Rectangle(inRect.x+1, inRect.y+1, px+4, 6), TITLE(inPane) );
            gfx.drawRect(inRect.x+1.5,inRect.y+1.5,px+2,py+8);

            gfx.moveTo(inRect.x+4.5,inRect.y+4.5);
            gfx.lineTo(inRect.x+px+0.4,inRect.y+4.5);
            gfx.moveTo(inRect.x+4.5,inRect.y+6.5);
            gfx.lineTo(inRect.x+px+0.5,inRect.y+6.5);
         }
         else
         {
            outHitBoxes.add(new Rectangle(inRect.x+1, inRect.y+1, 6, py+4), TITLE(inPane) );
            gfx.drawRect(inRect.x+1.5,inRect.y+1.5,px+8,py+2);

            gfx.moveTo(inRect.x+4.5,inRect.y+4.5);
            gfx.lineTo(inRect.x+4.5,inRect.y+py+0.5);
            gfx.moveTo(inRect.x+6.5,inRect.y+4.5);
            gfx.lineTo(inRect.x+6.5,inRect.y+py+0.5);
         }
      }
      else
      {
         gfx.drawRect(inRect.x+1.5,inRect.y+21.5,inRect.width-2,inRect.height-23);
         gfx.lineStyle();
         gfx.beginFill(panelColor);
         gfx.drawRect(inRect.x,inRect.y,inRect.width,inRect.height);

         /*
         var mtx = new nme.geom.Matrix();
         mtx.createGradientBox(21,21, Math.PI*-0.5, inRect.x+1.5, inRect.y+1.5);
         var cols:Array<Int> = [guiLight, guiMedium, guiDark];
         var alphas:Array<Float> = [1.0, 1.0, 1.0];
         var ratio:Array<Int> = [0, 128, 255];
         gfx.beginGradientFill(nme.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
         */
         gfx.beginFill(guiDark);
         //gfx.drawRoundRect(inRect.x+1, inRect.y+2, inRect.width-2, 20, 8,8);
         gfx.drawRect(inRect.x+1, inRect.y, inRect.width-2, 21);
         gfx.endFill();
 
         var w = inRect.width;
         var flags = [ SHOW_COLLAPSE, SHOW_EXPAND ];
         var buts = [MiniButton.MINIMIZE, MiniButton.MAXIMIZE ];
         for(i in 0...2)
            if ( (inFlags&flags[i])!=0 )
            {
               var but = buts[i];
               /*
               var state = getButtonBitmap(but,HitBoxes.BUT_STATE_UP);
               var button = new SimpleButton( state,
                                  getButtonBitmap(but,HitBoxes.BUT_STATE_OVER),
                                  getButtonBitmap(but,HitBoxes.BUT_STATE_DOWN), state );
               */
               var button =  Button.create(["PaneButton", "UiButton"], { id:but });

               inContainer.addChild(button);
               button.x = inRect.x + w - 16 - 2;
               w-=16+2;
               button.y = Std.int( inRect.y + 1);

               if (outHitBoxes.mCallback!=null)
                  button.addEventListener( MouseEvent.CLICK,
                     function(e) outHitBoxes.mCallback( BUTTON(inPane,but), e ) );
            }

         var text = new TextField();
         styleText(text);
         text.selectable = false;
         text.mouseEnabled = false;
         text.text = inPane.shortTitle;
         text.x = inRect.x+2;
         text.y = inRect.y+2;
         text.width = w-4;
         text.height = inRect.height-4;
         inContainer.addChild(text);

         outHitBoxes.add(new Rectangle(inRect.x+2, inRect.y+2, w-4, 18), TITLE(inPane) );
      }

   }

   public static function renderResizeBars(inDock:SideDock,inContainer:Sprite,outHitBoxes:HitBoxes,inRect:Rectangle,inHorizontal:Bool,inSizes:Array<Float>):Void
   {
      var gfx = inContainer.graphics;
      //gfx.lineStyle();
      gfx.beginFill(panelColor);
      var gap = getResizeBarWidth();
      var extra = 2;
      var pos = 0.0;
      for(p in 0...inSizes.length-1)
      {
         pos += inSizes[p];
         if (inHorizontal)
         {
            gfx.drawRect(inRect.x+pos, inRect.y,gap,inRect.height);
            outHitBoxes.add( new Rectangle(inRect.x+pos-extra, inRect.y,gap+extra*2,inRect.height), DOCKSIZE(inDock,p) );
         }
         else
         {
            gfx.drawRect(inRect.x, inRect.y+pos,inRect.width,gap);
            outHitBoxes.add( new Rectangle(inRect.x, inRect.y+pos-extra,inRect.width,gap+extra*2), DOCKSIZE(inDock,p) );
         }
         pos += gap;
      }
   }


   public static function addResizeDockZones(outZones:DockZones,inRect:Rectangle,inHorizontal:Bool,inSizes:Array<Float>, inOnDock:IDockable->Int->Void ):Void
   {
      var gfx = outZones.container.graphics;
      //gfx.lineStyle();
      gfx.lineStyle(1,0x0000ff,0.5);
      var gap = getResizeBarWidth();
      var extra = 2;
      var pos = 0.0;
      var r:Rectangle = null;

      if (inHorizontal)
         r = new Rectangle(inRect.x+pos, inRect.y,8,inRect.height);
      else
         r = new Rectangle(inRect.x, inRect.y+pos,inRect.width,8);
      var over = r.contains(outZones.x,outZones.y);
      if (over)
      {
         gfx.beginFill(0x0000ff,over ? 0.5 : 0.25);
         gfx.drawRect(r.x, r.y, r.width, r.height );
         outZones.addRect( r, function(d) inOnDock(d,0) );
      }
 
 

      for(p in 0...inSizes.length-1)
      {
         pos += inSizes[p];
         if (inHorizontal)
            r = new Rectangle(inRect.x+pos-2, inRect.y,gap+4,inRect.height);
         else
            r = new Rectangle(inRect.x, inRect.y+pos-2,inRect.width,gap+4);
         
         var over = r.contains(outZones.x,outZones.y);
         if (over)
         {
            gfx.beginFill(0x0000ff,over ? 0.5 : 0.25);
            gfx.drawRect(r.x, r.y, r.width, r.height );
            outZones.addRect( r, function(d) inOnDock(d,p+1) );
         }
         pos += gap;
      }

      if (inHorizontal)
         r = new Rectangle(inRect.right-4, inRect.y,4,inRect.height);
      else
         r = new Rectangle(inRect.x, inRect.bottom-4,inRect.width,4);
      var over = r.contains(outZones.x,outZones.y);
      if (over)
      {
         gfx.beginFill(0x0000ff,over ? 0.5 : 0.25);
         gfx.drawRect(r.x, r.y, r.width, r.height );
         outZones.addRect( r, function(d) inOnDock(d,inSizes.length) );
      }
 
   }


   static function clearSprite(outSprite:Sprite)
   {
      outSprite.graphics.clear();
      while(outSprite.numChildren>0)
         outSprite.removeChildAt(0);
   }


/*
   public static function renderButton(inWidget:Widget)
   {
      var gfx = inWidget.mChrome.graphics;
      gfx.beginFill(inWidget.disabled ? disableColor :
                    inWidget.state==0 ? controlColor :
                                        guiMedium );
      gfx.lineStyle(1,controlBorder);
      var r = inWidget.mRect;
      gfx.drawRoundRect(r.x+0.5,r.y+0.5,r.width-1,r.height-1,roundRectRad,roundRectRad);
   }
*/
    public static function renderProgressBar(inGfx:Graphics, inWidth:Float, inHeight:Float, inFraction:Float)
   {
      inGfx.clear();
      inGfx.beginFill(0xffffff);
      inGfx.lineStyle(1,0x000000);
      inGfx.drawRoundRect(0.5,0.5,inWidth,inHeight,6,6);
      inGfx.lineStyle();
      inGfx.beginFill(0x2020ff);
      inGfx.drawRoundRect(0.5,0.5,inWidth*inFraction,inHeight,6,6);
   }

   public static function renderDialog(widget:Widget)
   {
      var outHitBoxes = widget.getHitBoxes();
      var rect = widget.mRect;
      var pane = widget.getPane();
      outHitBoxes.clear();
      clearSprite(widget.mChrome);

      var ox = rect.x+0.5;
      var oy = rect.y+0.5;
      var w = rect.width;
      var h = rect.height;

      var titleWidth = rect.width;

      var gfx = widget.mChrome.graphics;
      gfx.clear();
      gfx.beginFill(panelColor);
      gfx.lineStyle(1,guiDark);

      gfx.drawRoundRect(ox,ox,w, h, 7,7 );

      if ( Dock.isResizeable(pane) )
      {
         gfx.endFill();
         for(o in 0...4)
         {
            var dx = (o+2)*3;
            gfx.moveTo(w-dx,h);
            gfx.lineTo(w,h-dx);
         }
         outHitBoxes.add( new Rectangle(w-12,h-12,12,12), HitAction.RESIZE(pane, ResizeFlag.S|ResizeFlag.E) );
      }

      /*
      if (false)
      {
         var but = MiniButton.CLOSE;
         var state =  getButtonBitmap(but,HitBoxes.BUT_STATE_UP);
         var button =  new SimpleButton( state,
                                        getButtonBitmap(but,HitBoxes.BUT_STATE_OVER),
                                        getButtonBitmap(but,HitBoxes.BUT_STATE_DOWN), state );
         widget.mChrome.addChild(button);
         button.y = Std.int( (title_h - button.height)/2 );
         titleWidth -= button.width + 2;
         button.x = titleWidth;

         if (outHitBoxes.mCallback!=null)
            button.addEventListener( MouseEvent.CLICK,
               function(e) outHitBoxes.mCallback( BUTTON(pane,but), e ) );
      }
      */

      var title = pane==null ? "" : pane.title;
      if (title!="")
      {
         var titleField = new TextField();
         titleField.defaultTextFormat = textFormat;
         var f = titleField.defaultTextFormat;
         f.size = 16;
         titleField.defaultTextFormat = f;
         titleField.mouseEnabled = false;
         titleField.textColor = 0x000000;
         titleField.selectable = false;
         titleField.text = title;
         titleField.autoSize = nme.text.TextFieldAutoSize.LEFT;
         titleField.y = 2;

         //var f:Array<BitmapFilter> = [];
         //f.push( new DropShadowFilter(2,45,0xffffff,1,0,0,1) );
         //titleField.filters = f;

         widget.mChrome.addChild(titleField);

         if (centerTitle)
            titleField.x = ox + Std.int((titleWidth-titleField.textWidth)/2);
      }

      outHitBoxes.add( new Rectangle(ox,ox,w,title_h), TITLE(pane) );
   }


   public static function renderMDI(inMDI:Sprite)
   {
      var gfx = inMDI.graphics;
      gfx.clear();
      var rect = inMDI.scrollRect;
      if (rect!=null)
      {
         gfx.beginFill(mdiBGColor);
         gfx.drawRect(rect.x, rect.y, rect.width, rect.height );
      }
   }

/*
   public static function getButtonBitmapData(inButton:String, inState:Int) : BitmapData
   {
      var key = inButton + ":" + inState;
      if (!mBitmaps.exists(key))
         mBitmaps.set(key,createButtonBitmap(inButton,inState));
      return mBitmaps.get(key);
   }

   public static function getButtonBitmap(inButton:String, inState:Int) : Bitmap
   {
      return new Bitmap(getButtonBitmapData(inButton,inState));
   }
*/

   public static function getFrameClientOffset() : Point
   {
      return new Point(borders,borders+title_h);
   }
   public static function getMiniWinClientOffset() : Point
   {
      return new Point(borders,borders);
   }
   public static function getMinFrameWidth() : Float
   {
      return 80;
   }
   public static function getResizeBarWidth() : Float
   {
      return 2;
   }
   public static function getSideBorder() : Float
   {
      return 0;
   }




   public static function renderFrame(inObj:Sprite, pane:IDockable, inW:Float, inH:Float,
             outHitBoxes:HitBoxes,inIsCurrent:Bool)
   {
      outHitBoxes.clear();

      var gfx = inObj.graphics;
      gfx.clear();

      var w = inW+borders*2;
      var h = inH+borders*2+title_h;
      var x = inW - borders;

      gfx.beginFill(panelColor);
      gfx.drawRoundRect(0.5,0.5,w, h, 3,3 );

      if (inIsCurrent)
      {
         var mtx = new nme.geom.Matrix();
         mtx.createGradientBox(title_h+borders,title_h+borders,Math.PI * 0.5);
         var cols:Array<CInt> = [guiLight, guiMedium, guiDark];
         var alphas:Array<Float> = [1.0, 1.0, 1.0];
         var ratio:Array<Int> = [0, 128, 255];
         gfx.beginGradientFill(nme.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      }
      else
      {
         gfx.beginFill(guiDark);
      }

      gfx.drawRoundRect(0.5,0.5,w, title_h, 3,3 );
      gfx.endFill();
      if (inIsCurrent)
         gfx.lineStyle(2,guiLight);
      else
         gfx.lineStyle(2,guiDark);

      gfx.drawRoundRect(0.5,0.5,w, h, 3,3 );
      if ( Dock.isResizeable(pane))
      {
         gfx.lineStyle(1,guiDark);
         for(o in 0...4)
         {
            var dx = (o+2)*3;
            gfx.moveTo(w-dx,h);
            gfx.lineTo(w,h-dx);
         }
         outHitBoxes.add( new Rectangle(w-12,h-12,12,12), HitAction.RESIZE(pane, ResizeFlag.S|ResizeFlag.E) );
      }


      for(but in [ MiniButton.CLOSE, MiniButton.MINIMIZE, MiniButton.MAXIMIZE ] )
      {
         var button =  Button.create(["PaneButton", "UiButton"], { id:but });
         /*
         var state =  getButtonBitmap(but,HitBoxes.BUT_STATE_UP);
         var button =  new SimpleButton( state,
                                        getButtonBitmap(but,HitBoxes.BUT_STATE_OVER),
                                        getButtonBitmap(but,HitBoxes.BUT_STATE_DOWN), state );
         */
         inObj.addChild(button);
         button.y = Std.int( (title_h - button.height)/2 );
         x-= button.width;
         button.x = x;

         if (outHitBoxes.mCallback!=null)
            button.addEventListener( MouseEvent.CLICK, function(e) outHitBoxes.mCallback( BUTTON(pane,but), e ) );
      }

      var titleBmp = new Bitmap();
      titleBmp.x = borders;
      titleBmp.y = borders;
      inObj.addChild(titleBmp);
      titleBmp.bitmapData = renderText(pane.getTitle(),pane.getShortTitle(),x-borders,  title_h-borders*2);

      if (centerTitle)
         titleBmp.x = Std.int((x-borders-titleBmp.width)/2);

      //trace("Title : " + inW + "x"  + title_h );
      outHitBoxes.add( new Rectangle(0,0,inW,title_h), TITLE(pane) );
   }

   public static function renderText(inText:String, inAltText:String,inWidth:Float, inHeight:Float)
   {
      mText.text = inText;
      var text_size = mText.textWidth;
      if (text_size>inWidth)
      {
         mText.text = inAltText;
         text_size = mText.textWidth;
      }

      var tw = Std.int(Math.min(text_size+0.99,inWidth));
      if (inText=="" || tw<1)
         return null;
      var bmp = new BitmapData(tw,Std.int(inHeight),true, gm2d.RGB.CLEAR );

      var mtx = new Matrix();
      mtx.tx = -2;
      mtx.ty = -2;

      if (tw>=text_size)
      {
         bmp.draw(mText,mtx);
      }
      else
      {
         mText.text = "...";
         var space = inWidth-mText.textWidth;

         var text = inAltText;
         var len = text.length;
         
         // Left align...
         var min=0;
         /*
         var min = 1;
         var max = text.length-1;
         while(min+1<max)
         {
            var mid = (min+max)>>1;
            mText.text = text.substr(mid);
            var diff =  mText.textWidth-space;
            if (diff==0)
            {
               min = mid;
               break;
            }
            else if (diff<0)
               max = mid;
            else
               min = mid;
         }
         */
         mText.text = "..." + text.substr(min);
         
         bmp.draw( mText, mtx );
      }

      return bmp;
   }


   public static function renderMiniWin(outChrome:Sprite, pane:Pane, inRect:Rectangle,outHitBoxes:HitBoxes,inFull:Bool)
   {
      var gfx = outChrome.graphics;
      gfx.clear();
      outHitBoxes.clear();

      gfx.beginFill(panelColor);
      gfx.lineStyle(1,0xffffff);
      while(outChrome.numChildren>0)
          outChrome.removeChildAt(0);
      outChrome.cacheAsBitmap = true;

      var x0 = inRect.x-2.5;
      var y0 = inRect.y-2.5;
      var rw = inRect.width;
      var rh = inRect.height;
      if (inFull)
      {
         var text = new TextField();
         styleLabel(text);
         text.text = pane.shortTitle;
         text.x = inRect.x+4;
         text.y = inRect.y+-18;
         outChrome.addChild(text);
         var w = text.textWidth;
         if (w>rw-10)
         {
            w = rw-10;
            text.width = w;
         }
         gfx.moveTo(x0,y0);
         gfx.lineTo(x0,y0-14);
         gfx.curveTo(x0,y0-18, x0+4, y0-18);
         gfx.lineTo(inRect.x+10+w, y0-18);
         gfx.curveTo(inRect.x+14+w,y0-18,inRect.x+14+w,y0-14);
         gfx.lineTo(inRect.x+14+w,y0);

         gfx.lineTo(inRect.x+rw+borders+0.5,y0);
         gfx.lineTo(inRect.x+rw+borders+0.5,rh+borders*2+y0);
         gfx.lineTo(x0,rh+borders*2+y0);
         gfx.lineTo(x0,y0);

         outHitBoxes.add( new Rectangle(inRect.x,inRect.y-title_h,w,title_h), TITLE(pane) );
      }
      else
      {
         gfx.drawRoundRect(x0,y0,rw+borders*2, rh+borders*2, 3,3 );
      }
      gfx.endFill();
   }



   static function initGfx()
   {
      if (mDrawing==null)
         mDrawing = new Shape();
      if (mText==null)
      {
         mText = new TextField();
         styleLabel(mText);
      }
   }

   public static function getMDIClientChrome() { return new Rectangle(0,tabHeight, 0, tabHeight); }

  

   public static function renderDropZone(inRect:Rectangle, outZones:DockZones, inPosition:DockPosition,
      inCentred:Bool, onDock:IDockable->Void):Void
   {
      var r:Rectangle = null;
      var x0 = Std.int(inRect.x) + 0.5;
      var y0 = Std.int(inRect.y) + 0.5;
      var showX = 0;
      var showY = 0;
      var showW = 32;
      var showH = 32;

      switch(inPosition)
      {
         case DOCK_LEFT:
            y0 = Std.int(inRect.y + inRect.height/2 - 16 ) + 0.5;
            if (inCentred)
               x0 = inRect.x +inRect.width*0.5 - 48 - 2;
            showW = 12;
         case DOCK_RIGHT:
            if (inCentred)
               x0 = inRect.x +inRect.width*0.5 + 16 + 2;
            else
               x0 = Std.int(inRect.right-32)-0.5;
            y0 = Std.int(inRect.y + inRect.height/2 - 16 ) + 0.5;
            showX = 20;
            showW = 12;
         case DOCK_TOP:
            if (inCentred)
               y0 = inRect.y +inRect.height*0.5 - 48 - 2;
            x0 = Std.int(inRect.x + inRect.width/2 - 16 ) + 0.5;
            showH = 12;
         case DOCK_BOTTOM:
            x0 = Std.int(inRect.x + inRect.width/2 - 16 ) + 0.5;
            if (inCentred)
               y0 = inRect.y +inRect.height*0.5 + 16 + 2;
            else
               y0 = Std.int(inRect.bottom-32)-0.5;
            showY = 20;
            showH = 12;
         case DOCK_OVER:
            if (!inCentred)
               return;

            x0 = inRect.x +inRect.width*0.5 - 16;
            y0 = inRect.y +inRect.height*0.5 - 16;
            showX = showY = 4;
            showW = showH = 24;
      }

      var gfx = outZones.container.graphics;
      var result = new Rectangle(x0,y0,32,32);
      if (result.contains(outZones.x,outZones.y))
      {
         gfx.lineStyle();
         gfx.beginFill(0x7070ff);
         gfx.drawRect(x0-4,y0-4,40,40);
      }
      gfx.beginFill(0xffffff);
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(x0,y0,32,32);
      gfx.beginFill(0x4040a0);
      gfx.drawRect(x0+showX,y0+showY,showW,showH);

      outZones.addRect(result, onDock);
   }


   static function mergeAttribMap(map:Map<String,Dynamic>, inAttribs:Dynamic)
   {
      if (inAttribs!=null)
         for(key in Reflect.fields(inAttribs))
             map.set(key, Reflect.field(inAttribs,key));
   }



   static function createAttribMap(inAttribs:Dynamic) : Map<String, Dynamic>
   {
      var result = new Map<String,Dynamic>();
      if (inAttribs!=null)
         for(key in Reflect.fields(inAttribs))
             result.set(key, Reflect.field(inAttribs,key));
      return result;
   }


}



