package gm2d.ui;
import nme.utils.ByteArray;
import gm2d.ui.ProgressDialog;

#if flash

import flash.net.FileReference;
import flash.net.FileFilter;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;

#elseif waxe

import wx.FileDialog;

#end


class FileSave
{
   public static function saveAs(inMessage:String,
            onResult:String->Void,
            onError:String->Void,
            ?inExtension:String,
            ?inDefaultPath:String,
            ?saveName:String,
            inFlags:Int = 0)
   {
      if (saveName!=null)
      {
         var parts = saveName.split("\\").join("/").split("/");
         if (parts.length>1)
         {
            saveName = parts.pop();
            if (inDefaultPath==null)
               inDefaultPath = parts.join("/");
         }
      }


      #if waxe
        var flags = inFlags | FileDialog.SAVE | FileDialog.OVERWRITE_PROMPT;
        
        var dialog = new wx.FileDialog(
               null,
               inMessage,
               inDefaultPath,
               saveName,
               inExtension==null ? null : "*." + inExtension,
               flags);
        if (dialog.showModal())
        {
           var dir = dialog.directory;
           var name = dir + "/" + dialog.file;
           onResult(name);
        }
        else
           onResult(null);
      #elseif flash
      #else

      var openScreen = new gm2d.ui.FileOpenScreen(inMessage, inDefaultPath==null?"":inDefaultPath,
         null, inExtension, inFlags | FileOpen.SAVE, saveName );
      openScreen.onSaveResult = onResult;
      openScreen.onError = onError;

      #end
   }

}


