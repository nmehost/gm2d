import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.svg.SVG2Gfx;

#if haxe3
import haxe.io.Path;
#else
import neko.io.Path;
#end

class RenderToImage
{
   static public function Usage()
   {
     neko.Lib.print("Usage RenderToImage [-w Width] [-h Height] [-ox OX] [-oy OY] file.svg outfile.png");
   }

   static public function main()
   {
      var in_file = "";
      var out_file = "";
      var out_width = 32;
      var out_height = 32;
      var bmp_w:Null<Int> = null;
      var bmp_h:Null<Int> = null;
      var ox:Null<Float> = null;
      var oy:Null<Float> = null;
      var scale:Null<Float> = null;
      var alpha = 0xff;
      var bg = 0xffffff;
      var quality = 0.75;

      #if haxe3
      var args = Sys.args();
      #elseif neko
      var args = neko.Sys.args();
      #elseif cpp
      var args = cpp.Sys.args();
      #end

      var skip = false;
      var i = 0;
      while(i<args.length)
      {
         var arg = args[i++];
         if (arg.substr(0,1)=="-")
         {
            switch(arg.substr(1))
            {
               case "w" : bmp_w = Std.parseInt(args[i++]);
               case "h" : bmp_h = Std.parseInt(args[i++]);
               case "ox" : ox = Std.parseFloat(args[i++]);
               case "oy" : oy = Std.parseFloat(args[i++]);
               case "scale" : scale = Std.parseFloat(args[i++]);
               case "alpha" : alpha = Std.parseInt(args[i++]);
               case "bg" : bg = Std.parseInt(args[i++]);
               case "quality" : quality = Std.parseFloat(args[i++]);
            }
         }
         else
         {
            if (in_file=="")
               in_file = arg;
            else if (out_file=="")
               out_file = arg;
            else
            {
               Usage();
               return;
            }
         }
      }
      if (out_file=="")
      {
          Usage();
          return;
      }


      var bytes = nme.utils.ByteArray.readFile(args[0]);
      var svg:SVG2Gfx = new SVG2Gfx( Xml.parse(bytes.asString()) );

		var shape = svg.CreateShape();
      var data_width = shape.width;
      var data_height = shape.height;
      if (scale!=null)
      {
         data_width *= scale;
         data_height *= scale;
      }
      if (bmp_w==null)
         bmp_w = Std.int(data_width+0.9999);
      if (bmp_h==null)
         bmp_h = Std.int(data_height+0.9999);
      if (scale==null)
      {
         var sx = bmp_w/data_width;
         var sy = bmp_h/data_width;
         scale = sx<sy ? sx : sy;
         if (scale<1.01 && (data_width < bmp_w) && (data_height < bmp_h) )
            scale = 1.0;
      }
         
      // trace("Active size: " + bmp_w + "x" + bmp_h + " scale " + scale );

      shape.scaleX = scale;
      shape.scaleY = scale;
      if (ox!=null)
         shape.x = ox;
      if (oy!=null)
         shape.y = oy;

      var bmp = new BitmapData(bmp_w,bmp_h, alpha<255, {a:alpha, rgb:bg} );

      bmp.draw(shape);

      var bytes = bmp.encode(Path.extension(out_file),quality);

      bytes.writeFile(out_file);
      
      // trace("Done !");
   }
}

