package gm2d.ui2;
import nme.utils.ByteArray;
import gm2d.ui2.ProgressDialog;

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
            inData:ByteArray,
            onResult:String->Void,
            onError:String->Void,
            ?inExtension:String,
            ?inDefaultPath:String,
            ?saveName:String,
            inFlags:Int = 0)
   {
      #if waxe
      #elseif flash
      #else

      var openScreen = new gm2d.ui2.FileOpenScreen(inMessage, inDefaultPath==null?"":inDefaultPath,
         null, inExtension, inFlags | FileOpen.SAVE, saveName );
      openScreen.onSaveResult = onResult;
      openScreen.onError = onError;
      openScreen.extension = inExtension;

      #end
   }

}


