import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.filters.BitmapFilter;
import nme.filters.GlowFilter;
import nme.display.Shape;
import nme.display.StageDisplayState;
import nme.events.KeyboardEvent;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldAutoSize;
import nme.ui.Keyboard;
import gm2d.ui.Layout;
import gm2d.ui.MouseWatcher;
import nme.Assets;


class Talk extends Sprite
{
   public static var instance:Talk;

   public var guiScale = 1.0;
   var layout:Layout = null;
   var screen = 0;
   var update:Void->Void = null;
   var onOption:Int->Void = null;
   var defaultFont:String;
   var defaultTextColour = 0x000000;
   var bulletBmp:BitmapData;
   var borderTop = 20;
   var borderLeft = 10;
   var borderRight = 10;
   var borderBottom = 20;
   var options:Array<DisplayObject>;
   var option:Int = 0;
   var mouseWatcher:MouseWatcher;

   var screens:Array<Void->Void>;

   // Syntax colouring
   var white = "<font color='#ffffff'>";
   var grey = "<font color='#808080'>";
   var o = "</font>";
   var green = "<font color='#00ff00'>";
   var purple = "<font color='#ff00ff'>";
   var meta = "<font color='#80ff80' bold='true'>";
   var at = "<font color='#ff4040'>@:</font>";
   var yellow = "<font color='#ffff00'>";
   var keyword = "<font color='#ffff00'>";
   var blue = "<font color='#8080ff'>";
   var red = "<font color='#ff0000'>";
   var xm = "<font color='#00ff00'>";
   var xa = "<font color='#ffff00'>";

   public function new()
   {
      defaultFont = "_sans";
      #if !flash
      if (Sys.systemName()=="Mac")
         defaultFont = "Arial";
      #end
      instance = this;
      super();

      screens = [];
      for(i in 0...1000)
      {
         var render = Reflect.field(this, "renderScreen" + i);
         if (render!=null)
            screens.push(render);
      }

      screen = 0;
      onResize();

      stage.addEventListener( Event.ENTER_FRAME, function(_) if (update!=null) update() );
      stage.addEventListener( Event.RESIZE, function(_) onResize() );
      stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );

      mouseWatcher = MouseWatcher.create(stage, null, null, onMouseUp );
      mouseWatcher.minDragDistance = stage.stageWidth * 0.05;
   }

   function onKeyDown(event:KeyboardEvent )
   {
      if (event.keyCode==13 && event.altKey)
         toggleFullscreen();
      else if (event.keyCode==Keyboard.LEFT)
      {
         if (screen>0)
           setScreen(screen-1);
      }
      else if (event.keyCode==Keyboard.RIGHT)
      {
         setScreen(screen+1);
      }
      else if (event.keyCode==Keyboard.UP)
         setOption(option-1);
      else if (event.keyCode==Keyboard.DOWN)
         setOption(option+1);
      #if !flash
      if (event.keyCode==27 && event.altKey)
         Sys.exit(0);
      #end
   }

   static public function toggleFullscreen()
   {
      #if nme
      var stage = nme.Lib.current.stage;
      stage.displayState = Type.enumEq(stage.displayState,StageDisplayState.NORMAL) ?
         StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
      #end
   }

   public function onMouseUp(event:MouseEvent)
   {
      if (mouseWatcher.wasDragged)
      {
         if (mouseWatcher.draggedX()>0)
            setScreen(screen-1);
         else
            setScreen(screen+1);
      }
      else
      {
         for(o in 0...options.length)
            if (event.target==options[o])
            {
               setOption(o);
               return;
            }
         setScreen(screen+1);
      }
   }

   public function colour(inString:String) : String
   {
      var r =  (~/</g).replace(inString,"&lt;");
      r =  (~/\b(\d+)\b/g).replace(r,red+"$1"+o);
      r = (~/\b(using|new|class|virtual|for)\b/g).replace(r,keyword+"$1"+o);
      r = (~/\b(var|public|function)\b/g).replace(r,green+"$1"+o);
      r = (~/\b(target|lib )\b/g).replace(r,meta+"$1"+o);
      r = (~/("[^"]*")/g).replace(r,yellow+"$1"+o);
      var quoteMatch = ~/[^"]/;
      r = (~/\b(Array|__global__|__cpp__|name|if|Int|String)\b/g).replace(r,purple+"$1"+o);
      r = (~/\b(std::string)\b/g).replace(r,blue+"$1"+o);
      r = (~/@:(\w+)/g).replace(r,red+"@:"+ o + meta + "$1"+o);

      return r;
   }

   public function setScreen(inScreen:Int)
   {
      if (inScreen>=0 && inScreen<screens.length)
      {
         screen = inScreen;
         layout = null;
         options = [];
         onOption = null;
         graphics.clear();
         while(numChildren>0)
           removeChildAt(0);
         screens[screen]();
         setOption(0);
      }
   }

   public function relayout()
   {
      if (layout!=null)
         layout.align(0,0,stage.stageWidth, stage.stageHeight);
   }

   public function onResize()
   {
      var sw = stage.stageWidth / 640.0;
      var sh = stage.stageHeight / 480.0;
      guiScale = sw<sh ? sh : sh;
      if (guiScale<1)
         guiScale = 1;
      setScreen(screen);
   }

   public function setLayout(inLayout:Layout)
   {
      layout = inLayout;
      relayout();
   }

   function createText(inText:String,inSize = 24.0,?inColour:Null<Int>,?filter:BitmapFilter)
   {
      var fmt = new TextFormat();
      fmt.font = defaultFont;
      fmt.size = Std.int(inSize*guiScale);
      fmt.color = inColour==null ? defaultTextColour : inColour;
      var textField = new TextField();
      textField.defaultTextFormat = fmt;
      textField.multiline = true;
      textField.selectable = false;
      textField.htmlText = inText;
      if (filter!=null)
         textField.filters = [ filter ];
      addChild(textField);
      textField.autoSize = nme.text.TextFieldAutoSize.LEFT;
      return textField;
   }

   function createTextLayout(inText:String,inSize = 24.0,?inColour:Null<Int>,?filter:BitmapFilter) : TextLayout
   {
      return new TextLayout( createText(inText,inSize,inColour,filter) );
   }


   function createTitleLayout(inLayout:Layout)
   {
      var layout = new VerticalLayout();
      layout.setColStretch(0,1)
               .setSpacing(0,10*guiScale);
      layout.add( inLayout.setAlignment(Layout.AlignCenterX|Layout.AlignTop)  );
      layout.setBorders(borderLeft*guiScale, borderTop*guiScale, borderRight*guiScale, borderBottom*guiScale);
      return layout.stretch();
   }


   function createTitle(inTitle,inSize=36.0)
   {
      return createTitleLayout( createTextLayout(inTitle,inSize));
   }


   function createImage(inData:BitmapData, inTitle,inSize=36.0, ?inColour:Null<Int>, ?filter:BitmapFilter)
   {
      var layout = new StackLayout();
      var bitmap = new Bitmap(inData);
      addChild(bitmap);
      var bmpLayout = new DisplayLayout(bitmap).setAlignment(Layout.AlignKeepAspect);
      bmpLayout.onLayout = function(x,y,w,h) { bitmap.width = w; bitmap.height=h; }
      layout.add(bmpLayout);
      layout.add( createTextLayout(inTitle,inSize,inColour,filter)
               .setAlignment(Layout.AlignCenterX|Layout.AlignBottom)
               .setBorders(borderLeft*guiScale, 0, borderRight*guiScale, borderBottom*guiScale)
               );
      return layout.stretch();
   }

   public function addOption(inOption:DisplayObject)
   {
      var id = options.length;
      /*
      inOption.addEventListener( MouseEvent.CLICK, function(event:MouseEvent) {
          event.stopImmediatePropagation();
          setOption(id);
          });
      */
      options.push(inOption);
   }

   public function setOption(inOption:Int)
   {
      if (options.length>0)
      {
         option = inOption<0 ? 0 : inOption>=options.length-1 ? options.length-1 : inOption;
         for(o in 0...options.length)
         {
            var opt = options[o];
            if (o != option)
               opt.filters = [];
            else
            {
               var s = 2.0 * guiScale;
               var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, s, s, 3, 3, false, false);
               opt.filters = [ glow ];
            }
         }
         if (onOption!=null)
            onOption(option);
      }
   }

   function renderBmp(inBmp:BitmapData, inWidth:Float)
   {
      var shape = new Shape();
      var gfx = shape.graphics;
      var mtx = new Matrix();
      var scale = inWidth*guiScale/inBmp.width;
      mtx.a = scale;
      mtx.d = scale;
      gfx.beginBitmapFill( inBmp, mtx, false, true );
      gfx.drawRect(0,0,scale*inBmp.width,scale*inBmp.height);
      addChild(shape);
      return shape;
   }

   function getTime()
   {
      return haxe.Timer.stamp();
   }

   function createCodeBox(inText:String)
   {
      var result = new CodeBox(inText);
      addChild(result);
      return result;
   }

   function codePoint(ioLayout:Layout,inText:String, inIndent=1)
   {
      var offset = (bulletBmp!=null) ? 20*guiScale : 0;
      ioLayout.add(createCodeBox(inText).layout
            .setAlignment(Layout.AlignCenterY)
            .setIndent(inIndent*20*guiScale + offset));
   }

   function bullet(ioLayout:Layout, inText:String,inIndent = 1) : DisplayObject
   {
      var textLayout = createTextLayout(inText);

      textLayout.setAlignment(Layout.AlignLeft|Layout.AlignCenterY)
          .setPadding(20*guiScale,0);

      if (bulletBmp!=null)
      {
         var bullet = renderBmp(bulletBmp,20);
         var bulletLayout = new DisplayLayout(bullet)
                   .setAlignment(Layout.AlignTop)
                   .setPadding(0,10*guiScale);
         var hlayout = new HorizontalLayout()
              .setAlignment(Layout.AlignLeft|Layout.AlignCenterY)
              .setIndent( (inIndent) * 20 * guiScale );

         hlayout.add(bulletLayout);
         hlayout.add(textLayout);
         ioLayout.add( hlayout );
      }
      else
      {
         textLayout.setIndent( (inIndent) * 20 * guiScale );
         ioLayout.add( textLayout );
      }
      return textLayout.getDisplayObject();
   }

}



