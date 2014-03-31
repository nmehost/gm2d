import gm2d.ui.App;
import gm2d.ui.Menubar;
import gm2d.ui.MenuItem;
import gm2d.ui.Pane;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.utils.ByteArray;
import gm2d.Game;
import gm2d.svg.SvgRenderer;
import gm2d.svg.Svg;
import gm2d.swf.SWF;
import gm2d.ui.FileOpen;
import nme.display.Loader;
import nme.events.Event;
import gm2d.ui.Dock;
import gm2d.ui.IDockable;
import gm2d.RGBHSV;
import gm2d.ui.ColourControl;
import gm2d.ui.DockPosition;
import gm2d.ui.Panel;

class SampleApp extends App
{
   public function new()
   {
      super();

      //Game.debugLayout = true;
      createMenus();

      var panel = new Panel("Colour");
      panel.addUI(new ColourControl( new RGBHSV(0xff00ff) ) );
      //addPane( panel.getPane(), DockPosition.DOCK_LEFT);
      //var dlg = new gm2d.ui.Dialog(panel.getPane());
      //Game.doShowDialog(dlg,true);
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
      addPane( new Pane(item,"View:"+col,Dock.RESIZABLE), DOCK_OVER );

   }

   function onTest(_)
   {
      var progressDialog = gm2d.ui.ProgressDialog.create("Test","Progress",100, 
            function() { Game.closeDialog(); } );
      Game.doShowDialog(progressDialog,true);
   }

   function addSVGDocument(inName:String, inData:ByteArray)
   {
      var string = inData.readUTFBytes(inData.length);
      var xml = Xml.parse(string);
      var svg = new SvgRenderer(new Svg(xml));
      var item = new Sprite();
      var gfx = item.graphics;
      svg.render(gfx);
      item.cacheAsBitmap = true;
      var pane = new Pane(item,inName,Dock.RESIZABLE);
      pane.bestWidth = svg.width;
      pane.bestHeight = svg.height;
      
      addPane( pane, DOCK_OVER );

      /*
      var commands = SvgRenderer.toHaxe(xml);
      for(c in commands)
         neko.Lib.println(c);
      var bytes = SvgRenderer.toBytes(xml);
      trace(bytes);
      */
   }

   function addSWFDocument(inName:String, inData:ByteArray)
   {
      var swf = new SWF(inData);
      var obj = swf.createInstance();
      obj.cacheAsBitmap = true;
      var pane = new Pane(obj,inName,Dock.RESIZABLE);
      pane.bestWidth = swf.Width();
      pane.bestHeight = swf.Height();

      addPane( pane, DOCK_OVER );
   }


   function addImageDocument(inName:String, inBitmap:Bitmap)
   {
      addPane( new Pane(inBitmap,inName,Dock.RESIZABLE), DOCK_OVER );
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
   #if (cpp || neko)
   public function openFile(inFilename:String)
   {
      var bytes = nme.utils.ByteArray.readFile(inFilename);
      if (bytes!=null)
         loadData(inFilename,bytes);
   }
   #end

   function onLoad(_)
   {
      #if (waxe || flash)
      gm2d.ui.FileOpen.load("Select Graphics File", loadData, "Graphics Files|*.svg;*.png;*.jpg;*.swf");
      #else
      var fo = new gm2d.ui.FileOpenScreen("Select Graphics File", "", loadData, "Graphics Files|*.svg;*.png;*.jpg;*.swf");
      Game.setCurrentScreen(fo);
      #end

   }

   function onViewDebugTracePanes(_)
   {
      #if cpp
      cpp.vm.Gc.trace(Pane);
      #end
   }


/*
   static public function main()
   {
      //Game.fpsColor = 0x000000;
      Game.backgroundColor = 0xffffff;
      var app = new SampleApp();
      #if (neko||cpp)
        #if haxe3
        var args = Sys.args();
        #else
        var args = #if neko neko #else cpp #end .Sys.args();
        #end
      if (args.length>0)
         app.openFile(args[0]);
      #end
   }
   */
}
