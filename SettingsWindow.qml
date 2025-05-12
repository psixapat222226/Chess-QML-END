import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: settingsWindow
    width: 600
    height: 500
    visible: false
    title: "Настройки"

    // Фоновое изображение
    Image {
        anchors.fill: parent
        source: "qrc:/resources/images/fon.png"
        fillMode: Image.PreserveAspectCrop
    }

    // Центральный блок настроек
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        width: parent.width - 40

        // Заголовок
        Text {
            text: "Настройки"
            font.pixelSize: 32
            font.bold: true
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        // Выбор сложности игры против ИИ
        Text {
            text: "Выберите сложность:"
            font.pixelSize: 18
            color: "#CCCCCC"
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "🙂 Легкий"
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                background: Rectangle {
                    color: chessEngine.difficulty === 1 ? "#DFF0D8" : "#444444"
                    radius: 10
                }
                onClicked: chessEngine.difficulty = 1
            }

            Button {
                text: "😐 Средний"
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                background: Rectangle {
                    color: chessEngine.difficulty === 2 ? "#CCE5FF" : "#444444"
                    radius: 10
                }
                onClicked: chessEngine.difficulty = 2
            }

            Button {
                text: "😈 Сложный"
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                background: Rectangle {
                    color: chessEngine.difficulty === 3 ? "#F8D7DA" : "#444444"
                    radius: 10
                }
                onClicked: chessEngine.difficulty = 3
            }
        }

        // Кнопки сохранения и загрузки игр
        Button {
            text: "Сохранить игру"
            Layout.preferredHeight: 50
            Layout.fillWidth: true
            background: Rectangle {
                color: "#666666"
                radius: 10
            }
            onClicked: {
                saveGameDialog.open()
            }
        }

        Button {
            text: "Загрузить игру"
            Layout.preferredHeight: 50
            Layout.fillWidth: true
            background: Rectangle {
                color: "#666666"
                radius: 10
            }
            onClicked: {
                loadGameDialog.open()
            }
        }

        // Кнопка возврата в главное меню
        Button {
            text: "Back to Main Menu"
            Layout.preferredHeight: 50
            Layout.fillWidth: true
            background: Rectangle {
                color: "#666666"
                radius: 10
            }
            onClicked: {
                settingsWindow.visible = false
            }
        }
    }
}
