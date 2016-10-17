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
import gm2d.svg.DisplayElement;






class Svg extends Group
{
    public var width(default,null):Float;
    public var height(default,null):Float;

    var mConvertCubics:Bool;
    var mGrads : GradHash;
    var mPathParser: PathParser;
    var mLinks:Map<String, DisplayElement>;

    static var SIN45:Float = 0.70710678118654752440084436210485;
    static var TAN22:Float = 0.4142135623730950488016887242097;

    static var mStyleSplit = ~/;/g;
    static var mStyleValue = ~/\s*(.*)\s*:\s*(.*)\s*/;
    static var mTranslate1Match = ~/translate\((.+)[\s]*\)/;
    static var mTranslateMatch = ~/translate\((.+)[,\s]+(.+)\)/;
    static var mRotateMatch = ~/rotate\((.+)[,\s]+(.+)[,\s]+(.+)\)/;
    static var mRotate1Match = ~/rotate\((.+)\)/;
    static var mScaleMatch = ~/scale\((.*)\)/;
    static var mMatrixMatch = ~/matrix\((.+)[,\s]+(.+)[,\s]+(.+)[,\s]+(.+)[,\s]+(.+)[,\s]+(.+)\)/;


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

       mLinks = new Map<String, DisplayElement>();

       width = loadFloatStyle("width",null,0.0, svg);
       height = loadFloatStyle("height",null,0.0, svg);
       if (width==0 && height==0)
          width = height = 400;
       else if (width==0)
          width = height;
       else if (height==0)
          height = width;

       loadGroup(this,svg);

       //trace("SVG:");
       //for(g in roots)
          //dumpGroup(g,"");
    }


    function dumpGroup(g:Group,indent:String)
    {
       trace(indent + "Group:" + g.name);
       indent += "  ";
       for(e in g.children)
          if (e.asGroup()!=null)
             dumpGroup(e.asGroup(),indent+"   ");
          else
             trace(indent + e);
    }

    function getFloat(inXML:Xml,inName:String,inDef:Float=0.0) : Float
    {
       if (inXML.exists(inName))
          return Std.parseFloat(inXML.get(inName));
       return inDef;
    }

    function loadMarker(inMarker:Xml)
    {
       var marker = new Marker();
       loadGroup(marker, inMarker);
       marker.refX = getFloat(inMarker, "refX", 0.0);
       marker.refY = getFloat(inMarker, "refY", 0.0);
       return marker;
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
          grad.gradMatrix = createTransform(inGrad.get("gradientTransform"));


       // todo - grad.spread = base.spread;

       for(stop in inGrad.elements())
       {
          var style = loadStyle(stop);

          grad.colors.push( loadColourStyle("stop-color",style,0x000000) );
          grad.alphas.push( loadFloatStyle("stop-opacity",style,1.0) );
          grad.ratios.push(
             Std.int( Std.parseFloat(stop.get("offset") ) * 255.0) );
       }


       mGrads.set(name,grad);
    }

    public function getGrad(inName:String) return mGrads.get(inName);

    public function getGradients() return mGrads;


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
             else if (name=="marker" && pass==0)
                loadMarker(def);
             else if (pass==0)
             {
                var el = loadNode(def);
                if (el!=null)
                   mLinks.set(el.id, el);
             }
          }
    }

    function parseTransform(inTrans:String) : Matrix
    {
       var scale = 1.0;
       var result:Matrix = null;

       if (mTranslateMatch.match(inTrans))
       {
          // TODO: Pre-translate
          (result = new Matrix()).translate(
                  Std.parseFloat( mTranslateMatch.matched(1) ),
                  Std.parseFloat( mTranslateMatch.matched(2) ));
       }
       else if (mTranslate1Match.match(inTrans))
       {
          // TODO: Pre-translate
          (result = new Matrix()).translate(
                  Std.parseFloat( mTranslate1Match.matched(1) ), 0 );
       }
       else if (mScaleMatch.match(inTrans))
       {
          // TODO: Pre-scale
          var s = Std.parseFloat( mScaleMatch.matched(1) );
          (result = new Matrix()).scale(s,s);
       }
       else if (mRotateMatch.match(inTrans))
       {
          // TODO: Pre-scale
          var angle = Std.parseFloat( mRotateMatch.matched(1) );
          var x = Std.parseFloat( mRotateMatch.matched(2) );
          var y = Std.parseFloat( mRotateMatch.matched(3) );
          result = new Matrix();
          result.tx -= x;
          result.ty -= y;
          result.rotate( angle*Math.PI/180.0 );
          result.tx += x;
          result.ty += y;
       }
       else if (mRotate1Match.match(inTrans))
       {
          // TODO: Pre-scale
          var angle = Std.parseFloat( mRotate1Match.matched(1) );
          result = new Matrix();
          result.rotate( angle*Math.PI/180.0 );
       }
       else if (mMatrixMatch.match(inTrans))
       {
          result = new Matrix(
                  Std.parseFloat( mMatrixMatch.matched(1) ),
                  Std.parseFloat( mMatrixMatch.matched(2) ),
                  Std.parseFloat( mMatrixMatch.matched(3) ),
                  Std.parseFloat( mMatrixMatch.matched(4) ),
                  Std.parseFloat( mMatrixMatch.matched(5) ),
                  Std.parseFloat( mMatrixMatch.matched(6) ) );
          //scale = Math.sqrt( ioMatrix.a*ioMatrix.a + ioMatrix.c*ioMatrix.c );
       }
       else 
          trace("Warning, unknown transform:" + inTrans);

       return result;
    }

    function createTransform(inTrans:String) : Matrix
    {
       var result:Matrix = null;

       for(part in inTrans.split(")"))
       {
          if (part.indexOf("(")>0)
          {
             var mat = parseTransform(part+")");
             if (mat!=null)
             {
                if (result==null)
                   result = mat;
                else
                {
                   mat.concat(result);
                   result = mat;
                }
             }
          }
       }
       return result;
    }



   static var attribStyles = [
"alignment-baseline", "baseline-shift", "clip", "clip-path", "clip-rule", "color", "color-interpolation", "color-interpolation-filters", "color-profile", "color-rendering", "cursor", "direction", "display", "dominant-baseline", "enable-background", "fill", "fill-opacity", "fill-rule", "filter", "flood-color", "flood-opacity", "font-family", "font-size", "font-size-adjust", "font-stretch", "font-style", "font-variant", "font-weight", "glyph-orientation-horizontal", "glyph-orientation-vertical", "image-rendering", "kerning", "letter-spacing", "lighting-color", "marker-end", "marker-mid", "marker-start", "mask", "opacity", "overflow", "pointer-events", "shape-rendering", "stop-color", "stop-opacity", "stroke", "stroke-dasharray", "stroke-dashoffset", "stroke-linecap", "stroke-linejoin", "stroke-miterlimit", "stroke-opacity", "stroke-width", "text-anchor", "text-decoration", "text-rendering", "unicode-bidi", "visibility", "word-spacing", "writing-mode" ];

   function loadStyle(inNode:Xml) : Style
   {
      var style:Style = null;

      if (inNode.exists("style"))
      {
         var strings = mStyleSplit.split( inNode.get("style"));
         for(s in strings)
         {
            if (mStyleValue.match(s))
            {
               if (style==null)
                   style = new Style();
               style.set(mStyleValue.matched(1),mStyleValue.matched(2));
            }
         }
      }

      for(a in attribStyles)
         if (inNode.exists(a))
         {
            if (style==null)
               style = new Style();
            style.set(a, inNode.get(a));
         }

      return style;
   }


   function loadFloatStyle(inKey:String, inStyle:Style, inDefault:Float, ?inXml:Xml)
   {
      var s = inStyle!=null && inStyle.exists(inKey) ? inStyle.get(inKey) : "";

      if (inXml!=null && inXml.exists(inKey))
         s = inXml.get(inKey);

      if (s=="")
         return inDefault;
      return Std.parseFloat(s);
   }

   function loadColourStyle(inKey:String,inStyle:Style, inDefault:Int)
   {
      var s = inStyle!=null && inStyle.exists(inKey) ? inStyle.get(inKey) : "";
      
      if (s=="")
         return inDefault;
      if (s.charAt(0)=='#')
         return Std.parseInt( "0x" + s.substr(1) );
      return Std.parseInt(s);
   }

    public function loadLink(inElem:Xml) : Link
    {
       var link = new Link();
       loadElement(link, inElem);

       if (inElem.exists("xlink:href"))
          link.link = inElem.get("xlink:href");

       return link;
    }

    public function loadPath(inPath:Xml, inMode:Int) : Path
    {
       var path = new Path();
       loadElement(path,inPath);

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

    public function loadText(inText:Xml) : Text
    {
       var text = new Text();
       loadElement(text, inText);

       /*
       */

       var string= "";
       for(el in inText.elements())
          if (el.nodeName=="tspan")
             text.addTSpan(el);
          else
            string += el.nodeValue;
       //trace(string);
       text.text= string;
       
       return text;
    }

    public function getLinks() return mLinks;

    public function findLink(inId:String):DisplayElement
    {
       if (inId.substr(0,1)=="#")
          return mLinks.get(inId.substr(1));
       return mLinks.get(inId);
    }

    public function loadElement(e:DisplayElement, xml:Xml )
    {
       if (xml.exists("transform"))
          e.matrix = createTransform(xml.get("transform"));

       if (xml.exists("id"))
       {
          e.id = xml.get("id");
          mLinks.set(e.id, e);
          e.name = e.id;
       }

       if (xml.exists("inkscape:label"))
          e.name = xml.get("inkscape:label");

       e.style = loadStyle(xml);
   }


    public function loadGroup(g:Group, inG:Xml) : Group
    {
       loadElement(g, inG);

       for(el in inG.elements())
       {
          var child = loadNode(el);
          if (child!=null)
             g.children.push(child);
       }

       return g;
    }

    public function loadNode(el:Xml) : DisplayElement
    {
       var name = el.nodeName;
       if (name.substr(0,4)=="svg:")
          name = name.substr(4);

       if (name=="defs")
          loadDefs(el);
       else if (name=="g" || name=="a")
       {
          return loadGroup(new Group(),el);
       }
       else if (name=="path")
       {
          return loadPath(el,PATH);
       }
       else if (name=="rect")
       {
          return loadPath(el,RECT);
       }
       else if (name=="polygon")
       {
          return loadPath(el,PATH);
       }
       else if (name=="polyline")
       {
          return loadPath(el,OPEN_PATH);
       }
       else if (name=="line")
       {
          return loadPath(el,LINE);
       }
       else if (name=="ellipse" || name=="circle")
       {
          return loadPath(el,CIRCLE);
       }
       else if (name=="text")
       {
          return loadText(el);
       }
       else if (name=="use")
       {
          return loadLink(el);
       }
       else
       {
           //throw("Unknown child : " + el.nodeName );
       }

       return null;
    }
}
