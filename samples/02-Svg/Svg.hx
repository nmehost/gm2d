import nme.display.Sprite;
import gm2d.Game;
import gm2d.Screen;
import gm2d.reso.Resources;
import gm2d.svg.SvgRenderer;

import nme.ui.Keyboard;


class Svg extends Screen
{
   var mResources:Hash<Dynamic>;
   var view:Sprite;
   var dragging = false;
   var dragX = 0.0;
   var dragY = 0.0;

   // Usage:  SvgTest [file.svg [scale]]
   //  With no file, the bundled test.svg is shown at a quarter size.
   //  With a file, it is scaled to fit the window, or by the given scale.
   //  Mouse wheel zooms and dragging pans.
   function new()
   {
      super();

      var args = nme.system.System.getArgs();
      var file = args.length>0 ? args[0] : null;

      var source:gm2d.svg.Svg = null;
      if (file==null)
         source = Resources.loadSvg("test.svg");
      else
      {
         var bytes = nme.utils.ByteArray.readFile(file);
         if (bytes==null)
            throw "Could not read " + file;
         source = new gm2d.svg.Svg( Xml.parse(bytes.readUTFBytes(bytes.length)) );
      }

      var svg = new SvgRenderer(source);
      //var shape = svg.createShape();
      var shape = svg.createDisplayTree();

      var scale = 0.25;
      if (file!=null)
      {
         var stage = nme.Lib.current.stage;
         scale = Math.min( stage.stageWidth/source.width, stage.stageHeight/source.height );
         if (args.length>1 && Std.parseFloat(args[1])>0)
            scale = Std.parseFloat(args[1]);
      }
      shape.scaleX = shape.scaleY = scale;
      //shape.cacheAsBitmap = true;

      view = new Sprite();
      view.addChild(shape);
      addChild(view);

      var stage = nme.Lib.current.stage;
      stage.addEventListener(nme.events.MouseEvent.MOUSE_WHEEL, onWheel);
      stage.addEventListener(nme.events.MouseEvent.MOUSE_DOWN, onDown);
      stage.addEventListener(nme.events.MouseEvent.MOUSE_MOVE, onMove);
      stage.addEventListener(nme.events.MouseEvent.MOUSE_UP, onUp);

      makeCurrent();
   }

   function onWheel(e:nme.events.MouseEvent)
   {
      var factor = Math.pow(1.1, e.delta);
      // Keep the point under the mouse where it is
      view.x = e.stageX - (e.stageX-view.x)*factor;
      view.y = e.stageY - (e.stageY-view.y)*factor;
      view.scaleX = view.scaleY = view.scaleX*factor;
   }

   function onDown(e:nme.events.MouseEvent)
   {
      dragging = true;
      dragX = e.stageX;
      dragY = e.stageY;
   }

   function onMove(e:nme.events.MouseEvent)
   {
      if (dragging)
      {
         view.x += e.stageX-dragX;
         view.y += e.stageY-dragY;
         dragX = e.stageX;
         dragY = e.stageY;
      }
   }

   function onUp(e:nme.events.MouseEvent) dragging = false;

   override public function getScaleMode() { return gm2d.ScreenScaleMode.TOPLEFT_SCALED; }

   override public function updateDelta(inDT:Float)
   {
   }


   static public function main()
   {
      Game.showFPS = true;
      Game.fpsColor = 0xffffff;
      new Svg();
   }
}

