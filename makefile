# This file is required to create a copy of *.ini files into assets
app/assets/environment.ini: environment.ini
	cp -r $< $@
	cd ./app && dart run build_runner build