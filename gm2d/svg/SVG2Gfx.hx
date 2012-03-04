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
import gm2d.gfx.Gfx;


typedef GroupPath = Array<String>;
typedef ObjectFilter = String->GroupPath->Bool;

class SVG2Gfx
{
    public var width(default,null):Float;
    public var height(default,null):Float;

    var mSvg:Svg;
    var mGfx : Gfx;
    var mMatrix : Matrix;
    var mFilter : ObjectFilter;
    var mGroupPath : GroupPath;

    public function new(inXML:Xml,inConvertCubics:Bool = false)
    {
       mSvg = new Svg(inXML,inConvertCubics);

       width = mSvg.width;
       height = mSvg.height;
    }

    public static function toHaxe(inXML:Xml,?inFilter:ObjectFilter) : Array<String>
    {
       return new SVG2Gfx(inXML,true).iterate(new gm2d.gfx.Gfx2Haxe(),inFilter).commands;
    }

    public static function toBytes(inXML:Xml,?inFilter:ObjectFilter) : gm2d.gfx.GfxBytes
    {
       return new SVG2Gfx(inXML,true).iterate(new gm2d.gfx.GfxBytes(),inFilter);
    }


    public function iterate<T>(inGfx:T, ?inFilter:ObjectFilter) : T
    {
       mGfx = cast inGfx;
       mMatrix = new Matrix();
       mFilter = inFilter;
       mGroupPath = [];
       mGfx.size(width,height);
       iterateGroup(mSvg,true);
       mGfx.eof();
       return inGfx;
    }

    public function iteratePath(inPath:Path)
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


       var geomOnly = mGfx.geometryOnly();

       context = new RenderContext();
       context.matrix = m;

       if (!geomOnly)
       {
          // Move to avoid the case of:
          //  1. finish drawing line on last path
          //  2. set fill=something
          //  3. move (this draws in the fill)
          //  4. continue with "real" drawing
          inPath.segments[0].toGfx(mGfx, context);

          switch(inPath.fill)
          {
             case FillGrad(grad):
                grad.updateMatrix(m);
                mGfx.beginGradientFill(grad);
             case FillSolid(colour):
                mGfx.beginFill(colour,inPath.fill_alpha);
             case FillNone:
                //mGfx.endFill();
          }


          if (inPath.stroke_colour==null)
          {
             //mGfx.lineStyle();
          }
          else
          {
             var style = new gm2d.gfx.LineStyle();
             var scale = Math.sqrt(m.a*m.a + m.c*m.c);
             style.thickness = inPath.stroke_width*scale;
             style.alpha = inPath.stroke_alpha;
             style.color = inPath.stroke_colour;
             style.capsStyle = inPath.stroke_caps;
             style.jointStyle = inPath.joint_style;
             style.miterLimit = inPath.miter_limit;
             mGfx.lineStyle(style);
          }
       }


       for(segment in inPath.segments)
          segment.toGfx(mGfx, context);

       mGfx.endFill();
       mGfx.endLineStyle();
    }



    public function iterateGroup(inGroup:Group,inIgnoreDot:Bool)
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
                iterateGroup(group,inIgnoreDot);
             case DisplayPath(path):
                iteratePath(path);
          }
       }

       mGroupPath.pop();
    }

    public function Render(inGfx:Graphics,?inMatrix:Matrix, ?inFilter:ObjectFilter )
    {
       mGfx = new gm2d.gfx.GfxGraphics(inGfx);
       if (inMatrix==null)
          mMatrix = new Matrix();
       else
          mMatrix = inMatrix.clone();

       mFilter = inFilter;
       mGroupPath = [];

       iterateGroup(mSvg,true);
    }

    public function GetExtent(?inMatrix:Matrix, ?inFilter:ObjectFilter, inIgnoreDot=true ) :
        Rectangle
    {
       var gfx = new gm2d.gfx.GfxExtent();
       mGfx = gfx;
       if (inMatrix==null)
          mMatrix = new Matrix();
       else
          mMatrix = inMatrix.clone();

       mFilter = inFilter;
       mGroupPath = [];

       iterateGroup(mSvg,inIgnoreDot);

       return gfx.extent;
    }

    public function RenderObject(inObj:DisplayObject,inGfx:Graphics,
                    ?inMatrix:Matrix,?inFilter:ObjectFilter)
    {
       Render(inGfx,inMatrix,inFilter);
       var rect = GetExtent(inMatrix, function(_,groups) { return groups[1]==".scale9"; } );
		 // TODO:
		 /*
       if (rect!=null)
          inObj.scale9Grid = rect;
       #if !flash
       inObj.cacheAsBitmap = neash.Lib.IsOpenGL();
       #end
		 */
    }

    public function RenderSprite(inObj:Sprite, ?inMatrix:Matrix,?inFilter:ObjectFilter)
    {
       RenderObject(inObj,inObj.graphics,inMatrix,inFilter);
    }

    public function CreateShape(?inMatrix:Matrix,?inFilter:ObjectFilter) : Shape
    {
       var shape = new Shape();
       RenderObject(shape,shape.graphics,inMatrix,inFilter);
       return shape;
    }

    public function namedShape(inName:String) : Shape
    {
       return CreateShape(null, function(name,_) { return name==inName; } );
    }



    public function ToBitmap()
    {
       mMatrix = new Matrix();

       var w = Math.ceil( width );
       var h = Math.ceil( height );

       var bmp = new gm2d.display.BitmapData(w,h,true,gm2d.RGB.CLEAR );

       var shape = new gm2d.display.Shape();
       mGfx = new gm2d.gfx.GfxGraphics(shape.graphics);

       mGroupPath = [];
       iterateGroup(mSvg,true);

      bmp.draw(shape);
      mGfx = null;

      return bmp;
    }

    public function RectToBitmap(inRect:Rectangle,inScale:Float = 1.0)
    {
       mMatrix = new Matrix(inScale,0,0,inScale, -inRect.x*inScale, -inRect.y*inScale);

       var w = Math.ceil( inRect.width*inScale );
       var h = Math.ceil( inRect.height*inScale );

       var bmp = new gm2d.display.BitmapData(w,h,true,gm2d.RGB.CLEAR );

       var shape = new gm2d.display.Shape();
       mGfx = new gm2d.gfx.GfxGraphics(shape.graphics);

       mGroupPath = [];
       iterateGroup(mSvg,true);

      bmp.draw(shape);
      mGfx = null;

      return bmp;
    }
}

