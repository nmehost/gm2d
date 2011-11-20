import gm2d.ui.App;
import gm2d.ui.Menubar;
import gm2d.ui.MenuItem;
import gm2d.ui.Pane;
import gm2d.display.Sprite;
import gm2d.utils.ByteArray;
import gm2d.Game;
import gm2d.svg.SVG2Gfx;

class SampleApp extends App
{
   public function new()
   {
      super();
      createMenus();

      /*
      var item = new Sprite();
      var gfx = item.graphics;
      gfx.beginFill(0x0000);
      gfx.drawRect(0,0,200,200);
      gfx.beginFill(0xffffff);
      gfx.drawCircle(100,100,100);
      addPane( new Pane(item,"Float",Pane.TOOLBAR), Pane.POS_OVER );
      */
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
      addPane( new Pane(item,"View:"+col,Pane.RESIZABLE), Pane.POS_OVER );

   }

   function addSVGDocument(inName:String, inData:ByteArray)
   {
      var xml = inData.readUTFBytes(inData.length);
      var svg = new SVG2Gfx(Xml.parse(xml));
      var item = new Sprite();
      var gfx = item.graphics;
      svg.Render(gfx);
      item.cacheAsBitmap = true;
      addPane( new Pane(item,inName,Pane.RESIZABLE), Pane.POS_OVER );
   }

   function loadData(inName:String,inData:ByteArray)
   {
      var pos = inName.lastIndexOf(".");
      if (pos>0)
      {
         var ext = inName.substr(pos+1).toLowerCase();
         switch(ext)
         {
            case "svg":
              addSVGDocument(inName, inData);
         }
      }
   }

   function onLoad(_)
   {
   #if waxe
      var dialog = new wx.FileDialog(null,"Select Graphics File");
      dialog.filter="Graphics Files|*.svg;*.png;*.jpg;*.swf";
      if (dialog.showModal())
      {
         var dir = dialog.directory;
         var name = dir + "/" + dialog.file;
         var data = ByteArray.readFile(name);
         trace(name + " = " + (data==null ? "Null" : ""+data.length ));
         if (data!=null)
            loadData(name,data);
      }
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
      //Game.fpsColor = 0x000000;
      Game.backgroundColor = 0xffffff;
      new SampleApp();
   }
}
