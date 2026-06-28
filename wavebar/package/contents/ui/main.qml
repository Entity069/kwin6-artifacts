import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import entity069.wavebar.cava 1.0

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    readonly property int waveCount: Plasmoid.configuration.waves
    readonly property real sensitivity: Plasmoid.configuration.sensitivity / 100.0
    readonly property int barStyle: Plasmoid.configuration.barStyle
    readonly property int colorMode: Plasmoid.configuration.colorMode
    readonly property color barColor: Plasmoid.configuration.barColor
    readonly property string gradientColors: Plasmoid.configuration.gradientColors
    readonly property int barWidth: Plasmoid.configuration.barWidth
    readonly property int barSpacing: Plasmoid.configuration.barSpacing
    readonly property int cornerRadius: Plasmoid.configuration.cornerRadius
    readonly property real barOpacity: Plasmoid.configuration.barOpacity / 100.0
    readonly property int framerate: Plasmoid.configuration.framerate
    readonly property int riseSpeed: Plasmoid.configuration.riseSpeed
    readonly property int releaseSpeed: Plasmoid.configuration.releaseSpeed
    readonly property real noiseReduction: Plasmoid.configuration.noiseReduction / 100.0

    Layout.preferredWidth: Plasmoid.configuration.width
    Layout.preferredHeight: Plasmoid.configuration.height

    function parseHexColor(hex) {
        hex = hex.replace(/^#/, "");
        if (hex.length === 3) {
            hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
        }
        var r = parseInt(hex.substring(0,2), 16) / 255;
        var g = parseInt(hex.substring(2,4), 16) / 255;
        var b = parseInt(hex.substring(4,6), 16) / 255;
        return {r:r, g:g, b:b};
    }

    function lerpColor(a, b, t) {
        return Qt.rgba(
            a.r + (b.r - a.r) * t,
            a.g + (b.g - a.g) * t,
            a.b + (b.b - a.b) * t,
            1);
    }

    function barColorForIndex(index) {
        if (root.colorMode === 0)
            return root.barColor;
        var parts = root.gradientColors.split(",");
        var stops = [];
        for (var i = 0; i < parts.length; i++) {
            var s = parts[i].trim();
            if (s.length > 0) stops.push(s);
        }
        if (stops.length === 0) return "#ffffff";
        if (stops.length === 1 || root.waveCount <= 1) return stops[0];
        var t = index / (root.waveCount - 1);
        var seg = t * (stops.length - 1);
        var i = Math.min(Math.floor(seg), stops.length - 2);
        var lt = seg - i;
        var c1 = parseHexColor(stops[i]);
        var c2 = parseHexColor(stops[i + 1]);
        return lerpColor(c1, c2, lt);
    }

    CavaModel {
        id: cavaModel
        bars: root.waveCount
        sensitivity: root.sensitivity
        framerate: root.framerate
        riseSpeed: root.riseSpeed
        releaseSpeed: root.releaseSpeed
        noiseReduction: root.noiseReduction
        lowCutoff: 50
        highCutoff: 10000
        running: true
    }

    Row {
        anchors.centerIn: parent
        spacing: root.barSpacing

        Repeater {
            model: root.waveCount

            delegate: Item {
                width: root.barWidth
                height: root.height
                readonly property real level: index < cavaModel.levels.length ? cavaModel.levels[index] : 0
                readonly property color thisColor: root.barColorForIndex(index)
                readonly property real barH: level * root.height / 2

                Rectangle {
                    width: root.barWidth
                    height: parent.barH
                    visible: root.barStyle !== 2
                    color: parent.thisColor
                    radius: root.cornerRadius
                    opacity: root.barOpacity
                    antialiasing: true
                    anchors.bottom: parent.verticalCenter
                }

                Rectangle {
                    width: root.barWidth
                    height: parent.barH
                    visible: root.barStyle !== 1
                    color: parent.thisColor
                    radius: root.cornerRadius
                    opacity: root.barOpacity
                    antialiasing: true
                    anchors.top: parent.verticalCenter
                }
            }
        }
    }
}
