package gm2d.skin;

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
import gm2d.ui.HitBoxes;

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

   public static var rowSelectColour = 0xffd0d0f0;
   public static var rowEvenColour   = 0xffffffff;
   public static var rowOddColour    = 0xfff0f0ff;


   public static var shadowFilters:Array<BitmapFilter>;
   public static var currentFilters:Array<BitmapFilter>;
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
   public static var resolveAttribs: String->AttribSet = defaultResolveAttribs;

   public static var tabSize = 32;
   public static var dpiScale:Float = 0.0;
   public static var isInit:Bool = false;


   // Chrome Buttons
   public static inline var Close    = "#close";
   public static inline var Minimize = "#minimize";
   public static inline var Maximize = "#maximize";
   public static inline var Restore  = "#restore";
   public static inline var Popup    = "#popup";
   public static inline var Expand   = "#expand";
   public static inline var Pin      = "#pin";
   public static inline var Add      = "#add";
   public static inline var Remove   = "#remove";
   public static inline var Resize   = "#resize";
 


   public static function init(inForce:Bool = false)
   {
      if (isInit && !inForce)
         return;

      isInit = true;
      if (dpiScale==0.0)
      {
         dpiScale = nme.system.Capabilities.screenDPI;
         if (dpiScale>120)
            dpiScale /= 120;
         else
            dpiScale = 1.0;
      }

      if (textFormat==null)
      {
         textFormat = new TextFormat();
         textFormat.size = scale(14);
         textFormat.font = "Arial";
         textFormat.color = 0x000000;
      }

      if (shadowFilters==null)
      {
         shadowFilters = [ new DropShadowFilter(3,45,0,0.8,3,3,1) ];
      }
      if (currentFilters==null)
      {
         var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 3, 3, false, false);
         currentFilters = [ glow ];
      }

      if (sliderRenderer==null)
         sliderRenderer = createSliderRenderer();

      if (defaultTabRenderer==null)
         defaultTabRenderer = createTabRenderer();

      initGfx();

      if (idAttribs==null)
         idAttribs = new Map<String,AttribSet>();

      // Rebuild attribs from scratch
      attribSet = [];
      addAttribs(null, Widget.CURRENT, {
          filters: currentFilters!=null && currentFilters.length==0 ? null : currentFilters,
       });
      addAttribs("Button", null, {
          style: StyleRoundRect,
          fill: FillLight,
          line: LineBorder,
          textAlign: "center",
          itemAlign: Layout.AlignCenter,
          padding: new Rectangle(buttonBorderX,buttonBorderY,buttonBorderX*2,buttonBorderY*2),
          offset: new Point(scale(1),scale(1)),
        });
      addAttribs("ToggleButton", null, {
         offset: new Point(0,0)
        });
      addAttribs("SimpleButton", null, {
          offset: new Point(0,0),
          line: LineNone,
          fill: FillNone,
          style: StyleRect,
          padding: new Rectangle(scale(2),scale(2),scale(4),scale(4)),
        });
      addAttribs("SimpleButton", Widget.DOWN, {
          line: LineBorder,
        });
      addAttribs("ChromeButton", null, {
          offset: new Point(1,1),
          line: LineSolid(1,guiMedium,1),
          fill: FillLight,
          minItemSize: new Size(scale(10),scale(10)),
          padding: new Rectangle(scale(2),scale(2),scale(4),scale(4)),
        });
 
      addAttribs("TextLabel", null, {
          align: Layout.AlignLeft,
        });
      addAttribs("TextPlaceholder", null, {
          textColor: 0xa0a0a0,
        });
      addAttribs("PanelText", null, {
          align: Layout.AlignRight,
        });
      addAttribs("DialogTitle", null, {
          align: Layout.AlignStretch | Layout.AlignCenterY,
          textAlign: "center",
          fontSize: scale(24),
          style: StyleUnderlineRect,
          fill: FillSolid(0xffffff,1),
          line: LineSolid(4,0x8080ff,1),
          //hitBoxId: HitBoxes.Title,
          chromeButtons: [ {id:Close,
                       align:Layout.AlignRight|Layout.AlignCenterY,
                       margin:new Rectangle(5,0,10,0),
                       itemAlign:Layout.AlignCenter,
                       lineage:["DialogButton"] } ],
        });
      addAttribs("Panel", null, {
          margin: scale(3),
        });
      addAttribs("GroupBox", null, {
          margin: 10,
          padding: new Rectangle(0,scale(20),0,scale(20)),
          line:LineBorder,
          fill: FillLight,
          style:StyleRoundRect
        });
      addAttribs("GroupBoxTitle", null, {
          line: LineBorder,
          fill: FillLight,
          style: StyleRoundRect,
        });
      addAttribs("TextInput", null, {
          style: StyleRect,
          align: Layout.AlignLeft,
          isInput: true,
          minItemSize : new Size(scale(100),1),
          line: LineBorder,
          fill: FillSolid(0xffffff,1),
        });
      addAttribs("Dock", null, {
          style: StyleRect,
          fill: FillMedium,
          filters: null,
          padding: null,
        });
      addAttribs("BitmapFromId", null, {
          bitmap: BitmapFactory(DefaultBitmaps.factory),
        });
      addAttribs("UiButton", null, {
          style: StyleNone,
          bitmap: BitmapFactory(DefaultBitmaps.factory),
          padding: new Rectangle(scale(2),scale(2),scale(4),scale(4)),
        });
      addAttribs("Frame", null, {
          style: StyleRect,
          fill: FillMedium,
          line: LineBorder,
          padding: new Rectangle(borders, borders, borders*2, borders*2),
        });

      addAttribs("Dialog", null, {
          chromeFilters: shadowFilters,
          fill: FillSolid(0xffffff,1),
          chromeButtons: [ {id:Resize,
              align:Layout.AlignRight|Layout.AlignBottom|Layout.AlignOverlap,
              margin:new Rectangle(0,0,0,0),
              wantsFocus:false,
              lineage:["NoChrome"] } ],
        });

      addAttribs("Line", null, {
          fill: FillDark,
          line: LineNone,
          style: StyleRect,
          minItemSize: new Size(1,1),
          align: Layout.AlignStretch,
        });
      addAttribs("ProgressBar", null, {
          align: Layout.AlignStretch,
          minItemSize: new Size(scale(100),scale(20)),
        });
      addAttribs("VLine", null, {
          align: Layout.AlignStretch,
          itemAlign: Layout.AlignStretch | Layout.AlignCenterX,
        });
      addAttribs("HLine", null, {
          align: Layout.AlignStretch,
          itemAlign: Layout.AlignStretch | Layout.AlignCenterY,
        });
      addAttribs("TabBar", null, {
          minSize: new Size(tabSize,tabSize),
        });
      addAttribs("Menubar", null, {
          minSize: new Size(0,menuHeight),
          line: LineNone,
          style: StyleCustom(renderMenubar),
        });
      addAttribs(null, Widget.DOWN, {
          fill: FillMedium,
        });
      addAttribs(null, Widget.DISABLED, {
          fill: FillDisabled,
        });
      addAttribs(null, Widget.DISABLED, {
          fill: FillDisabled,
        });
      addAttribs("MenubarItem", null, {
          filters:null,
          line: LineNone,
        });
      addAttribs("ListRow", null, {
          filters:null,
          line: LineNone,
          style: StyleUnderlineRect,
          fill: FillRowOdd,
        });
      addAttribs("ListRow", Widget.ALTERNATE, {
          fill: FillRowEven,
        });
      addAttribs("ListRow", Widget.CURRENT, {
          fill: FillRowSelect,
        });
 
      addAttribs("MenuCheckbox", null, {
          filters:null,
          line: LineNone,
          style: StyleNone,
          overlapped: true,
        });
      addAttribs("PopupMenu", null, {
          chromeFilters: shadowFilters,
          style: StyleRect,
          fill: FillLight,
          line: LineBorder,
        });
      addAttribs("PopupComboBox", null, {
          chromeFilters: shadowFilters,
          style: StyleRect,
          fill: FillNone,
          line: LineBorder,
          padding: 0,
        });

      addAttribs("PopupMenuItem", null, {
          style: StyleRect,
          fill: FillLight,
          textAlign: "left",
          padding: scale(3),
          align: Layout.AlignStretch | Layout.AlignCenterY,
        });
      addAttribs("PopupMenuItem", Widget.CURRENT, {
          fill: FillMedium,
          //line: LineBorder,
          textColor: 0xffffff,
          filters: null,
        });

      addAttribs("NoFilters", null, {
          filters: null,
          chromeFilters: null,
        });

      addAttribs("NoChrome", null, {
          filters: null,
          chromeFilters: null,
          fill: FillNone,
          line: LineNone,
          style: StyleNone,
        });


      return null;
   }

   public static function scale(inVal:Float):Int
   {
      return Std.int(inVal*dpiScale);
   }

   public static function addId(inId:String, inState:Null<Int>, inAttribs:{ })
   {
      var attribs = idAttribs.get(inId);
      if (attribs==null)
         idAttribs.set( inId, attribs = new AttribSet() );
      
      attribs.push( new RenderAttribs(null, inState, inAttribs) );
   }


   public static function getIdAttribs(inId:String)
   {
      var attribs = idAttribs.get(inId);
      if (attribs!=null)
         return attribs;
      if (resolveAttribs!=null)
          attribs = resolveAttribs(inId);
      if (attribs==null)
          attribs = [];
      idAttribs.set(inId, attribs);
      return attribs;
    }
  

   public static function getIdAttrib(inId:String, inName:String, ?inState:Null<Int>) : Dynamic
   {
      var attribs = getIdAttribs(inId);
      for(attrib in attribs)
         if (attrib.matches(null,inState))
         {
            var result = attrib.attribs.get(inName);
            if (result!=null)
               return result;
         }
      return null;
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
      init();
      return new DockRenderer(hasLineage(inLineage,"VariableWidth"));
   }

   public static function tabRenderer(inLineage:Array<String>, ?inAttribs:Dynamic) : TabRenderer
   {
      init();
      return defaultTabRenderer;
   }

   public static function combineAttribs(inLineage:Array<String>,inState:Int=0, ?inAttribs:{}) : Map<String,Dynamic>
   {
       init();
       var map = new Map<String,Dynamic>();
       for(attrib in attribSet)
          if (attrib.matches(inLineage,inState))
             attrib.merge(map);
       if (inAttribs!=null && Reflect.hasField(inAttribs,"id"))
       {
          var id = Reflect.field(inAttribs,"id");
          var attribs = getIdAttribs(id);
          for(attrib in attribs)
              if (attrib.matches(inLineage,inState))
                 attrib.merge(map);
       }
       mergeAttribMap(map,inAttribs);

       return map;
   }

   public static function renderer(inLineage:Array<String>,inState:Int=0, ?inAttribs:{}) : Renderer
   {
      init();
      return new Renderer(combineAttribs(inLineage,inState,inAttribs));
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


   public static function onCreateSlider(inSlider:Slider):Void
   {
      init();
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
      init();
      if (inSvg.hasGroup("dialog"))
      {
         var frameRenderer = SvgSkin.createFrameRenderer(inSvg,"dialog");
         replaceAttribs("Frame", null, frameRenderer);
         var title = inSvg.findGroup("dialog").findGroup(".title");
         if (title!=null)
            replaceAttribs("DialogTitle", null, SvgSkin.createButtonRenderer(title));
      }
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


   public static function renderMenubar(widget:Widget)
   {
      var gfx = widget.graphics;
      gfx.clear();
      var mtx = new nme.geom.Matrix();
      var rect = widget.mRect;
      mtx.createGradientBox(rect.height,rect.height,Math.PI * 0.5);
      var cols:Array<CInt> = [guiLight, guiMedium, guiDark];
      var alphas:Array<Float> = [1.0, 1.0, 1.0];
      var ratio:Array<Int> = [0, 128, 255];
      gfx.beginGradientFill(nme.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,rect.width,rect.height);
   }


   public static function styleLabel(label:TextField)
   {
      init();
      label.defaultTextFormat = textFormat;
      label.textColor = labelColor;
      if (label.type != nme.text.TextFieldType.INPUT)
      {
         label.autoSize = TextFieldAutoSize.LEFT;
         label.selectable = false;
      }
      //label.mouseEnabled = false;
   }


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


   public static function defaultResolveAttribs(inId) : AttribSet
   {
      var result = new AttribSet();

      switch(inId)
      {
         case "#checked":
            var gfx = mDrawing.graphics;
            gfx.clear();
            gfx.lineStyle(4,0x00ff00);
            gfx.moveTo(4,16);
            gfx.lineTo(8,20);
            gfx.lineTo(20,8);
            var bmp = new BitmapData(24,24,true,gm2d.RGB.CLEAR );
            bmp.draw(mDrawing);
            result.push( new RenderAttribs(null, null, { icon:bmp } ) );

         case "#unchecked":
            var gfx = mDrawing.graphics;
            gfx.clear();
            gfx.lineStyle(4,0xff0000);
            gfx.moveTo(8,8);
            gfx.lineTo(16,16);
            gfx.moveTo(8,16);
            gfx.lineTo(16,8);
            var bmp = new BitmapData(24,24,true,gm2d.RGB.CLEAR );
            bmp.draw(mDrawing);
            result.push( new RenderAttribs(null, null, { icon:bmp } ) );
       }

       return result;
   }
}





