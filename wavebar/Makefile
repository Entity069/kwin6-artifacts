.PHONY: all build install uninstall clean

QML_DIR ?= /usr/lib/qt6/qml/entity069/wavebar/cava

all: build

build:
	cmake -S plugin -B plugin/build
	cmake --build plugin/build

install: build
	sudo install -d $(QML_DIR)

	sudo install -m755 plugin/build/entity069/wavebar/cava/libwavebar_cava.so $(QML_DIR)/
	sudo install -m644 plugin/build/entity069/wavebar/cava/qmldir $(QML_DIR)/

	@kpackagetool6 --type Plasma/Applet --upgrade package >/dev/null 2>&1 || kpackagetool6 --type Plasma/Applet --install package
	
	systemctl --user restart plasma-plasmashell.service

uninstall:
	sudo rm -rf /usr/lib/qt6/qml/entity069/wavebar

	-kpackagetool6 --type Plasma/Applet --remove entity069.wavebar
	
	systemctl --user restart plasma-plasmashell.service

clean:
	rm -rf plugin/build
