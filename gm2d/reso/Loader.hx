package gm2d.reso;

#if flash
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.IOErrorEvent;
#end

class Loader
{
   var mLoadedCount:Int;
   var mRequests:Int;
   var mError:Bool;
   var mOnFinished: Resources -> Void;
   var mResources : Resources;

   public function new()
   {
      mLoadedCount = 0;
      mRequests = 0;
      mError = false;
      mOnFinished = null;
      mResources = new Resources();
   }

   public function Loaded():Bool
   {
      return mLoadedCount == mRequests;
   }

   function OnError(e:Dynamic)
   {
      trace("Error:" + e);
   }

   function OneComplete()
   {
      mLoadedCount++;
      if (Loaded() && mOnFinished!=null)
         mOnFinished(mResources);
   }

   public function loadBitmapResource(inResourceName:String)
   {
      var bytes = haxe.Resource.getBytes(inResourceName);
      #if flash

       var loader = new flash.display.Loader();
       var me = this;
       mRequests++;
       loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,
          function(e:flash.events.Event)
             {
             var obj:flash.display.Bitmap = untyped loader.content;

             me.mResources.set(inResourceName,obj.bitmapData);
             me.OneComplete();
             }
          );
       loader.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, OnError);
       loader.contentLoaderInfo.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, OnError);
       loader.loadBytes(bytes.getData());
 

      #else
      var bmp = nme.display.BitmapData.loadFromHaxeBytes(bytes);
      mResources.set(inResourceName,bmp);
      #end
   }

   public function loadBitmap(inFilename:String, inResourceName:String)
   {
   #if flash
       var urlReq = new flash.net.URLRequest(inFilename);
       var loader = new flash.display.Loader();
       var me = this;
       mRequests++;
       loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,
          function(e:flash.events.Event)
             {
             var obj:flash.display.Bitmap = untyped loader.content;

             me.mResources.set(inResourceName,obj.bitmapData);
             me.OneComplete();
             }
          );
       loader.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, OnError);
       loader.contentLoaderInfo.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, OnError);
       loader.load(urlReq);
   #else
       var bmp = nme.display.BitmapData.load(inFilename);
       mResources.set(inResourceName,bmp);
   #end
   }

   public function LoadXML(inFilename:String, inResourceName:String,?inTransform:Dynamic)
   {
   #if flash
      mRequests++;
      var me = this;
      var loader:URLLoader = new URLLoader();
      loader.dataFormat = flash.net.URLLoaderDataFormat.TEXT;
      loader.addEventListener(Event.COMPLETE, function(e:Event) {
           var str:String = loader.data;
           var node:Xml=Xml.parse(str);
           if (inTransform==null)
              me.mResources.set(inResourceName,node);
            else
               me.mResources.set(inResourceName,inTransform(node));
            me.OneComplete();
         } );
      // TODO: track loading byte status ...
      loader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, OnError);
      loader.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, OnError);
      loader.load(new URLRequest(inFilename));
   #else
       var xml_data = nme.utils.ByteArray.readFile(inFilename).asString();
       trace("Got reso data : " + inFilename + " = " + xml_data.length );

       //if (xml_data==null)
          //xml_data = cpp.io.File.getContent(inFilename);
       if (xml_data.length < 1)
          throw ("Could not find file:" + inFilename);
       var xml = Xml.parse(xml_data);
       if (inTransform==null)
          mResources.set(inResourceName,xml);
       else
          mResources.set(inResourceName,inTransform(xml));
   #end
   }

   public function loadSVG(inFilename:String, inResourceName:String)
   {
      LoadXML(inFilename,inResourceName,
         function(xml:Xml) { return new gm2d.svg.SVG2Gfx(xml); } );
   }

   public function Process( inOnFinished:Dynamic->Void )
   {
      mOnFinished = inOnFinished;
      if (Loaded() && mOnFinished!=null)
         mOnFinished(mResources);
   }

}
