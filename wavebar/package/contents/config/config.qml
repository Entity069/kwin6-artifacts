import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure-symbolic"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Styling")
        icon: "preferences-desktop-color"
        source: "configStyling.qml"
    }
}
