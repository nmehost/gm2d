import gm2d.ui.App;
import gm2d.ui.Menubar;
import gm2d.ui.MenuItem;
import gm2d.ui.Pane;
import gm2d.display.Sprite;
import gm2d.display.Bitmap;
import gm2d.utils.ByteArray;
import gm2d.Game;
import gm2d.svg.SVG2Gfx;
import gm2d.swf.SWF;
import gm2d.ui.FileOpen;
import gm2d.display.Loader;
import gm2d.events.Event;
import gm2d.ui.DockFlags;
import gm2d.ui.IDockable;

class SampleApp extends App
{
   public function new()
   {
      super();
      createMenus();
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
      edit.add( new MenuItem("Copy", onTest) );
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
   #if !flash
      nme.Lib.exit();
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
      addPane( new Pane(item,"View:"+col,DockFlags.RESIZABLE), DOCK_OVER );

   }

   function onTest(_)
   {
      var progressDialog = new gm2d.ui.ProgressDialog("Test","Progress",100, 
            function() { Game.closeDialog(); } );
      Game.doShowDialog(progressDialog,true);
   }

   function addSVGDocument(inName:String, inData:ByteArray)
   {
      var xml = inData.readUTFBytes(inData.length);
      var svg = new SVG2Gfx(Xml.parse(xml));
      var item = new Sprite();
      var gfx = item.graphics;
      svg.Render(gfx);
      item.cacheAsBitmap = true;
      addPane( new Pane(item,inName,DockFlags.RESIZABLE), DOCK_OVER );
   }

   function addSWFDocument(inName:String, inData:ByteArray)
   {
      var swf = new SWF(inData);
      var obj = swf.createInstance();
      obj.cacheAsBitmap = true;
      var pane = new Pane(obj,inName,DockFlags.RESIZABLE);
      pane.bestWidth = swf.Width();
      pane.bestHeight = swf.Height();

      addPane( pane, DOCK_OVER );
   }


   function addImageDocument(inName:String, inBitmap:Bitmap)
   {
      addPane( new Pane(inBitmap,inName,DockFlags.RESIZABLE), DOCK_OVER );
   }


   function loadData(inName:String,inData:ByteArray)
   {
      if (inName!=null && inData!=null)
      {
         var pos = inName.lastIndexOf(".");
         if (pos>0)
         {
            var ext = inName.substr(pos+1).toLowerCase();
            switch(ext)
            {
               case "svg":
                 addSVGDocument(inName, inData);

               case "png","jpg":
                 var loader:Loader = new Loader();
                 loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
                   function(_) {
                     var bitmap:Bitmap = cast loader.content;
                     addImageDocument(inName,bitmap);
                 } );
                 loader.loadBytes(inData);

               case "swf":
                 addSWFDocument(inName, inData);
            }
         }
      }
   }

   function onLoad(_)
   {
      gm2d.ui.FileOpen.load("Select Graphics File", loadData, "Graphics Files|*.svg;*.png;*.jpg;*.swf");
   }

   function onViewDebugTracePanes(_)
   {
      #if cpp
      cpp.vm.Gc.trace(Pane);
      #end
   }


   static public function main()
   {
      //Game.fpsColor = 0x000000;
      Game.backgroundColor = 0xffffff;
      new SampleApp();
   }
}
