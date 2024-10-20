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
import nme.display.Graphics;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.text.TextFormat;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import nme.Assets;
import gm2d.ui.Layout;
import gm2d.ui.Slider;
import gm2d.ui.Widget;
import gm2d.ui.HitBoxes;

import gm2d.skin.FillStyle;
import gm2d.skin.LineStyle;
import gm2d.skin.BitmapStyle;
import gm2d.skin.ProgressStyle;
import gm2d.skin.Shape;

import nme.display.SimpleButton;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;
import gm2d.CInt;

typedef AttribSet = Map<String,Dynamic>;


class Skin
{
   public static var dpiScale(get,null):Float;

   public var uiScale:Float;

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
   public static inline var Grip     = "#grip";

   // Other Buttons
   public static inline var Checkbox   = "#checkbox";
   public static inline var CheckboxSmall   = "#checkbox-small";
   public static inline var Radiobox   = "#radiobox";
   public static inline var ComboPopup = "#combopopup";


   public static inline var TOOLBAR_GRIP_TOP = 0x0001;
   public static inline var SHOW_COLLAPSE    = 0x0002;
   public static inline var SHOW_EXPAND      = 0x0004;


   public static var theSkin:Skin;



   // You can use these to set the defaults before you create a Widget
   public var roundRectRad = 4.0;
   public var guiLight = 0xf0f0f0;
   public var guiMedium = 0xe0e0e0;
   public var guiTrim = 0xadadad;
   public var guiHighlight = 0x1883d7;
   public var guiDark = 0x606060;
   public var guiVeryDark = 0x404040;
   public var guiLightText = 0xffffff;
   public var panelColor = 0xe0e0e0;
   public var controlColor = 0xf0f0f0;
   public var dialogColor = 0xf0f0f0;
   public var guiButton = 0xe0e0e0;

   public var guiDisabled = 0x808080;
   public var guiBorder = 0x000000;
   public var textFormat:nme.text.TextFormat;


   public var controlBorder = 0x000000;
   public var centerTitle = true;
   public var buttonBorderX = 10;
   public var buttonBorderY = 2;
   public var mdiBGColor:Null<Int> = 0x404040;
   public var labelColor = 0x000000;
   public var disableColor = 0x808080;
   public var resizeBarColor = 0x00ff00;
   public var tabGradientColor = 0x909080;
   public var menuHeight:Float = 32;
   public var tabSize = 32;

   public var rowSelectColour = 0xffd0d0f0;
   public var rowEvenColour   = 0xffffffff;
   public var rowOddColour    = 0xfff0f0ff;


   public var shadowFilters:Array<BitmapFilter>;
   public var currentFilters:Array<BitmapFilter>;
   public var sliderRenderer:SliderRenderer;
   public var defaultTabRenderer:TabRenderer;
   public var bmpCache = new Map<String, BitmapData>();


   public var tabHeight:Int = 24;
   public var title_h:Int = 22;
   public var borders:Int = 3;

   public var mDrawing:Sprite;
   public var mText:TextField;

   public var attribSet:Map<String,Dynamic>;
   public var cachedIdAttribs:Map<String,Dynamic>;
   public var resolveAttribs: String->Dynamic;



   public function new(andInit=true)
   {
      uiScale = nme.ui.Scale.getFontScale();
      resolveAttribs = defaultResolveAttribs;

      if (andInit)
         init();
   }

   public static function getSkin(?inSkin:Skin)
   {
      if (inSkin!=null)
         return inSkin;
      if (theSkin==null)
         theSkin = new Skin();
      return theSkin;
   }

   public static function get_dpiScale()
   {
      return getSkin().uiScale;
   }

   public static function uiWidth(inSize:Int) return new Size( getSkin().scale(inSize), 0);


   public function init()
   {
      if (textFormat==null)
      {
         textFormat = new TextFormat();
         textFormat.size = scale(14);
         textFormat.font = "Arial";
         textFormat.color = 0x000000;
      }

      if (shadowFilters==null)
      {
         var s = scale(3);
         shadowFilters = [ new DropShadowFilter(s,45,0,0.5,s,s,3) ];
      }

      /*
      if (currentFilters==null)
      {
         var s = scale(3);
         var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, s, s, 2, 1, false, false);
         currentFilters = [ glow ];
      }
      */


      initGfx();

      if (cachedIdAttribs==null)
         cachedIdAttribs = new Map<String,Dynamic>();

      // Rebuild attribs from scratch
      attribSet = [
        "*" => {
           stateDown: {
              fill: FillMedium,
              },
           stateDisabled: {
              fill: FillDisabled,
              },
           },
        "Control" => {
           wantsFocus: true,
           stateCurrent: {
              filters: currentFilters!=null && currentFilters.length==0 ? null : currentFilters,
              line: LineHighlight,
              },
           },
        "Button" => {
           parent:"Control",
           shape: ShapeRect,
           fill: FillButton,
           line: LineTrim,
           textAlign: "center",
           itemAlign: Layout.AlignCenter,
           padding: new Rectangle(buttonBorderX,buttonBorderY,buttonBorderX*2,buttonBorderY*2),
           offset: new Point(scale(1),scale(1)),
           },
        "SimpleButton" => {
           parent:"Control",
           offset: new Point(0,0),
           line: LineNone,
           fill: FillNone,
           shape: ShapeRect,
           padding: new Rectangle(scale(2),scale(2),scale(4),scale(4)),
           },
        "ToggleButton" => {
           parent:"Button",
           offset: new Point(0,0),
           },
        "ButtonText" => {
           textAlign: "center",
        },
        "BMPTextButton" => {
           parent:"Button",
           shape: ShapeRoundRect,
           fill: FillLight,
           line: LineBorder,
           contents:"icon-text",
           textAlign: "center",
           itemAlign: Layout.AlignCenter,
           padding: new Rectangle(buttonBorderX,buttonBorderY,buttonBorderX*2,buttonBorderY*2),
           offset: new Point(scale(1),scale(1)),
           },
        "Keyboard" => {
           wantsFocus: true,
           filters: null,
           },

        "DialogButton" => {
           parent:"Button",
           offset: new Point(0,0),
           line: LineNone,
           fill: FillLight,
           //fill: FillButton,
           shape: ShapeRect,
           padding: new Rectangle(scale(2),scale(2),scale(4),scale(4)),
           },
        "ChromeButton" => {
           parent:["Button"],
           offset: new Point(1,1),
           //line: LineSolid(1,guiDark,0.5),
           line: LineNone,
           fill: FillMedium,
           minItemSize: new Size(scale(10),scale(10)),
           padding: new Rectangle(scale(2),scale(2),scale(4),scale(4)),
           filters: null,
           chromeFilters: null,
           align:Layout.AlignRight|Layout.AlignCenterY,
           margin:new Rectangle(5,0,10,0),
           itemAlign:Layout.AlignCenter,
           bitmap: BitmapFactory(createDefaultBitmap),
           },
        "TextLabel" => {
           align: Layout.AlignLeft,
           },
        "ListText" => {
           padding:scale(5),
           },
        "TextPlaceholder" => {
           textColor: 0xa0a0a0,
           },
        "TextPlaceholderAlways" => {
           textAlign: "right",
           },
        "StatusBar" => {
           align: Layout.AlignLeft,
           shape:ShapeRect,
           fill: FillSolid(guiVeryDark,1),
           textColor: guiLightText,
           padding: scale(5),
           },
        "PanelText" => {
           align: Layout.AlignRight,
           },
        "DialogTitle" => {
           align: Layout.AlignStretch | Layout.AlignCenterY,
           textAlign: "left",
           fontSize: scale(16),
           padding: new Rectangle(scale(2),scale(2),scale(4),scale(4)),
           shape: ShapeRect,
           fill: FillSolid(0xffffff,1),
           //hitBoxId: HitBoxes.Title,
           chromeButtons: [ {
                id:Close,
                align:Layout.AlignRight|Layout.AlignCenterY,
                margin:new Rectangle(5,0,10,0),
                itemAlign:Layout.AlignCenter,
                parent:"DialogButton"
                }
              ],
           },
        "DocumentFrame" => {
           padding: 0,//new Rectangle(scale(2),scale(2),scale(4),scale(4)),
           sampe: ShapeRect,
           fill: FillMedium,
           line: LineSolid(scale(2),guiLight,1),
        },
        "TitleBar" => {
           align: Layout.AlignStretch | Layout.AlignLeft,
           textAlign: "left",
           fontSize: scale(16),
           padding: new Rectangle(scale(2),scale(2),scale(4),scale(4)),
           shape: ShapeRect,
           fill: FillLight,

           },

        "Panel" => {
           padding: scale(10),
           buttonGap: scale(10),
           buttonSpacing: scale(10),
           buttonAlign: Layout.AlignCenter | Layout.AlignEqual,
           supportsSecondary : false,
           },
        "MediumBg" => {
           fill: FillMedium,
           shape: ShapeRect,
           },
        "DarkBg" => {
           fill: FillDark,
           shape: ShapeRect,
           },

        "GroupBox" => {
           margin: 10,
           padding: new Rectangle(0,scale(20),0,scale(20)),
           line:LineTrim,
           fill: FillLight,
           shape:ShapeRoundRect
           },
        "GroupBoxTitle" => {
           line: LineBorder,
           fill: FillLight,
           shape: ShapeRoundRect,
           },
        "TextInput" => {
           parent:"Control",
           shape: ShapeRoundRectRad(1.5),
           align: Layout.AlignLeft,
           isInput: true,
           minItemSize : new Size(scale(100),1),
           line: LineTrim,
           fill: FillSolid(0xffffff,1),
           stateCurrent: {
              line: LineHighlight,
              },
           },
        "Dock" => {
           shape: ShapeRect,
           fill: FillSolid(guiLight,1),
           filters: null,
           padding: null,
           },
        "BitmapFromId" => {
           bitmap: BitmapFactory(createDefaultBitmap),
           },
        "Image" => {
           alignBitmap: Layout.AlignGraphcsRect | Layout.AlignKeepAspect,
           },

        "UiButton" => {
           shape: ShapeNone,
           bitmap: BitmapFactory(createDefaultBitmap),
           padding: new Rectangle(scale(2),scale(2),scale(4),scale(4)),
           },
        "CheckButton" => {
           shape: ShapeNone,
           offset: new Point(0,0),
           itemAlign: Layout.AlignLeft,
           padding: 1,
           toggle: true,
           bitmapId:"#checkbox-small",
           stateCurrent: {
              shape: ShapeRoundRect,
           },
           bitmap: BitmapFactory(createDefaultBitmap),
           },
        "DockItem" => {
           align: Layout.AlignStretch,
           titleLineage:[ "FrameTitle" ],
           },
        "Frame" => {
           shape: ShapeRect,
           //line: LineBorder,
           },
        "FrameTitle" => {
           align: Layout.AlignStretch | Layout.AlignCenterY,
           textAlign: "center",
           fontSize: scale(14),
           shape: ShapeRect,
           fill: FillSolid(0xf0f0f0,1),
           padding: new Rectangle(0,scale(4),0,scale(8)),
           //shape: ShapeUnderlineRect,
           //line: LineSolid(2,0x8080ff,1),
           },

        "Tabs" => {
           tab : {
              shape: ShapeRoundRect,
              //line: LineBorder,
              line: null,
              }
           },

        "TabRenderer" => {
           shape: ShapeRect,
           fill: FillLight,
           align: Layout.AlignStretch | Layout.AlignTop,
           },


        "BarDock" => {
           align: Layout.AlignStretch | Layout.AlignTop,
        },

        "GripBarDock" => {
           shape: ShapeRect,
           fill: FillMedium,
           align: Layout.AlignStretch | Layout.AlignTop,
           },


        "TabButton" => {
           fill: FillLight,
           },

        "TabBarButton" => {
           bitmap: BitmapFactory(createDefaultDarkBitmap),
           fill: guiMedium,
           shape: ShapeRect,
           },

        "Dialog" => {
           shape: ShapeRect,
           line: LineHighlight,
           //padding: new Rectangle(borders, borders, borders*2, borders*2),
           chromeFilters: shadowFilters,
           fill: FillLight,
           /*
           chromeButtons: [ {bitmapId:Resize,
              align:Layout.AlignRight|Layout.AlignBottom|Layout.AlignOverlap,
              margin:new Rectangle(0,0,0,0),
              wantsFocus:false,
              lineage:["NoChrome"] } ],
           */
           },
        "DialogScreen" => {
           shape: ShapeRect,
           fill: FillLight,
           line: LineHighlight,
        },

        "Line" => {
           fill: FillDark,
           line: LineNone,
           shape: ShapeItemRect,
           minItemSize: new Size(1,1),
           align: Layout.AlignStretch,
           },
        "ProgressBar" => {
           align: Layout.AlignStretch,
           minItemSize: new Size(scale(100),scale(20)),
           progressStyle: ProgressRoundRect(0x000000, guiHighlight, guiLight, scale(1), scale(6) ),
           },
        "Stretch" => {
           align: Layout.AlignStretch,
           itemAlign: Layout.AlignStretch,
           },
        "VLine" => {
           align: Layout.AlignStretch,
           itemAlign: Layout.AlignStretch | Layout.AlignCenterX,
           },
        "HLine" => {
           align: Layout.AlignStretch,
           itemAlign: Layout.AlignStretch | Layout.AlignCenterY,
           },
        "TabBar" => {
           minSize: size(tabSize,tabSize),
           fill: FillLight,
           shape:ShapeRect,
           },
        "Menubar" => {
           minSize: new Size(0,scale(menuHeight)),
           align: Layout.AlignStretch,
           itemAlign: Layout.AlignLeft | Layout.AlignCenterY,
           line: LineNone,
           fill: FillSolid(guiVeryDark,1),
           shape: ShapeRect,
           },
        "MenubarItem" => {
           filters:null,
           shape: ShapeUnderlineRect,
           line: LineNone,
           fill: FillNone,
           textColor: guiLightText,
           stateCurrent : {
              filters:null,
              line: LineSolid(scale(4),guiHighlight,1),
              }
           },
        "ListRow" => {
           filters:null,
           line: LineNone,
           shape: ShapeUnderlineRect,
           fill: FillRowOdd,
           stateAlternate: {
             fill: FillRowEven,
             },
           stateCurrent: {
             fill: FillRowSelect,
             },
           },
        "TileControl" => {
           fill: FillSolid(0xffffff,1),
           shape: ShapeRect,
           wantsFocus:false,
           },
        "SimpleTile" => {
           filters: null,
           fill: FillSolid(0xffffff,1),
           line: LineSolid(0,0xffffff,0),
           shape: ShapeShadowRect(1,0),
           padding: new Rectangle(10,10,20,20),
           wantsFocus:true,
           stateCurrent: {
              shape: ShapeShadowRect(3,0),
              line: LineSolid(0,0x8080ff,1),
              }
           },
        "AppBar" => {
           filters: null,
           fill: FillSolid(0xffffff,1),
           line: LineNone,
           shape: ShapeShadowRect(2, EdgeFlags.BottomOnly),
           padding: new Rectangle(0,0,0,6),
           align:Layout.AlignTop,
           wantsFocus:false,
           },
 
        "MenuCheckbox" => {
           filters:null,
           line: LineNone,
           shape: ShapeNone,
           overlapped: true,
           },

        "MenuRadiobox" => {
           filters:null,
           line: LineNone,
           shape: ShapeNone,
           overlapped: true,
           bitmapId:"#radiobox",
           },

         /*
         "MenuCheckbox" => {
           fill: FillMedium,
           shape: ShapeRect,
           },
         */

        "PopupMenu" => {
           chromeFilters: shadowFilters,
           filters: null,
           shape: ShapeRect,
           fill: FillLight,
           line: LineBorder,
           },
        "PopupComboBox" => {
           chromeFilters: shadowFilters,
           filters: null,
           shape: ShapeRect,
           fill: FillNone,
           line: LineBorder,
           padding: 0,
           },

        "PopupMenuItemBase" => {
           padding: scale(3),
        },

        // The text part
        "PopupMenuItem" => {
           //shape: ShapeRect,
           //fill: FillLight,
           filters: null,
           textAlign: "left",
           align: Layout.AlignStretch | Layout.AlignCenterY,
           stateCurrent:{
              textColor: 0xffffff,
              }
           },

        "PopupMenuItemShortcut" => {
           textAlign: "right",
           },

        "PopupMenuItemIcon" => {
           },


        "PopupMenuSeparator" => {
           rowHeight: scale(5),
           align:Layout.AlignStretch | Layout.AlignCenterY,
           fill: FillDark,
           },

        "PopupMenuList" => {
           rowLineage:"PopupMenuRow",
           textColor: 0xffffff,
           },
        "PopupMenuRow" => {
           shape: ShapeUnderlineRect,
           fill: FillNone,
           stateAlternate: {
              fill: FillNone,
              },
           stateCurrent: {
             fill: FillHighlight,
             },
           },

        "ChoiceBox" => {
           isInput: false,
           listOnly: true,
           },

        "ComboBox" => {
           bitmap: BitmapFactory(createDefaultBitmap),
           bitmapId: ComboPopup,
        },

        "ChoiceButton" => {
           stateDown: {
              shape: ShapeRect,
              line: LineBorder,
              },

           stateCurrent: {
              line: LineHighlight,
              },
           },

        "WidgetDrawer" => {
           filters: null,
           fill: FillSolid(0xffffff,1),
           line: LineSolid(0,0x0000ff,0),
           shape: ShapeShadowRect(3,0),
           },

        "FileBox" => {
           showRight: true,
           },


        "NoFilters" => {
           filters: null,
           chromeFilters: null,
           },

        "NoChrome" => {
           filters: null,
           chromeFilters: null,
           fill: FillNone,
           line: LineNone,
           shape: ShapeNone,
           }
      ];

      if (sliderRenderer==null)
         sliderRenderer = createSliderRenderer();

      if (defaultTabRenderer==null)
         defaultTabRenderer = createTabRenderer(["Tabs", "TabRenderer"],{});

      theSkin = this;
   }

   public function createDefaultBitmap( inButton:String, inState:Int) : BitmapData
   {
      var key = inButton + "::" + inState;
      if (bmpCache.exists(key))
          return  bmpCache.get(key);
      var bmp = DefaultBitmaps.createBitmap(this, inButton, inState, guiDark, guiLight);
      bmpCache[key] = bmp;
      return bmp;
   }

   public function createDefaultDarkBitmap( inButton:String, inState:Int) : BitmapData
   {
      var key = "dark::" + inButton + "::" + inState;
      if (bmpCache.exists(key))
          return  bmpCache.get(key);

      var bmp = DefaultBitmaps.createBitmap(this, inButton, inState,  guiLight, guiDark);
      bmpCache[key] = bmp;
      return bmp;
   }



   public static function scaleBitmap(inBmp:BitmapData,extraScale:Float=1.0)
   {
      var skin = getSkin();
      var w = skin.scale(inBmp.width*extraScale);
      var h = skin.scale(inBmp.height*extraScale);
      var bitmap = new Bitmap(inBmp);
      var mtx = new nme.geom.Matrix(w/inBmp.width,0,0,h/inBmp.height,0,0);

      var result = new BitmapData(w,h, inBmp.transparent, 0);
      result.draw(bitmap, mtx);
      return result;
   }
   public function size(inX:Float,inY:Float) return new Size( scale(inX), scale(inY) );
   public function scale(inVal:Float):Int
   {
      return Std.int(inVal*uiScale);
   }

   public function addId(inId:String, inAttribs:{ })
   {
      var attribs = cachedIdAttribs.get(inId);
      if (attribs==null)
         cachedIdAttribs.set( inId, attribs = { } );

      for(key in Reflect.fields(inAttribs))
         Reflect.setField(attribs, key, Reflect.field(inAttribs,key));
   }


   public function getIdAttribs(inId:String) : Dynamic
   {
      if (cachedIdAttribs.exists(inId))
         return cachedIdAttribs.get(inId);
      var attribs:Dynamic = null;
      if (resolveAttribs!=null)
          attribs = resolveAttribs(inId);
      cachedIdAttribs.set(inId, attribs);
      return attribs;
    }
  

   public function getIdAttrib(inId:String, inName:String) : Dynamic
   {
      var attribs = getIdAttribs(inId);
      if (attribs==null)
         return null;

      if (Reflect.hasField(attribs,inName))
         return Reflect.field(attribs,inName);

      return null;
   }


   public function addAttribs(inLine:String, inAttribs:Dynamic)
   {
      var oldAttribs = attribSet.get(inLine);
      if (oldAttribs!=null)
      {
         for(key in Reflect.fields(inAttribs))
             Reflect.setField(oldAttribs, key, Reflect.field(inAttribs,key));
      }
      else
         attribSet.set( inLine, inAttribs );
   }

   public function removeAttribs(inLine:String)
   {
      attribSet.remove(inLine);
   }

   public function replaceAttribs(inLine:String, inAttribs:Dynamic)
   {
      if (inLine==null)
         inLine = "*";
      #if flash9
      if (Std.is(inAttribs,Renderer))
      {
         var o = {};
         for(field in Type.getInstanceFields(Renderer))
            Reflect.setField(o, field, Reflect.field(inAttribs,field));
         inAttribs = o;
      }
      #end
      attribSet.set( inLine, inAttribs );
   }



   public static function hasLineage(inLineage:Array<String>, inClassName)
   {
      for(line in inLineage)
         if (inClassName==line)
            return true;
      return false;
   }

   public function dockRenderer(inLineage:Array<String>, ?inAttribs:Dynamic) : DockRenderer
   {
      return new DockRenderer(this,hasLineage(inLineage,"VariableWidth"));
   }

   public function tabRenderer() : TabRenderer
   {
      return defaultTabRenderer;
   }

   function mergeAttribMapState(map, attrib:Dynamic, inState:Int)
   {
      if (attrib==null)
         return;

      if ( (inState & Widget.ALTERNATE)!=0)
         mergeAttribMap( map, Reflect.field(attrib,"stateAlternate") );

      if ( (inState & Widget.CURRENT)!=0)
         mergeAttribMap( map, Reflect.field(attrib,"stateCurrent") );

      if ( (inState & Widget.DOWN)!=0)
         mergeAttribMap( map, Reflect.field(attrib,"stateDown") );

      if ( (inState & Widget.DISABLED)!=0)
         mergeAttribMap( map, Reflect.field(attrib,"stateDisabled") );

      if ( (inState & Widget.SELECTED)!=0)
         mergeAttribMap( map, Reflect.field(attrib,"stateSelected") );
   }


   public function combineAttribs(inLineage:Array<String>,inState:Int=0, ?inAttribs:{}) : Map<String,Dynamic>
   {
       var map = new Map<String,Dynamic>();
       var last = inLineage.length;
       var stateAttribs:Array<Dynamic> = null;

       mergeAttribMap(map, attribSet.get("*") );

       for(line in 0...last)
          mergeAttribMap(map, attribSet.get(inLineage[last-1-line]) );

       mergeAttribMap(map,inAttribs);

       for( flag in [ Widget.ALTERNATE, Widget.DOWN, Widget.SELECTED, Widget.CURRENT, Widget.DISABLED ] )
       if ( (inState&flag) >0 )
       {
          for(line in 0...last)
             mergeAttribMapState(map, attribSet.get(inLineage[last-1-line]), inState & flag);

          mergeAttribMapState(map, inAttribs, inState & flag);
       }

       var id = map.get("id");
       var attribs = getIdAttribs(id);
       if (attribs!=null)
          mergeAttribMap(map,attribs);

       return map;
   }

   public function renderer(inLineage:Array<String>,inState:Int=0, ?inAttribs:{}) : Renderer
   {
      return new Renderer(this,combineAttribs(inLineage,inState,inAttribs));
   }


   public function createSliderRenderer()
   {
      var result = new SliderRenderer();
      result.onCreate = onCreateSlider;
      result.onRender = onRenderSlider;
      return result;
   }
   public function createTabRenderer(inLineage:Array<String>, ?inAttribs:Dynamic) : TabRenderer
   {
      var result = new TabRenderer(this, inLineage, inAttribs);
      return result;
   }


   public function onCreateSlider(inSlider:Slider):Void
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

   public function onRenderSlider(inSlider:Slider, inRect:Rectangle):Void
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


   public function fromSvg(inSvg:Svg)
   {
      if (inSvg.hasGroup("dialog"))
      {
         var frameRenderer = SvgSkin.createFrameRenderer(this, inSvg,"dialog");
         addAttribs("Dialog", frameRenderer);

         var title = inSvg.findGroup("dialog").findGroup(".title");
         if (title!=null)
            replaceAttribs("DialogTitle", SvgSkin.createButtonRenderer(title));
            // Inherit chrome buttons?
            //addAttribs("DialogTitle", null, SvgSkin.createButtonRenderer(title));
      }
      if (inSvg.hasGroup("slider"))
         sliderRenderer = SvgSkin.createSliderRenderer(inSvg,"slider");
      if (inSvg.hasGroup("button"))
         replaceAttribs("Button", SvgSkin.createButtonRenderer(inSvg,"button") );
   }


   public function getTextFormat()
   {
      var fmt = new TextFormat();
      fmt.size = textFormat.size;
      fmt.font = textFormat.font;
      fmt.color = textFormat.color;
      return fmt;
   }


   public function styleLabel(label:TextField)
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


   public function styleText(inText:nme.text.TextField)
   {
      inText.defaultTextFormat = textFormat;
   }

   public function getChromeRect(inDocked:IDockable,inTopGrip:Bool) : Rectangle
   {
      var pane = inDocked.asPane();
      if (pane!=null)
      {
         if (Dock.isToolbar(pane))
         {
            if (inTopGrip)
               return new Rectangle(scale(2),scale(8),scale(4),scale(10));
            else
               return new Rectangle(scale(8),scale(2),scale(10),scale(4));
         }
         else
            return new Rectangle(scale(2),scale(22),scale(4),scale(24));
      }
      return new Rectangle(0,0,0,0);
   }

   public function getMultiDockChromePadding(inN:Int,tabStyle:Bool) : Size
   {
      return new Size(0,tabStyle ? scale(tabHeight) : inN*24);
   }


   public function renderToolbarGap(inContainer:Sprite,inX:Float, inY:Float, inW:Float, inH:Float)
   {
      var gfx = inContainer.graphics;
      gfx.lineStyle();
      gfx.beginFill(panelColor);
      gfx.drawRect(inX,inY,inW,inH);
      gfx.endFill();
   }

   public function renderPaneChrome(inPane:Pane,inContainer:Sprite,outHitBoxes:HitBoxes,inRect:Rectangle,inFlags:Int):Void
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


   public function addResizeDockZones(outZones:DockZones,inRect:Rectangle,inHorizontal:Bool,inSizes:Array<Float>, inOnDock:IDockable->Int->Void ):Void
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
*/

   public function getFrameClientOffset() : Point
   {
      return new Point(borders,borders+title_h);
   }
   public function getMiniWinClientOffset() : Point
   {
      return new Point(borders,borders);
   }
   public function getMinFrameWidth() : Float
   {
      return 80;
   }
   public function getResizeBarWidth() : Float
   {
      return scale(3);
   }
   public function getSideBorder() : Float
   {
      return 0;
   }



   public function renderText(inText:String, inAltText:String,inWidth:Float, inHeight:Float)
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


   public function renderMiniWin(outChrome:Sprite, pane:Pane, inRect:Rectangle,outHitBoxes:HitBoxes,inFull:Bool)
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



   function initGfx()
   {
      if (mText==null)
      {
         mText = new TextField();
         styleLabel(mText);
      }

      if (mDrawing==null)
         mDrawing = new Sprite();
      else
      {
         mDrawing.graphics.clear();
         while(mDrawing.numChildren>0)
            mDrawing.removeChildAt( mDrawing.numChildren-1 );
      }
      return mDrawing.graphics;
   }

   public function getMDIClientChrome() { return new Rectangle(0,scale(tabHeight), 0, scale(tabHeight)); }

  

   public function renderDropZone(inRect:Rectangle, outZones:DockZones, inPosition:DockPosition,
      inCentred:Bool, onDock:IDockable->Void):Void
   {
      var r:Rectangle = null;
      var x0 = Std.int(inRect.x) + 0.5;
      var y0 = Std.int(inRect.y) + 0.5;
      var showX = 0;
      var showY = 0;
      var showW = scale(32);
      var showH = scale(32);
      var half = scale(16);
      var plusHalf = scale(48);
      var gap = scale(2);

      switch(inPosition)
      {
         case DOCK_LEFT:
            y0 = Std.int(inRect.y + inRect.height/2 - half ) + 0.5;
            if (inCentred)
               x0 = inRect.x +inRect.width*0.5 - plusHalf - gap;
            showW = scale(12);
         case DOCK_RIGHT:
            if (inCentred)
               x0 = inRect.x +inRect.width*0.5 + half + gap;
            else
               x0 = Std.int(inRect.right-showW)-0.5;
            y0 = Std.int(inRect.y + inRect.height/2 - half ) + 0.5;
            showX = scale(20);
            showW = scale(12);
         case DOCK_TOP:
            if (inCentred)
               y0 = inRect.y +inRect.height*0.5 - plusHalf - 2;
            x0 = Std.int(inRect.x + inRect.width/2 - half ) + 0.5;
            showH = scale(12);
         case DOCK_BOTTOM:
            x0 = Std.int(inRect.x + inRect.width/2 - half ) + 0.5;
            if (inCentred)
               y0 = inRect.y +inRect.height*0.5 + half + gap;
            else
               y0 = Std.int(inRect.bottom-showH)-0.5;
            showY = scale(20);
            showH = scale(12);
         case DOCK_OVER:
            if (!inCentred)
               return;

            x0 = inRect.x +inRect.width*0.5 - half;
            y0 = inRect.y +inRect.height*0.5 - half;
            showX = showY = scale(4);
            showW = showH = scale(24);
         case DOCK_BAR:
            return;
      }

      var gfx = outZones.container.graphics;
      var result = new Rectangle(x0,y0,scale(32),scale(32));
      if (result.contains(outZones.x,outZones.y))
      {
         gfx.lineStyle();
         gfx.beginFill(0x7070ff);
         gfx.drawRect(x0-gap*2,y0-gap*2,scale(40),scale(40));
      }
      gfx.beginFill(0xffffff);
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(x0,y0,scale(32),scale(32));
      gfx.beginFill(0x4040a0);
      gfx.drawRect(x0+showX,y0+showY,showW,showH);

      outZones.addRect(result, onDock);
   }



   public function mergeAttribs(a0:{}, aover:{}) : {}
   {
      var result = {};
      for(k in Reflect.fields(a0))
         Reflect.setField(result, k, Reflect.field(a0,k));
      for(k in Reflect.fields(aover))
         Reflect.setField(result, k, Reflect.field(aover,k));
      return result;
   }

   public function mergeAttribMap(map:Map<String,Dynamic>, inAttribs:Dynamic,maxDepth=10)
   {
      if (inAttribs!=null)
      {
         if (maxDepth>0 && Reflect.hasField(inAttribs,"parent"))
            mergeAttribMap(map, inAttribs.parent, maxDepth-1 );

         for(key in Reflect.fields(inAttribs))
             if (key!="parent")
                 map.set(key, Reflect.field(inAttribs,key));
      }
   }


   static function createAttribMap(inAttribs:Dynamic) : Map<String, Dynamic>
   {
      var result = new Map<String,Dynamic>();
      if (inAttribs!=null)
         for(key in Reflect.fields(inAttribs))
             result.set(key, Reflect.field(inAttribs,key));
      return result;
   }


   public function defaultResolveAttribs(inId) : Dynamic
   {
      switch(inId)
      {
         case "#checked":
            var gfx = initGfx();
            gfx.lineStyle(4,0x00ff00);
            gfx.moveTo(4,16);
            gfx.lineTo(8,20);
            gfx.lineTo(20,8);
            var bmp = new BitmapData(24,24,true,gm2d.RGB.CLEAR );
            bmp.draw(mDrawing);
            return( { icon:bmp } );

         case "#unchecked":
            var gfx = initGfx();
            gfx.lineStyle(4,0xff0000);
            gfx.moveTo(8,8);
            gfx.lineTo(16,16);
            gfx.moveTo(8,16);
            gfx.lineTo(16,8);
            var bmp = new BitmapData(24,24,true,gm2d.RGB.CLEAR );
            bmp.draw(mDrawing);
            return( { icon:bmp } );
       }

       return null;
   }

   public function createBitmapData(inResoName:String,inWidth:Int) : BitmapData
   {
      var bmp:BitmapData = null;
      if (Assets.hasBitmapData(inResoName))
      {
         bmp = Assets.getBitmapData(inResoName);

         var extraScale = inWidth/bmp.width;
         return scaleBitmap(bmp,extraScale);
      }
      else
      {
         var svg = new SvgRenderer(gm2d.reso.Resources.loadSvg(inResoName));
         var size = scale(inWidth);
         var bmp = new BitmapData(size,size,true, gm2d.RGB.CLEAR );

         var shape = svg.createShape();
         var scaled = new Sprite();
         scaled.addChild(shape);
         shape.scaleX = shape.scaleY = size/svg.width;
         bmp.draw(scaled);
         return bmp;
      }
   }


}





