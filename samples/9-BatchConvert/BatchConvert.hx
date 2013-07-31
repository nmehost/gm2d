import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.geom.Point;
import gm2d.geom.Rectangle;
import haxe.io.Path;
import sys.FileSystem;

class BatchConvert
{
   var from:String = null;
   var to:String = null;
   var quality = 0.95;
   var filter:String = null;
   var outExt:String = null;
   var testRun = false;
   var job:BitmapData->BitmapData;

   static public function Usage(?inMessage:String)
   {
      Sys.println("");
      Sys.println("Usage: BatchConvert -from FromPath -to ToPath ...");
      Sys.println("  -quality JPEGQ (out of 100)");
      Sys.println("  -filter exts (; separated list of extensions)");
      Sys.println("  -outext Ext (set output extension)");
      Sys.println("  -test (test run, do not process)");
      Sys.println("  -jps2jpg (extract left half of image)");
      if (inMessage!=null)
         Sys.println("\n" + inMessage + "\n");
   }

   function matches(file:String):Bool
   {
      if (file.substr(0,1)=='.')
         return false;
      if (filter==null)
         return true;
      var path = new Path(file);
      var ext = path.ext;
      for(test in filter.split(";"))
         if (ext==test)
            return true;
      return false;
   }

   function recompress(image:BitmapData) : BitmapData { return image; }

   function jps2Jpg(image:BitmapData) : BitmapData
   {
      var w = image.width;
      var h = image.height;
      var result = new BitmapData(w>>1,h,false);
      result.copyPixels(image, new Rectangle(w>>1,0,w>>1,h), new Point(0,0));
      return result;
   }

   public function makeOutDir(inDir:String)
   {
      var parts = inDir.split("/");
      var total = "";
      for(part in parts)
      {
         if (part!="." && part!="")
         {
            if (total!="") total+="/";
            total += part;
            if (!FileSystem.exists(total))
               try
               {
                  if (testRun)
                     Sys.println("mkdir " + total + "/");
                  else
                     FileSystem.createDirectory(total + "/");
               } catch (e:Dynamic)
               {
                  return false;
               }
         }
      }
      return true;
   }

   static public function main()
   {
      new BatchConvert();
   }

   function Convert(inFrom:String, inTo:String)
   {
      if (testRun)
      {
         Sys.println('Convert $inFrom -> $inTo');
      }
      else
      {
         var image = BitmapData.load(inFrom);
         Sys.println("Loaded " + inFrom + ":" + image.width + "x" + image.height);
         var result = job(image);

         var bytes = result.encode(Path.extension(inTo),quality);

         try
         {
            bytes.writeFile(inTo);
         }
         catch (e:Dynamic)
         {
            Sys.println("Error writing " + inTo);
            return;
         }
         Sys.println("Wrote " + inTo + ":" + bytes.length + " bytes");
      }
   }

   function ProcessFiles(files:Array<String>)
   {
      var forceGc = 5;
      for(file in files)
      {
         var inFile = from + "/" + file;
         if (outExt!=null)
         {
            var bits = file.split(".");
            if (bits.length==1)
               bits.push(outExt);
            else
               bits[bits.length-1] = outExt;
            file = bits.join(".");
         }
         var outFile = to + "/" + file;

         Convert(inFile,outFile);

         forceGc--;
         if (forceGc==0)
         {
            #if neko
            neko.vm.Gc.run(true);
            #else
            cpp.vm.Gc.run(true);
            #end
            forceGc = 5;
         }
      }
   }

   function new()
   {
      var args = Sys.args();

      job = recompress;
      var skip = false;
      var i = 0;
      while(i<args.length)
      {
         var arg = args[i++];
         if (arg.substr(0,1)=="-")
         {
            switch(arg.substr(1))
            {
               case "f", "from" : from = args[i++];
               case "t", "to" : to = args[i++];
               case "test" : testRun = true;
               case "filter" : filter = args[i++];
               case "outext" : outExt = args[i++];
               case "q","quality" : quality = Std.parseFloat(args[i++]);
                  if (quality<=1 || quality>100)
                  {
                     Usage("quality must be greater than 1 and less than or equal to 100");
                     return;
                  }
                  quality *= 0.01;
               case "jps2jpg" : filter = "jps"; outExt="jpg"; job=jps2Jpg;
               default:
                  Usage("Unknown switch " + arg);
                  return;
            }
         }
         else
         {
           Usage();
           return;
         }
      }

      if (from==null)
      {
         Usage("No from directory supplied");
         return;
      }

      if (to==null)
      {
         Usage("No to directory supplied");
         return;
      }

      var files = new Array<String>();
      try
      {
         if (FileSystem.isDirectory(from))
         {
            var tests = FileSystem.readDirectory(from);
            for(file in tests)
            {
               if (matches(file))
                  files.push(file);
            }
         }
         else
         {
            if (matches(from))
               files.push(from);
         }
      }
      catch(e:Dynamic)
      {
         Usage("Error reading input " + e);
         return;
      }

      if (files.length<1)
      {
         Sys.println('No files found matching [$filter]');
         return;
      }

      if (!makeOutDir(to))
      {
         Sys.println('Could not make output dir $to');
         return;
      }

      ProcessFiles(files);
   }
}

