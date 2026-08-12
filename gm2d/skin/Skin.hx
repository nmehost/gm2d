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
import gm2d.skin.TextColour;
import gm2d.skin.FilterSet;
import gm2d.skin.BitmapFilterStyle;
import gm2d.skin.BitmapStyle;
import gm2d.skin.ProgressStyle;
import gm2d.skin.Shape;

import nme.display.SimpleButton;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;
import gm2d.CInt;

import gm2d.ui.Attribs;

typedef AttribSet = Map<String,Dynamic>;


class Skin
{
   public static var dpiScale(get,null):Float;

   public var uiScale(default,set):Float;
   function set_uiScale(inScale:Float):Float
   {
      if (!mutable)
         throw "Skin is frozen - uiScale cannot be changed";
      return uiScale = inScale;
   }

   // Once a skin is used in anger, it should not be changed.
   public var mutable:Bool = true;

   // Closed set of named colour roles, keyed by FillStyle/LineStyle(/TextColour) constructor name
   // (eg. FillMax -> "FillMax"). See setColour/setFillColor/setLineColour.
   public var colours:Map<String,Int>;

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



   public var roundRectRad = 4.0;
   public var resizeBarFill:FillStyle = FillInv;
   // Null/FillNone/FillTransparent disables the MDI background fill entirely.
   public var mdiFill:FillStyle = FillInv;
   public var tabHeight:Int = 24;

   public var textFormat:nme.text.TextFormat;


   public var filterStyles:Map<String,Array<BitmapFilterStyle>>;
   var cachedFilters:Map<String,Array<BitmapFilter>>;
   public var sliderRenderer:SliderRenderer;
   public var defaultTabRenderer:TabRenderer;
   public var bmpCache = new Map<String, BitmapData>();
   public var shadowCache = new ShadowCache();



   public var mDrawing:Sprite;
   public var mText:TextField;

   public var attribSet:Map<String,Attribs>;
   public var cachedIdAttribs:Map<String,Attribs>;
   public var resolveAttribs: String->Attribs;



   public function new()
   {
      uiScale = nme.ui.Scale.getFontScale();
      resolveAttribs = defaultResolveAttribs;
      initColours();
      initFilters();
      init();
   }

   function initColours()
   {
      colours = new Map<String,Int>();
      colours.set("FillLight", 0xf0f0f0);
      colours.set("FillMedium", 0xe0e0e0);
      colours.set("FillButton", 0xe0e0e0);
      colours.set("FillDark", 0x606060);
      colours.set("FillHighlight", 0x1883d7);
      colours.set("FillDisabled", 0x808080);
      colours.set("FillRowOdd", 0xfff0f0ff);
      colours.set("FillRowEven", 0xffffffff);
      colours.set("FillRowSelect", 0xffd0d0f0);
      colours.set("FillMax", 0xffffff);
      colours.set("FillInv", 0x404040);
      colours.set("LineBorder", 0x000000);
      colours.set("LineTrim", 0xadadad);
      colours.set("LineHighlight", 0x1883d7);
      colours.set("TextColNormal", 0x000000);
      colours.set("TextColMuted", 0xa0a0a0);
      colours.set("TextColInverse", 0xffffff);
   }

   function initFilters()
   {
      filterStyles = new Map<String,Array<BitmapFilterStyle>>();
      filterStyles.set("FilterSetShadow", [ FilterDropShadow(3, 45, 3, FillSolid(0,1), 0.5) ]);
      filterStyles.set("FilterSetCurrent", []);
      cachedFilters = new Map<String,Array<BitmapFilter>>();
   }

   public function getColour(inKey:String):Int
   {
      return colours.get(inKey);
   }

   public function setColour(inKey:String, inRgb:Int):Void
   {
      if (!mutable)
         throw "Skin is frozen - colour '" + inKey + "' cannot be changed";
      if (!colours.exists(inKey))
         throw "Unknown skin colour key '" + inKey + "'";
      colours.set(inKey, inRgb);
   }

   public function getFillColour(inStyle:FillStyle):Int
   {
      if (Type.enumParameters(inStyle).length != 0)
         throw "getFillColour: not a named colour role: " + inStyle;
      return getColour(Type.enumConstructor(inStyle));
   }

   public function getLineColour(inStyle:LineStyle):Int
   {
      if (Type.enumParameters(inStyle).length != 0)
         throw "getLineColour: not a named colour role: " + inStyle;
      return getColour(Type.enumConstructor(inStyle));
   }

   public function setFillColor(inStyle:FillStyle, inRgb:Int):Void
   {
      if (Type.enumParameters(inStyle).length != 0)
         throw "setFillColor: not a named colour role: " + inStyle;
      setColour(Type.enumConstructor(inStyle), inRgb);
   }

   public function setLineColour(inStyle:LineStyle, inRgb:Int):Void
   {
      if (Type.enumParameters(inStyle).length != 0)
         throw "setLineColour: not a named colour role: " + inStyle;
      setColour(Type.enumConstructor(inStyle), inRgb);
   }

   public function getTextColour(inStyle:TextColour):Int
   {
      if (Type.enumParameters(inStyle).length != 0)
         throw "getTextColour: not a named colour role: " + inStyle;
      return getColour(Type.enumConstructor(inStyle));
   }

   public function setTextColour(inStyle:TextColour, inRgb:Int):Void
   {
      if (Type.enumParameters(inStyle).length != 0)
         throw "setTextColour: not a named colour role: " + inStyle;
      setColour(Type.enumConstructor(inStyle), inRgb);
   }

   // Create and cache
   public function getFilterSet(inSet:FilterSet):Array<BitmapFilter>
   {
      var key = Type.enumConstructor(inSet);
      var cached = cachedFilters.get(key);
      if (cached==null)
      {
         cached = realizeFilters(filterStyles.get(key));
         cachedFilters.set(key, cached);
      }
      return cached;
   }

   public function setFilterStyle(inSet:FilterSet, inStyles:Array<BitmapFilterStyle>):Void
   {
      if (!mutable)
         throw "Skin is frozen - filter set '" + inSet + "' cannot be changed";
      var key = Type.enumConstructor(inSet);
      if (!filterStyles.exists(key))
         throw "Unknown filter set '" + key + "'";
      filterStyles.set(key, inStyles);
      cachedFilters.remove(key);
   }

   function realizeFilters(inStyles:Array<BitmapFilterStyle>):Array<BitmapFilter>
   {
      var result = [];
      if (inStyles!=null)
         for(s in inStyles)
            result.push(realizeFilter(s));
      return result;
   }

   function realizeFilter(inStyle:BitmapFilterStyle):BitmapFilter
   {
      return switch(inStyle)
      {
         case FilterDropShadow(distance,angle,blur,colour,alpha):
            var d = toPixels(distance);
            var b = toPixels(blur);
            new DropShadowFilter(d, angle, resolveFillColour(colour), alpha, b, b, 3);

         case FilterGlow(colour,blur,alpha):
            var b = toPixels(blur);
            new GlowFilter(resolveFillColour(colour), alpha, b, b, 2, 1, false, false);

         case FilterCustom(filter):
            filter;
      }
   }

   public function resolveFillColour(inStyle:FillStyle):Int
   {
      return switch(inStyle)
      {
         case FillSolid(rgb,a): rgb;
         default: getFillColour(inStyle);
      }
   }

   public function resolveLineColour(inStyle:LineStyle):Int
   {
      return switch(inStyle)
      {
         case LineSolid(_, rgb, _): rgb;
         case LineSolidFill(_, fill, _): resolveFillColour(fill);
         default: getLineColour(inStyle);
      }
   }

   // Shallow copy avoids duplication the attribs, but allows changing the colours or scale
   function shallowCopy():Skin
   {
      var result:Skin = Type.createEmptyInstance(Skin);
      result.mutable = true;
      result.uiScale = uiScale;
      //result.roundRectRad = roundRectRad;
      result.resizeBarFill = resizeBarFill;
      result.mdiFill = mdiFill;
      result.textFormat = textFormat;
      result.filterStyles = filterStyles.copy();

      result.cachedFilters = new Map<String,Array<BitmapFilter>>();
      result.bmpCache = new Map<String, BitmapData>();
      result.shadowCache = new ShadowCache();

      result.sliderRenderer = sliderRenderer;
      result.defaultTabRenderer = defaultTabRenderer;
      result.tabHeight = tabHeight;
      result.mDrawing = mDrawing;
      result.mText = mText;
      result.attribSet = attribSet;
      result.cachedIdAttribs = cachedIdAttribs;
      result.resolveAttribs = resolveAttribs;
      result.colours = colours.copy();
      return result;
   }

   public function copyWithScale(inUiScale:Float):Skin
   {
      var result = shallowCopy();
      result.uiScale = inUiScale;
      result.textFormat = new TextFormat(textFormat.font, result.toPixels(14));
      result.mText = new TextField();
      result.styleLabel(result.mText);
      if (sliderRenderer!=null)
         result.sliderRenderer = result.createSliderRenderer();
      if (defaultTabRenderer!=null)
         result.defaultTabRenderer = result.createTabRenderer(["Tabs","TabRenderer"],{});
      return result;
   }

   public function copyWithPalette(inColours:Map<String,Int>):Skin
   {
      var result = shallowCopy();
      for(key in inColours.keys())
         result.colours.set(key, inColours.get(key));
      result.mText = new TextField();
      result.styleLabel(result.mText);
      if (sliderRenderer!=null)
         result.sliderRenderer = result.createSliderRenderer();
      if (defaultTabRenderer!=null)
         result.defaultTabRenderer = result.createTabRenderer(["Tabs","TabRenderer"],{});
      return result;
   }

   // Create a simple variation of existing colours
   public function createDark():Skin
   {
      var inverted = new Map<String,Int>();
      for(key in colours.keys())
      {
         var v = colours.get(key);
         var alpha = v & 0xff000000;
         var rgb = v & 0xffffff;
         inverted.set(key, alpha | (0xffffff - rgb));
      }
      return copyWithPalette(inverted);
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

   public static function uiWidth(inSize:Int) return new Size( getSkin().toPixels(inSize), 0);


   function init()
   {
      if (textFormat==null)
      {
         textFormat = new TextFormat();
         textFormat.size = toPixels(14);
         textFormat.font = "Arial";
      }

      initGfx();

      if (cachedIdAttribs==null)
         cachedIdAttribs = new Map<String,Attribs>();

      // Rebuild attribs from scratch
      attribSet = [
        "*" => {
           font: "Arial",
           fontSize: 14,
           stateDown: {
              fill: FillMedium,
              },
           stateDisabled: {
              fill: FillDisabled,
              },
           },
        "Control" => {
           wantsFocus: true,
           autoCurrent: true,
           stateCurrent: {
              filters: FilterSetCurrent,
              line: LineHighlight,
              },
           },
        "Scroll" => {
           scrollWheelStep: 20,
           },
        "ColourWheel" => {
           itemAlign: Layout.AlignKeepAspect | Layout.AlignStretch,
           },
        "ColourControl" => {
           itemAlign: Layout.AlignStretch | Layout.AlignTop,
           },
        "Button" => {
           parent:"Control",
           shape: ShapeRect,
           fill: FillButton,
           line: LineTrim,
           textAlign: "center",
           autoCurrent: false,
           itemAlign: Layout.AlignCenterY,
           padding: new Rectangle(10,2,20,4),
           offset: new Point(1,1),
           stateDisabled: {
              bitmapTransform: Skin.makeGrey,
              },
           },
        "SimpleButton" => {
           parent:"Control",
           offset: new Point(0,0),
           line: LineNone,
           fill: FillNone,
           shape: ShapeRect,
           padding: new Rectangle(2,2,4,4),
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
           itemAlign: Layout.AlignCenterY,
           padding: new Rectangle(10,2,20,4),
           offset: new Point(1,1),
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
           padding: new Rectangle(2,2,4,4),
           },
        "ChromeButton" => {
           parent:["Button"],
           offset: new Point(1,1),
           //line: LineSolid(1,guiDark,0.5),
           line: LineNone,
           fill: FillMedium,
           minItemSize: new Size(10,10),
           padding: new Rectangle(2,2,4,4),
           filters: null,
           chromeFilters: null,
           align:Layout.AlignRight|Layout.AlignCenterY,
           margin:new Rectangle(5,0,10,0),
           itemAlign:Layout.AlignCenter,
           bitmap: BitmapFactory(createDefaultBitmap),
           },
        "TextLabel" => {
           align: Layout.AlignLeft | Layout.AlignHalfPixel,
           itemAlign: Layout.AlignCenterY,
           },
        "ListText" => {
           padding:5,
           },
        "TextPlaceholder" => {
           textColor: TextColMuted,
           },
        "TextPlaceholderAlways" => {
           textAlign: "right",
           },
        "StatusBar" => {
           align: Layout.AlignLeft,
           shape:ShapeRect,
           fill: FillInv,
           textColor: TextColInverse,
           padding: 5,
           },
        "PanelText" => {
           align: Layout.AlignRight,
           },
        "DialogTitle" => {
           align: Layout.AlignStretch | Layout.AlignCenterY,
           textAlign: "left",
           fontSize: 16,
           padding: new Rectangle(2,2,4,4),
           shape: ShapeRect,
           fill: FillMax,
           //hitBoxId: HitBoxes.Title,
           },
        "DocumentFrame" => {
           padding: 0,//new Rectangle(toPixels(2),toPixels(2),toPixels(4),toPixels(4)),
           shape: ShapeRect,
           fill: FillMedium,
           line: LineSolidFill(toPixels(2),FillLight,1),
        },
        "TitleBar" => {
           align: Layout.AlignStretch | Layout.AlignLeft,
           textAlign: "left",
           fontSize: 16,
           padding: new Rectangle(2,2,4,4),
           shape: ShapeRect,
           fill: FillLight,

           },

        "Panel" => {
           padding: 10,
           buttonGap: 10,
           buttonSpacing: 10,
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
           padding: new Rectangle(0,20,0,20),
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
           align: Layout.AlignStretch | Layout.AlignCenterY,
           isInput: true,
           minItemSize : new Size(100,1),
           line: LineTrim,
           fill: FillMax,
           stateCurrent: {
              line: LineHighlight,
              },
           },
        "Dock" => {
           shape: ShapeRect,
           fill: FillLight,
           filters: null,
           padding: null,
           },
        "BitmapFromId" => {
           bitmap: BitmapFactory(createDefaultBitmap),
           },
        "Image" => {
           alignBitmap: Layout.AlignGraphcsRect | Layout.AlignKeepAspect,
           //align: Layout.AlignStretch,
           },

        "UiButton" => {
           shape: ShapeNone,
           bitmap: BitmapFactory(createDefaultBitmap),
           padding: new Rectangle(2,2,4,4),
           },
        "CheckButton" => {
           shape: ShapeNone,
           offset: new Point(0,0),
           itemAlign: Layout.AlignLeft | Layout.AlignCenterY,
           align: Layout.AlignLeft | Layout.AlignCenterY,
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
           fontSize: 14,
           shape: ShapeRect,
           fill: FillSolid(0xf0f0f0,1),
           padding: new Rectangle(0,4,0,8),
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
           fill: FillMedium,
           shape: ShapeRect,
           },

        "Dialog" => {
           shape: ShapeRect,
           line: LineHighlight,
           chromeFilters: FilterSetShadow,
           fill: FillLight,
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
           minItemSize: new Size(100,20),
           progressStyle: ProgressRoundRect(LineBorder, FillHighlight, FillLight, 1, 6),
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
           minSize: new Size(32,32),
           fill: FillLight,
           shape:ShapeRect,
           },
        "Menubar" => {
           minSize: new Size(0,32),
           align: Layout.AlignStretch,
           itemAlign: Layout.AlignLeft | Layout.AlignCenterY,
           line: LineNone,
           fill: FillLight,
           shape: ShapeRect,
           },
        "MenubarItem" => {
           filters:null,
           shape: ShapeUnderlineRect,
           line: LineNone,
           fill: FillNone,
           textColor: TextColNormal,
           stateCurrent : {
              filters:null,
              line: LineSolidFill(toPixels(4),FillHighlight,1),
              }
           },
        "ListRow" => {
           filters:null,
           line: LineNone,
           shape: ShapeUnderlineRect,
           fill: FillRowOdd,
           align:Layout.AlignStretch,
           stateAlternate: {
             fill: FillRowEven,
             },
           stateCurrent: {
             fill: FillRowSelect,
             },
           },
        "TileControl" => {
           fill: FillMax,
           shape: ShapeRect,
           wantsFocus:false,
           },
        "SimpleTile" => {
           filters: null,
           fill: FillMax,
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
           fill: FillMax,
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
           chromeFilters: FilterSetShadow,
           filters: null,
           shape: ShapeRect,
           fill: FillLight,
           line: LineBorder,
           },
        "PopupComboBox" => {
           chromeFilters: FilterSetShadow,
           filters: null,
           shape: ShapeRect,
           fill: FillNone,
           line: LineBorder,
           padding: 0,
           },

        "PopupMenuItemBase" => {
           padding: 3,
        },

        // The text part
        "PopupMenuItem" => {
           //shape: ShapeRect,
           //fill: FillLight,
           filters: null,
           textAlign: "left",
           align: Layout.AlignStretch | Layout.AlignCenterY,
           stateCurrent:{
              textColor: TextColInverse,
              }
           },

        "PopupMenuItemShortcut" => {
           textAlign: "right",
           },

        "PopupMenuItemIcon" => {
           },


        "PopupMenuSeparator" => {
           rowHeight: 5,
           align:Layout.AlignStretch | Layout.AlignCenterY,
           fill: FillDark,
           },

        "PopupMenuList" => {
           rowLineage:"PopupMenuRow",
           textColor: TextColInverse,
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
           fill: FillMax,
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

   public static function createDefaultBitmap( skin:Skin, inButton:String, inState:Int) : BitmapData
   {
      var key = inButton + "::" + inState;
      var bmp = skin.bmpCache.get(key);
      if (bmp==null)
      {
         bmp = DefaultBitmaps.createBitmap(skin, inButton, inState, skin.getColour("FillDark"), skin.getColour("FillLight"));
         skin.bmpCache.set(key, bmp);
      }
      return bmp;
   }

   public static function createDefaultDarkBitmap( skin:Skin, inButton:String, inState:Int) : BitmapData
   {
      var key = "dark::" + inButton + "::" + inState;
      var bmp = skin.bmpCache.get(key);
      if (bmp==null)
      {
         bmp = DefaultBitmaps.createBitmap(skin, inButton, inState, skin.getColour("FillLight"), skin.getColour("FillDark"));
         skin.bmpCache.set(key, bmp);
      }
      return bmp;
   }



   public static function scaleBitmap(inBmp:BitmapData,extraScale:Float=1.0)
   {
      var skin = getSkin();
      var w = skin.toPixels(inBmp.width*extraScale);
      var h = skin.toPixels(inBmp.height*extraScale);
      var bitmap = new Bitmap(inBmp);
      bitmap.smoothing = true;
      var mtx = new nme.geom.Matrix(w/inBmp.width,0,0,h/inBmp.height,0,0);

      var result = new BitmapData(w,h, inBmp.transparent, 0);
      result.draw(bitmap, mtx);
      return result;
   }
   public function size(inX:Float,inY:Float) return new Size( toPixels(inX), toPixels(inY) );
   public function toPixels(inVal:Float):Int
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


   public function combineAttribs(inLineage:Array<String>,inState:Int=0, ?inAttribs:Attribs) : Map<String,Dynamic>
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

   public function renderer(inLineage:Array<String>,inState:Int=0, ?inAttribs:Attribs) : Renderer
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
   public function createTabRenderer(inLineage:Array<String>, ?inAttribs:Attribs) : TabRenderer
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
      Renderer.setFill(this, gfx, FillLight, 20, 20);
      Renderer.setLine(this, gfx, LineBorder);
      gfx.drawRect(-10,0,20,20);
      inSlider.getItemLayout().onInnerRect = function(inX:Float,inY:Float,inW:Float,inH:Float)
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
      Renderer.setFill(this, gfx, FillDisabled, inRect.width-20, inRect.height);
      Renderer.setLine(this, gfx, LineBorder);
      gfx.drawRect(10,0,inRect.width-20,inRect.height);

      var gfx = inSlider.mThumb.graphics;
      gfx.clear();
      Renderer.setFill(this, gfx, FillLight, inRect.height, inRect.height);
      Renderer.setLine(this, gfx, LineBorder);
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




   public function styleLabel(label:TextField)
   {
      label.defaultTextFormat = textFormat;
      label.textColor = getTextColour(TextColNormal);
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
               return new Rectangle(toPixels(2),toPixels(8),toPixels(4),toPixels(10));
            else
               return new Rectangle(toPixels(8),toPixels(2),toPixels(10),toPixels(4));
         }
         else
            return new Rectangle(toPixels(2),toPixels(22),toPixels(4),toPixels(24));
      }
      return new Rectangle(0,0,0,0);
   }

   public function getMultiDockChromePadding(inN:Int,tabStyle:Bool) : Size
   {
      return new Size(0,tabStyle ? toPixels(tabHeight) : inN*24);
   }


   public function renderToolbarGap(inContainer:Sprite,inX:Float, inY:Float, inW:Float, inH:Float)
   {
      var gfx = inContainer.graphics;
      gfx.lineStyle();
      gfx.beginFill(getFillColour(FillMedium));
      gfx.drawRect(inX,inY,inW,inH);
      gfx.endFill();
   }

   public function renderPaneChrome(inPane:Pane,inContainer:Sprite,outHitBoxes:HitBoxes,inRect:Rectangle,inFlags:Int):Void
   {
      var gfx = inContainer.graphics;
      gfx.lineStyle();
      gfx.beginFill(getFillColour(FillMedium));
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
         gfx.beginFill(getFillColour(FillMedium));
         gfx.drawRect(inRect.x,inRect.y,inRect.width,inRect.height);

         /*
         var mtx = new nme.geom.Matrix();
         mtx.createGradientBox(21,21, Math.PI*-0.5, inRect.x+1.5, inRect.y+1.5);
         var cols:Array<Int> = [guiLight, guiMedium, guiDark];
         var alphas:Array<Float> = [1.0, 1.0, 1.0];
         var ratio:Array<Int> = [0, 128, 255];
         gfx.beginGradientFill(nme.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
         */
         gfx.beginFill(getColour("FillDark"));
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
               var button =  new Button(null, null, ["PaneButton", "UiButton"], { id:but });

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

   public function getResizeBarWidth() : Float
   {
      return toPixels(3);
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

   public function getMDIClientChrome() { return new Rectangle(0,toPixels(tabHeight), 0, toPixels(tabHeight)); }

  

   public function renderDropZone(inRect:Rectangle, outZones:DockZones, inPosition:DockPosition,
      inCentred:Bool, onDock:IDockable->Void):Void
   {
      var r:Rectangle = null;
      var x0 = Std.int(inRect.x) + 0.5;
      var y0 = Std.int(inRect.y) + 0.5;
      var showX = 0;
      var showY = 0;
      var showW = toPixels(32);
      var showH = toPixels(32);
      var half = toPixels(16);
      var plusHalf = toPixels(48);
      var gap = toPixels(2);

      switch(inPosition)
      {
         case DOCK_LEFT:
            y0 = Std.int(inRect.y + inRect.height/2 - half ) + 0.5;
            if (inCentred)
               x0 = inRect.x +inRect.width*0.5 - plusHalf - gap;
            showW = toPixels(12);
         case DOCK_RIGHT:
            if (inCentred)
               x0 = inRect.x +inRect.width*0.5 + half + gap;
            else
               x0 = Std.int(inRect.right-showW)-0.5;
            y0 = Std.int(inRect.y + inRect.height/2 - half ) + 0.5;
            showX = toPixels(20);
            showW = toPixels(12);
         case DOCK_TOP:
            if (inCentred)
               y0 = inRect.y +inRect.height*0.5 - plusHalf - 2;
            x0 = Std.int(inRect.x + inRect.width/2 - half ) + 0.5;
            showH = toPixels(12);
         case DOCK_BOTTOM:
            x0 = Std.int(inRect.x + inRect.width/2 - half ) + 0.5;
            if (inCentred)
               y0 = inRect.y +inRect.height*0.5 + half + gap;
            else
               y0 = Std.int(inRect.bottom-showH)-0.5;
            showY = toPixels(20);
            showH = toPixels(12);
         case DOCK_OVER:
            if (!inCentred)
               return;

            x0 = inRect.x +inRect.width*0.5 - half;
            y0 = inRect.y +inRect.height*0.5 - half;
            showX = showY = toPixels(4);
            showW = showH = toPixels(24);
         case DOCK_BAR:
            return;
      }

      var gfx = outZones.container.graphics;
      var result = new Rectangle(x0,y0,toPixels(32),toPixels(32));
      if (result.contains(outZones.x,outZones.y))
      {
         gfx.lineStyle();
         gfx.beginFill(0x7070ff);
         gfx.drawRect(x0-gap*2,y0-gap*2,toPixels(40),toPixels(40));
      }
      gfx.beginFill(0xffffff);
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(x0,y0,toPixels(32),toPixels(32));
      gfx.beginFill(0x4040a0);
      gfx.drawRect(x0+showX,y0+showY,showW,showH);

      outZones.addRect(result, onDock);
   }



   public static function mergeAttribs(a0:Attribs, aover:Attribs) : Attribs
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


   public function defaultResolveAttribs(inId) : Attribs
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

   // inWidth is a logical unit (scaled to pixels internally, once) - matches the convention used
   // throughout attribSet/Renderer. Do not pre-scale the value you pass in.
   public function createBitmapData(inResoName:String,inWidth:Int) : BitmapData
   {
      var bmp:BitmapData = null;
      if (Assets.hasBitmapData(inResoName))
      {
         bmp = Assets.getBitmapData(inResoName);

         var extraScale = toPixels(inWidth)/bmp.width;
         return scaleBitmap(bmp,extraScale);
      }
      else
      {
         var svg = new SvgRenderer(gm2d.reso.Resources.loadSvg(inResoName));
         var size = toPixels(inWidth);
         var bmp = new BitmapData(size,size,true, gm2d.RGB.CLEAR );

         var shape = svg.createShape();
         var scaled = new Sprite();
         scaled.addChild(shape);
         shape.scaleX = shape.scaleY = size/svg.width;
         bmp.draw(scaled);
         return bmp;
      }
   }

   // Resolves a size-driven BitmapStyle (as opposed to BitmapFactory/BitmapAndDisable, which are
   // resolved by id+state via Renderer.getBitmap) to a BitmapData rendered fresh for the current
   // scale. Used by Button.resolveIcon() and Image.fromStyle() so a single "source + logical
   // size" pair is enough to stay correctly scaled across every rescale, with no per-call-site
   // addScaleChanged bookkeeping.
   public function renderBitmapStyle(style:BitmapStyle, logicalSize:Int) : BitmapData
   {
      var pixelSize = toPixels(logicalSize);
      return switch(style)
      {
         case BitmapBitmap(bmp): bmp;
         case BitmapResource(name):
            if (Assets.hasBitmapData(name))
               return scaleRasterTo(Assets.getBitmapData(name), pixelSize);
            return renderSvgIcon(name, pixelSize);
         case BitmapRender(draw): draw(this, pixelSize);
         default: throw "BitmapStyle not resolvable by logical size: " + style;
      }
   }

   // Like the static scaleBitmap(), but scales to an exact target pixel width (preserving
   // aspect) using *this* skin's uiScale, rather than the static's Skin.getSkin() global.
   function scaleRasterTo(inBmp:BitmapData, inPixelWidth:Int) : BitmapData
   {
      var w = inPixelWidth;
      var h = Std.int(w * inBmp.height/inBmp.width);
      var bitmap = new Bitmap(inBmp);
      bitmap.smoothing = true;
      var mtx = new nme.geom.Matrix(w/inBmp.width,0,0,h/inBmp.height,0,0);
      var result = new BitmapData(w,h, inBmp.transparent, 0);
      result.draw(bitmap, mtx);
      return result;
   }

   // Same rendering (scale 0.8, 2-logical-pixel inset) as the icons previously baked by
   // App.createSvg - kept here so BitmapResource-sourced SVG icons look identical to before.
   function renderSvgIcon(inResoName:String, inPixelSize:Int) : BitmapData
   {
      var bmp = new BitmapData(inPixelSize,inPixelSize,true, gm2d.RGB.CLEAR );
      var svg = new SvgRenderer(gm2d.reso.Resources.loadSvg(inResoName));
      var svgScale = Math.min(inPixelSize/svg.width, inPixelSize/svg.height) * 0.8;
      var shape = svg.createShape();
      var scaled = new Sprite();
      scaled.addChild(shape);
      shape.scaleX = shape.scaleY = svgScale;
      shape.x = shape.y = toPixels(2) + 0.5;
      bmp.draw(scaled);
      return bmp;
   }

   // Moved from BitmapButton.createDisabled - the default "stateDisabled" bitmapTransform for
   // the "Button" lineage (see attribSet below). A plain BitmapData->BitmapData transform, so
   // call sites can override or null it out per lineage/instance via the bitmapTransform attrib.
   public static function makeGrey(inBmp:BitmapData) : BitmapData
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

}





