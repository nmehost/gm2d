package gm2d.skin;

import gm2d.text.TextField;
import gm2d.text.TextFormat;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;
import gm2d.ui.Layout;


class LabelRenderer
{
   public function new() { }

   public dynamic function styleLabel(ioLabel:TextField) { Skin.current.styleLabel(ioLabel); }


   public static function fromSvg(inSvg:Svg, inSearch:Array<String>)
   {
      for(layer in inSearch)
      {
         if (layer==null || inSvg.findGroup(layer)!=null)
         {
            var renderer = new SvgRenderer(inSvg,layer);
            if (renderer.hasGroup(".font"))
            {
               var text = renderer.findText( function(_,groups) { /*trace(groups);*/return groups[1]==".font"; } );
               if (text!=null)
               {
                  var result = new LabelRenderer();
                  var fmt = new TextFormat();
                  fmt.size = text.font_size;
                  fmt.font = text.font_family;
                  switch(text.fill)
                  {
                     case FillSolid(c) : fmt.color = c;
                     default:
                  }
  
                  result.styleLabel = function(ioLabel:TextField)
                  {
                     Skin.current.styleLabel(ioLabel);
                     ioLabel.defaultTextFormat = fmt;
                  };
                  return result;
               }
            }
         }
      }
      return new LabelRenderer();
   }
}


