package gm2d.ui;
import gm2d.utils.ByteArray;
import gm2d.ui.ProgressDialog;

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
   var progressDialog:ProgressDialog;

   public function new(inRef:FileReference,inOnResult:String->ByteArray->Void)
   {
      fileReference = inRef;
      onResult = inOnResult;
      progressDialog = null;

      inRef.addEventListener(Event.CANCEL, cancelHandler);
      inRef.addEventListener(Event.COMPLETE, completeHandler);
      inRef.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
      inRef.addEventListener(Event.OPEN, openHandler);
      inRef.addEventListener(ProgressEvent.PROGRESS, progressHandler);
      inRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
      inRef.addEventListener(Event.SELECT, selectHandler);
    }

    function showProgress(inName:String, inSize:Float)
    {
       if (progressDialog==null)
       {
          progressDialog = new ProgressDialog(inName,"Upload",inSize, 
            function() { fileReference.cancel(); closeProgress(); } );
          gm2d.Game.doShowDialog(progressDialog,true);
          progressDialog.update(10000);
       }
    }
    function closeProgress()
    {
       if (progressDialog!=null)
       {
          progressDialog = null;
          Game.closeDialog();
       }
    }

    function cancelHandler(event:Event):Void
    {
       closeProgress();
       onResult(fileReference.name,null);
       //trace("cancelHandler: " + event);
    }

    function completeHandler(event:Event):Void
    {
       closeProgress();
       onResult(fileReference.name,fileReference.data);
       //trace("completeHandler: " + event);
    }

    function ioErrorHandler(event:IOErrorEvent):Void
    {
       closeProgress();
       onResult(fileReference.name,null);
       //trace("ioErrorHandler: " + event);
    }

    function openHandler(event:Event):Void
    {
       //trace("openHandler: " + event);
    }

    function progressHandler(event:ProgressEvent):Void
    {
       if (progressDialog!=null)
          progressDialog.update(event.bytesLoaded);

       //trace("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
    }

    function securityErrorHandler(event:SecurityErrorEvent):Void
    {
       closeProgress();
       onResult(null,null);
       //trace("securityErrorHandler: " + event);
    }

    function selectHandler(event:Event):Void
    {
       showProgress(fileReference.name, fileReference.size);
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


