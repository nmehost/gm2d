import gm2d.ui.App;
import gm2d.ui.Menubar;
import gm2d.ui.MenuItem;
import gm2d.ui.Pane;
import gm2d.display.Sprite;
import gm2d.Game;

import systools.Dialogs;

class SampleApp extends App
{
   public function new()
   {
      super();
      createMenus();

      var item = new Sprite();
      var gfx = item.graphics;
      gfx.beginFill(0x0000);
      gfx.drawRect(0,0,200,200);
      gfx.beginFill(0xff0000);
      gfx.drawCircle(100,100,100);
      addPane( new Pane(item,"Red",Pane.RESIZABLE), Pane.POS_OVER );
   }

   function createMenus()
   {
      var bar = menubar;
      var file = new MenuItem("File");
      file.add( new MenuItem("Load", onLoad) );
      file.add( new MenuItem("Save") );
      file.add( new MenuItem("Save As") );
      file.add( new MenuItem("Exit",onExit) );
      bar.add( file );
      var edit = new MenuItem("Edit");
      edit.add( new MenuItem("Cut") );
      edit.add( new MenuItem("Copy") );
      edit.add( new MenuItem("Paste") );
      bar.add( edit );
      var view = new MenuItem("View");
      view.add( new MenuItem("New", onViewNew) );
      #if cpp
      view.add( new MenuItem("Debug Trace Panes", onViewDebugTracePanes) );
      #end
      bar.add( view );
   }

   function onExit(_)
   {
      #if nme
      nme.Lib.close();
      #end
   }

   function onViewNew(_)
   {
      var item = new Sprite();
      var gfx = item.graphics;
      var col = Std.int(Math.random()*0xffffff);
      gfx.beginFill(0x0000);
      gfx.drawRect(0,0,200,200);
      gfx.beginFill(col);
      gfx.drawCircle(100,100,100);
      addPane( new Pane(item,"View:"+col,Pane.RESIZABLE), Pane.POS_OVER );

   }

   function onLoad(_)
   {
   #if systools
   #if neko
   neko.vm.Thread.create( function() {
      var filters: FILEFILTERS = 
         { count: 2
         , descriptions: ["Text files", "JPEG files"]
         , extensions: ["*.txt","*.jpg;*.jpeg"]         
         };      
      var result = Dialogs.openFile
         ( "Select a file please!"
         , "Please select one or more files, so we can see if this method works"
         , filters 
         );
      trace(result);      
      } );
   #end
   #end
   }

   function onViewDebugTracePanes(_)
   {
      #if cpp
      cpp.vm.Gc.trace(Pane);
      #end
   }


   static public function main()
   {
      Game.useHardware = true;
      Game.title = "Data";
      //Game.showFPS = true;
      Game.fpsColor = 0x000000;
      Game.backgroundColor = 0xffffff;
      Game.iPhoneOrientation = 90;
      Game.create(function() new SampleApp());
   }
}
