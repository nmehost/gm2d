package gm2d.ui;

import nme.text.TextField;
import gm2d.ui.Button;
import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;


class FileBox extends TextInput
{
   var mButtonX:Float;
   var onText:String->Void;
   var isDir:Bool;
   var rightAlign = true;
   var defaultText:String;

   public function new(inVal="", ?inLineage:Array<String>, ?inAttribs:{})
   {
       super(inVal, null, Widget.addLine(inLineage,"FileBox"), inAttribs);
       isDir = attribBool("directory",false);
       setText( inVal );
       if (inVal=="" || inVal==null)
       {
          var rememberKey = attribString("dir_id");
          if (rememberKey!=null)
          {
             var def = nme.system.Dialog.getDefaultPath(rememberKey);
             setText( def );
             if (!isDir)
                defaultText = def;
          }
          else
          {
             setText( inVal );
          }
       }
   }

   override public function get(inValue:Dynamic) : Void
   {
      if (Reflect.hasField(inValue,name))
      {
         var value = getText();
         if (defaultText==null || value!=defaultText)
            Reflect.setField(inValue, name, value );
      }
   }

   function onBrowse()
   {
      var title = attribString("browseTitle",isDir ? "Select Directory" : "Select File");
      // remembered in panel
      var rememberKey = attribString("dir_id");
      if (isDir)
      {
         nme.system.Dialog.getDirectory(title,"Directory", function(f) if (f!=null) setTextEnter(f),rememberKey );
      }
      else
      {
         var flags = attribInt("browseFlags",0);
         var ext = attribString("browseFilter","All Files|*.*");
         var start = getText();
         nme.system.Dialog.fileDialog(title,"File", getText(), ext,
             function(f) if (f!=null) setTextEnter(f), rememberKey, flags );
      }
   }

   function setTextEnter(val:String)
   {
      setText(val);
      if (onTextEnter!=null)
         onTextEnter(val);
   }

   override public function createExtraWidgetLayout() : Layout
   {
      var browseButton = Button.TextButton("Browse",onBrowse);
      addChild(browseButton);
      return browseButton.getLayout();
   }

}



