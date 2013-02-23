all: create-file build-file


create-file:
	echo "" > All.hx
	cd ../.. && find gm2d -name "*.hx" | awk -F '.hx$$' '{  x=$$1; gsub("\/",".",x);  print "import " x ";" }' >> samples/0-ImportAll/All.hx
	echo "class All { public static function main(){} }" >> All.hx


build-file:
	haxe -cp ../.. -lib nme -main All -swf t.swf
	haxe -cp ../.. -lib nme -main All -cpp cpp
	haxe -cp ../.. -lib nme -main All -neko t.n

