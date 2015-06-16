import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldAutoSize;
import nme.filters.GlowFilter;
import gm2d.ui.Layout;
import nme.Assets;


class Wwx2015 extends Talk
{
   public function new()
   {
      super();
      defaultTextColour = 0x000000;
      bulletBmp = Assets.getBitmapData("Bullet.png");
   }

   public function renderScreen0()
   {
      var sw = stage.stageWidth;
      var sh = stage.stageHeight;
      var gfx = graphics;
      gfx.beginFill(0x000000);
      gfx.drawRect(0,0,sw,sh);
      
      var col = 0xffff00;
      var size = 40;
      var hlayout = new HorizontalLayout();
      hlayout.add( createTextLayout("Hxcpp: State of the", size, col) );
      hlayout.add( createTextLayout("Union", size, col) );
      var union: TextField  = cast getChildAt( numChildren -1 );
      hlayout.add( createTextLayout("Enum", size, col) );
      var layout = createTitleLayout(hlayout);


      var bmp = Assets.getBitmapData("VmVmVm.jpg");
      var bitmap = new Bitmap(bmp);
      bitmap.scaleX = bitmap.scaleY = sh*0.8/bmp.height;
      addChild(bitmap);
      var bmpLayout = new DisplayLayout(bitmap);

      var wrap = new BorderLayout(bmpLayout,false);
      layout.add( wrap.stretch() );


      //bullet(layout,"Create extern definitions (meta-data)",2);

      var strike = new Sprite();
      addChild(strike);
      layout.onLayout = function(_,_,_,_) {
         var gfx = strike.graphics;
         gfx.clear();
         gfx.lineStyle(3,col);
         gfx.moveTo( union.x, union.y + union.height*0.5 );
         gfx.lineTo( union.x + union.width, union.y + union.height*0.5 );
      };

      setLayout(layout);
   }

   public function renderScreen10()
   {
      drawBg();
      var layout = createTitle('Outline',36);
      bullet(layout,"Highlights 2014/2015");
      bullet(layout,"Extended low-level native support",2);
      bullet(layout,"Improved CFFI Prime",2);
      bullet(layout,"Extended high-level scripting support",2);
      bullet(layout,"Review from last year");
      bullet(layout,"Where to from here");
      setLayout(layout);
   }


   public function renderScreen20()
   {
      var sw = stage.stageWidth;
      var sh = stage.stageHeight;
      var gfx = graphics;
      gfx.beginFill(0x000000);
      gfx.drawRect(0,0,sw,sh);
      
      var layout = createTitle("");
      layout.add( createTextLayout("\"You can use C as a high level language\"", 30, 0xffffff ) );
      layout.add( createTextLayout("       - <i>Hardware engineer</i>", 20, 0xe0e0e0 ).setAlignment(Layout.AlignLeft) );
      layout.add( createTextLayout("\"You can use C as a low level language\"", 30, 0xffffff ) );
      layout.add( createTextLayout("       - <i>Software engineer</i>", 20, 0xe0e0e0 ).setAlignment(Layout.AlignLeft) );
      setLayout(layout);
   }



   public function renderScreen30()
   {
      drawBg();
      var layout = createTitle("Native Support");


      bullet(layout,"Last year");
      bullet(layout,"Added cpp.Pointer",2);
      bullet(layout,"This year" );
      bullet(layout,"Added cpp.Struct",2);
      bullet(layout,"Added cpp.Reference",2);
      bullet(layout,"Makes use of @:native to avoid syntax issues",2);

      setLayout(layout);
   }


   public function renderScreen40()
   {
      drawBg();
      var layout = createTitle("Native Implementation - Step 1");

      bullet(layout,"Write your API using an extern class");
      bullet(layout,"Use \"include\" point to the real definition");

      addCode(layout,[
       '@:include("myinclude/Rectangle.h")',
       'extern class Rectangle',
       '{',
       '   public var x0:Float;',
       '   public var y0:Float;',
       '   public var x1:Float;',
       '   public var y1:Float;',
       '}'
       ] );

      setLayout(layout);
   }



   public function renderScreen50()
   {
      drawBg();
      var layout = createTitle("Native Implementation - Step 2");

      bullet(layout,"Extend the extern class and add @:native meta");

      var codeBox = createCodeBox( "<font size='20'>" + colour([
         '@:native("::cpp::Reference< Rectangle>")',
         'class RectangleRef extends Rectangle { }',
         '',
         '@:native("::cpp::Struct< Rectangle>")',
         'class RectangleStruct extends Rectangle { }',
         '',
         ' or',
         '',
         '@:native("::cpp::Struct< Rectangle>")',
         'class RectangleStruct extends RectangleRef { }',

       ].join("\n") )  + "</font>" );
       layout.add(codeBox.layout);

      setLayout(layout);
   }


   public function renderScreen60()
   {
      drawBg();
      var layout = createTitle("Step 3 - profit!");

      bullet(layout,"cpp.Struct has <em>copy</em> semantics");

      addCode( layout, [
         'var a:RectangleStruct = null;',
         'a.x = 1;',
         'trace(a.x);',
         '',
         'var b = a;',
         'b.x = 2;',
         'trace(a.x); // Still 1',

       ] );

      setLayout(layout);
   }


   public function renderScreen70()
   {
      drawBg();
      var layout = createTitle("Step 3 - more profit!");

      bullet(layout,"cpp.Refrence is a non-gc pointer to the data.");
      bullet(layout,"Watch out for null pointers.",2);

      bullet(layout,"Use 'cast' to move between storage types.");

      addCode(layout,[
         'var a:RectangleStruct = null;',
         'a.x = 1;',
         '',
         'var b:RectangleRef = a;',
         'b.x = 2;',
         'trace(a.x); // Now 2, since b points to a',
         '',
         'var c:RectangleStruct = cast b; // copy the data',
          ]);
      setLayout(layout);
   }


   public function renderScreen80()
   {
      drawBg();
      var layout = createTitle("Native Tips");

      bullet(layout,'Write a handler to help with "toString"');
      addCode(layout,['@:native("::cpp::Struct< Rectangle, MyRectangleHandler>")'],14);

      bullet(layout,'Use properties via "get_value" functions etc.');
      bullet(layout,'Use the @:native meta on static functions');
      addCode(layout,[
       '@:include("myincldue/Rectangle.h")',
       'extern class Rectangle',
       '{',
       '   @:native("new Rectangle")',
       '   public static function create():RectangleRef;',
       '',
       '   @:native("~Rectangle")',
       '   public function delete():Void;',
       '}',
      ],14);


      setLayout(layout);
   }

   public function renderScreen85()
   {
      drawBg();
      var layout = createTitle("More Tips");

      bullet(layout,'@:include("./") relative to .hx file');
      bullet(layout,'@:native static functions = global functions');
      bullet(layout,'cppInclude glue/api code from a local cpp file');

      addCode(layout,[
          '@:include("./../../include/MyApi.h")',
          '@:cppInclude("MyApiGlue.cpp")',
          'extern class SomeApi',
          '{',
          '   @:native("some_api_do_something")',
          '   public static function doSomething():Void;',
          '}',
          'SomeApi.doSomething();'
      ]);


      setLayout(layout);
   }



   public function renderScreen90()
   {
      drawBg();
      var layout = createTitle("Advantages");

      bullet(layout,'Struct creates values on the stack (no GC)');
      bullet(layout,'Works with reflection/Dynamic');
      bullet(layout,'Allows for natural syntax');
      bullet(layout,'A better way of writing (small) native extensions');
      bullet(layout,'No external libraries are required.',2);
      bullet(layout,'Can generate ".mm" code for iOS extensions\n-D file-extension=mm',2);
      setLayout(layout);
   }



   public function renderScreen100()
   {
      drawBg();
      var layout = createTitle("CFFI Prime");

      bullet(layout,'Interface with ndlls');
      bullet(layout,'Tradeoffs vs native includes',2);
      bullet(layout,'Like CFFI "prim" code, only better');
      bullet(layout,'Added type safety',2);
      bullet(layout,'No boxing',2);
      bullet(layout,'Works on neko and cpp');
      bullet(layout,'Easier to write cpp implementation code');
      setLayout(layout);
   }


   public function renderScreen120()
   {
      drawBg();
      var layout = createTitle("CFFI Prime Example");

      bullet(layout,'Java-style signature');
      bullet(layout,'Use implicit typing (different for neko/cpp)');
      bullet(layout,'CFFI "value" code for objects is unchanged');
      addCode(layout,[
         'static var add = Loader.load("addInts", "iii" );',
         '...',
         'var x = add.call(1,2.0); // Error',
         '',
         '// Cpp implementation',
         'int addInts(int a, int b) {',
         '   return a+b;',
         '}',
         'DEFINE_PRIME2(addInts);',
      ]);



      setLayout(layout);
   }



   public function renderScreen200()
   {
      cppiaBg();
      
      var layout = createTitle('Cppia ("sepia")');
      bullet(layout,'C Plus Plus Instruction Assembly');
      bullet(layout,'Tightly integrated scripting for cpp target');
      bullet(layout,"Everyone's favourite compiler");
      bullet(layout,"macros, type inference etc.",2);
      bullet(layout,'Sub-target of cpp, use "-D cppia"');
      setLayout(layout);
   }

   public function renderScreen210()
   {
      cppiaBg();
 
      var layout = createTitle('Cppia compiling');
      bullet(layout,"Output directory becomes output file");
      bullet(layout,'Both "cpp" and "cppia" defined');
      bullet(layout,"Can't use __cpp__ or native featutes");
      bullet(layout,"Generates a file looks like an AST dump");
      bullet(layout,"debug version is ascii",2);
      bullet(layout,"release version is binary",2);
      addCode(layout,["haxe -main Test -cpp test.cppia -D cppia"]);
      setLayout(layout);
   }


   public function renderScreen220()
   {
      cppiaBg();
 
      var layout = createTitle('Cppia host/client');
      bullet(layout,"Cppia program consists of 2 parts");
      bullet(layout,"Host - native hxcpp program",2);
      bullet(layout,"Client - script program",2);

      bullet(layout,"Compile host with '-D scriptable'");
      bullet(layout,"Generates layout info, and exe_classes.info",2);

      bullet(layout,"Compile client with '-D cppia'");
      bullet(layout,"Uses exe_classes.info to exclude classes",2);

      setLayout(layout);
   }


   public function renderScreen230()
   {
      cppiaBg();
 
      var layout = createTitle('Running CPPIA');
      bullet(layout,"Call cpp.cppia.Host.run(script) on host");
      bullet(layout,"A basic cppia host is provided by hxcpp:");
      addCode(layout,[ "haxe -main Test -cpp test.cppia -D cppia",
                       "haxelib run hxcpp test.cppia"] );
      bullet(layout,"You can make your own host with more in it");


      setLayout(layout);
   }

   public function renderScreen240()
   {
      cppiaBg();
 
      var layout = createTitle('Sexy screenshot');

      var sw = stage.stageWidth;
      var sh = stage.stageHeight;

      var bmp = Assets.getBitmapData("TestScreen.png");
      var bitmap = new Bitmap(bmp,PixelSnapping.AUTO,true);
      bitmap.scaleX = bitmap.scaleY = sw*0.8/bmp.width;
      addChild(bitmap);
      var bmpLayout = new DisplayLayout(bitmap);
      layout.add(bmpLayout);

      setLayout(layout);
   }


   public function renderScreen250()
   {
      cppiaBg();
 
      var layout = createTitle('Integration');
      bullet(layout,"Very tight, low friction integration");
      bullet(layout,"Uses same GC code");
      bullet(layout,"Phsically the same memory layout");
      bullet(layout,"Override host functions in client");
      bullet(layout,"Implement host interfaces in client");
      bullet(layout,"Pass closures back and forwards");
      bullet(layout,"etc etc");

      setLayout(layout);
   }


   public function renderScreen260()
   {
      cppiaBg();
 
      var layout = createTitle('Performace');
      bullet(layout,"No Jit, so 'interpreted' code");
      bullet(layout,"Uses strong memory binding, so fast-ish");
      bullet(layout,"About the same as Jit neko",2);
      bullet(layout,"Faster than non-Jit neko",2);
      bullet(layout,"Slower than JS",2);
      layout.add( createTextLayout("BUT") );
      bullet(layout,"You can easly move the host/client boundary");
      bullet(layout,"eg, build physics into host -> hxcpp speed",2);

      setLayout(layout);
   }


   public function renderScreen270()
   {
      cppiaBg();
 
      var layout = createTitle('Uses');
      bullet(layout,"Compiling without cpp compiler");
      bullet(layout,"Plugins - load multiple scripts");
      bullet(layout,"Rapid development - hotswap");
      bullet(layout,"Website  - script per page");

      setLayout(layout);
   }


   public function renderScreen275()
   {
      cppiaBg();
 
      var layout = createTitle('VM Inception');
      bullet(layout,"Running Hxcpp VM",2);
      bullet(layout,"Running Cppia Script",4);
      bullet(layout,"Running hscript",6);
      bullet(layout,"Time goes slower at each level");

      setLayout(layout);
   }



   public function renderScreen300()
   {
      drawBg();
      var layout = createTitle("Review");

      layout.add( createTextLayout("Miss").setAlignment(Layout.AlignLeft) );
      bullet(layout,"Numeric template specialization",2);
      bullet(layout,"Fake interfaces/Anon types (macros/cppia?)",2);

      layout.add( createTextLayout("Glancing blow").setAlignment(Layout.AlignLeft) );
      bullet(layout,"Strong function typing",2);

      layout.add( createTextLayout("Hit").setAlignment(Layout.AlignLeft) );
      bullet(layout,"Native Int64", 2);
      bullet(layout,"More native integration", 2);

      setLayout(layout);
   }



   public function renderScreen310()
   {
      drawBg();
      var layout = createTitle("Future");

      bullet(layout,"Investigate Gc alternatives");
      bullet(layout,"Continue to evolve");
      bullet(layout,"Remove Dynamic where possible");
      bullet(layout,"Cppia Jit (stretch goal)");
      setLayout(layout);
   }

   public function renderScreen400()
   {
      drawBg();
      var layout = createTitle("Demo");

      bullet(layout,'"Acadnme" is a Cppia host built from Nme.');
      bullet(layout,'Compile + Test with only haxelib/haxe compiler');
      bullet(layout,'Android (Google Play Download)',2);
      bullet(layout,'haxelib for Windows/Mac - Linux to come',2);
      bullet(layout,'not iOS - this program is too useful\n  but, can compile yourself',2);
      setLayout(layout);
   }




   public function addCode(layout, lines:Array<String>,size=20)
   {
      var box = createCodeBox( "<font size='" + size + "'>" + colour(lines.join("\n")) + "</font>" );
      layout.add(box.layout);
   }

 
   function cppiaBg()
   {
      var sw = stage.stageWidth;
      var sh = stage.stageHeight;
      var gfx = graphics;
      gfx.beginFill( 0x704214 );
      gfx.drawRect(0,0,sw,sh);

      gfx.beginFill(0xffffff);
      gfx.lineStyle(1,0x3030ff);
      gfx.drawRect(10.5,20.5,sw-21,sh-41);
   }

 
   function drawBg()
   {
      var sw = stage.stageWidth;
      var sh = stage.stageHeight;
      var gfx = graphics;
      gfx.beginFill(0xf0f0f0);
      gfx.drawRect(0,0,sw,sh);

      gfx.beginFill(0xffffff);
      gfx.lineStyle(1,0x3030ff);
      gfx.drawRect(10.5,20.5,sw-21,sh-41);
   }





}


