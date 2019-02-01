all: create-file build-file

ifndef FIND_EXE
FIND_EXE := find
endif

create-file:
	echo "" > All.hx
	cd ../.. && $(FIND_EXE) gm2d -name "*.hx" | awk -F '.hx$$' '{  x=$$1; gsub("\/",".",x);  print "import " x ";" }' >> samples/00-ImportAll/All.hx
	echo "class All { public static function main(){} }" >> All.hx


build-file:
	haxe -cp ../.. -lib nme -main All -dce no -cpp cpp
	haxe -cp ../.. -lib nme -main All -dce no -neko t.n

#	haxe -cp ../.. -lib nme -main All -dce no -swf t.swf

