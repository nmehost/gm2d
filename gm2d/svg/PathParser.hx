// This code borrowed from "Xinf", http://xinf.org
// Copyright of original author.
//package xinf.ony;
//import xinf.ony.PathSegment;

package gm2d.svg;

import gm2d.svg.PathSegment;

enum PathParserState {
    Empty;
    ParseCommand( cmd:String, nargs:Int );
    ParseFloat( s:String, old:PathParserState );
}

class PathParser {
    static var commandReg = ~/[MmZzLlHhVvCcSsQqTtAa]/;

    var g:Array<PathSegment>;

    var input:String;
    var pin:Int;
	 var lastMoveX:Float;
	 var lastMoveY:Float;

    var state:PathParserState;
    var args:Array<Float>;
    

    static var MOVE  = "M".charCodeAt(0);
    static var MOVER = "m".charCodeAt(0);
    static var LINE  = "L".charCodeAt(0);
    static var LINER = "l".charCodeAt(0);
    static var HLINE = "H".charCodeAt(0);
    static var HLINER = "h".charCodeAt(0);
    static var VLINE = "V".charCodeAt(0);
    static var VLINER = "v".charCodeAt(0);
    static var CUBIC = "C".charCodeAt(0);
    static var CUBICR = "c".charCodeAt(0);
    static var SCUBIC = "S".charCodeAt(0);
    static var SCUBICR = "s".charCodeAt(0);
    static var QUAD = "Q".charCodeAt(0);
    static var QUADR = "q".charCodeAt(0);
    static var SQUAD = "T".charCodeAt(0);
    static var SQUADR = "t".charCodeAt(0);
    static var ARC = "A".charCodeAt(0);
    static var ARCR = "a".charCodeAt(0);
    static var CLOSE = "Z".charCodeAt(0);
    static var CLOSER = "z".charCodeAt(0);


    public function new() {
        state=Empty;
    }

    public function parse( pathToParse:String ) :Iterable<PathSegment> {
        lastMoveX = lastMoveY = 0;
        input=pathToParse;
        pin=0;
        args = new Array<Float>();
        g = new Array<PathSegment>();
        
        while( pin<input.length ) {
            var c = input.charAt(pin);
           // trace("CHAR '"+c+"', STATE "+state);
            if( StringTools.isSpace(c,0) || c=="," ) {  // whitespace
                endState();
			} else if( c=="-" ) {            // - (minus) // fixme should trigger new float, except when in exponent like "1.324e-12"
                switch( state ) {
                    case ParseFloat(f,old):
                        if( f.length==0 ) state=ParseFloat("-",old);
						else if( f.charAt(f.length-1)=="e" ) {
							state=ParseFloat(f+c,old);
							pin++;
                        } else {
                            endState();
                            state=ParseFloat("-",state);
                        }
                    default:
                        state=ParseFloat("-",state);
                        pin++;
                }
			} else if( commandReg.match(c) ) {
                endState();
                parseCommand(commandReg.matched(0));
            } else {
                switch( state ) {
                    case ParseFloat(f,old):
                        state = ParseFloat(f+c,old);
                        pin++;
                    default:
                        state = ParseFloat(c,state);
                        pin++;
                }
            }
        }
        endState();
        
        return g;
    }
    
    function parseCommand( cmd:String ) {
        var nargs = switch(cmd.toUpperCase()) {
            case "Z":
                0;
            case "H","V":
                1;
            case "M","L","T":
                2;
            case "S","Q":
                4;
            case "C":
                6;
            case "A":
                7;
        }    
        state = ParseCommand(cmd,nargs);
    }
    
    function fail() {
        throw("failed parsing path '"+input.substr(pin)+"'");
    }
    
    function endState() {
       //trace("END "+state );
        switch( state ) {
        
            case Empty:
                pin++;
                
            case ParseFloat(c,old):
                args.push( Std.parseFloat(c) );
                state = old;
                endState();
                
            case ParseCommand(cmd,nargs):
                if( args.length==nargs ) {
        //            trace("COMMAND "+cmd+", args: "+args );
                    command( cmd, args );
                    args = new Array<Float>();
                    if( nargs==0 ) state=Empty;
                    else if( cmd.toUpperCase()=="M" ) {
                        if( cmd=="M" ) cmd="L";
                        else cmd="l";
                        parseCommand(cmd);
                    }
                } 
                pin++;
                
        }
    }

    function prevX():Float { return (g.length>0) ? g[g.length-1].prevX() : 0; }
    function prevY():Float { return (g.length>0) ? g[g.length-1].prevY() : 0; }
    function prevCX():Float { return (g.length>0) ? g[g.length-1].prevCX() : 0; }
    function prevCY():Float { return (g.length>0) ? g[g.length-1].prevCY() : 0; }
    
    function command( cmd:String, a:Array<Float> ) {
        var code = cmd.charCodeAt(0);
        var op:PathSegment = 
            switch(code) {
                case MOVE:
		              lastMoveX = a[0];
		              lastMoveY = a[1];
					     cast(new MoveSegment( lastMoveX, lastMoveY),PathSegment);
                case MOVER:
		              lastMoveX = a[0]+prevX();
		              lastMoveY = a[1]+prevY();
					     new MoveSegment(lastMoveX, lastMoveY);
                case LINE:  new DrawSegment( a[0], a[1] );
                case LINER: new DrawSegment( a[0]+prevX(), a[1]+prevX() );
                case HLINE:  new DrawSegment( a[0], 0 );
                case HLINER: new DrawSegment( a[0]+prevX(), 0);
                case VLINE:  new DrawSegment( 0, a[0] );
                case VLINER: new DrawSegment( 0, a[0]+prevX());
                case CUBIC:
                    new CubicSegment( a[0], a[1], a[2], a[3], a[4], a[5] );
                case CUBICR:
                    var rx = prevX();
                    var ry = prevY();
                    new CubicSegment( a[0]+rx, a[1]+ry, a[2]+rx, a[3]+ry, a[4]+rx, a[5]+ry );
                case SCUBIC:
                    var rx = prevX();
                    var ry = prevY();
                    new CubicSegment( rx*2-prevCX(), ry*2-prevCY(),a[0], a[1], a[2], a[3] );
                case SCUBICR:
                    var rx = prevX();
                    var ry = prevY();
                    new CubicSegment( rx*2-prevCX(), ry*2-prevCY(),a[0]+rx, a[1]+ry, a[2]+rx, a[3]+ry );
                case QUAD: new QuadraticSegment( a[0], a[1], a[2], a[3] );
                case QUADR:
                    var rx = prevX();
                    var ry = prevY();
                    new QuadraticSegment( a[0], a[1], a[2], a[3] );
                case SQUAD:
                    var rx = prevX();
                    var ry = prevY();
                    new QuadraticSegment( rx*2-prevCX(), rx*2-prevCY(),a[2], a[3] );
                case SQUADR:
                    var rx = prevX();
                    var ry = prevY();
                    new QuadraticSegment( rx*2-prevCX(), ry*2-prevCY(),a[0]+rx, a[1]+ry );
                case ARC:
                    new ArcSegment(prevX(), prevY(), a[0], a[1], a[2], a[3]!=0., a[4]!=0., a[5], a[6] );
                case ARCR:
                    var rx = prevX();
                    var ry = prevY();
                    new ArcSegment( rx,ry, a[0], a[1], a[2], a[3]!=0., a[4]!=0., a[5]+rx, a[6]+ry );
                case CLOSE:
                    new DrawSegment(lastMoveX, lastMoveY);
                case CLOSER:
                    new DrawSegment(lastMoveX, lastMoveY);
                default:
                    throw("unimplemented shape command "+cmd);
            }
        
        g.push(op);
    }
}

