package gm2d.swf;





class Tags
{
   public static inline var End : Int = 0;
   public static inline var ShowFrame : Int = 1;
   public static inline var DefineShape : Int = 2;
   public static inline var FreeCharacter : Int = 3;
   public static inline var PlaceObject : Int = 4;
   public static inline var RemoveObject : Int = 5;
   public static inline var DefineBits : Int = 6;
   public static inline var DefineButton : Int = 7;
   public static inline var JPEGTables : Int = 8;
   public static inline var SetBackgroundColor : Int = 9;

   public static inline var DefineFont : Int = 10;
   public static inline var DefineText : Int = 11;
   public static inline var DoAction : Int = 12;
   public static inline var DefineFontInfo : Int = 13;

   public static inline var DefineSound : Int = 14;
   public static inline var StartSound : Int = 15;
   public static inline var StopSound : Int = 16;

   public static inline var DefineButtonSound : Int = 17;

   public static inline var SoundStreamHead : Int = 18;
   public static inline var SoundStreamBlock : Int = 19;

   public static inline var DefineBitsLossless : Int = 20;
   public static inline var DefineBitsJPEG2 : Int = 21;

   public static inline var DefineShape2 : Int = 22;
   public static inline var DefineButtonCxform : Int = 23;

   public static inline var Protect : Int = 24;

   public static inline var PathsArePostScript : Int = 25;

   public static inline var PlaceObject2 : Int = 26;
   public static inline var c27 : Int = 27;
   public static inline var RemoveObject2 : Int = 28;

   public static inline var SyncFrame : Int = 29;
   public static inline var c30 : Int = 30;
   public static inline var FreeAll : Int = 31;

   public static inline var DefineShape3 : Int = 32;
   public static inline var DefineText2 : Int = 33;
   public static inline var DefineButton2 : Int = 34;
   public static inline var DefineBitsJPEG3 : Int = 35;
   public static inline var DefineBitsLossless2 : Int = 36;
   public static inline var DefineEditText : Int = 37;

   public static inline var DefineVideo : Int = 38;

   public static inline var DefineSprite : Int = 39;
   public static inline var NameCharacter : Int = 40;
   public static inline var ProductInfo : Int = 41;
   public static inline var DefineTextFormat : Int = 42;
   public static inline var FrameLabel : Int = 43;
   public static inline var DefineBehavior : Int = 44;
   public static inline var SoundStreamHead2 : Int = 45;
   public static inline var DefineMorphShape : Int = 46;
   public static inline var FrameTag : Int = 47;
   public static inline var DefineFont2 : Int = 48;
   public static inline var GenCommand : Int = 49;
   public static inline var DefineCommandObj : Int = 50;
   public static inline var CharacterSet : Int = 51;
   public static inline var FontRef : Int = 52;

   public static inline var DefineFunction : Int = 53;
   public static inline var PlaceFunction : Int = 54;

   public static inline var GenTagObject : Int = 55;

   public static inline var ExportAssets : Int = 56;
   public static inline var ImportAssets : Int = 57;

   public static inline var EnableDebugger : Int = 58;

   public static inline var DoInitAction : Int = 59;
   public static inline var DefineVideoStream : Int = 60;
   public static inline var VideoFrame : Int = 61;

   public static inline var DefineFontInfo2 : Int = 62;
   public static inline var DebugID : Int = 63;
   public static inline var EnableDebugger2 : Int = 64;
   public static inline var ScriptLimits : Int = 65;

   public static inline var SetTabIndex : Int = 66;

   public static inline var DefineShape4_hmm : Int = 67;
   public static inline var c68 : Int = 68;

   public static inline var FileAttributes : Int = 69;

   public static inline var PlaceObject3 : Int = 70;
   public static inline var ImportAssets2 : Int = 71;

   public static inline var DoABC : Int = 72;
   public static inline var DefineFontAlignZones : Int = 73;
   public static inline var CSMTextSettings : Int = 74;
   public static inline var DefineFont3 : Int = 75;
   public static inline var SymbolClass : Int = 76;
   public static inline var MetaData : Int = 77;
   public static inline var DefineScalingGrid : Int = 78;
   public static inline var c79 : Int = 79;
   public static inline var c80 : Int = 80;
   public static inline var c81 : Int = 81;
   public static inline var DoABC2 : Int = 82;
   public static inline var DefineShape4 : Int = 83;
   public static inline var DefineMorphShape2 : Int = 84;
   public static inline var c85 : Int = 85;
   public static inline var DefineSceneAndFrameLabelData : Int = 86;
   public static inline var DefineBinaryData : Int = 87;
   public static inline var DefineFontName : Int = 88;
   public static inline var StartSound2 : Int = 89;


   public static inline var LAST : Int = 90;





   static var tags:Array<String> =
      [
      "End",               // 00
      "ShowFrame",         // 01
      "DefineShape",         // 02
      "FreeCharacter",      // 03
      "PlaceObject",         // 04
      "RemoveObject",         // 05
      "DefineBits",         // 06
      "DefineButton",         // 07
      "JPEGTables",         // 08
      "SetBackgroundColor",   // 09

      "DefineFont",         // 10
      "DefineText",         // 11
      "DoAction",            // 12
      "DefineFontInfo",      // 13

      "DefineSound",         // 14
      "StartSound",         // 15
      "StopSound",         // 16

      "DefineButtonSound",   // 17

      "SoundStreamHead",      // 18
      "SoundStreamBlock",      // 19

      "DefineBitsLossless",   // 20
      "DefineBitsJPEG2",      // 21

      "DefineShape2",         // 22
      "DefineButtonCxform",   // 23

      "Protect",            // 24

      "PathsArePostScript",   // 25

      "PlaceObject2",         // 26
      "27 (invalid)",         // 27
      "RemoveObject2",      // 28

      "SyncFrame",         // 29
      "30 (invalid)",         // 30
      "FreeAll",            // 31

      "DefineShape3",         // 32
      "DefineText2",         // 33
      "DefineButton2",      // 34
      "DefineBitsJPEG3",      // 35
      "DefineBitsLossless2",   // 36
      "DefineEditText",      // 37

      "DefineVideo",         // 38

      "DefineSprite",         // 39
      "NameCharacter",      // 40
      "ProductInfo",         // 41
      "DefineTextFormat",      // 42
      "FrameLabel",         // 43
      "DefineBehavior",      // 44
      "SoundStreamHead2",      // 45
      "DefineMorphShape",      // 46
      "FrameTag",            // 47
      "DefineFont2",         // 48
      "GenCommand",         // 49
      "DefineCommandObj",      // 50
      "CharacterSet",         // 51
      "FontRef",            // 52

      "DefineFunction",      // 53
      "PlaceFunction",      // 54

      "GenTagObject",         // 55

      "ExportAssets",         // 56
      "ImportAssets",         // 57

      "EnableDebugger",      // 58

      "DoInitAction",         // 59
      "DefineVideoStream",   // 60
      "VideoFrame",         // 61

      "DefineFontInfo2",      // 62
      "DebugID",             // 63
      "EnableDebugger2",       // 64
        "ScriptLimits",       // 65

        "SetTabIndex",          // 66

      "DefineShape4",       // 67
      "DefineMorphShape2",    // 68

      "FileAttributes",       // 69

      "PlaceObject3",       // 70
      "ImportAssets2",       // 71

      "DoABC",             // 72
      "DefineFontAlignZones",         // 73
      "CSMTextSettings",         // 74
      "DefineFont3",         // 75
      "SymbolClass",         // 76
        "Metadata",         // 77
        "DefineScalingGrid",         // 78
        "79 (invalid)",         // 79
        "80 (invalid)",         // 80
        "81 (invalid)",         // 81
        "DoABC2",               // 82
        "DefineShape4",         // 83
        "DefineMorphShape2",         // 84
        "c85", // 85
        "DefineSceneAndFrameLabelData", // 86
        "DefineBinaryData", //  87
        "DefineFontName", //  88
        "StartSound2", // 89
        "LAST", // 90
      ];

   static public function string(i:Int) { return tags[i]; }

}

