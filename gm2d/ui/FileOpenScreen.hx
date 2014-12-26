package gm2d.ui;

import gm2d.Screen;
import gm2d.ui.Layout;
import nme.text.TextField;
import gm2d.ScreenScaleMode;
import gm2d.ui.HitBoxes;
import nme.display.Sprite;
import gm2d.skin.Skin;

import nme.display.Graphics;
import nme.display.Bitmap;
import nme.geom.Matrix;
import nme.net.FileFilter;

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
   var dirButtons:Layout;
   var screenLayout:Layout;
   var list:ListControl;
   var message:String;
   var filter:String;
   var baseDir:String;
   var dirs: Array<String>;
   var filterList: Array<FileFilter>;
   var currentFilter:FileFilter;
   var filterWidget:ComboBox;
   var files:Array<String>;
   var allButtons:Array<Widget>;
   var onResult:String->ByteArray->Void;
   public var onSaveResult:String->Void;
   public var onError:String->Void;
   public var saveName:String;
   var flags:Int;
   var isSave:Bool;
   var saveTextInput:TextInput;

   public function new(inMessage:String,
         inDir:String,
         inOnResult:String->ByteArray->Void,
         inFilter:String,
         inFlags:Int = 0,
         inSaveName="",
         filterIndex:Int = 0)
   {
      super();

      #if flash
      throw "FileOpenScreen Not supported on flash";
      #else
      flags = inFlags;
      message = inMessage;
      if (message=="")
         message = "Select File";
      
      saveName = inSaveName;
      filter = inFilter;

      filterList = new Array<FileFilter>();
      if (inFilter!=null)
      {
         var parts = inFilter.split("|");
         var p = 0;
         while(p+1<parts.length)
         {
            filterList.push( new FileFilter(parts[p],parts[p+1]) );
            p+=2;
         }
      }

      onResult = inOnResult;
      folderIcon = new gm2d.icons.Folder().toBitmap(Skin.dpiScale);
      docIcon = new gm2d.icons.Document().toBitmap(Skin.dpiScale);


      var top = new VerticalLayout([0,0,1,0,0]);


      var topRow = new HorizontalLayout();
      topRow.setSpacing(5,0);

      var title = new TextLabel(message);
      addChild(title);
      topRow.add(title.getLayout());

      isSave =  (flags&FileOpen.SAVE)!=0;
      if (isSave)
      {
         saveTextInput = new TextInput(saveName, function(s) saveName=s );
         saveTextInput.setOnEnter(function(s) { saveName=s; onSave(); } );
         addChild(saveTextInput);
         topRow.add(saveTextInput.getLayout().stretch());
         topRow.setColStretch(1,1);
      }

      if (filterList.length>0)
      {
         currentFilter = filterList[filterIndex];
         var options = new Array<String>();
         for(f in filterList)
            options.push(f.description);
         filterWidget = new ComboBox(options[0], options, function(idx:Int) {
            currentFilter = filterList[idx];
            setDir(baseDir);
            });
         addChild(filterWidget);

         topRow.add(filterWidget.getLayout());
      }

      top.add(topRow);


      top.setRowStretch(1,0);
      top.setColStretch(0,1);

      list = new ListControl();


      dirButtons = new FlowLayout().setSpacing(2,5).setName("dir button").setAlignment(Layout.AlignLeft|Layout.AlignTop).setBorders(5,0,5,0);

      top.add(dirButtons);

      setDir(inDir,false);

      addChild(list);

      list.onSelect = onListSelect;
      
      var layout = list.getLayout().stretch();
      top.add(layout);

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

      top.setBorders(5,5,5,5).setSpacing(0,5);

      screenLayout = top;

      Game.pushScreen(this);
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
      if (name.indexOf(".")<0 && currentFilter!=null)
      {
         name += currentFilter.getBestExtension();
      }
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
               onSaveResult(name);
               Game.popScreen();
            } );
         panel.addTextButton( "Cancel", Game.closeDialog );
         var dialog = new Dialog(panel.getPane());
         Game.doShowDialog(dialog,true);
      }
      else
      {
         onSaveResult(name);
         Game.popScreen();
      }
      #end
   }

   function onCancel()
   {
     if (onResult!=null)
        onResult(null,null);
     Game.popScreen();
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
         onResult(baseDir + "/" + inFile,result);
      }
      Game.popScreen();
      #end
   }

   function addButton(button:Widget)
   {
      allButtons.push(button);
      addChild(button);
      dirButtons.add(button.getLayout());
   }


   public function setDir(inDir:String,inRelayout=true)
   {
      if (allButtons!=null)
      {
         for(but in allButtons)
            removeChild(but);
      }
      allButtons = [];
      dirButtons.clear();

      var button = Button.TextButton("All", function() setDir(null) );
      addButton(button);

      if (inDir=="")
      {
         var def = SharedObject.getLocal("fileOpen");
         if (def!=null && Reflect.hasField(def.data,message))
            inDir = Reflect.field(def.data,message);
         #if !flash
         else
            inDir = File.documentsDirectory.nativePath;
         #end
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
               var spacer = new TextLabel(spaceChar);
               spacer.getLayout().setAlignment(Layout.AlignCenter);
               spaceChar = "/";
               addButton(spacer);
               var link = soFar.join("/");
               var button = Button.TextButton(part, function() setDir(link) );
               addButton(button);
            }
         }
         #if !flash
         var add = Button.create(["BitmapFromId"], { margin:5, id:MiniButton.ADD }, onNewDir);
         addButton(add);
         #end
      }

      list.clear();

      files = new Array<String>();
      dirs = new Array<String>();

      #if !flash
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
               {
                  var found = currentFilter==null || currentFilter.matches(item);

                  if (found)
                     files.push(item);
               }
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
      #end
      if (inRelayout)
         screenLayout.setRect(0,0, stage.stageWidth, stage.stageHeight);
   }

   public function onNewDir()
   {
      #if !flash
      Game.inputBox( {title:"Create new directory", label:"Directory Name", value:"", onOk:function(name) {
          try
          {
            sys.FileSystem.createDirectory(baseDir+"/"+name);
            setDir(baseDir);
          }
          catch(e:Dynamic)
          {
             Game.messageBox({title:"Error Creating Directory", label:""+e});
          }
      } } );
      #end
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


