package gm2d.reso;

import gm2d.utils.IDataInput;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;

#if haxe3
typedef ResourceMap<T> = haxe.ds.StringMap<T>;
#else
typedef ResourceMap<T> = Hash<T>;
#end


class Resources
{
   static var mLoaded = new ResourceMap<Dynamic>();

   static public function loadAsset(inAssetName:String, inCache=false) : Dynamic
   {
      if (mLoaded.exists(inAssetName)) return mLoaded.get(inAssetName);
      var result = ApplicationMain.getAsset(inAssetName);
      if (result==null)
         throw "Missing asset: " + inAssetName;
      if  (inCache) mLoaded.set(inAssetName,result);
      return result;
   }


   static public function loadBitmap(inAssetName:String, inCache=false) : gm2d.display.BitmapData
   {
      return loadAsset(inAssetName,inCache);
   }

   static public function loadBytes(inAssetName:String, inCache=false) : gm2d.utils.ByteArray
   {
      return loadAsset(inAssetName,inCache);
   }


   static public function loadString(inAssetName:String, inCache=false) : String
   {
      var bytes = loadAsset(inAssetName,inCache);
      var string:String;
      #if neko
      if (bytes==null)
         return null;
      string = Std.string(bytes);
      #else
      string = bytes;
      #end

      if (inCache)
         mLoaded.set(inAssetName,string);
      return string;
   }

   static public function loadXml(inAssetName:String, inCache=false) : Xml
   {
      var str = loadString(inAssetName,false);
      if (str==null)
         return null;
      var xml:Xml = Xml.parse(str);
      if (xml==null)
         return null;
      if (inCache)
         mLoaded.set(inAssetName,xml);
      return xml;
   }

   static public function loadSvg(inAssetName:String, inCache=false) : Svg
   {
      var cached = mLoaded.get(inAssetName);
      if (cached!=null && Std.is(cached,Svg))
         return cached;

      var xml:Xml = loadXml(inAssetName,false);
      if (xml==null)
         return null;
      var svg = new Svg(xml);
      if (inCache)
         mLoaded.set(inAssetName,svg);
      return svg;
   }

   static public function loadSvgRenderer(inAssetName:String, inCache=false) : SvgRenderer
   {
      return new SvgRenderer(loadSvg(inAssetName,inCache));
   }



   static public function loadSound(inAssetName:String, inCache=false) : gm2d.media.Sound
   {
      return loadAsset(inAssetName,inCache);
   }


   static public function free(inResource:String)
   {
      if (mLoaded.exists(inResource))
         mLoaded.remove(inResource);
   }
}


