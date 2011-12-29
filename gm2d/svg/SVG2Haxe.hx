package gm2d.svg;

import Xml;
import gm2d.svg.PathParser;
import gm2d.svg.PathSegment;

import gm2d.geom.Matrix;
import gm2d.geom.Rectangle;
import gm2d.display.Graphics;

import gm2d.display.Shape;
import gm2d.display.Sprite;
import gm2d.display.DisplayObject;
import gm2d.display.GradientType;
import gm2d.display.SpreadMethod;
import gm2d.display.InterpolationMethod;
import gm2d.display.CapsStyle;
import gm2d.display.JointStyle;
import gm2d.display.LineScaleMode;

import gm2d.svg.Grad;
import gm2d.svg.Group;
import gm2d.svg.FillType;


typedef ObjectFilter1 = String->Array<String>->Bool;

class SVG2Haxe
{
    public var width(default,null):Float;
    public var height(default,null):Float;

    var mSvg:Svg;
    var mCommands : Array<String>;
    var mMatrix : Matrix;
    var mFilter : ObjectFilter1;
    var mGroupPath : Array<String>;
    var mExtent:Rectangle;

    public function new(inXML:Xml)
    {
       mSvg = new Svg(inXML,true);
    }

    function newMatrix(m:Matrix)
    {
       return "new Matrix(" + m.a + "," + m.b + "," + m.c + "," + m.d + "," + m.tx + "," + m.ty + ")";
    }

    public function RenderPath(inPath:Path)
    {
       if (mFilter!=null && !mFilter(inPath.name,mGroupPath))
          return;

       if (inPath.segments.length==0)
           return;
       var px = 0.0;
       var py = 0.0;

       var m:Matrix  = inPath.matrix.clone();
       m.concat(mMatrix);
       var context:RenderContext = null;


          context = new RenderContext();
          context.matrix = m;

          // Move to avoid the case of:
          //  1. finish drawing line on last path
          //  2. set fill=something
          //  3. move (this draws in the fill)
          //  4. continue with "real" drawing
          inPath.segments[0].toCommands(mCommands, context);

          switch(inPath.fill)
          {
             case FillGrad(grad):
                mCommands.push("g.beginGradientFill(" + grad.type + ","+  grad.cols + "," +  grad.alphas + "," + 
                         grad.ratios + "," +  newMatrix(grad.GetMatrix(m)) + "," +  grad.spread + "," +  grad.interp + "," +  grad.focus  + ");" );

             case FillSolid(colour):
                mCommands.push("g.beginFill(" + colour + "," + inPath.fill_alpha  + ");");
             case FillNone:
                //mGfx.endFill();
          }


          if (inPath.stroke_colour==null)
          {
             //mGfx.lineStyle();
          }
          else
          {
             var scale = Math.sqrt(m.a*m.a + m.c*m.c);
             var sw = inPath.stroke_width*scale;
             var a = inPath.stroke_alpha;

             mCommands.push("g.lineStyle("+sw+","+inPath.stroke_colour+","+a+
                             ",false,LineScaleMode.NORMAL," +
                             inPath.stroke_caps + "," + inPath.joint_style + "," + 
                             inPath.miter_limit + ");");
          }


       for(segment in inPath.segments)
          segment.toCommands(mCommands, context);
       mCommands.push("g.endFill();");
       mCommands.push("g.lineStyle();");
    }



    public function RenderGroup(inGroup:Group,inIgnoreDot:Bool)
    {
       // Convention for hidden layers ...
       if (inGroup.name!=null && inGroup.name.substr(0,1)==".")
          return;

       mGroupPath.push(inGroup.name);

       // if (mFilter!=null && !mFilter(inGroup.name)) return;

       for(child in inGroup.children)
       {
          switch(child)
          {
             case DisplayGroup(group):
                RenderGroup(group,inIgnoreDot);
             case DisplayPath(path):
                RenderPath(path);
          }
       }

       mGroupPath.pop();
    }

    public function toHaxe(?inFilter:ObjectFilter1 )
    {
       mCommands = [];
       mMatrix = new Matrix();

       mFilter = inFilter;
       mGroupPath = [];

       for(g in mSvg.roots)
          RenderGroup(g,true);

       return mCommands;
    }

}

