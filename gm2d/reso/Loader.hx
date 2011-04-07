package gm2d.reso;

import gm2d.net.URLLoader;
import gm2d.net.URLRequest;
import gm2d.events.Event;
import gm2d.events.IOErrorEvent;

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

   function loadBitmapBytes(inBytes:haxe.io.Bytes,inAsReso:String)
   {
      #if flash

      var loader = new gm2d.display.Loader();
      var me = this;
      mRequests++;
      loader.contentLoaderInfo.addEventListener(gm2d.events.Event.COMPLETE,
          function(e:gm2d.events.Event)
             {
             var obj:gm2d.display.Bitmap = untyped loader.content;

             me.mResources.set(inAsReso,obj.bitmapData);
             me.OneComplete();
             }
          );
       loader.contentLoaderInfo.addEventListener(gm2d.events.IOErrorEvent.IO_ERROR, OnError);
       loader.contentLoaderInfo.addEventListener(gm2d.events.SecurityErrorEvent.SECURITY_ERROR, OnError);
       loader.loadBytes(inBytes.getData());
      #else
      var bmp = gm2d.display.BitmapData.loadFromHaxeBytes(inBytes);
      mResources.set(inAsReso,bmp);
      #end
   }

   public function loadBitmap(inResoName:String, inAsResource:String="")
   {
	   if (inAsResource=="")
		   inAsResource = inResoName;

      var bytes = haxe.Resource.getBytes(inResoName);
		if (bytes!=null)
		{
		   loadBitmapBytes(bytes,inAsResource);
			return;
		}

	   #if nme
      var bmp = gm2d.display.BitmapData.load(inResoName);
      mResources.set(inAsResource,bmp);
      #else
      var urlReq = new gm2d.net.URLRequest(inResoName);
      var loader = new gm2d.display.Loader();
      var me = this;
      mRequests++;
      loader.contentLoaderInfo.addEventListener(gm2d.events.Event.COMPLETE,
          function(e:gm2d.events.Event)
             {
             var obj:gm2d.display.Bitmap = untyped loader.content;

             me.mResources.set(inAsResource,obj.bitmapData);
             me.OneComplete();
             }
          );
       loader.contentLoaderInfo.addEventListener(gm2d.events.IOErrorEvent.IO_ERROR, OnError);
       loader.contentLoaderInfo.addEventListener(gm2d.events.SecurityErrorEvent.SECURITY_ERROR, OnError);
       loader.load(urlReq);
      #end
   }

   public function LoadXML(inFilename:String, inResourceName:String,?inTransform:Dynamic)
   {
   #if flash
      mRequests++;
      var me = this;
      var loader:URLLoader = new URLLoader();
      loader.dataFormat = gm2d.net.URLLoaderDataFormat.TEXT;
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
      loader.addEventListener(gm2d.events.IOErrorEvent.IO_ERROR, OnError);
      loader.addEventListener(gm2d.events.SecurityErrorEvent.SECURITY_ERROR, OnError);
      loader.load(new URLRequest(inFilename));
   #else
       var xml_data = nme.utils.ByteArray.readFile(inFilename).asString();
       //trace("Got reso data : " + inFilename + " = " + xml_data.length );

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
