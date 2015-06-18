package gm2d.skin;

class ShadowFlags
{
    public static inline var All  = 0x0000;

    public static inline var None  = 0x00ff;

    public static inline var TopSolid  = 0x0001;
    public static inline var TopLine   = 0x0002;
    public static inline var Top       = 0x0003;
    public static inline var LeftSolid = 0x0004;
    public static inline var LeftLine  = 0x0008;
    public static inline var Left      = 0x000c;
    public static inline var RightSolid = 0x0010;
    public static inline var RightLine  = 0x0020;
    public static inline var Right      = 0x0030;
    public static inline var BottomSolid = 0x0040;
    public static inline var BottomLine  = 0x0080;
    public static inline var Bottom      = 0x00c0;


    public static inline var TopOnly    = 0x0054;
    public static inline var LeftOnly   = 0x0051;
    public static inline var RightOnly  = 0x0045;
    public static inline var BottomOnly = 0x0015;

    public static inline var TopLineOnly    = 0x0056;
    public static inline var LeftLineOnly   = 0x0059;
    public static inline var RighLinetOnly  = 0x0065;
    public static inline var BottomLineOnly = 0x0095;
}


