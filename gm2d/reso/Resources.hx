package gm2d.reso;

import nme.utils.IDataInput;
import nme.Assets;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;


class Resources
{
   static public function loadAsset(inName:String, ?inCache:Bool) : Dynamic
   {
      var i = Assets.getInfo(inName);
      if (i==null)
         throw "Missing asset: " + inName;

      var cached = i.getCache();
      if (cached!=null)
         return cached;
      switch(i.type)
      {
         case BINARY, TEXT: return Assets.getBytes(inName,inCache);
         case FONT: return Assets.getFont(inName,inCache);
         case IMAGE: return Assets.getBitmapData(inName,inCache);
         case MUSIC, SOUND: return Assets.getSound(inName,inCache);
         case _: throw "Unknown asset type: " + i.type;
      }

      return null;
   }


   static public function loadBitmap(inAssetName:String, ?inCache:Bool) : nme.display.BitmapData
   {
      return Assets.getBitmapData(inAssetName,inCache);
   }

   static public function loadBytes(inAssetName:String, ?inCache:Bool) : nme.utils.ByteArray
   {
      return Assets.getBytes(inAssetName,inCache);
   }


   static public function loadString(inAssetName:String, ?inCache:Bool) : String
   {
      return Assets.getString(inAssetName,inCache);
   }

   static public function loadXml(inAssetName:String, ?inCache:Bool) : Xml
   {
      var str = loadString(inAssetName,inCache);
      if (str==null)
         return null;
      var xml:Xml = Xml.parse(str);
      if (xml==null)
         return null;
      //if (inCache)
      //   mLoaded.set(inAssetName,xml);
      return xml;
   }

   static public function loadSvg(inAssetName:String, ?inCache:Bool) : Svg
   {
      //var cached = mLoaded.get(inAssetName);
      //if (cached!=null && Std.is(cached,Svg))
      //   return cached;

      var xml:Xml = loadXml(inAssetName,inCache);
      if (xml==null)
         return null;
      var svg = new Svg(xml);
      //if (inCache)
      //   mLoaded.set(inAssetName,svg);
      return svg;
   }

   static public function loadSvgRenderer(inAssetName:String, ?inCache:Bool) : SvgRenderer
   {
      return new SvgRenderer(loadSvg(inAssetName,inCache));
   }



   static public function loadSound(inAssetName:String, ?inCache:Bool) : nme.media.Sound
   {
      return loadAsset(inAssetName,inCache);
   }

}


