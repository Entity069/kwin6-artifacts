import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_barStyle: barStyleCombo.currentIndex
    property alias cfg_colorMode: colorModeCombo.currentIndex
    property alias cfg_barColor: colorField.text
    property alias cfg_gradientColors: gradientField.text
    property alias cfg_barOpacity: opacitySlider.value

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Style")
    }

    QQC2.ComboBox {
        id: barStyleCombo
        Kirigami.FormData.label: i18n("Bar style:")
        model: ["Center mirrored", "Single side up", "Single side down"]
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Colors")
    }

    QQC2.ComboBox {
        id: colorModeCombo
        Kirigami.FormData.label: i18n("Color mode:")
        model: ["Solid", "Gradient"]
    }

    Item {
        Kirigami.FormData.label: i18n("Bar color:")
        implicitWidth: colorRow.implicitWidth
        implicitHeight: colorRow.implicitHeight
        visible: colorModeCombo.currentIndex === 0

        Row {
            id: colorRow
            spacing: Kirigami.Units.smallSpacing

            QQC2.Button {
                width: 32
                height: 32
                padding: 2
                onClicked: colorDialog.open()
                background: Rectangle {
                    radius: 4
                    color: colorField.text
                    border.width: 1
                    border.color: Qt.darker(colorField.text, 1.4)
                }
            }

            QQC2.TextField {
                id: colorField
                width: 120
                maximumLength: 9
            }
        }
    }

    ColorDialog {
        id: colorDialog
        selectedColor: colorField.text
        onAccepted: colorField.text = selectedColor
    }

    Item {
        Kirigami.FormData.label: i18n("Gradient colors:")
        implicitWidth: gradCol.implicitWidth
        implicitHeight: gradCol.implicitHeight
        visible: colorModeCombo.currentIndex === 1

        Column {
            id: gradCol
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                text: i18n("Comma-separated hex colors")
                font: Kirigami.Theme.smallFont
                opacity: 0.7
            }

            QQC2.TextField {
                id: gradientField
                width: 220
                placeholderText: "#3daee9,#ff6600,#00ff00"
            }

            Item {
                width: 220
                height: 20

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 4
                    border.width: 1
                    border.color: Kirigami.ColorUtils.linearInterpolation(
                        Kirigami.Theme.backgroundColor,
                        Kirigami.Theme.textColor, 0.15)
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: {
                                var c = gradientField.text.split(",");
                                return c[0] && c[0].trim().length > 0 ? c[0].trim() : "transparent"
                            }
                        }
                        GradientStop {
                            position: 0.5
                            color: {
                                var c = gradientField.text.split(",");
                                if (c.length > 1 && c[1].trim().length > 0) return c[1].trim();
                                return c[0] && c[0].trim().length > 0 ? c[0].trim() : "transparent"
                            }
                        }
                        GradientStop {
                            position: 1.0
                            color: {
                                var c = gradientField.text.split(",");
                                if (c.length > 2 && c[2].trim().length > 0) return c[2].trim();
                                if (c.length > 1 && c[1].trim().length > 0) return c[1].trim();
                                return c[0] && c[0].trim().length > 0 ? c[0].trim() : "transparent"
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Appearance")
    }

    Item {
        Kirigami.FormData.label: i18n("Opacity:")
        implicitWidth: opacityRow.implicitWidth
        implicitHeight: opacityRow.implicitHeight

        Row {
            id: opacityRow
            spacing: Kirigami.Units.smallSpacing
            QQC2.Slider {
                id: opacitySlider
                from: 0
                to: 100
                stepSize: 5
                width: 180
            }
            QQC2.Label {
                text: opacitySlider.value + "%"
                anchors.verticalCenter: opacitySlider.verticalCenter
            }
        }
    }
}
