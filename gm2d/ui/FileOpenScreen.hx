package gm2d.ui;

import gm2d.Screen;
import gm2d.ui.Layout;
import nme.text.TextField;
import gm2d.ScreenScaleMode;
import nme.display.Sprite;
import gm2d.skin.Skin;

import nme.display.Graphics;
import nme.display.Bitmap;
import nme.geom.Matrix;

import nme.display.BitmapData;
import nme.display.Bitmap;

import haxe.io.Path;

#if flash
// Nothing
#else
import sys.FileSystem;
import nme.filesystem.File;
#end

import nme.utils.ByteArray;
import nme.net.SharedObject;

class FileOpenScreen extends Screen
{
   var folderIcon:BitmapData;
   var docIcon:BitmapData;
   var dirButtonContainer:Sprite;
   var dirButtons:Array<Button>;
   var screenLayout:Layout;
   var message:String;
   var filter:String;
   var baseDir:String;
   var dirs: Array<String>;
   var filterList: Array<String>;
   var files:Array<String>;
   var onResult:String->ByteArray->Void;
   public var onSaveResult:String->Void;
   public var onError:String->Void;
   public var extension:String;
   public var saveName:String;
   var returnScreen:Screen;
   var flags:Int;
   var isSave:Bool;
   var saveTextInput:TextInput;

   public function new(inMessage:String,inDir:String,inOnResult:String->ByteArray->Void,inFilter:String,?inReturnScreen:Screen,inFlags:Int = 0, inSaveName="")
   {
      super();

      #if flash
      throw "FileOpenScreen Not supported on flash";
      #else
      flags = inFlags;
      message = inMessage;
      
      saveName = inSaveName;
      filter = inFilter;
      onResult = inOnResult;
      returnScreen = inReturnScreen==null ? Game.screen : inReturnScreen;
      folderIcon = new gm2d.icons.Folder().toBitmap();
      docIcon = new gm2d.icons.Document().toBitmap();


      var top = new VerticalLayout();
      top.add(StaticText.createLayout(inMessage,this));
      top.setColStretch(0,1);

      var dir_buttons = new VerticalLayout().setName("dir button").setAlignment(Layout.AlignLeft);
      dir_buttons.setSpacing(2,10);

      var button = Button.TextButton("All", function() setDir(null) );
      addChild(button);
      dir_buttons.add(button.getLayout());

      if (inDir=="")
      {
         var def = SharedObject.getLocal("fileOpen");
         if (def!=null && Reflect.hasField(def.data,inMessage))
            inDir = Reflect.field(def.data,inMessage);
         else
            inDir = File.documentsDirectory.nativePath;
      }

      if (inDir!=null)
      {
         inDir = inDir.split("\\").join("/");
         baseDir = inDir;
         var parts = inDir.split("/");
         var soFar : Array<String> = [];
         var spaceChar = "    /";
         for(part in parts)
         {
            if (part!="" || soFar.length<2)
               soFar.push(part);
            if (part!="")
            {
               var spacer = StaticText.createLayout(spaceChar,this);
               spaceChar = "/";
               dir_buttons.add(spacer);
               var link = soFar.join("/");
               var button = Button.TextButton(part, function() setDir(link) );
               addChild(button);
               dir_buttons.add(button.getLayout());
            }
         }
      }
      top.add(dir_buttons);



      isSave =  (flags&FileOpen.SAVE)!=0;
      if (isSave)
      {
         var panel = new Panel("NameBox");
         addChild(panel);
         saveTextInput = new TextInput(saveName, function(s) saveName=s );
         panel.addLabelObj("Save Name", saveTextInput);
         top.add(panel.setStretchX(0).getLayout().setBorders(10,0,10,0) );
      }

      var list = new ListControl();
      addChild(list);

      files = new Array<String>();
      dirs = new Array<String>();
      if (inDir==null)
      {
         baseDir = "";
         //list.addRow( [folderIcon,"Application Base"] );
         //dir.push(File.applicationDirectory);
         list.addRow( [folderIcon,"Documents"] );
         dirs.push(File.documentsDirectory.nativePath);
         list.addRow( [folderIcon,"Home"] );
         dirs.push(File.userDirectory.nativePath);
         list.addRow( [folderIcon,"Desktop"] );
         dirs.push(File.desktopDirectory.nativePath);
         list.addRow( [folderIcon,"Application Files"] );
         dirs.push(File.applicationStorageDirectory.nativePath);

         for(v in nme.filesystem.StorageVolumeInfo.getInstance().getStorageVolumes())
         {
            list.addRow( [folderIcon,v.name] );
            dirs.push(v.rootDirectory.nativePath);
         }
      }
      else
      {
         try
         {
         for(item in FileSystem.readDirectory(inDir))
         {
            if (item.substr(0,1)!=".")
            {
               if (FileSystem.isDirectory(inDir + "/" + item))
                  dirs.push(item);
               else
                  files.push(item);
            }
         }
         } catch (e:Dynamic) { }
         dirs.sort(function(a,b) { return a<b ? -1 : 1; } );
         files.sort(function(a,b) { return a<b ? -1 : 1; } );
         for(d in dirs)
         {
            list.addRow( [folderIcon,d] );
         }
         for(f in files)
         {
            list.addRow( [docIcon,f] );
         }
      }
      list.onSelect = onListSelect;
      
      var layout = list.getLayout();
      layout.mAlign = Layout.AlignStretch;
      top.add(layout);

      top.setRowStretch(isSave ? 3:2,1);

      var buttons = new HorizontalLayout();
      buttons.setSpacing(10,0);

      if (isSave)
      {
         var button = Button.TextButton("Ok", function() onSave() );
         addChild(button);
         buttons.add(button.getLayout());
      }
      var button = Button.TextButton("Cancel", function() onCancel() );
      addChild(button);
      buttons.add(button.getLayout());

      top.add(buttons);

      top.setBorders(5,5,5,5);

      screenLayout = top;

      Game.setCurrentScreen(this);
      #end
   }

   override public function getScaleMode() : ScreenScaleMode
      { return ScreenScaleMode.TOPLEFT_UNSCALED; }

   public function onListSelect(inRow:Int)
   {
      if (inRow<dirs.length)
      {
         if (baseDir=="")
            setDir(dirs[inRow]);
         else
            setDir(baseDir + "/" + dirs[inRow]);
         return;
      }
      inRow -= dirs.length;

      if (saveTextInput!=null)
      {
         saveTextInput.text = saveName = files[inRow];
      }
      else
         setResult(files[inRow]);
   }

   public function onSave( )
   {
      #if !flash
      var def = SharedObject.getLocal("fileOpen");
      if (def!=null)
      {
         Reflect.setField(def.data, message, baseDir);
         def.flush();
      }

      var name = saveName;
      if (extension!="" && name.indexOf(".")<0)
         name = name + "." + extension;
      var start = name.substr(0,1);
      var isAbsolute = start=='/' || start=='\\' || name.substr(1,1)==':';
      if (!isAbsolute)
         name = baseDir + "/" + name;

      if ( (flags & FileOpen.CHECK_OVERWRITE)!=0 && FileSystem.exists(name) )
      {
         var panel = new Panel("Confirm Overwrite");
         panel.addLabel("File " + name + " already exists.  Do you want ot overwrite?");
         panel.addTextButton( "Ok", function()
            {
               Game.closeDialog();
               if (returnScreen!=null)
               {
                  Game.setCurrentScreen(returnScreen);
                  returnScreen = null;
               }
               onSaveResult(name);
            } );
         panel.addTextButton( "Cancel", Game.closeDialog );
         var dialog = new Dialog(panel.getPane());
         Game.doShowDialog(dialog,true);
      }
      else
      {
         if (returnScreen!=null)
         {
            Game.setCurrentScreen(returnScreen);
            returnScreen = null;
         }
         onSaveResult(name);
      }
      #end
   }

   function onCancel()
   {
     if (returnScreen!=null)
     {
        Game.setCurrentScreen(returnScreen);
        returnScreen = null;
     }
     if (onResult!=null)
        onResult(null,null);
   }

   function setResult(inFile:String)
   {
      #if flash
      throw "Not supported";
      #else
      //trace("Selected file: " + inFile);
      if (inFile=="")
        onResult(null,null);
      else
      {
         var def = SharedObject.getLocal("fileOpen");
         if (def!=null)
         {
            Reflect.setField(def.data, message, baseDir);
            def.flush();
         }

         var result:ByteArray = null;
         if ( (flags & FileOpen.NO_DATA)==0 )
         {
            try
            {
               result = ByteArray.readFile(baseDir + "/" + inFile);
            }
            catch(e:Dynamic) { }
         }
         Game.setCurrentScreen(returnScreen);
         onResult(baseDir + "/" + inFile,result);
      }
      #end
   }


   public function setDir(inLink:String)
   {
      var screen = new FileOpenScreen(message,inLink,onResult,filter,returnScreen,flags,saveName);
      screen.onSaveResult = onSaveResult;
      screen.onError = onError;
      screen.extension = extension;
   }

   override public function scaleScreen(inScale:Float)
   {
      var gfx = graphics;
      gfx.clear();
      gfx.beginFill(Skin.panelColor);
      gfx.drawRect(0,0, stage.stageWidth, stage.stageHeight);
      screenLayout.setRect(0,0, stage.stageWidth, stage.stageHeight);
   }


}


