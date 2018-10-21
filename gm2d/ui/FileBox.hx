package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.events.MouseEvent;
import nme.geom.Point;
import gm2d.ui.Button;
import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;


class FileBox extends TextInput
{
   var mButtonX:Float;
   var onText:String->Void;
   var isDir:Bool;

   public function new(inVal="", ?inLineage:Array<String>, ?inAttribs:{})
   {
       super(inVal, null, Widget.addLine(inLineage,"FileBox"), inAttribs);
       isDir = attribBool("directory",false);
       if (inVal=="" || inVal==null)
       {
          var rememberKey = attribString("id");
          if (rememberKey!=null)
          {
             var def = nme.system.Dialog.getDefaultPath(rememberKey);
             setText( def );
          }
       }
   }

   function onBrowse()
   {
      var title = attribString("browseTitle","Selete Directory");
      var rememberKey = attribString("id");
      if (isDir)
      {
         nme.system.Dialog.getDirectory(title,"Directory", function(f) if (f!=null) setText(f),rememberKey );
      }
      else
      {
         var ext = attribString("browseFilter","All Files|*.*");
         nme.system.Dialog.fileDialog(title,"File", getText(), ext,
             function(f) if (f!=null) setText(f), rememberKey,0 );
      }
   }

   override public function createExtraWidgetLayout() : Layout
   {
      var browseButton = Button.TextButton("Browse",onBrowse);
      addChild(browseButton);
      return browseButton.getLayout();
   }

}



