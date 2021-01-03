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
   var urlMatch = ~/url\(#(.*?)\)/;

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
   public var currentColor = 0x000000;
   public var forceCurrentColour = true;
   var rectW:Float;
   var rectH:Float;

   // For iterating
   var mIgnoreDot:Bool;
   var mFilter : ObjectFilter;
   var mGroupPath : GroupPath;
   var styles : SvgStyles;
   var mGfx : Gfx;
   var mMatrix : Matrix;
   var mMarkerLockout:Bool;

   public function new(inSvg:Group,?inLayer:String,?inCurrentColour:Int, ?inForceCurrent:Bool)
   {
       mRoot = inSvg;
       mMarkerLockout = false;

       if (Std.isOfType(inSvg,Svg))
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
       if (inCurrentColour!=null)
          currentColor = inCurrentColour;
       forceCurrentColour = inForceCurrent==null ? inCurrentColour!=null : forceCurrentColour;

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
       textStyle.fill = styles.getFill("fill",false);
       textStyle.size = styles.getFloat("font-size",14);
       textStyle.family = styles.get("font-family","");
       textStyle.weight = styles.get("font-weight","");
       mGfx.renderText(inText,mMatrix,textStyle);
    }

    public function createTextObj(inText:Text)
    {
       var shape = new Shape();
       mGfx = new gm2d.gfx.GfxGraphics(shape.graphics);
       renderText(inText);
       mGfx = null;
       return shape;
    }

    public function createPathObj(inPath:Path) : Shape
    {
       if (inPath.segments.length==0)
           return null;

       var shape = new Shape();
       mGfx = new gm2d.gfx.GfxGraphics(shape.graphics);
       renderPath(inPath);
       mGfx = null;
       return shape;
    }


    public function renderPath(inPath:Path)
    {
       if (mFilter!=null && !mFilter(inPath.name,mGroupPath))
          return null;

       if (inPath.segments.length==0 || mGfx==null)
           return;

       resetRenderContext();


       var geomOnly = mGfx.geometryOnly();
       var lineStyle:gm2d.gfx.LineStyle = null;
       var strokeScale = 1.0;
       if (!geomOnly)
       {
          // Move to avoid the case of:
          //  1. finish drawing line on last path
          //  2. set fill=something
          //  3. move (this draws in the fill)
          //  4. continue with "real" drawing
          inPath.segments[0].toGfx(mGfx, this);
          var opacity = styles.getFloat("opacity",1.0);
          switch(styles.getFill("fill",forceCurrentColour))
          {
             case FillGrad(grad):
                grad.updateMatrix(mMatrix);
                mGfx.beginGradientFill(grad);
             case FillSolid(colour):
                mGfx.beginFill(colour,styles.getFloat("fill-opacity",1.0)*opacity);
             case FillCurrentColor:
                mGfx.beginFill(currentColor,styles.getFloat("fill-opacity",1.0)*opacity);

             case FillNone:
                //mGfx.endFill();
          }


          var strokeFill=styles.getFill("stroke",false);

          if (strokeFill!=null && strokeFill!=FillNone)
          {

             lineStyle = new gm2d.gfx.LineStyle();
             strokeScale = mMatrix==null ? 1.0 : Math.sqrt(mMatrix.a*mMatrix.a + mMatrix.c*mMatrix.c);
             lineStyle.thickness = styles.getFloat("stroke-width",1)*strokeScale;
             lineStyle.alpha = styles.getFloat("stroke-opacity",1)*opacity;
             lineStyle.color = 0;
             lineStyle.capsStyle = CapsStyle.ROUND;
             lineStyle.jointStyle = JointStyle.ROUND;
             lineStyle.miterLimit = styles.getFloat("stroke-miterlimit",3.0);

             switch(strokeFill)
             {
                case FillGrad(grad):
                   lineStyle.gradient = grad;
                case FillSolid(colour):
                   lineStyle.color = colour;
                case FillCurrentColor:
                   lineStyle.color = currentColor;

                case FillNone:
                   //mGfx.endFill();
             }
             mGfx.lineStyle(lineStyle);
          }
       }

       for(segment in inPath.segments)
       {
          segment.toGfx(mGfx, this);
       }

       mGfx.endFill();
       mGfx.endLineStyle();

       if (lineStyle!=null && !mMarkerLockout)
       {
          var markerEnd = styles.getMarker("marker-end",mSvg.getLinks());
          if (markerEnd!=null)
          {
             var segs = inPath.segments;
             var n = segs.length;
             var seg = segs[ n-1 ];
             var prev = n>1 ? segs[ n-2 ] : null;
             var dir = seg.getDirection(1.0, prev);

             var ex = seg.prevX();
             var ey = seg.prevY();
             var thick = lineStyle.thickness / strokeScale;
             var c = Math.cos(dir) * thick;
             var s = Math.sin(dir) * thick;
             var matrix = new Matrix(c, s, -s, c, ex-markerEnd.refX, ey-markerEnd.refY);
             mMarkerLockout = true;
             var old = pushMatrix(matrix);
             iterateGroup(markerEnd);
             mMatrix = old;
             mMarkerLockout = false;
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

   public function getMask(style:Map<String,String>) : Group
   {
      if (style==null)
         return null;
      var s = style.get("mask");
      if (s==null || s=="" || s=="none")
         return null;

      if (urlMatch.match(s))
      {
         var url = urlMatch.matched(1);
         var mask = mSvg.mMasks.get(url);
         if (mask==null)
            throw "Unknown mask " + url;
         return mask;
      }
      throw("Unknown marker string:" + s);
      return null;
   }

    public function renderDisplayTreeGroup(inParent:Sprite, group:Group)
    {
       if (group.matrix!=null)
          inParent.transform.matrix = group.matrix;

       var mask = getMask(group.style);
       if (mask!=null)
       {
          var m = new Sprite();
          renderDisplayTreeGroup(m,mask);
          inParent.addChild(m);
          inParent.mask = m;
       }

       var doPop = pushStyle(group.style);
       for(child in group.children)
       {
          if (child.style!=null && child.style.get("display")=="none")
             continue;

          var g = child.asGroup();
          if (g!=null)
          {
             var c = new Sprite();
             inParent.addChild(c);
             renderDisplayTreeGroup(c,g);
          }
          else
          {
             var obj:DisplayObject = null;

             var doPop = pushStyle(child.style);
             while(child.asLink()!=null)
             {
                var link = child.asLink();
                if (link==null || link.link==null)
                   break;
                var linked = mSvg.findLink(link.link);
                if (linked==null)
                {
                   trace("Could not find " +link.link);
                   break;
                }

                var lg = linked.asGroup();
                if (lg!=null)
                {
                   var sprite = new Sprite();
                   renderDisplayTreeGroup(sprite,lg);
                   obj = sprite;
                   break;
                }
                else
                {
                   child = linked;
                }
             }

             if (child.asPath()!=null)
                obj = createPathObj(child.asPath());
             else if (child.asText()!=null)
                obj = createTextObj(child.asText());


             if (obj!=null)
             {
                var filters = styles.getFilterSet(mSvg.mFilters);
                if (filters!=null)
                   obj.filters = filters.filters;

                if (child.matrix!=null)
                    obj.transform.matrix = child.matrix;
                inParent.addChild(obj);
             }

             if (doPop)
                popStyle();
          }
       }
       var filters = styles.getFilterSet(mSvg.mFilters);
       if (filters!=null)
          inParent.filters = filters.filters;
       if (doPop)
          popStyle();
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

    public function createDisplayTree() : Sprite
    {
       var sprite = new Sprite();
       mMatrix = null;
       renderDisplayTreeGroup(sprite,mRoot);
       return sprite;
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

       var w = Std.int(Math.ceil( inRect==null ? width*inScale : inRect.width ));
       var h = Std.int(Math.ceil( inRect==null ? height*inScale : inRect.height ));

       var bmp = new nme.display.BitmapData(w,h,true,gm2d.RGB.CLEAR );

       var shape = new nme.display.Shape();
       render(shape.graphics,matrix);
       bmp.draw(shape);
       return bmp;
    }
}

