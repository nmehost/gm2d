import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldAutoSize;
import nme.ui.Keyboard;
import gm2d.ui.Layout;


class CodeBox extends TextField
{
   public var layout:Layout;

   public function new(inText:String)
   {
      super();
      var fmt = new TextFormat();
      fmt.font = "courier";
      fmt.size = Std.int(12*Talk.instance.guiScale);
      //fmt.color = 0xff00ff;
      fmt.color = 0xffffff;
      fmt.bold = true;
      defaultTextFormat = fmt;
      border = true;
      borderColor = 0x0000ff;
      background = true;
      backgroundColor = 0x000000;
      selectable = false;
      multiline = true;

      setText(inText);
      var pad = 10*Talk.instance.guiScale;
      layout = new TextLayout(this).setPadding(pad,pad).stretch();
   }

   public function setText(inText:String)
   {
      htmlText = inText;
   }
}
