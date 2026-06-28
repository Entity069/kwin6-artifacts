import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_waves: wavesSpin.value
    property alias cfg_sensitivity: sensSpin.value
    property alias cfg_width: widthSpin.value
    property alias cfg_height: heightSpin.value
    property alias cfg_barWidth: barWidthSpin.value
    property alias cfg_barSpacing: barSpacingSpin.value
    property alias cfg_cornerRadius: radiusSpin.value
    property alias cfg_framerate: framerateSlider.value
    property alias cfg_riseSpeed: riseSlider.value
    property alias cfg_releaseSpeed: releaseSlider.value
    property alias cfg_noiseReduction: noiseSlider.value

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("General")
    }

    QQC2.SpinBox {
        id: wavesSpin
        Kirigami.FormData.label: i18n("Number of bars:")
        from: 1
        to: 128
        value: 16
    }

    QQC2.SpinBox {
        id: sensSpin
        Kirigami.FormData.label: i18n("Sensitivity (%):")
        from: 1
        to: 1000
        value: 100
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Size")
    }

    QQC2.SpinBox {
        id: widthSpin
        Kirigami.FormData.label: i18n("Width (px):")
        from: 32
        to: 4096
        value: 300
    }

    QQC2.SpinBox {
        id: heightSpin
        Kirigami.FormData.label: i18n("Height (px):")
        from: 16
        to: 2048
        value: 80
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Bar shape")
    }

    QQC2.SpinBox {
        id: barWidthSpin
        Kirigami.FormData.label: i18n("Bar width (px):")
        from: 1
        to: 64
        value: 8
    }

    QQC2.SpinBox {
        id: barSpacingSpin
        Kirigami.FormData.label: i18n("Bar spacing (px):")
        from: 0
        to: 64
        value: 3
    }

    QQC2.SpinBox {
        id: radiusSpin
        Kirigami.FormData.label: i18n("Corner radius (px):")
        from: 0
        to: 32
        value: 3
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("CAVA engine")
    }

    Row {
        spacing: Kirigami.Units.smallSpacing
        Kirigami.FormData.label: i18n("Framerate:")

        QQC2.Slider {
            id: framerateSlider
            from: 15
            to: 144
            stepSize: 1
            width: 180
        }
        QQC2.Label {
            text: framerateSlider.value + " fps"
            anchors.verticalCenter: framerateSlider.verticalCenter
        }
    }

    Row {
        spacing: Kirigami.Units.smallSpacing
        Kirigami.FormData.label: i18n("rise speed:")

        QQC2.Slider {
            id: riseSlider
            from: 1
            to: 100
            stepSize: 1
            width: 180
        }
        QQC2.Label {
            text: riseSlider.value + "%"
            anchors.verticalCenter: riseSlider.verticalCenter
        }
    }

    Row {
        spacing: Kirigami.Units.smallSpacing
        Kirigami.FormData.label: i18n("Release speed:")

        QQC2.Slider {
            id: releaseSlider
            from: 1
            to: 100
            stepSize: 1
            width: 180
        }
        QQC2.Label {
            text: releaseSlider.value + "%"
            anchors.verticalCenter: releaseSlider.verticalCenter
        }
    }

    Row {
        spacing: Kirigami.Units.smallSpacing
        Kirigami.FormData.label: i18n("Noise reduction:")

        QQC2.Slider {
            id: noiseSlider
            from: 0
            to: 100
            stepSize: 1
            width: 180
        }
        QQC2.Label {
            text: noiseSlider.value + "%"
            anchors.verticalCenter: noiseSlider.verticalCenter
        }
    }
}
