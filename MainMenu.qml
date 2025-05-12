import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: mainMenu
    width: 800
    height: 650
    visible: true
    title: "Шахматы"

    // Фоновое изображение
    Image {
        anchors.fill: parent
        source: "qrc:/resources/images/fon.png"
        fillMode: Image.PreserveAspectCrop
    }

    // Центральный блок меню
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        // Заголовок
        Text {
            text: "CHESS"
            font.pixelSize: 50
            font.bold: true
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Checkmate!"
            font.pixelSize: 20
            color: "yellow"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        // Кнопка одиночной игры
        Button {
            text: "Singleplayer"
            Layout.preferredWidth: 300
            Layout.preferredHeight: 50
            font.pixelSize: 18
            background: Rectangle {
                color: "#666666"
                radius: 5
            }
            onClicked: {
                chessEngine.setGameMode("singlePlayer")
                chessEngine.startNewGame()
            }
        }

        // Кнопка мультиплеера
        Button {
            text: "Multiplayer"
            Layout.preferredWidth: 300
            Layout.preferredHeight: 50
            font.pixelSize: 18
            background: Rectangle {
                color: "#666666"
                radius: 5
            }
            onClicked: {
                chessEngine.setGameMode("multiplayer")
                chessEngine.startNewGame()
            }
        }

        // Кнопка для открытия окна настроек
        Button {
            text: "Options..."
            Layout.preferredWidth: 300
            Layout.preferredHeight: 50
            font.pixelSize: 18
            background: Rectangle {
                color: "#666666"
                radius: 5
            }
            onClicked: {
                settingsWindow.visible = true
            }
        }

        // Кнопка выхода
        Button {
            text: "Quit Game"
            Layout.preferredWidth: 300
            Layout.preferredHeight: 50
            font.pixelSize: 18
            background: Rectangle {
                color: "#666666"
                radius: 5
            }
            onClicked: {
                Qt.quit()
            }
        }
    }
}
