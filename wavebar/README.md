# Wavebar

![](media/preview.gif)

A KDE Plasma 6 desktop widget that visualizes system audio as a wavebar. It bridges the raw binary output of [`cava`](https://github.com/karlstav/cava) to a QML frontend through a Qt6 plugin.

## Install

First you need to install [`cava`](https://github.com/karlstav/cava).
Then build the widget from the source.

```bash
git clone https://github.com/Entity069/kwin6-artifacts.git
cd kwin6-artifacts/wavebar
make install
```

## Usage

Add **Wavebar** via *Add Widgets* and start playing audio.

## Uninstall

```bash
cd kwin6-artifacts/wavebar
make uninstall
```

## License

See [LICENSE](../LICENSE)