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


typedef GroupPath = Array<String>;
typedef ObjectFilter = String->GroupPath->Bool;

class SVG2Gfx
{
    public var width(default,null):Float;
    public var height(default,null):Float;

    var mSvg:Svg;
    var mGfx : Graphics;
    var mMatrix : Matrix;
    var mFilter : ObjectFilter;
    var mGroupPath : GroupPath;
    var mExtent:Rectangle;

    public function new(inXML:Xml)
    {
       mSvg = new Svg(inXML);

       width = mSvg.width;
       height = mSvg.height;
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


       if (mGfx!=null)
       {
          context = new RenderContext();
          context.matrix = m;

          // Move to avoid the case of:
          //  1. finish drawing line on last path
          //  2. set fill=something
          //  3. move (this draws in the fill)
          //  4. continue with "real" drawing
          inPath.segments[0].Draw(mGfx, context);

          switch(inPath.fill)
          {
             case FillGrad(grad):
                mGfx.beginGradientFill(grad.type, grad.cols, grad.alphas,
                         grad.ratios, grad.GetMatrix(m), grad.spread, grad.interp, grad.focus );

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
             var scale = Math.sqrt(m.a*m.a + m.c*m.c);
             var sw = inPath.stroke_width*scale;
             var a = inPath.stroke_alpha;
             mGfx.lineStyle( sw, inPath.stroke_colour,
                             a, false,LineScaleMode.NORMAL,
                             inPath.stroke_caps,inPath.joint_style,
                             inPath.miter_limit);
          }
       }


       if (mGfx==null)
       {
          for(segment in inPath.segments)
             segment.GetExtent(m,mExtent);

          // switch(inPath.fill) { case FillNone: default: Finalise(); }
       }
       else
       {
          for(segment in inPath.segments)
             segment.Draw(mGfx, context);
          mGfx.endFill();
          mGfx.lineStyle();
       }

    }



    public function RenderGroup(inGroup:Group,inIgnoreDot:Bool)
    {
       // Convention for hidden layers ...
       if (inGroup.name!=null && mGfx!=null && inGroup.name.substr(0,1)==".")
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

    public function Render(inGfx:Dynamic,?inMatrix:Matrix, ?inFilter:ObjectFilter )
    {
       mGfx = inGfx;
       if (inMatrix==null)
          mMatrix = new Matrix();
       else
          mMatrix = inMatrix.clone();

       mFilter = inFilter;
       mGroupPath = [];

       for(g in mSvg.roots)
          RenderGroup(g,true);
    }

    public function GetExtent(?inMatrix:Matrix, ?inFilter:ObjectFilter, inIgnoreDot=true ) :
        Rectangle
    {
       mGfx = null;
       mExtent = new Rectangle(0,0,-1,-1);
       if (inMatrix==null)
          mMatrix = new Matrix();
       else
          mMatrix = inMatrix.clone();

       mFilter = inFilter;
       mGroupPath = [];

       for(g in mSvg.roots)
          RenderGroup(g,inIgnoreDot);

       return mExtent;
    }

    public function RenderObject(inObj:DisplayObject,inGfx:Graphics,
                    ?inMatrix:Matrix,?inFilter:ObjectFilter)
    {
       Render(inGfx,inMatrix,inFilter);
       var rect = GetExtent(inMatrix, function(_,groups) { return groups[0]==".scale9"; } );
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
       mGfx = shape.graphics;

       mGroupPath = [];
       for(g in mSvg.roots)
          RenderGroup(g,true);

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
       mGfx = shape.graphics;

       mGroupPath = [];
       for(g in mSvg.roots)
          RenderGroup(g,true);

      bmp.draw(shape);
      mGfx = null;

      return bmp;
    }
}

