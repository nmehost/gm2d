package gm2d.swf;


import nme.display.BitmapData;
import nme.display.Loader;
import nme.display.MovieClip;
import nme.events.Event;
import nme.media.Sound;
import nme.net.URLRequest;
import nme.system.ApplicationDomain;
import nme.system.LoaderContext;
import nme.text.Font;
import nme.utils.ByteArray;
import haxe.Unserializer;
import nme.Assets;


@:keep
class SWFLibrary extends AssetLibrary
{
   private var context:LoaderContext;
   private var id:String;
   private var loader:Loader;
   private var swf:SWF;

   public function new(inId:String)
   {
      super ();
      id = inId;
   }

   public override function exists(id:String, type:AssetType):Bool
   {
      if (id == "" && type == AssetType.MOVIE_CLIP)
         return true;
      if (type == AssetType.IMAGE || type == AssetType.MOVIE_CLIP)
         return swf.hasSymbol(id);
      return false;
   }

   public override function getBitmapData(id:String):BitmapData
   {
      return swf.createSymbolInstance(id);
   }
   
   public override function getMovieClip(id:String):MovieClip
   {
      if (id=="")
         return swf.createInstance();
      return swf.createSymbolInstance(id);
   }

   public override function load(handler:AssetLibrary->Void):Void
   {
      if (swf == null)
      {
         swf = new SWF(Assets.getBytes(id));
         handler(this);
      }
   }
}

