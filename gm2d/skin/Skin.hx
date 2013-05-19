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
import gm2d.skin.ButtonState;
import gm2d.filters.BitmapFilter;
import gm2d.filters.BitmapFilterType;
import gm2d.filters.DropShadowFilter;
import gm2d.filters.GlowFilter;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.display.Shape;
import gm2d.display.Graphics;
import gm2d.text.TextField;
import gm2d.text.TextFieldAutoSize;
import gm2d.events.MouseEvent;
import gm2d.geom.Point;
import gm2d.geom.Rectangle;
import gm2d.geom.Matrix;
import gm2d.ui.Layout;
import gm2d.ui.Slider;

import nme.display.SimpleButton;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;
import gm2d.CInt;



class Skin
{
   static var sCurrent:Skin;
   public static var current(get_current,set_current):Skin;

   public var labelColor:Int;
   public var panelColor:Int;
   public var controlColor:Int;
   public var disableColor:Int;
   public var controlBorder:Int;
   public var mdiBGColor:Int;
   public var buttonCorner:Float;
   public var tabGradientColor:Int;

   public var guiLight:Int;
   public var guiMedium:Int;
   public var guiDark:Int;

   public var textFormat:gm2d.text.TextFormat;
   public var menuHeight:Float;
   public var mBitmaps:Array< Array<BitmapData> >;
   public var centerTitle:Bool;
   public var buttonBorderX:Float;
   public var buttonBorderY:Float;

   public var dialogRenderer:FrameRenderer;
   public var buttonRenderer:ButtonRenderer;
   public var sliderRenderer:SliderRenderer;
   public var labelRenderer:LabelRenderer;
   public var tabRenderer:TabRenderer;

   public var tabHeight:Int;
   public var title_h:Int;
   public var borders:Int;

   public static var svgInterior = ~/\.interior/;
   public static var svgScaleX = ~/\.scaleX/;
   public static var svgScaleY = ~/\.scaleY/;
   public static var svgBounds = ~/\.bounds/;
   public static var svgActive = ~/\.active/;
   public static var svgThumb = ".thumb";

   public var mDrawing:Shape;
   public var mText:TextField;

   public static inline var TOOLBAR_GRIP_TOP = 0x0001;
   public static inline var SHOW_COLLAPSE    = 0x0002;
   public static inline var SHOW_EXPAND      = 0x0004;

   public function new()
   {
      textFormat = new gm2d.text.TextFormat();
      textFormat.size = 12;
      textFormat.font = "Arial";
      menuHeight = 22;
      mBitmaps = [];
      centerTitle = true;
      buttonBorderX = 10;
      buttonBorderY = 5;
      guiLight = 0xf0f0e0;
      guiMedium = 0xe0e0d0;
      guiDark = 0xa0a090;
      mdiBGColor = 0x404040;
      labelColor = 0x000000;
      panelColor = guiMedium;
      controlColor = guiLight;
      disableColor = 0x808080;
      controlBorder = 0x000000;
      tabGradientColor = 0x909080;
      buttonCorner = 6.0;
      tabHeight = 24;
      title_h = 22;
      borders = 3;


      initGfx();

      for(state in  HitBoxes.BUT_STATE_UP...HitBoxes.BUT_STATE_DOWN+1)
         mBitmaps[state] = [];

      createRenderers();
   }

   public function createRenderers()
   {
      dialogRenderer = createDialogRenderer();
      buttonRenderer = createButtonRenderer();
      sliderRenderer = createSliderRenderer();
      labelRenderer = createLabelRenderer();
      tabRenderer = createTabRenderer();
   }

   public function createDialogRenderer()
   {
      var result = new FrameRenderer();
      result.borders = borders;
      result.titleHeight = 26;
      result.render = renderDialog;
      return result;
   }
   public function createButtonRenderer()
   {
      var result = new ButtonRenderer();
      result.render = renderButton;
      result.updateLayout = function(ioButton:Button)
      {
         ioButton.getItemLayout().setBorders(buttonBorderX,buttonBorderY,buttonBorderX,buttonBorderY);
      };
      result.styleLabel = styleLabel;
      return result;
   }
   public function createSliderRenderer()
   {
      var result = new SliderRenderer();
      result.onCreate = onCreateSlider;
      result.onRender = onRenderSlider;
      return result;
   }
   public function createLabelRenderer()
   {
      var result = new LabelRenderer();
      result.styleLabel = styleLabel;
      return result;
   }
   public function createTabRenderer()
   {
      var result = new TabRenderer();
      return result;
   }



   public function onCreateSlider(inSlider:Slider):Void
   {
      var layout = inSlider.getLayout();
      layout.setMinSize(120,20);

      inSlider.mThumb = new Sprite();
      var gfx = inSlider.mThumb.graphics;
      gfx.beginFill(controlColor);
      gfx.lineStyle(1,controlBorder);
      gfx.drawRect(-10,0,20,20);
      inSlider.getLayout().onLayout = function(inX:Float,inY:Float,inW:Float,inH:Float)
      {
          inSlider.mRenderer.onRender( inSlider, new Rectangle(inX,inY,inW,inH) );
          inSlider.mRenderer.onPosition(inSlider);
      };
   }

   public function onRenderSlider(inSlider:Slider, inRect:Rectangle):Void
   {
      inSlider.mX0 = 10;
      inSlider.mX1 = inRect.width-10;

      var gfx = inSlider.mTrack.graphics;
      gfx.beginFill(disableColor);
      gfx.lineStyle(1,controlBorder);
      gfx.drawRect(10,0,inRect.width-20,inRect.height);

   }


   public function fromSvg(inSvg:Svg)
   {
      if (inSvg.hasGroup("dialog"))
         dialogRenderer = FrameRenderer.fromSvg(inSvg,"dialog");
      if (inSvg.hasGroup("slider"))
         sliderRenderer = SliderRenderer.fromSvg(inSvg,"slider");
      if (inSvg.hasGroup("button"))
         buttonRenderer = ButtonRenderer.fromSvg(inSvg,"button");
   }

   public static function getScaleRect(inRenderer:SvgRenderer, inBounds:Rectangle) : Rectangle
   {
      var scaleX = inRenderer.getMatchingRect(svgScaleX);
      var scaleY = inRenderer.getMatchingRect(svgScaleY);
      if (scaleX==null && scaleY==null)
         return null;
      return  new Rectangle(scaleX==null ? inBounds.x - 1000 : scaleX.x,
                            scaleY==null ? inBounds.y - 1000 : scaleY.y,
                            scaleX==null ? inBounds.width + 2000 : scaleX.width,
                            scaleY==null ? inBounds.height + 2000 : scaleY.height );
   }



   public static function get_current():Skin
   {
      if (sCurrent==null)
         sCurrent = new Skin();

      return sCurrent;
   }

   public function getTextFormat()
   {
      var fmt = new gm2d.text.TextFormat();
      fmt.size = 16;
      fmt.font = "Arial";
      return fmt;
   }


   public static function set_current(skin:Skin):Skin
   {
      sCurrent = skin;
      return sCurrent;
   }


   public function renderCurrent(inWidget:Widget)
   {
      var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 3, 3, false, false);
      inWidget.filters = [ glow ];
   }
   public function clearCurrent(inWidget:Widget)
   {
      inWidget.filters = null;
   }

   public function renderMenubar(inObject:gm2d.display.Sprite,inW:Float, inH:Float)
   {
      var gfx = inObject.graphics;
      gfx.clear();
      var mtx = new gm2d.geom.Matrix();
      mtx.createGradientBox(inH,inH,Math.PI * 0.5);
      var cols:Array<CInt> = [guiLight, guiMedium, guiDark];
      var alphas:Array<Float> = [1.0, 1.0, 1.0];
      var ratio:Array<Int> = [0, 128, 255];
      gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,inW,inH);
   }

   public function styleMenu(inItem:Button)
   {
      inItem.getLabel().backgroundColor = 0x4040a0;
      inItem.getLabel().textColor = 0x000000;
      inItem.onCurrentChangedFunc = function(_) { };
   }

   public function styleLabel(label:TextField)
   {
      label.defaultTextFormat = textFormat;
      label.textColor = labelColor;
      label.autoSize = TextFieldAutoSize.LEFT;
      label.selectable = false;
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

   public function styleText(inText:gm2d.text.TextField)
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
               return new Rectangle(2,8,4,10);
            else
               return new Rectangle(8,2,10,4);
         }
         else
            return new Rectangle(2,22,4,24);
      }
      return new Rectangle(0,0,0,0);
   }

   public function getMultiDockChromePadding(inN:Int,tabStyle:Bool) : Size
   {
      return new Size(0,tabStyle ? tabHeight : inN*24);
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
         var mtx = new gm2d.geom.Matrix();
         mtx.createGradientBox(21,21, Math.PI*-0.5, inRect.x+1.5, inRect.y+1.5);
         var cols:Array<Int> = [guiLight, guiMedium, guiDark];
         var alphas:Array<Float> = [1.0, 1.0, 1.0];
         var ratio:Array<Int> = [0, 128, 255];
         gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
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
               var state = getButtonBitmap(but,HitBoxes.BUT_STATE_UP);
               var button = new SimpleButton( state,
                                  getButtonBitmap(but,HitBoxes.BUT_STATE_OVER),
                                  getButtonBitmap(but,HitBoxes.BUT_STATE_DOWN), state );
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

    public function renderTabs(inTabContainer:Sprite,
                              inRect:Rectangle,
                              inPanes:Array<IDockable>,
                              inCurrent:IDockable,
                              outHitBoxes:HitBoxes,
                              inShowRestore:Bool  )
      {
         var flags = (inShowRestore ? TabRenderer.SHOW_RESTORE : 0) |
               TabRenderer.SHOW_TEXT | TabRenderer.SHOW_ICON | TabRenderer.SHOW_POPUP;
         tabRenderer.renderTabs(inTabContainer, inRect, inPanes, inCurrent, outHitBoxes, TabRenderer.TOP, flags ); }


   public function renderMultiDock(dock:MultiDock,inContainer:Sprite,outHitBoxes:HitBoxes,inRect:Rectangle,inDockables:Array<IDockable>,current:IDockable,tabStyle:Bool)
   {
      var gfx = inContainer.graphics;
      if (tabStyle)
      {
         gfx.beginFill(panelColor);
         gfx.drawRect(inRect.x,inRect.y+tabHeight,inRect.width,inRect.height-tabHeight);
         gfx.endFill();
         renderTabs(inContainer,inRect,inDockables, current, outHitBoxes, false );
         return;
      }

      var gap = inRect.height - inDockables.length*24;
      if (gap<0)
        gap = 0;
      var y = inRect.y;
      gfx.lineStyle();
      gfx.beginFill(panelColor);
      gfx.drawRect(inRect.x,inRect.y,inRect.width,inRect.height);
      gfx.endFill();

      for(d in inDockables)
      {
         gfx.beginFill(guiDark);
         gfx.drawRoundRect(inRect.x+1+0.5, y+0.5, inRect.width-2, 22,5,5);
         gfx.endFill();

         var pane = d.asPane();
         if (pane!=null)
         {
            var but = (current==d) ? MiniButton.MINIMIZE : MiniButton.EXPAND;
            var state =  getButtonBitmap(but,HitBoxes.BUT_STATE_UP);
            var button =  new SimpleButton( state,
                                        getButtonBitmap(but,HitBoxes.BUT_STATE_OVER),
                                        getButtonBitmap(but,HitBoxes.BUT_STATE_DOWN), state );
            inContainer.addChild(button);
            button.x = inRect.right-16;
            button.y = Std.int( y + 3);

            outHitBoxes.add(new Rectangle(inRect.x+2, y+2, inRect.width-18, 18), TITLE(pane) );

            if (outHitBoxes.mCallback!=null)
               button.addEventListener( MouseEvent.CLICK, function(e) outHitBoxes.mCallback( BUTTON(pane,but), e ) );
         }

         if (pane!=null)
         {
            var text = new TextField();
            styleText(text);
            text.selectable = false;
            text.mouseEnabled = false;
            text.text = pane.shortTitle;
            text.x = inRect.x+2;
            text.y = y+2;
            text.width = inRect.width-4;
            text.height = inRect.height-4;
            inContainer.addChild(text);
         }
         
         y+=24;
         if (d==current)
            y+=gap;
      }
   }

   public function getMultiDockRect(inRect:Rectangle,inDockables:Array<IDockable>,current:IDockable,tabStyle:Bool) : Rectangle
   {
      if (tabStyle)
         return new Rectangle(inRect.x, inRect.y + tabHeight, inRect.width, inRect.height-tabHeight);

      var pos = 0;
      for(i in 0...inDockables.length)
         if (current==inDockables[i])
            pos = i;
      return new Rectangle(inRect.x, inRect.y+24*(pos+1), inRect.width, Math.max(0,inRect.height-inDockables.length*24));
   }


   public function renderResizeBars(inDock:SideDock,inContainer:Sprite,outHitBoxes:HitBoxes,inRect:Rectangle,inHorizontal:Bool,inSizes:Array<Float>):Void
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


   function clearSprite(outSprite:Sprite)
   {
      outSprite.graphics.clear();
      while(outSprite.numChildren>0)
         outSprite.removeChildAt(0);
   }



   public function renderButton(outChrome:Sprite, inRect:Rectangle, inState:ButtonState)
   {
      clearSprite(outChrome);
      var gfx = outChrome.graphics;
      gfx.beginFill(inState==BUTTON_DISABLE ? disableColor : inState==BUTTON_UP ? controlColor : guiMedium );
      gfx.lineStyle(1,controlBorder);
      gfx.drawRoundRect(inRect.x+0.5,inRect.y+0.5,inRect.width-1,inRect.height-1,buttonCorner,buttonCorner);
   }

    public function renderProgressBar(inGfx:Graphics, inWidth:Float, inHeight:Float, inFraction:Float)
   {
      inGfx.clear();
      inGfx.beginFill(0xffffff);
      inGfx.lineStyle(1,0x000000);
      inGfx.drawRoundRect(0.5,0.5,inWidth,inHeight,6,6);
      inGfx.lineStyle();
      inGfx.beginFill(0x2020ff);
      inGfx.drawRoundRect(0.5,0.5,inWidth*inFraction,inHeight,6,6);
   }

   public function renderDialog(outChrome:Sprite, inPane:IDockable, inRect:Rectangle, outHitBoxes:HitBoxes)
   {
      outHitBoxes.clear();
      clearSprite(outChrome);

      var ox = inRect.x+0.5;
      var oy = inRect.y+0.5;
      var w = inRect.width;
      var h = inRect.height;

      var gfx = outChrome.graphics;
      gfx.clear();
      gfx.beginFill(panelColor);
      gfx.lineStyle(1,guiDark);

      gfx.drawRoundRect(ox,ox,w, h, 7,7 );

      if ( Dock.isResizeable(inPane) )
      {
         gfx.endFill();
         for(o in 0...4)
         {
            var dx = (o+2)*3;
            gfx.moveTo(w-dx,h);
            gfx.lineTo(w,h-dx);
         }
         outHitBoxes.add( new Rectangle(w-12,h-12,12,12), HitAction.RESIZE(inPane, ResizeFlag.S|ResizeFlag.E) );
      }

      var pane = inPane.asPane();
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
         titleField.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
         titleField.y = 2;

         //var f:Array<BitmapFilter> = [];
         //f.push( new DropShadowFilter(2,45,0xffffff,1,0,0,1) );
         //titleField.filters = f;

         outChrome.addChild(titleField);

         if (centerTitle)
            titleField.x = ox + Std.int((inRect.width-titleField.textWidth)/2);
      }

      outHitBoxes.add( new Rectangle(ox,ox,w,title_h), TITLE(inPane) );
   }


   public function renderMDI(inMDI:Sprite)
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

   function createButtonBitmap(inButton:Int, inState:Int) : BitmapData
   {
      var bmp = new BitmapData(16,16,true, gm2d.RGB.CLEAR );
      var shape = new gm2d.display.Shape();
      var gfx = shape.graphics;

      if (false)
      {
         var cols = [ 0xff0000, 0x00ff00, 0x0000ff ];
         gfx.beginFill(cols[inState]);
         gfx.drawRect(0,0,16,16);
         gfx.endFill();
      }


      gfx.lineStyle(1,0xffffff);
      var matrix = new Matrix();

      if (inButton==MiniButton.CLOSE)
      {
         gfx.moveTo(3,3);
         gfx.lineTo(12,12);
         gfx.moveTo(12,3);
         gfx.lineTo(3,12);
      }
      if (inButton==MiniButton.MINIMIZE)
      {
         gfx.moveTo(3,12);
         gfx.lineTo(12,12);
      }
      else if (inButton==MiniButton.MAXIMIZE)
      {
         gfx.drawRect(3,3,11,11);
      }
      else if (inButton==MiniButton.RESTORE)
      {
         gfx.drawRect(3,3,6,6);
         gfx.drawRect(8,8,6,6);
      }
      else if (inButton==MiniButton.EXPAND)
      {
         gfx.drawRect(4,2,8,12);
      }
      else if (inButton==MiniButton.POPUP)
      {
         gfx.beginFill(0xffffff);
         gfx.moveTo(5,7);
         gfx.lineTo(11,7);
         gfx.lineTo(8,10);
         gfx.lineTo(5,7);
      }

      else if (inButton==MiniButton.PIN)
      {
         gfx.moveTo(1,7);
         gfx.lineTo(5,7);
         gfx.drawRect(5,3,2,9);
         gfx.drawRect(7,5,6,5);
      }

      else if (inButton==MiniButton.ADD)
      {
         gfx.moveTo(3,7);
         gfx.lineTo(11,7);
         gfx.moveTo(7,11);
         gfx.lineTo(7,11);
      }
      else if (inButton==MiniButton.REMOVE)
      {
         gfx.moveTo(3,7);
         gfx.lineTo(11,7);
      }


      if (inState==HitBoxes.BUT_STATE_DOWN)
         matrix.tx = matrix.ty = 1.5;
      else
         matrix.tx = matrix.ty = 0.5;

      if (inState!=HitBoxes.BUT_STATE_UP)
      {
         // todo: why does this not work in flash
         var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 2, 2, false, false);
         shape.filters = [ glow ];
      }
        
      bmp.draw(shape,matrix);
      return bmp;
   }

   public function getButtonBitmapData(inButton:Int, inState:Int) : BitmapData
   {
      if (mBitmaps[inState][inButton]==null)
         mBitmaps[inState][inButton]=createButtonBitmap(inButton,inState);
      return mBitmaps[inState][inButton];
   }

   public function getButtonBitmap(inButton:Int, inState:Int) : Bitmap
   {
      return new Bitmap(getButtonBitmapData(inButton,inState));
   }


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
      return 2;
   }
   public function getSideBorder() : Float
   {
      return 0;
   }




   public function renderFrame(inObj:Sprite, pane:IDockable, inW:Float, inH:Float,
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
         var mtx = new gm2d.geom.Matrix();
         mtx.createGradientBox(title_h+borders,title_h+borders,Math.PI * 0.5);
         var cols:Array<CInt> = [guiLight, guiMedium, guiDark];
         var alphas:Array<Float> = [1.0, 1.0, 1.0];
         var ratio:Array<Int> = [0, 128, 255];
         gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
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
         var state =  getButtonBitmap(but,HitBoxes.BUT_STATE_UP);
         var button =  new SimpleButton( state,
                                        getButtonBitmap(but,HitBoxes.BUT_STATE_OVER),
                                        getButtonBitmap(but,HitBoxes.BUT_STATE_DOWN), state );
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
      if (mDrawing==null)
         mDrawing = new Shape();
      if (mText==null)
      {
         mText = new TextField();
         styleLabel(mText);
      }
   }

   public function getMDIClientChrome() { return new Rectangle(0,tabHeight, 0, tabHeight); }

  

   public function renderDropZone(inRect:Rectangle, outZones:DockZones, inPosition:DockPosition,
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
}



