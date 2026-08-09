package gm2d.ui;
import nme.display.BitmapData;
import cpp.abi.Abi;
import gm2d.skin.BitmapStyle;
import gm2d.skin.FillStyle;
import gm2d.skin.LineStyle;
import gm2d.skin.TextColour;
import gm2d.skin.FilterSet;
import gm2d.skin.ProgressStyle;
import gm2d.skin.Shape;
import nme.geom.Point;
import nme.text.TextFormat;

typedef Attribs =
{
   // State merge/override options
   ?parent:Dynamic,
   ?stateDown:Attribs,
   ?stateDisabled:Attribs,
   ?stateCurrent:Attribs,
   ?stateAlternate:Attribs,
   ?stateSelected:Attribs,

   // Identity and nested style references
   ?id:String,
   ?tab:Attribs,
   ?titleLineage:Array<String>,
   ?rowLineage:String,
   ?rowAttribs:Attribs,

   // Renderer/chrome options
   ?shape:Shape,
   ?line:LineStyle,
   ?fill:FillStyle,
   ?bitmap:BitmapStyle,
   ?bitmapId:String,
   ?bitmapStyle:BitmapStyle,
   ?bitmapRenderSize:Int,
   ?bitmapTransform:BitmapData->BitmapData,
   ?filters:FilterSet,
   ?chromeFilters:FilterSet,
   ?padding:Dynamic,
   ?margin:Dynamic,
   ?offset:Point,
   ?minItemSize:Size,
   ?minSize:Size,
   ?align:Int,
   ?itemAlign:Int,
   ?alignBitmap:Int,
   ?autoCurrent:Bool,

   // Text/presentation options
   ?textAlign:String,
   ?textFormat:TextFormat,
   ?font:String,
   ?fontSize:Int,
   ?textColor:TextColour,
   ?textBorder:Int,
   ?bold:Bool,
   ?contents:String,
   ?rowHeight:Int,
   ?wordWrap: Bool,
   ?multiline: Bool,

   ?wantsFocus:Bool,
   ?isInput:Bool,
   ?isInteger:Bool,
   ?listOnly:Bool,
   ?toggle:Bool,
   ?tooltip:String,
   ?overlapped:Bool,
   ?supportsSecondary:Bool,
   ?showRight:Bool,
   ?buttonGap:Int,
   ?buttonSpacing:Int,
   ?buttonAlign:Int,
   ?width:Float,
   ?down:Bool,
   ?resource:String,


   ?bmpScale:Float,
   ?smooth:Bool,
   ?dynamicSize:Bool,
   ?titleStyle:Attribs,
   ?onClick:Void->Void,
   ?panelCols:Int,
   ?panelText: Attribs,
   ?progressStyle: ProgressStyle,
   ?bestWidth:Float,
   ?bestHeight:Float,
   ?itemHeight:Float,
   ?columnWidth:Float,
   ?scrollWheelStep:Float,

   ?step:Float,
   ?arrowStep:Float,
   ?placeholder:String,
   ?minValue:Float,
   ?maxValue:Float,
   ?barColour:Int,

   ?browseTitle: String,
   ?browseFilter: String,
   ?browseFlags: Int,
   ?onTextEnter:String->Void,
   ?icon:BitmapData,
   ?text:String,
   ?alternateText:String,
   ?onState: Int->Void,
}
