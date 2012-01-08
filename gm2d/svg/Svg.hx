package gm2d.svg;

import Xml;
import gm2d.svg.PathParser;
import gm2d.svg.PathSegment;
import gm2d.geom.Matrix;
import gm2d.geom.Rectangle;
import gm2d.display.GradientType;
import gm2d.display.SpreadMethod;
import gm2d.display.CapsStyle;
import gm2d.display.JointStyle;

import gm2d.svg.Grad;
import gm2d.svg.Group;
import gm2d.svg.FillType;



typedef Styles = Hash<String>;


class Svg
{
    public var width(default,null):Float;
    public var height(default,null):Float;
    public var roots(default,null):Array<Group>;

    var mConvertCubics:Bool;
    var mGrads : GradHash;
    var mPathParser: PathParser;

    static var mStyleSplit = ~/;/g;
    static var mStyleValue = ~/\s*(.*)\s*:\s*(.*)\s*/;
    static var mTranslateMatch = ~/translate\((.*),(.*)\)/;
    static var mScaleMatch = ~/scale\((.*)\)/;
    static var mMatrixMatch = ~/matrix\((.*),(.*),(.*),(.*),(.*),(.*)\)/;
    static var mURLMatch = ~/url\(#(.*)\)/;

    public function new(inXML:Xml,inConvertCubics:Bool=false)
    {
       var svg =  inXML.firstElement();
       if (svg==null || (svg.nodeName!="svg" && svg.nodeName!="svg:svg" ) )
          throw "Not an SVG file (" + (svg==null ? "null" : svg.nodeName) + ")";

       mGrads = new GradHash();

       mPathParser = new PathParser();

       mConvertCubics = inConvertCubics;

       roots = new Array();

       width = getFloatStyle("width",svg,null,0.0);
       height = getFloatStyle("height",svg,null,0.0);
       if (width==0 && height==0)
          width = height = 400;
       else if (width==0)
          width = height;
       else if (height==0)
          height = width;

       for(element in svg.elements())
       {
          var name = element.nodeName;
          if (name.substr(0,4)=="svg:")
             name = name.substr(4);

          if (name=="defs")
             loadDefs(element);
          else if (name=="g")
          {
             roots.push( loadGroup(element,new Matrix(), null)  );
          }
       }

       //trace("SVG:");
       //for(g in roots)
          //dumpGroup(g,"");
    }

    function dumpGroup(g:Group,indent:String)
    {
       trace(indent + "Group:" + g.name);
       indent += "  ";
       for(e in g.children)
       {
          switch(e)
          {
             case DisplayPath(path): trace(indent + "Path" + "  " + path.matrix);
             case DisplayGroup(group): dumpGroup(group,indent+"   ");
          }
       }
    }

    function getFloat(inXML:Xml,inName:String,inDef:Float=0.0) : Float
    {
       if (inXML.exists(inName))
          return Std.parseFloat(inXML.get(inName));
       return inDef;
    }

    function loadGradient(inGrad:Xml,inType:GradientType,inCrossLink:Bool)
    {
       var name = inGrad.get("id");
       var grad = new Grad(inType);

       if (inCrossLink && inGrad.exists("xlink:href"))
       {
          var xlink = inGrad.get("xlink:href");
          if (xlink.charAt(0)!="#")
             throw("xlink - unkown syntax : " + xlink );
          var base = mGrads.get(xlink.substr(1));
          if (base!=null)
          {
             grad.colors = base.colors;
             grad.alphas = base.alphas;
             grad.ratios = base.ratios;
             grad.gradMatrix = base.gradMatrix.clone();
             grad.spread = base.spread;
             grad.interp = base.interp;
             grad.radius = base.radius;
          }
             else throw("Unknown xlink : " + xlink);
       }

       if (inGrad.exists("x1"))
       {
          grad.x1 = getFloat(inGrad,"x1");
          grad.y1 = getFloat(inGrad,"y1");
          grad.x2 = getFloat(inGrad,"x2");
          grad.y2 = getFloat(inGrad,"y2");
       }
       else
       {
          grad.x1 = getFloat(inGrad,"cx");
          grad.y1 = getFloat(inGrad,"cy");
          grad.x2 = getFloat(inGrad,"fx",grad.x1);
          grad.y2 = getFloat(inGrad,"fy",grad.y1);
       }

       grad.radius = getFloat(inGrad,"r");


       if (inGrad.exists("gradientTransform"))
          applyTransform(grad.gradMatrix,inGrad.get("gradientTransform"));


       // todo - grad.spread = base.spread;

       for(stop in inGrad.elements())
       {
          var styles = getStyles(stop,null);

          grad.colors.push( getColourStyle("stop-color",stop,styles,0x000000) );
          grad.alphas.push( getFloatStyle("stop-opacity",stop,styles,1.0) );
          grad.ratios.push(
             Std.int( Std.parseFloat(stop.get("offset") ) * 255.0) );
       }


       mGrads.set(name,grad);
    }

    function loadDefs(inXML:Xml)
    {
       // Two passes - to allow forward xlinks
       for(pass in 0...2)
          for(def in inXML.elements())
          {
             var name = def.nodeName;
             if (name.substr(0,4)=="svg:")
                name = name.substr(4);
             if (name=="linearGradient")
                loadGradient(def,GradientType.LINEAR,pass==1);
             else if (name=="radialGradient")
                loadGradient(def,GradientType.RADIAL,pass==1);
          }
    }

    function applyTransform(ioMatrix:Matrix, inTrans:String) : Float
    {
       var scale = 1.0;
       if (mTranslateMatch.match(inTrans))
       {
          // TODO: Pre-translate
          ioMatrix.translate(
                  Std.parseFloat( mTranslateMatch.matched(1) ),
                  Std.parseFloat( mTranslateMatch.matched(2) ));
       }
       else if (mScaleMatch.match(inTrans))
       {
          // TODO: Pre-scale
          var s = Std.parseFloat( mScaleMatch.matched(1) );
          ioMatrix.scale(s,s);
          scale = s;
       }
       else if (mMatrixMatch.match(inTrans))
       {
          var m = new Matrix(
                  Std.parseFloat( mMatrixMatch.matched(1) ),
                  Std.parseFloat( mMatrixMatch.matched(2) ),
                  Std.parseFloat( mMatrixMatch.matched(3) ),
                  Std.parseFloat( mMatrixMatch.matched(4) ),
                  Std.parseFloat( mMatrixMatch.matched(5) ),
                  Std.parseFloat( mMatrixMatch.matched(6) ) );
          m.concat(ioMatrix);
          ioMatrix.a = m.a;
          ioMatrix.b = m.b;
          ioMatrix.c = m.c;
          ioMatrix.d = m.d;
          ioMatrix.tx = m.tx;
          ioMatrix.ty = m.ty;
          scale = Math.sqrt( ioMatrix.a*ioMatrix.a + ioMatrix.c*ioMatrix.c );
       }
       else 
          trace("Warning, unknown transform:" + inTrans);
       return scale;
    }


   function getStyles(inNode:Xml,inPrevStyles:Styles) : Styles
   {
      if (!inNode.exists("style"))
         return inPrevStyles;

      var styles = new Styles();
      if (inPrevStyles!=null)
         for(s in inPrevStyles.keys())
         {
            styles.set(s,inPrevStyles.get(s));
         }

      var style = inNode.get("style");
      var strings = mStyleSplit.split(style);
      for(s in strings)
      {
         if (mStyleValue.match(s))
            styles.set(mStyleValue.matched(1),mStyleValue.matched(2));
      }

      return styles;
   }

   function getStyle(inKey:String,inNode:Xml,inStyles:Styles,inDefault:String)
   {
      if (inNode!=null && inNode.exists(inKey))
      {
         return inNode.get(inKey);
      }

      if (inStyles!=null && inStyles.exists(inKey))
         return inStyles.get(inKey);
 
      //trace("Key not found : " + inKey);
      //trace(inStyles);
      //throw("not found");

      return inDefault;
   }

   function getFloatStyle(inKey:String,inNode:Xml,inStyles:Styles,
               inDefault:Float)
   {
      var s = getStyle(inKey,inNode,inStyles,"");
      if (s=="")
         return inDefault;
      return Std.parseFloat(s);
   }

   function getColourStyle(inKey:String,inNode:Xml,inStyles:Styles,
               inDefault:Int)
   {
      var s = getStyle(inKey,inNode,inStyles,"");
      if (s=="")
         return inDefault;
      if (s.charAt(0)=='#')
         return Std.parseInt( "0x" + s.substr(1) );
         
      return Std.parseInt(s);
   }

   function getStrokeStyle(inKey:String,inNode:Xml,inStyles:Styles,
               inDefault:Null<Int>)
   {
      var s = getStyle(inKey,inNode,inStyles,"");
      if (s=="")
         return inDefault;

      if (s=="none")
         return null;

      if (s.charAt(0)=='#')
         return Std.parseInt( "0x" + s.substr(1) );

      return Std.parseInt(s);
   }

   function GetFillStyle(inKey:String,inNode:Xml,inStyles:Styles)
   {
      var s = getStyle(inKey,inNode,inStyles,"");
      if (s=="")
         return FillNone;

      if (s.charAt(0)=='#')
         return FillSolid( Std.parseInt( "0x" + s.substr(1) ) );
 
      if (s=="none")
         return FillNone;

      if (mURLMatch.match(s))
      {
         var url = mURLMatch.matched(1);
         if (mGrads.exists(url))
            return FillGrad(mGrads.get(url));
         
         throw("Unknown url:" + url);
      }

      throw("Unknown fill string:" + s);

      return FillNone;
   }



    public function loadPath(inPath:Xml, matrix:Matrix,inStyles:Styles,inIsRect:Bool) : Path
    {
       if (inPath.exists("transform"))
       {
          matrix = matrix.clone();
          applyTransform(matrix,inPath.get("transform"));
       }

       var styles = getStyles(inPath,inStyles);

       var name = inPath.exists("id") ? inPath.get("id") : "";

       var path = new Path();
       path.fill=GetFillStyle("fill",inPath,styles);
       path.fill_alpha= getFloatStyle("fill-opacity",inPath,styles,1.0);
       path.stroke_alpha= getFloatStyle("stroke-opacity",inPath,styles,1.0);
       path.stroke_colour=getStrokeStyle("stroke",inPath,styles,null);
       path.stroke_width= getFloatStyle("stroke-width",inPath,styles,1.0);
       path.stroke_caps=CapsStyle.ROUND;
       path.joint_style=JointStyle.ROUND;
       path.miter_limit= getFloatStyle("stroke-miterlimit",inPath,styles,3.0);
       path.segments=[];
       path.matrix=matrix;
       path.name=name;

       if (inIsRect)
       {
          var x = inPath.exists("x") ? Std.parseFloat(inPath.get("x")) : 0;
          var y = inPath.exists("y") ? Std.parseFloat(inPath.get("y")) : 0;
          var w = Std.parseFloat(inPath.get("width"));
          var h = Std.parseFloat(inPath.get("height"));
          var rx = inPath.exists("rx") ? Std.parseFloat(inPath.get("rx")) : 0.0;
          var ry = inPath.exists("ry") ? Std.parseFloat(inPath.get("ry")) : 0.0;
          if (rx==0 || ry==0)
          {
             path.segments.push( new MoveSegment(x,y) );
             path.segments.push( new DrawSegment(x+w,y) );
             path.segments.push( new DrawSegment(x+w,y+h) );
             path.segments.push( new DrawSegment(x,y+h) );
             path.segments.push( new DrawSegment(x,y) );
          }
          else
          {
             path.segments.push( new MoveSegment(x,y+ry) );
             // top-left
             path.segments.push( new QuadraticSegment(x,y,x+rx,y) );
 
             path.segments.push( new DrawSegment(x+w-rx,y) );
             // top-right
             path.segments.push( new QuadraticSegment(x+w,y,x+w,y+rx) );
 
             path.segments.push( new DrawSegment(x+w,y+h-ry) );
 
             // bottom-right
             path.segments.push( new QuadraticSegment(x+w,y+h,x+w-rx,y+h) );
 
             path.segments.push( new DrawSegment(x+rx,y+h) );
 
             // bottom-left
             path.segments.push( new QuadraticSegment(x,y+h,x,y+h-ry) );
 
             path.segments.push( new DrawSegment(x,y+ry) );
           }
       }
       else
       {
          var d = inPath.exists("points") ? ("M" + inPath.get("points") + "z" ) : inPath.get("d");
          for(segment in mPathParser.parse(d,mConvertCubics) )
             path.segments.push(segment);
       }

       return path;
    }

    public function loadGroup(inG:Xml, matrix:Matrix,inStyles:Styles) : Group
    {
       var g = new Group();
       if (inG.exists("transform"))
       {
          matrix = matrix.clone();
          applyTransform(matrix,inG.get("transform"));
       }
       if (inG.exists("inkscape:label"))
          g.name = inG.get("inkscape:label");
       else if (inG.exists("id"))
          g.name = inG.get("id");

       var styles = getStyles(inG,inStyles);


       for(el in inG.elements())
       {
          var name = el.nodeName;
          if (name.substr(0,4)=="svg:")
             name = name.substr(4);
          if (name=="g")
          {
             g.children.push( DisplayGroup(loadGroup(el,matrix, styles)) );
          }
          else if (name=="path")
          {
             g.children.push( DisplayPath( loadPath(el,matrix, styles, false) ) );
          }
          else if (name=="rect")
          {
             g.children.push( DisplayPath( loadPath(el,matrix, styles, true) ) );
          }
          else if (name=="polygon")
          {
             g.children.push( DisplayPath( loadPath(el,matrix, styles, false) ) );
          }
          else
          {
             // throw("Unknown child : " + el.nodeName );
          }
       }
       return g;
    }
}
