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
import nme.display.DisplayObjectContainer;

import haxe.io.Path;
import nme.utils.ByteArray;
import nme.net.SharedObject;

#if flash
// Nothing
#else
import nme.filesystem.File;
#if js
class FileSource
{
   public static function exists(inName:String) return false;
   public static function createDirectory(inName:String) throw "Can't createDirectory";
   public static function isDirectory(inName:String) return false;
   public static function readDirectory(inName:String) : Array<String> return [];
}
#else
typedef FileSource = sys.FileSystem;
#end
#end


class FileOpenScreen extends Screen
{
   var folderIcon:BitmapData;
   var docIcon:BitmapData;
   var dirButtonContainer:DisplayObjectContainer;
   var dirButtons:Layout;
   var layout:Layout;
   //var list:ListControl;
   var list:TileControl;
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
   var thumbSize:Size;
   public static var thumbnailFactory:String->Widget->Size->Void;

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
         if (parts.length==1)
         {
            filterList.push( new FileFilter(inFilter + " files", "*." + inFilter) );
         }
         else
         {
            var p = 0;
            while(p+1<parts.length)
            {
               filterList.push( new FileFilter(parts[p],parts[p+1]) );
               p+=2;
            }
         }
      }

      onResult = inOnResult;
      folderIcon = new gm2d.icons.Folder().toBitmap(Skin.dpiScale);
      docIcon = new gm2d.icons.Document().toBitmap(Skin.dpiScale);
      thumbSize = new Size(docIcon.width<24 ? 24 : docIcon.width,
                           docIcon.height<24 ? 24 : docIcon.height );
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

      var dirButtonBox = new Widget();
      addChild(dirButtonBox);
      dirButtonContainer = dirButtonBox;



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

      //list = new ListControl();
      list = new TileControl();


      dirButtons = new FlowLayout().setSpacing(2,5).setName("dir button").setAlignment(Layout.AlignLeft|Layout.AlignTop).setBorders(5,0,5,0);

      dirButtonBox.setItemLayout(dirButtons);
      dirButtonBox.getLayout().setAlignment(Layout.AlignLeft|Layout.AlignTop);

      top.add(dirButtonBox.getLayout());

      setDir(inDir,false);

      addChild(list);

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

      layout = top;

      Game.pushScreen(this);
      #end
   }

   override public function getScaleMode() : ScreenScaleMode
      { return ScreenScaleMode.TOPLEFT_UNSCALED; }

   function onDir(dir:String)
   {
      if (baseDir=="")
         setDir(dir);
      else
         setDir(baseDir + "/" + dir);
   }

   function onFile(file:String)
   {
      if (saveTextInput!=null)
         saveTextInput.text = saveName = file;
      else
         setResult(file);
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

      if ( (flags & FileOpen.CHECK_OVERWRITE)!=0 && FileSource.exists(name) )
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
      Game.popScreen();
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
      #end
   }

   function addButton(button:Widget)
   {
      allButtons.push(button);
      dirButtonContainer.addChild(button);
      dirButtons.add(button.getLayout());
   }
   
   function addItem(icon:BitmapData, name:String, dir:String, ?file:String)
   {
      var widget =  Button.BMPTextButton(icon,name, dir!=null ? function() onDir(dir) : function() onFile(file), ["SimpleTile"] );
      widget.getItemLayout().setAlignment( Layout.AlignLeft | Layout.AlignCenterY );
      widget.getLayout().stretch();
      list.add(widget);

      if (icon!=folderIcon && thumbnailFactory!=null)
         thumbnailFactory(baseDir+"/"+name, widget, thumbSize);

      //list.addRow([icon,name]);
   }


   public function setDir(inDir:String,inRelayout=true)
   {
      list.holdUpdates(true);
      if (allButtons!=null)
      {
         for(but in allButtons)
            but.parent.removeChild(but);
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
         addItem( folderIcon,"Documents", File.documentsDirectory.nativePath );
         dirs.push(File.documentsDirectory.nativePath);
         addItem( folderIcon,"Home",File.userDirectory.nativePath );
         dirs.push(File.userDirectory.nativePath);
         addItem( folderIcon,"Desktop", File.desktopDirectory.nativePath );
         dirs.push(File.desktopDirectory.nativePath);
         addItem( folderIcon,"Application Files", File.applicationStorageDirectory.nativePath );
         dirs.push(File.applicationStorageDirectory.nativePath);

         for(v in nme.filesystem.StorageVolumeInfo.getInstance().getStorageVolumes())
         {
            addItem( folderIcon,v.name,v.rootDirectory.nativePath );
            dirs.push(v.rootDirectory.nativePath);
         }
      }
      else
      {
         try
         {
         for(item in FileSource.readDirectory(inDir))
         {
            if (item.substr(0,1)!=".")
            {
               if (FileSource.isDirectory(inDir + "/" + item))
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
            addItem( folderIcon,d,d );
         }
         for(f in files)
         {
            addItem( docIcon,f,null,f );
         }
      }
      #end
      list.holdUpdates(false);
      if (inRelayout)
         layout.setRect(0,0, stage.stageWidth, stage.stageHeight);
   }

   public function onNewDir()
   {
      #if !flash
      Game.inputBox( {title:"Create new directory", label:"Directory Name", value:"", onOk:function(name) {
          try
          {
            FileSource.createDirectory(baseDir+"/"+name);
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
      layout.setRect(0,0, stage.stageWidth, stage.stageHeight);
   }


}


