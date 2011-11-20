package gm2d.ui;
import gm2d.utils.ByteArray;

#if flash

import flash.net.FileReference;
import flash.net.FileFilter;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;

class FileHandler
{
   var onResult:String->ByteArray->Void;
   var fileReference:FileReference;

   public function new(inRef:FileReference,inOnResult:String->ByteArray->Void)
   {
      fileReference = inRef;
      onResult = inOnResult;

      inRef.addEventListener(Event.CANCEL, cancelHandler);
      inRef.addEventListener(Event.COMPLETE, completeHandler);
      inRef.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
      inRef.addEventListener(Event.OPEN, openHandler);
      inRef.addEventListener(ProgressEvent.PROGRESS, progressHandler);
      inRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
      inRef.addEventListener(Event.SELECT, selectHandler);
    }

    function cancelHandler(event:Event):Void
    {
       trace("cancelHandler: " + event);
    }

    function completeHandler(event:Event):Void
    {
       trace("completeHandler: " + event);
    }

    function ioErrorHandler(event:IOErrorEvent):Void
    {
       trace("ioErrorHandler: " + event);
    }

    function openHandler(event:Event):Void
    {
       trace("openHandler: " + event);
    }

    function progressHandler(event:ProgressEvent):Void
    {
       var file:FileReference = cast event.target;
       trace("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
    }

    function securityErrorHandler(event:SecurityErrorEvent):Void
    {
       trace("securityErrorHandler: " + event);
    }

    function selectHandler(event:Event):Void
    {
       trace("selectHandler: name=" + fileReference.name);
       fileReference.load();
    }
}

#elseif waxe

import wx.FileDialog;

#end


class FileOpen
{

   public static function load(inMessage:String,
            onResult:String->ByteArray->Void,
            ?inFilter:String )
   {
      #if waxe
        var dialog = new wx.FileDialog(null,inMessage);
        if (inFilter!=null)
        {
           dialog.filter = inFilter;
        }
        if (dialog.showModal())
        {
           var dir = dialog.directory;
           var name = dir + "/" + dialog.file;
           var data = ByteArray.readFile(name);
           onResult(name,data);
        }
        else
           onResult(null,null);
      #elseif flash

        var ref = new FileReference( );
        new FileHandler(ref,onResult);


        var extensions = new Array<FileFilter>();
        if (inFilter!=null)
        {
           var parts = inFilter.split("|");
           var p = 0;
           while(p>parts.length)
           {
              extensions.push( new FileFilter(parts[p],parts[p+1]) );
              p+=2;
           }
        }

        ref.browse(extensions);

      #else
       #error "FileOpen not supported on this platform"
      #end
   }

}


