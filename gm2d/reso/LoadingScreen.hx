package gm2d.reso;

class LoadingScreen
{
   var mLoader:Loader;
   var mLoadingDisplay:gm2d.display.Sprite;

   public function new()
   {
      mLoader = new Loader();
      mLoadingDisplay = new gm2d.display.Sprite();
      gm2d.Lib.current.addChild(mLoadingDisplay);
      mLoadingDisplay.addEventListener(gm2d.events.Event.ENTER_FRAME,update);
   }

   public function Load()
   {
      mLoader.Process(_onLoaded);
   }

   function renderLoading(inFraction:Float)
   {
      var w = mLoadingDisplay.stage.stageWidth;
      var h = mLoadingDisplay.stage.stageHeight;
      var gfx = mLoadingDisplay.graphics;
      gfx.clear();

      gfx.lineStyle(2,0x008000);
      gfx.drawRect(w/8,h/2-15,w*0.75,30);
      gfx.lineStyle();
      gfx.beginFill(0x008000);
      gfx.drawRect(w/8+2,h/2-15+2,w*0.75*inFraction-4,30-4);
   }

   function update(_)
   {
      renderLoading(0.5);
   }

   function onLoaded(inResources:Resources) { }
 

   function _onLoaded(inResources:Resources)
   {
      gm2d.Lib.current.removeChild(mLoadingDisplay);
      mLoadingDisplay = null;
      gm2d.Game.setResources(inResources);
      onLoaded(inResources);
   }

}
