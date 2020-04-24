import nme.display.*;
import gm2d.svg.SvgRenderer;
using StringTools;


class Svg extends Sprite
{
   var allSvgs:Array<String>;
   var pos = 0;

   function new()
   {
      super();

      allSvgs = [];

      var args = Sys.args();
      if (args.length==0)
      {
         Sys.println("Usage: SvgDir dirname | name1.svg name2.svg ...");
      }
      else
      {
         for(a in args)
         {
            if (a.endsWith(".svg"))
               allSvgs.push(a);
            else
            {
               try
               {
                  for(f in sys.FileSystem.readDirectory(a))
                     if (f.endsWith(".svg"))
                        allSvgs.push(a + "/" + f);
               }
               catch(e:Dynamic)
               {
                  trace("Error:" + e);
               }
            }
         }
      }

      Sys.println("Found " + allSvgs.length + " files");
      if (allSvgs.length>0)
      {
         stage.addEventListener( nme.events.MouseEvent.CLICK, (_)->next() );
         next();
      }
   }
   function next()
   {
      var filename = allSvgs[pos];
      pos = (pos+1)%allSvgs.length;
      while(numChildren>0)
         removeChildAt(0);

      try
      {
         var file = sys.io.File.getContent(filename);

         var xml:Xml = Xml.parse(file);
         var svg = new gm2d.svg.Svg(xml,true);
         var renderer = new SvgRenderer(svg);
         var shape = renderer.createShape();
         var scale = Math.min( stage.stageWidth/svg.width, stage.stageHeight/svg.height);
         shape.scaleX = shape.scaleY = scale;
         shape.x = (stage.stageWidth-svg.width*scale)*0.5;
         shape.y = (stage.stageHeight-svg.height*scale)*0.5;
         addChild(shape);
         Sys.println(filename);
      }
      catch(e:Dynamic)
      {
         trace('Error loading: $filename, $e');
      }

   }
}

