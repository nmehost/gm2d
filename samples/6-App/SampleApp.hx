import gm2d.ui.App;
import gm2d.ui.Menubar;
import gm2d.ui.Pane;
import gm2d.display.Sprite;
import gm2d.Game;

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
      file.add( new MenuItem("Load") );
      file.add( new MenuItem("Save") );
      file.add( new MenuItem("Save As") );
      file.add( new MenuItem("Exit",onExit) );
      bar.add( file );
      var edit = new MenuItem("Edit");
      edit.add( new MenuItem("Cut") );
      edit.add( new MenuItem("Copy") );
      edit.add( new MenuItem("Paste") );
      bar.add( edit );
   }

   function onExit(_)
   {
      #if nme
      nme.Lib.close();
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
