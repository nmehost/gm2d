package gm2d.utils;

#if flash
typedef Uncompress = {};
#elseif neko
typedef Uncompress = neko.zip.Uncompress;
#else
typedef Uncompress = cpp.zip.Uncompress;
#end
