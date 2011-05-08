package gm2d.reso;

class Resources
{
   var mLoaded:Hash<Dynamic>;

   public function new()
   {
      mLoaded = new Hash<Dynamic>();
   }

   public function loadBitmap(inAssetName:String, inCache=false) : gm2d.display.BitmapData
   {
      if (mLoaded.exists(inAssetName)) return mLoaded.get(inAssetName);
      return null;
   }

   public function loadBytes(inAssetName:String, inCache=false) : haxe.io.Bytes
   {
      if (mLoaded.exists(inAssetName)) return mLoaded.get(inAssetName);
      #if flash
      var result:Dynamic = ApplicationMain.getAsset(inAssetName);
      #else
      var result = null
      #end
      if  (inCache) mLoaded.set(inAssetName,result);

      return result;
   }

   public function loadString(inAssetName:String, inCache=false) : String
   {
      return null;
   }


   public function loadSound(inAssetName:String, inCache=false) : gm2d.media.Sound
   {
      return null;
   }


   public function loadMusic(inAssetName:String, inCache=false) : gm2d.media.Sound
   {
      return null;
   }

   public function free(inResource:String)
   {
   }


}

