package gm2d.svg;

import Xml;
import gm2d.svg.PathParser;
import gm2d.svg.PathSegment;

import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.display.Graphics;

import nme.display.Shape;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.GradientType;
import nme.display.SpreadMethod;
import nme.display.InterpolationMethod;
import nme.display.CapsStyle;
import nme.display.JointStyle;
import nme.display.LineScaleMode;

import gm2d.svg.Grad;
import gm2d.svg.Group;
import gm2d.svg.FillType;
import gm2d.svg.DisplayElement;
import gm2d.gfx.Gfx;
import nme.geom.Rectangle;


typedef GroupPath = Array<String>;
typedef ObjectFilter = String->GroupPath->Bool;

class SvgRenderer
{
   public var width(default,null):Float;
   public var height(default,null):Float;

   var mSvg:Svg;
   var mRoot:Group;

   var mScaleRect:Rectangle;
   var mScaleW:Null<Float>;
   var mScaleH:Null<Float>;

   // RenderContext
   public var lastX(default,null):Float;
   public var lastY(default,null):Float;
   public var firstX:Float;
   public var firstY:Float;
   var rectW:Float;
   var rectH:Float;

   // For iterating
   var mIgnoreDot:Bool;
   var mFilter : ObjectFilter;
   var mGroupPath : GroupPath;
   var styles : SvgStyles;
   var mGfx : Gfx;
   var mMatrix : Matrix;

   public function new(inSvg:Group,?inLayer:String)
   {
       mRoot = inSvg;

       if (Std.is(inSvg,Svg))
       {
          mSvg = cast inSvg;
          width = mSvg.width;
          height = mSvg.height;
          mRoot = mSvg;
       }
       else
       {
          mSvg = null;
          width = 100;
          height = 100;
       }

       styles = new SvgStyles(mSvg==null ? null : mSvg.getGradients());

       if (inLayer!=null)
       {
          mRoot = mRoot.findGroup(inLayer);
          if (mRoot==null)
             throw "Could not find SVG group: " + inLayer;
       }
    }

   // Render context
   public function resetRenderContext()
   {
      firstX = 0;
      firstY = 0;
      lastX = 0;
      lastY = 0;
   }
   inline public function getMatrix() return mMatrix;
   public function  transX(inX:Float, inY:Float)
   {
      if (mScaleRect!=null && inX>mScaleRect.x)
      {
         if (inX>mScaleRect.right)
            inX += rectW - mScaleRect.width;
         else
            inX = mScaleRect.x + rectW * (inX-mScaleRect.x)/mScaleRect.width;
      }
      if (mMatrix==null)
         return inX;
      return inX*mMatrix.a + inY*mMatrix.c + mMatrix.tx;
   }
   public function  transY(inX:Float, inY:Float)
   {
      if (mScaleRect!=null && inY>mScaleRect.y)
      {
         if (inY>mScaleRect.right)
            inY += rectH - mScaleRect.height;
         else
            inY = mScaleRect.y + rectH * (inY-mScaleRect.y)/mScaleRect.height;
      }
      if (mMatrix==null)
         return inY;
      return inX*mMatrix.b + inY*mMatrix.d + mMatrix.ty;
   }


   public function setLast(inX:Float, inY:Float)
   {
      lastX = transX(inX,inY);
      lastY = transY(inX,inY);
   }


    public function pushStyle(style:Style) return styles.push(style);
    public function popStyle() styles.pop();


    public function pushMatrix(inMatrix:Matrix) : Matrix
    {
       var result = mMatrix;
       if (inMatrix!=null)
       {
          if (mMatrix==null)
             mMatrix = inMatrix;
          else
          {
             var old = mMatrix;
             mMatrix = inMatrix.clone();
             mMatrix.concat(old);
          }
       }
       return result;
    }


    public static function toHaxe(inXML:Xml,?inFilter:ObjectFilter) : Array<String>
    {
       return new SvgRenderer(new Svg(inXML,true)).iterate(new gm2d.gfx.Gfx2Haxe(),inFilter).commands;
    }

    public static function toBytes(inXML:Xml,?inFilter:ObjectFilter) : gm2d.gfx.GfxBytes
    {
       return new SvgRenderer(new Svg(inXML,true)).iterate(new gm2d.gfx.GfxBytes(),inFilter);
    }


    public function hasGroup(inName:String)
    {
        return mRoot.hasGroup(inName);
    }

    public function renderText(inText:Text)
    {
       if (mFilter!=null && !mFilter(inText.name,mGroupPath))
          return;

       var textStyle = new TextStyle();
       textStyle.fill = styles.getFill("fill");
       textStyle.size = styles.getFloat("font-size",14);
       textStyle.family = styles.get("font-family","");
       textStyle.weight = styles.get("font-weight","");
       mGfx.renderText(inText,mMatrix,textStyle);
    }

    public function renderPath(inPath:Path)
    {
       if (mFilter!=null && !mFilter(inPath.name,mGroupPath))
          return;

       if (inPath.segments.length==0 || mGfx==null)
           return;

       resetRenderContext();


       var geomOnly = mGfx.geometryOnly();
       var lineStyle:gm2d.gfx.LineStyle = null;
       if (!geomOnly)
       {
          // Move to avoid the case of:
          //  1. finish drawing line on last path
          //  2. set fill=something
          //  3. move (this draws in the fill)
          //  4. continue with "real" drawing
          inPath.segments[0].toGfx(mGfx, this);
          var opacity = styles.getFloat("opacity",1.0);
          switch(styles.getFill("fill"))
          {
             case FillGrad(grad):
                grad.updateMatrix(mMatrix);
                mGfx.beginGradientFill(grad);
             case FillSolid(colour):
                mGfx.beginFill(colour,styles.getFloat("fill-opacity",1.0)*opacity);

             case FillNone:
                //mGfx.endFill();
          }


          var stroke_colour=styles.getStroke("stroke");
          if (stroke_colour!=null)
          {
             lineStyle = new gm2d.gfx.LineStyle();
             var scale = mMatrix==null ? 1.0 : Math.sqrt(mMatrix.a*mMatrix.a + mMatrix.c*mMatrix.c);
             lineStyle.thickness = styles.getFloat("stroke-width",1)*scale;
             lineStyle.alpha = styles.getFloat("stroke-opacity",1)*opacity;
             lineStyle.color = stroke_colour;
             lineStyle.capsStyle = CapsStyle.ROUND;
             lineStyle.jointStyle = JointStyle.ROUND;
             lineStyle.miterLimit = styles.getFloat("stroke-miterlimit",3.0);
             mGfx.lineStyle(lineStyle);
          }
       }

       for(segment in inPath.segments)
       {
          segment.toGfx(mGfx, this);
       }

       mGfx.endFill();
       mGfx.endLineStyle();

       if (lineStyle!=null)
       {
          var markerEnd = styles.getMarker("marker-end",mSvg.getLinks());
          if (markerEnd!=null)
          {
             // TODO
          }
       }
    }

    public function iterateChild(child:DisplayElement)
    {
       if (child.asGroup()!=null)
          iterateGroup(child.asGroup());
       else
       {
          var matrix = pushMatrix(child.matrix);
          var doPop = pushStyle(child.style);

          if (child.asPath()!=null)
             renderPath(child.asPath());
          else if (child.asText()!=null)
             renderText(child.asText());
          else if (child.asLink()!=null)
             renderLink(child.asLink());

          mMatrix = matrix;
          if (doPop)
             popStyle();
       }
    }


    public function renderLink(link:Link)
    {
       if (link.link==null)
          return;

       var linked = mSvg.findLink(link.link);
       if (linked==null)
       {
          trace("Could not find " +link.link);
          return;
       }

       iterateChild(linked);
    }


    public function iterateGroup(inGroup:Group)
    {
       // Convention for hidden layers ...
       if (mIgnoreDot && inGroup.name!=null && inGroup.name.substr(0,1)==".")
          return;

       mGroupPath.push(inGroup.name);
       var matrix = pushMatrix(inGroup.matrix);
       var doPop = pushStyle(inGroup.style);

       // if (mFilter!=null && !mFilter(inGroup.name)) return;

       for(child in inGroup.children)
          iterateChild(child);

       mGroupPath.pop();
       mMatrix = matrix;
       if (doPop)
          popStyle();
    }



    public function iterateRoot(inGfx:Gfx,inMatrix:Matrix, inFilter:ObjectFilter, inScaleRect:Rectangle,inScaleW:Null<Float>, inScaleH:Null<Float>, inIgnoreDot:Bool ) : Gfx
    {
       mGfx = inGfx;
       mMatrix = inMatrix;
       mFilter = inFilter;
       mScaleRect = inScaleRect;
       mScaleW = inScaleW;
       mScaleH = inScaleH;
       mIgnoreDot = inIgnoreDot;

       mGroupPath = [];
       mGroupPath = [];
       styles.reset();
       rectW = mScaleW!=null ? mScaleW : mScaleRect!=null? mScaleRect.width : 1;
       rectH = mScaleH!=null ? mScaleH : mScaleRect!=null? mScaleRect.height : 1;


       mGfx.size(width,height);
       iterateGroup(mRoot);
       mGfx.eof();

       return inGfx;
    }



    public function iterate<T>(inGfx:T, ?inFilter:ObjectFilter):T
    {
       iterateRoot(cast inGfx, null, inFilter, null, null, null, true);
       return inGfx;
    }


    public function render(inGfx:Graphics,?inMatrix:Matrix, ?inFilter:ObjectFilter, ?inScaleRect:Rectangle,?inScaleW:Float, ?inScaleH:Float )
    {
       return iterateRoot( new gm2d.gfx.GfxGraphics(inGfx), inMatrix, inFilter, inScaleRect, inScaleW, inScaleH, inFilter==null);
    }


    public function renderRect(inGfx:Graphics,inFilter:ObjectFilter,scaleRect:Rectangle,inBounds:Rectangle,inRect:Rectangle) : Void
    {
       var matrix = new Matrix();
       matrix.tx = inRect.x-(inBounds.x);
       matrix.ty = inRect.y-(inBounds.y);
       if (scaleRect!=null)
       {
          var extraX = inRect.width-(inBounds.width-scaleRect.width);
          var extraY = inRect.height-(inBounds.height-scaleRect.height);
          render(inGfx,matrix,inFilter,scaleRect, extraX, extraY );
       }
       else
         render(inGfx,matrix,inFilter);
    }

    public function renderRect0(inGfx:Graphics,inFilter:ObjectFilter,scaleRect:Rectangle,inBounds:Rectangle,inRect:Rectangle) : Void
    {
       var matrix = new Matrix();
       matrix.tx = -(inBounds.x);
       matrix.ty = -(inBounds.y);
       if (scaleRect!=null)
       {
          var extraX = inRect.width-(inBounds.width-scaleRect.width);
          var extraY = inRect.height-(inBounds.height-scaleRect.height);
          render(inGfx,matrix,inFilter,scaleRect, extraX, extraY );
       }
       else
         render(inGfx,matrix,inFilter);
    }


    public function getExtent(?inMatrix:Matrix, ?inFilter:ObjectFilter, ?inIgnoreDot:Bool ) : Rectangle
    {
       if (inIgnoreDot==null)
          mIgnoreDot = inFilter==null;
       else
          mIgnoreDot = inIgnoreDot;

       var gfx = new gm2d.gfx.GfxExtent();

       iterateRoot(gfx, inMatrix, inFilter, null, null, null, inIgnoreDot==null ? inFilter==null : inIgnoreDot);

       return gfx.extent;
    }

    public function findText(?inFilter:ObjectFilter)
    {
       var finder = new gm2d.gfx.GfxTextFinder();
       iterateRoot(finder, null, inFilter, null, null, null, false );
       if (finder.text==null)
           return null;
       return finder;
    }

    public function getMatchingRect(inMatch:EReg) : Rectangle
    {
       return getExtent(null, function(_,groups) {
          return groups[1]!=null && inMatch.match(groups[1]);
       }, false  );
    }

    public function renderObject(inObj:DisplayObject,inGfx:Graphics,
                    ?inMatrix:Matrix,?inFilter:ObjectFilter,?inScale9:Rectangle)
    {
       render(inGfx,inMatrix,inFilter,inScale9);
       var rect = getExtent(inMatrix, function(_,groups) { return groups[1]==".scale9"; } );
		 // TODO:
		 /*
       if (rect!=null)
          inObj.scale9Grid = rect;
       #if !flash
       inObj.cacheAsBitmap = neash.Lib.IsOpenGL();
       #end
		 */
    }

    public function renderSprite(inObj:Sprite, ?inMatrix:Matrix,?inFilter:ObjectFilter, ?inScale9:Rectangle)
    {
       renderObject(inObj,inObj.graphics,inMatrix,inFilter,inScale9);
    }

    public function createShape(?inMatrix:Matrix,?inFilter:ObjectFilter, ?inScale9:Rectangle) : Shape
    {
       var shape = new Shape();
       renderObject(shape,shape.graphics,inMatrix,inFilter,inScale9);
       return shape;
    }

    public function namedShape(inName:String) : Shape
    {
       return createShape(null, function(name,_) { return name==inName; } );
    }


    public function renderBitmap(?inRect:Rectangle,inScale:Float = 1.0)
    {
       var matrix = new Matrix(inScale,0,0,inScale,
              inRect==null ? 0 : -inRect.x*inScale,
              inRect==null ? 0 : -inRect.y*inScale);

       var w = Std.int(Math.ceil( inRect==null ? width : inRect.width*inScale ));
       var h = Std.int(Math.ceil( inRect==null ? width : inRect.height*inScale ));

       var bmp = new nme.display.BitmapData(w,h,true,gm2d.RGB.CLEAR );

       var shape = new nme.display.Shape();
       render(shape.graphics,matrix);
       bmp.draw(shape);
       return bmp;
    }
}

