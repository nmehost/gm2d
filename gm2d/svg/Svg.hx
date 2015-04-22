package gm2d.svg;

import Xml;
import gm2d.svg.PathParser;
import gm2d.svg.PathSegment;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.display.GradientType;
import nme.display.SpreadMethod;
import nme.display.CapsStyle;
import nme.display.JointStyle;

import gm2d.svg.Grad;
import gm2d.svg.Group;
import gm2d.svg.FillType;



typedef Styles = haxe.ds.StringMap<String>;


class Svg extends Group
{
    public var width(default,null):Float;
    public var height(default,null):Float;

    var mConvertCubics:Bool;
    var mGrads : GradHash;
    var mPathParser: PathParser;

    static var SIN45:Float = 0.70710678118654752440084436210485;
    static var TAN22:Float = 0.4142135623730950488016887242097;

    static var mStyleSplit = ~/;/g;
    static var mStyleValue = ~/\s*(.*)\s*:\s*(.*)\s*/;
    static var mTranslateMatch = ~/translate\((.+)[,\s]+(.+)\)/;
    static var mRotateMatch = ~/rotate\((.+)[,\s]+(.+)[,\s]+(.+)\)/;
    static var mScaleMatch = ~/scale\((.*)\)/;
    static var mMatrixMatch = ~/matrix\((.+)[,\s]+(.+)[,\s]+(.+)[,\s]+(.+)[,\s]+(.+)[,\s]+(.+)\)/;
    static var mURLMatch = ~/url\(#(.*)\)/;
    static var mRGBMatch = ~/rgb\((\d+)[,\s](\d+)[,\s](\d+)\)/;
    static var defaultFill = FillSolid(0x000000);

    inline static var PATH   = 0;
    inline static var CIRCLE = 1;
    inline static var RECT   = 2;
    inline static var LINE   = 3;
    inline static var OPEN_PATH = 4;

    public function new(inXML:Xml,inConvertCubics:Bool=false)
    {
       super();
       var svg =  inXML.firstElement();
       if (svg==null || (svg.nodeName!="svg" && svg.nodeName!="svg:svg" ) )
          throw "Not an SVG file (" + (svg==null ? "null" : svg.nodeName) + ")";

       mGrads = new GradHash();

       mPathParser = new PathParser();

       mConvertCubics = inConvertCubics;

       width = getFloatStyle("width",svg,null,0.0);
       height = getFloatStyle("height",svg,null,0.0);
       if (width==0 && height==0)
          width = height = 400;
       else if (width==0)
          width = height;
       else if (height==0)
          height = width;

       loadGroup(this,svg,new Matrix(), null);

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
             case DisplayText(text): trace(indent+"Text " + text.text);
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
       else if (mRotateMatch.match(inTrans))
       {
          // TODO: Pre-scale
          var angle = Std.parseFloat( mRotateMatch.matched(1) );
          var x = Std.parseFloat( mRotateMatch.matched(2) );
          var y = Std.parseFloat( mRotateMatch.matched(3) );
          trace('TODO - rotate $angle $x $y');
          //ioMatrix.rotate();
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

      if (mRGBMatch.match(s))
      {
         return (Std.parseInt(mRGBMatch.matched(1))<<16 ) |
                (Std.parseInt(mRGBMatch.matched(2))<<8 ) |
                (Std.parseInt(mRGBMatch.matched(3))<<8 );
      }

      var col = gm2d.RGB.resolve(s);
      if (col!=null)
         return col;

      return Std.parseInt(s);
   }

   function GetFillStyle(inKey:String,inNode:Xml,inStyles:Styles)
   {
      var s = getStyle(inKey,inNode,inStyles,"");
      if (s=="")
         return defaultFill;

      if (s.charAt(0)=='#')
         return FillSolid( Std.parseInt( "0x" + s.substr(1) ) );
 
      if (s=="none")
         return FillNone;

      if (mRGBMatch.match(s))
      {
         return FillSolid( (Std.parseInt(mRGBMatch.matched(1))<<16 ) |
                           (Std.parseInt(mRGBMatch.matched(2))<<8 ) |
                           (Std.parseInt(mRGBMatch.matched(3))<<8 ) );
      }

      if (mURLMatch.match(s))
      {
         var url = mURLMatch.matched(1);
         if (mGrads.exists(url))
            return FillGrad(mGrads.get(url));
         
         throw("Unknown url:" + url);
      }

      var col = gm2d.RGB.resolve(s);
      if (col!=null)
         return FillSolid(col);

      throw("Unknown fill string:" + s);

      return FillNone;
   }



    public function loadPath(inPath:Xml, matrix:Matrix,inStyles:Styles,inMode:Int) : Path
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
       var opacity = getFloatStyle("opacity",inPath,styles,1.0);
       path.fill_alpha= getFloatStyle("fill-opacity",inPath,styles,1)*opacity;
       path.stroke_alpha= getFloatStyle("stroke-opacity",inPath,styles,1)*opacity;
       path.stroke_colour=getStrokeStyle("stroke",inPath,styles,null);
       path.stroke_width= getFloatStyle("stroke-width",inPath,styles,1.0);
       path.stroke_caps=CapsStyle.ROUND;
       path.joint_style=JointStyle.ROUND;
       path.miter_limit= getFloatStyle("stroke-miterlimit",inPath,styles,3.0);
       path.segments=[];
       path.matrix=matrix;
       path.name=name;

       if (inMode==LINE)
       {
          var x1 = inPath.exists("x1") ? Std.parseFloat(inPath.get("x1")) : 0;
          var y1 = inPath.exists("y1") ? Std.parseFloat(inPath.get("y1")) : 0;
          var x2 = inPath.exists("x2") ? Std.parseFloat(inPath.get("x2")) : 0;
          var y2 = inPath.exists("y2") ? Std.parseFloat(inPath.get("y2")) : 0;

          path.segments.push( new MoveSegment(x1,y1) );
          path.segments.push( new DrawSegment(x2,y2) );
       }
       else if (inMode==RECT)
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
       else if (inMode==CIRCLE)
       {
          var x = inPath.exists("cx") ? Std.parseFloat(inPath.get("cx")) : 0;
          var y = inPath.exists("cy") ? Std.parseFloat(inPath.get("cy")) : 0;

          var defaultRad = inPath.exists("r") ? Std.parseFloat(inPath.get("r")) : 0.0;
          var w = inPath.exists("rx") ? Std.parseFloat(inPath.get("rx")) : defaultRad;
          var w_ = w*SIN45;
          var cw_ = w*TAN22;
          var h = inPath.exists("ry") ? Std.parseFloat(inPath.get("ry")) : defaultRad;
          var h_ = h*SIN45;
          var ch_ = h*TAN22;

          path.segments.push( new MoveSegment(x+w,y) );
          path.segments.push( new QuadraticSegment(x+w,  y+ch_, x+w_, y+h_) );
          path.segments.push( new QuadraticSegment(x+cw_,y+h,   x,    y+h) );
          path.segments.push( new QuadraticSegment(x-cw_,y+h,   x-w_, y+h_) );
          path.segments.push( new QuadraticSegment(x-w,  y+ch_, x-w,  y) );
          path.segments.push( new QuadraticSegment(x-w,  y-ch_, x-w_, y-h_) );
          path.segments.push( new QuadraticSegment(x-cw_,y-h,   x,    y-h) );
          path.segments.push( new QuadraticSegment(x+cw_,y-h,   x+w_, y-h_) );
          path.segments.push( new QuadraticSegment(x+w,  y-ch_, x+w,  y) );
       }
       else
       {
          var close = inMode==OPEN_PATH ? "" : "z";
          var d = inPath.exists("points") ? ("M" + inPath.get("points") + close ) : inPath.get("d");
          for(segment in mPathParser.parse(d,mConvertCubics) )
             path.segments.push(segment);
       }

       return path;
    }

    public function loadText(inText:Xml, matrix:Matrix,inStyles:Styles) : Text
    {
       if (inText.exists("transform"))
       {
          matrix = matrix.clone();
          applyTransform(matrix,inText.get("transform"));
       }

       var styles = getStyles(inText,inStyles);

       var text = new Text();
       text.matrix=matrix;
       text.name=inText.exists("id") ? inText.get("id") : "";
       text.x=getFloat(inText,"x",0.0);
       text.y=getFloat(inText,"y",0.0);

       var opacity = getFloatStyle("opacity",inText,styles,1.0);
       text.fill=GetFillStyle("fill",inText,styles);
       text.fill_alpha= getFloatStyle("fill-opacity",inText,styles,opacity);
       text.stroke_alpha= getFloatStyle("stroke-opacity",inText,styles,opacity);
       text.stroke_colour=getStrokeStyle("stroke",inText,styles,null);
       text.stroke_width= getFloatStyle("stroke-width",inText,styles,1.0);
       text.font_family= getStyle("font-family",inText,styles,"");
       text.font_size= getFloatStyle("font-size",inText,styles,12);
       text.letter_spacing= getFloatStyle("letter-spacing",inText,styles,0);
       text.kerning= getFloatStyle("kerning",inText,styles,0);

       var string="";
       for(el in inText.elements())
          string += el.toString();
       //trace(string);
       text.text= string;
       
       return text;
    }

    public function loadGroup(g:Group, inG:Xml, matrix:Matrix,inStyles:Styles) : Group
    {
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

          if (name=="defs")
             loadDefs(el);
          else if (name=="g")
          {
             g.children.push( DisplayGroup(loadGroup(new Group(),el,matrix, styles)) );
          }
          else if (name=="path")
          {
             g.children.push( DisplayPath( loadPath(el,matrix, styles, PATH) ) );
          }
          else if (name=="rect")
          {
             g.children.push( DisplayPath( loadPath(el,matrix, styles, RECT) ) );
          }
          else if (name=="polygon")
          {
             g.children.push( DisplayPath( loadPath(el,matrix, styles, PATH) ) );
          }
          else if (name=="polyline")
          {
             g.children.push( DisplayPath( loadPath(el,matrix, styles, OPEN_PATH) ) );
          }
          else if (name=="line")
          {
             g.children.push( DisplayPath( loadPath(el,matrix, styles, LINE) ) );
          }
          else if (name=="ellipse" || name=="circle")
          {
             g.children.push( DisplayPath( loadPath(el,matrix, styles, CIRCLE) ) );
          }
          else if (name=="text")
          {
             g.children.push( DisplayText( loadText(el,matrix, styles) ) );
          }
          else
          {
              throw("Unknown child : " + el.nodeName );
          }
       }
       return g;
    }
}
