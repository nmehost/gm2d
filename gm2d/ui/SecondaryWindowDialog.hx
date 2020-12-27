package gm2d.ui;

import gm2d.skin.Skin;
import gm2d.skin.FillStyle;
import nme.display.*;
import nme.events.*;

class SecondaryWindowDialog implements IDialog
{
   var window:nme.app.Window;

   public function new(pane:Pane, ?inAttribs:{}, ?inLineage:Array<String> )
   {
      var fps = 0.0;
      var layout = pane.getLayout();
      var size = layout.getBestSize();

      var bgCol = 0xffffff;
      var combined = Skin.combineAttribs(["Dialog"], 0, inAttribs);
      var bg:FillStyle = combined.get("fill");
      if (bg!=null)
         switch(bg)
         {
            case FillSolid(c,a) : bgCol = c;
            case FillLight: bgCol = Skin.guiLight;
            case FillMedium: bgCol = Skin.guiMedium;
            case FillButton: bgCol = Skin.guiButton;
            case FillDark: bgCol = Skin.guiDark;
            case FillHighlight: bgCol = Skin.guiHighlight;
            default:
         }

      window = nme.Lib.createSecondaryWindow(
           Std.int(size.x), Std.int(size.y), pane.getTitle(),
           nme.app.Application.HARDWARE | nme.app.Application.RESIZABLE |
           nme.app.Application.ALWAYS_ON_TOP,
           bgCol, fps, pane.getIcon() );
      var stage = window.stage;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.addEventListener( Event.RESIZE, (_) ->
         layout.setRect(0,0, stage.stageWidth, stage.stageHeight)
         );
      stage.onCloseRequest = Game.closeDialog;

      pane.setDock(null,stage.current);
   }

   public function closeFrame():Void
   {
      window.close();
   }
   public function asDialog():Dialog return null;
}
