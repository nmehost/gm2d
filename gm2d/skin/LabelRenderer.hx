package gm2d.skin;

import nme.text.TextFormat;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;


class LabelRenderer
{
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
                  var fmt = new TextFormat();
                  fmt.size = text.font_size;
                  fmt.font = text.font_family;
                  switch(text.fill)
                  {
                     case FillSolid(c) : fmt.color = c;
                     default:
                  }
                  return fmt;
               }
            }
         }
      }
      return Skin.textFormat;
   }
}


