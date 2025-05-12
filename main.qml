import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: root
    width: 800
    height: 650
    visible: true
    title: "Шахматы"

    property int boardMargin: 20
    property int boardSize: Math.min(width, height - 50) - (2 * boardMargin)
    property int cellSize: boardSize / 8
    property var selectedPiece: null
    property bool inMenu: true
    property bool inSettings: false

    // Функция для преобразования логических координат в визуальные
    function logicalToVisualPos(x, y) {
        return {
            x: x * cellSize,
            y: (7 - y) * cellSize
        }
    }

    // Функция для преобразования визуальных координат в логические
    function visualToLogicalPos(x, y) {
        return {
            x: Math.floor(x / cellSize),
            y: 7 - Math.floor(y / cellSize)
        }
    }

    // Очистка всех индикаторов и выбранных фигур
    function clearAllSelections() {
        moveIndicators.visible = false
        if (selectedPiece !== null) {
            selectedPiece.highlighted = false
        }
        selectedPiece = null
    }

    // Функция для поиска всех кнопок загрузки
    function findAllLoadButtons() {
        var buttons = [];

        // Напрямую добавляем ссылку на кнопку загрузки, если она доступна
        if (typeof loadButtonInSettings !== "undefined") {
            buttons.push(loadButtonInSettings);
        }

        return buttons;
    }

    component StyledButton: Item {
        id: buttonContainer
        width: 300
        height: 50

        property string buttonText: "Button"
        property bool isSmall: false
        property int fontSize: isSmall ? 14 : 16
        property bool enabled: true
        property color shadowColor: "#333333"
        property int shadowSize: 4
        property string objectName: ""

        signal clicked()

        // Тень (нижняя полоса)
        Rectangle {
            id: shadow
            width: parent.width
            height: shadowSize
            color: shadowColor
            opacity: 0.5
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }

        // Основная кнопка
        Rectangle {
            id: styleButton
            width: parent.width
            height: parent.height - shadowSize
            color: "#828282"
            border.color: "#5A5A5A"
            border.width: 2
            anchors.top: parent.top

            Rectangle {
                width: parent.width - 4
                height: parent.height - 4
                x: 2
                y: 2
                color: mouseArea.pressed && buttonContainer.enabled ? "#5A5A5A" : "#6D6D6D"
                opacity: buttonContainer.enabled ? 1.0 : 0.5

                Text {
                    anchors.centerIn: parent
                    text: buttonContainer.buttonText
                    color: "white"
                    font.pixelSize: buttonContainer.fontSize
                    font.family: "Courier"
                    font.bold: true
                }
            }
        }

        // Эффект при нажатии - кнопка опускается к тени
        states: State {
            name: "pressed"
            when: mouseArea.pressed && buttonContainer.enabled
            PropertyChanges {
                target: styleButton
                y: shadowSize / 2
            }
            PropertyChanges {
                target: shadow
                height: shadowSize / 2
            }
        }

        // Плавная анимация перехода
        transitions: Transition {
            PropertyAnimation {
                properties: "y, height"
                duration: 50
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                if (buttonContainer.enabled) {
                    buttonContainer.clicked()
                }
            }
        }
    }

    // Начальный экран с выбором режима игры
    Rectangle {
        id: menuScreen
        anchors.fill: parent
        visible: inMenu && !inSettings

        // Фон
        Image {
            anchors.fill: parent
            source: "qrc:/resources/images/fon.png"
            fillMode: Image.PreserveAspectCrop
        }

        // Позиционируем кнопки в нижней части экрана, чтобы не перекрывать надпись
        ColumnLayout {
            anchors {
                bottom: parent.bottom
                bottomMargin: 100
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 20
            width: 300

            // Кнопки меню
            StyledButton {
                Layout.fillWidth: true
                buttonText: "Одиночная игра"
                onClicked: {
                    chessEngine.setGameMode("vsComputer")
                    chessEngine.startNewGame()
                    inMenu = false
                }
            }

            StyledButton {
                Layout.fillWidth: true
                buttonText: "Многопользовательский режим"
                onClicked: {
                    chessEngine.setGameMode("twoPlayers")
                    chessEngine.startNewGame()
                    inMenu = false
                }
            }

            StyledButton {
                Layout.fillWidth: true
                buttonText: "Настройки"
                onClicked: {
                    // Обновляем список сохраненных игр перед открытием настроек
                    inSettings = true
                }
            }

            // Нижняя кнопка
            StyledButton {
                buttonText: "Выход из игры"
                Layout.fillWidth: true
                Layout.topMargin: 20
                onClicked: {
                    Qt.quit()
                }
            }
        }

        // Кнопка информации с исправленным hover-эффектом
        Rectangle {
            id: infoButton
            width: 40
            height: 40
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 20
            radius: 20
            color: infoMouseArea.containsMouse ? "#775544" : "#664433"
            border.color: "#886644"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "i"
                color: "white"
                font.pixelSize: 24
                font.family: "Courier"
                font.bold: true
            }

            MouseArea {
                id: infoMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    infoDialog.open()
                }
            }
        }
    }

    // Экран настроек
    Rectangle {
        id: settingsScreen
        anchors.fill: parent
        visible: inSettings

        // Свойство для отслеживания выбранного сохранения (объявлено на уровне экрана настроек)
        property int selectedSaveIndex: -1
        onSelectedSaveIndexChanged: {
            console.log("Выбран индекс сохранения: " + selectedSaveIndex);

            // Обновляем состояние кнопок при изменении выбранного сохранения
            if (typeof loadButtonInSettings !== "undefined") {
                loadButtonInSettings.enabled = chessEngine.getSavedGames().length > 0 && selectedSaveIndex >= 0;
            }

            if (typeof deleteButtonInSettings !== "undefined") {
                deleteButtonInSettings.enabled = chessEngine.getSavedGames().length > 0 && selectedSaveIndex >= 0;
            }
        }
        // Исправленный обработчик onVisibleChanged для экрана настроек
        onVisibleChanged: {
            if (visible) {
                console.log("Экран настроек открыт, принудительно обновляем список сохранений");
                // Получаем актуальный список сохранений напрямую
                var currentSaves = chessEngine.getSavedGames();
                console.log("Количество сохранений: " + currentSaves.length);

                // Полностью пересоздаем модель для settingsSavedGamesList
                if (typeof settingsSavedGamesList !== "undefined") {
                    settingsSavedGamesList.model = null;
                    settingsSavedGamesList.model = currentSaves;
                }

                // Сбрасываем выбранный индекс сохранения
                settingsScreen.selectedSaveIndex = -1;

                // ВАЖНО: обновляем состояние кнопок при каждом входе в настройки
                // Обновляем состояние кнопки "Загрузить"
                if (typeof loadButtonInSettings !== "undefined") {
                    loadButtonInSettings.enabled = currentSaves.length > 0 && settingsScreen.selectedSaveIndex >= 0;
                }

                // Обновляем состояние кнопки "Удалить"
                if (typeof deleteButtonInSettings !== "undefined") {
                    deleteButtonInSettings.enabled = currentSaves.length > 0 && settingsScreen.selectedSaveIndex >= 0;
                }

                // Обновляем кнопку "Удалить все сохранения"
                if (typeof deleteAllButtonInSettings !== "undefined") {
                    deleteAllButtonInSettings.enabled = currentSaves.length > 0;
                }
            }
        }



        // Фон
        Image {
            anchors.fill: parent
            source: "qrc:/resources/images/fon2.png"
            fillMode: Image.PreserveAspectCrop
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            width: 500

            Text {
                text: "НАСТРОЙКИ"
                font.pixelSize: 32
                font.family: "Courier"
                font.bold: true
                color: "white"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 60

            }

            // Улучшенная настройка сложности
            Rectangle {
                Layout.fillWidth: true
                height: 200
                // Градиентный фон вместо простого цвета
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#35281E" }
                    GradientStop { position: 1.0; color: "#241812" }
                }
                radius: 10 // Более закругленные углы
                border.width: 2
                border.color: "#886644" // Золотисто-коричневый цвет для границы

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text {
                        text: "Сложность"
                        font.pixelSize: 22
                        font.family: "Courier"
                        font.bold: true
                        color: "#E0C9A6" // Золотистый цвет для заголовка
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15 // Увеличиваем расстояние между кнопками

                        // Легкий уровень
                        Rectangle {
                            id: easyButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 85
                            radius: 8
                            // Градиентный фон для кнопки
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: chessEngine.difficulty === 1 ? "#7DE07D" : "#9A9A9A" }
                                GradientStop { position: 1.0; color: chessEngine.difficulty === 1 ? "#4DB74D" : "#6D6D6D" }
                            }
                            border.color: chessEngine.difficulty === 1 ? "#50FF50" : "#777777"
                            border.width: chessEngine.difficulty === 1 ? 3 : 2

                            // Контейнер для содержимого кнопки
                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                // Иконка для легкого уровня (шахматная пешка)
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "♙"
                                    font.pixelSize: 26
                                    font.family: "Arial"
                                    color: "white"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Легкий"
                                    font.pixelSize: 16
                                    font.family: "Courier"
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            // Эффект при наведении
                            MouseArea {
                                id: easyMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: chessEngine.difficulty = 1

                                onEntered: {
                                    if (chessEngine.difficulty !== 1) {
                                        parent.scale = 1.05;
                                    }
                                }
                                onExited: {
                                    if (chessEngine.difficulty !== 1) {
                                        parent.scale = 1.0;
                                    }
                                }
                                onPressed: {
                                    parent.scale = 0.95;
                                }
                                onReleased: {
                                    parent.scale = containsMouse ? 1.05 : 1.0;  // Используем containsMouse вместо hovered
                                }
                            }

                            // Плавная анимация изменения размера
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        // Средний уровень
                        Rectangle {
                            id: mediumButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 85
                            radius: 8
                            // Градиентный фон для кнопки
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: chessEngine.difficulty === 2 ? "#7D9BE0" : "#9A9A9A" }
                                GradientStop { position: 1.0; color: chessEngine.difficulty === 2 ? "#4D77B7" : "#6D6D6D" }
                            }
                            border.color: chessEngine.difficulty === 2 ? "#5080FF" : "#777777"
                            border.width: chessEngine.difficulty === 2 ? 3 : 2

                            // Контейнер для содержимого кнопки
                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                // Иконка для среднего уровня (шахматный конь)
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "♘"
                                    font.pixelSize: 26
                                    font.family: "Arial"
                                    color: "white"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Средний"
                                    font.pixelSize: 16
                                    font.family: "Courier"
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            // Эффект при наведении
                            MouseArea {
                                id: mediumMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: chessEngine.difficulty = 2

                                onEntered: {
                                    if (chessEngine.difficulty !== 2) {
                                        parent.scale = 1.05;
                                    }
                                }
                                onExited: {
                                    if (chessEngine.difficulty !== 2) {
                                        parent.scale = 1.0;
                                    }
                                }
                                onPressed: {
                                    parent.scale = 0.95;
                                }
                                onReleased: {
                                    parent.scale = containsMouse ? 1.05 : 1.0;  // Используем containsMouse вместо hovered
                                }
                            }

                            // Плавная анимация изменения размера
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        // Сложный уровень
                        Rectangle {
                            id: hardButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 85
                            radius: 8
                            // Градиентный фон для кнопки
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: chessEngine.difficulty === 3 ? "#E07D7D" : "#9A9A9A" }
                                GradientStop { position: 1.0; color: chessEngine.difficulty === 3 ? "#B74D4D" : "#6D6D6D" }
                            }
                            border.color: chessEngine.difficulty === 3 ? "#FF5050" : "#777777"
                            border.width: chessEngine.difficulty === 3 ? 3 : 2

                            // Контейнер для содержимого кнопки
                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                // Иконка для сложного уровня (шахматная королева)
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "♕"
                                    font.pixelSize: 26
                                    font.family: "Arial"
                                    color: "white"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Сложный"
                                    font.pixelSize: 16
                                    font.family: "Courier"
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            // Эффект при наведении
                            MouseArea {
                                id: hardMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: chessEngine.difficulty = 3

                                onEntered: {
                                    if (chessEngine.difficulty !== 3) {
                                        parent.scale = 1.05;
                                    }
                                }
                                onExited: {
                                    if (chessEngine.difficulty !== 3) {
                                        parent.scale = 1.0;
                                    }
                                }
                                onPressed: {
                                    parent.scale = 0.95;
                                }
                                onReleased: {
                                    parent.scale = containsMouse ? 1.05 : 1.0;  // Используем containsMouse вместо hovered
                                }
                            }

                            // Плавная анимация изменения размера
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }
            }

            // Управление сохраненными партиями (улучшенный раздел)
            Rectangle {
                id: savesSection
                Layout.fillWidth: true
                height: 300 // Увеличенная высота для списка
                // Градиентный фон вместо простого цвета
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#35281E" }
                    GradientStop { position: 1.0; color: "#241812" }
                }
                radius: 10 // Закругленные углы как у раздела сложности
                border.color: "#886644" // Коричневый цвет границы как у раздела сложности
                border.width: 2

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text {
                        text: "Сохранения"
                        font.pixelSize: 22
                        font.family: "Courier"
                        font.bold: true
                        color: "#E0C9A6" // Золотистый цвет для заголовка
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Добавляем список сохранений
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#262626"
                        radius: 5

                        ListView {
                            id: settingsSavedGamesList
                            anchors.fill: parent
                            anchors.margins: 5
                            model: chessEngine.getSavedGames()
                            clip: true

                            onModelChanged: {
                                // При изменении модели проверяем, если список пуст - сбрасываем выбор
                                if (count === 0) {
                                    settingsScreen.selectedSaveIndex = -1;

                                    // Принудительно обновляем состояние кнопок
                                    if (typeof loadButtonInSettings !== "undefined") {
                                        loadButtonInSettings.enabled = false;
                                    }
                                    if (typeof deleteButtonInSettings !== "undefined") {
                                        deleteButtonInSettings.enabled = false;
                                    }
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                active: true
                                policy: ScrollBar.AsNeeded
                            }

                            delegate: Rectangle {
                                width: settingsSavedGamesList.width
                                height: 60
                                // Используем свойство экрана настроек для выделения
                                color: settingsScreen.selectedSaveIndex === index ? "#555555" : "#3D3D3D"
                                radius: 4
                                border.color: settingsScreen.selectedSaveIndex === index ? "#886644" : "#555555"
                                border.width: settingsScreen.selectedSaveIndex === index ? 2 : 1

                                // Сохраняем ссылку на объект модели
                                property var gameData: modelData

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        // Используем свойство экрана настроек
                                        settingsScreen.selectedSaveIndex = index
                                        console.log("Выбрано сохранение: " + index)
                                    }
                                }

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 2

                                    Text {
                                        text: parent.parent.gameData && parent.parent.gameData.name ?
                                              parent.parent.gameData.name : "Без названия"
                                        font.pixelSize: 14
                                        font.family: "Courier"
                                        font.bold: true
                                        color: "white"
                                    }

                                    Text {
                                        text: {
                                            var gameData = parent.parent.gameData;
                                            if (!gameData) return "Режим: Неизвестно";

                                            var modeText = gameData.gameMode === "vsComputer" ?
                                                          "Против ИИ" : "Два игрока";

                                            if (gameData.gameMode === "vsComputer") {
                                                var diffText = "";
                                                if (gameData.difficulty === 1) diffText = "Легкий";
                                                else if (gameData.difficulty === 2) diffText = "Средний";
                                                else if (gameData.difficulty === 3) diffText = "Сложный";
                                                else diffText = gameData.difficulty;

                                                modeText += " | " + diffText;
                                            }

                                            return modeText;
                                        }
                                        font.pixelSize: 12
                                        font.family: "Courier"
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        text: "Дата: " + (parent.parent.gameData && parent.parent.gameData.date ?
                                                        parent.parent.gameData.date : "Неизвестно")
                                        font.pixelSize: 12
                                        font.family: "Courier"
                                        color: "#DDDDDD"
                                    }
                                }
                            }

                            // Если список пуст
                            Text {
                                anchors.centerIn: parent
                                visible: settingsSavedGamesList.count === 0
                                text: "Нет сохранённых игр"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                font.family: "Courier"
                            }
                        }
                    }

                    // Заменяем одну кнопку на три и добавляем кнопку удаления всех сохранений
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Кнопка "Загрузить"
                        Rectangle {
                            id: loadButtonInSettings
                            objectName: "loadButtonInSettings"
                            Layout.fillWidth: true
                            height: 40
                            // Используем свойство экрана настроек
                            enabled: chessEngine.getSavedGames().length > 0 && settingsScreen.selectedSaveIndex >= 0
                            color: enabled ? (loadSettingsMouseArea.containsMouse ?
                                    (loadSettingsMouseArea.pressed ? "#4D8F4D" : "#6DAF6D") : "#5D9F5D") : "#444444"
                            radius: 5
                            border.color: enabled ? "#8AFF8A" : "#555555"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "Загрузить"
                                color: "white"
                                font.pixelSize: 14
                                font.family: "Courier"
                                font.bold: true
                            }

                            MouseArea {
                                id: loadSettingsMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (parent.enabled) {
                                        // Используем свойство экрана настроек
                                        var index = settingsScreen.selectedSaveIndex;
                                        if (index >= 0 && chessEngine.loadGame(index)) {
                                            inSettings = false;
                                            inMenu = false;
                                        }
                                    }
                                }
                            }
                        }

                        // Кнопка "Удалить"
                        Rectangle {
                            id: deleteButtonInSettings
                            Layout.fillWidth: true
                            height: 40
                            // Используем свойство экрана настроек
                            enabled: chessEngine.getSavedGames().length > 0 && settingsScreen.selectedSaveIndex >= 0
                            color: enabled ? (deleteSettingsMouseArea.containsMouse ?
                                    (deleteSettingsMouseArea.pressed ? "#8F4D4D" : "#AF6D6D") : "#9F5D5D") : "#444444"
                            radius: 5
                            border.color: enabled ? "#FF8A8A" : "#555555"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "Удалить"
                                color: "white"
                                font.pixelSize: 14
                                font.family: "Courier"
                                font.bold: true
                            }

                            MouseArea {
                                id: deleteSettingsMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (parent.enabled) {
                                        // Используем свойство экрана настроек
                                        var index = settingsScreen.selectedSaveIndex;
                                        if (index >= 0 && chessEngine.deleteGame(index)) {
                                            // Сбрасываем выбранный индекс
                                            settingsScreen.selectedSaveIndex = -1;
                                            // Обновляем список сохранений
                                            settingsSavedGamesList.model = null;
                                            settingsSavedGamesList.model = chessEngine.getSavedGames();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Добавляем кнопку для удаления всех сохранений
                    Rectangle {
                        id: deleteAllButtonInSettings
                        objectName: "deleteAllSavesButton"
                        Layout.fillWidth: true
                        height: 40
                        enabled: chessEngine.getSavedGames().length > 0
                        color: enabled ? (deleteAllMouseArea.containsMouse ?
                                (deleteAllMouseArea.pressed ? "#8F4D4D" : "#D74D4D") : "#C74D4D") : "#444444"
                        radius: 5
                        border.color: enabled ? "#FF8A8A" : "#555555"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: "Удалить все сохранения"
                            color: "white"
                            font.pixelSize: 14
                            font.family: "Courier"
                            font.bold: true
                        }

                        MouseArea {
                            id: deleteAllMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (parent.enabled) {
                                    // Создаем диалог подтверждения для удаления всех сохранений
                                    confirmDeleteAllDialog.open();
                                }
                            }
                        }
                    }
                }
            }

            // Кнопки в нижней части
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Layout.bottomMargin: 60

                StyledButton {
                    buttonText: "Готово"
                    Layout.fillWidth: true
                    onClicked: {
                        inSettings = false
                    }
                }
            }
        }
    }

    // Игровой экран
    Item {
        anchors.fill: parent
        visible: !inMenu && !inSettings

        Image {
            anchors.fill: parent
            source: "qrc:/resources/images/fon2.png"
            fillMode: Image.PreserveAspectCrop
        }

        // Статус игры (перемещен в верхнюю часть)
        Text {
            id: statusText
            text: chessEngine.status
            font.pixelSize: 20
            font.family: "Courier"
            font.bold: true
            color: "white"
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
        }

        // Компонент шахматной фигуры
        component ChessPiece: Image {
            id: piece

            property int pieceX: 0  // Логическая X координата (0-7)
            property int pieceY: 0  // Логическая Y координата (0-7)
            property bool highlighted: false

            // Небольшой эффект подсветки для выбранной фигуры
            Rectangle {
                anchors.fill: parent
                color: "yellow"
                opacity: piece.highlighted ? 0.3 : 0
                z: -1
            }

            // Начальное позиционирование
            Component.onCompleted: {
                let pos = logicalToVisualPos(pieceX, pieceY)
                x = pos.x
                y = pos.y
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Уже выбрана эта фигура - отменяем выбор
                    if (selectedPiece === piece) {
                        clearAllSelections()
                        return
                    }

                    // Сбрасываем предыдущие выборы
                    clearAllSelections()

                    // Проверяем, может ли эта фигура ходить
                    let legalMoves = chessEngine.getLegalMovesForPiece(pieceX, pieceY)

                    if (legalMoves.length > 0) {
                        // Показываем возможные ходы
                        moveIndicators.fromX = pieceX
                        moveIndicators.fromY = pieceY
                        moveIndicators.legalMoves = legalMoves
                        moveIndicators.visible = true

                        // Выделяем выбранную фигуру
                        piece.highlighted = true
                        selectedPiece = piece
                    }
                }
            }
        }

        // Шахматная доска (центр)
        Rectangle {
            id: board
            width: boardSize
            height: boardSize
            color: "#FFFFFF"
            anchors {
                centerIn: parent
                verticalCenterOffset: -10 // Немного выше центра для пространства кнопкам
            }

            // MouseArea для фона доски чтобы снимать выделения по клику на пустую область
            MouseArea {
                anchors.fill: parent
                z: -1  // Под всеми фигурами
                onClicked: {
                    clearAllSelections()
                }
            }

            // Рисуем шахматную доску
            Grid {
                anchors.fill: parent
                rows: 8
                columns: 8

                Repeater {
                    model: 64

                    Rectangle {
                        width: cellSize
                        height: cellSize
                        color: {
                            let row = Math.floor(index / 8)
                            let col = index % 8
                            return (row + col) % 2 === 0 ? "#F1D9B5" : "#B98863"
                        }
                    }
                }
            }

            // Компонент для выделения последнего хода
            Item {
                id: lastMoveHighlight
                anchors.fill: parent
                visible: chessEngine.hasLastMove()
                z: 1  // Над доской

                Rectangle {
                    width: cellSize
                    height: cellSize
                    x: chessEngine.hasLastMove() ? chessEngine.getLastMoveFrom().x * cellSize : 0
                    y: chessEngine.hasLastMove() ? (7 - chessEngine.getLastMoveFrom().y) * cellSize : 0
                    color: "#FFFF0055" // Полупрозрачный желтый
                    visible: chessEngine.hasLastMove()
                }

                Rectangle {
                    width: cellSize
                    height: cellSize
                    x: chessEngine.hasLastMove() ? chessEngine.getLastMoveTo().x * cellSize : 0
                    y: chessEngine.hasLastMove() ? (7 - chessEngine.getLastMoveTo().y) * cellSize : 0
                    color: "#FFFF0055" // Полупрозрачный желтый
                    visible: chessEngine.hasLastMove()
                }
            }

            // Шахматные фигуры
            Repeater {
                id: piecesRepeater
                model: chessEngine.getPieces()

                ChessPiece {
                    width: cellSize
                    height: cellSize
                    source: resourceManager.getTexturePath(modelData.type)
                    pieceX: modelData.x
                    pieceY: modelData.y
                }
            }

            // Индикаторы возможных ходов
            Item {
                id: moveIndicators
                anchors.fill: parent
                visible: false

                property var legalMoves: []
                property int fromX: -1
                property int fromY: -1

                Repeater {
                    id: movesRepeater
                    model: moveIndicators.legalMoves

                    Rectangle {
                        property var visualPos: logicalToVisualPos(modelData.x, modelData.y)

                        x: visualPos.x
                        y: visualPos.y
                        width: cellSize
                        height: cellSize
                        color: "transparent"
                        border.width: 3
                        border.color: "#32CD32"
                        radius: cellSize / 2
                        opacity: 0.7

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (chessEngine.processMove(
                                    moveIndicators.fromX, moveIndicators.fromY,
                                    modelData.x, modelData.y)) {
                                    clearAllSelections()
                                }
                            }
                        }
                    }
                }
            }
        }

        // Кнопки в нижней части
        Row {
            spacing: 30
            anchors {
                bottom: parent.bottom
                bottomMargin: 4
                horizontalCenter: parent.horizontalCenter
            }

            StyledButton {
                id: saveButton2
                width: 150
                height: 45
                buttonText: "Сохранить"
                isSmall: true
                enabled: chessEngine.getSavedGames().length < 10
                shadowColor: "#224422"
                onClicked: {
                    gameNameInput.text = ""
                    saveGameDialog.open()
                }
            }

            StyledButton {
                id: newGameButton
                width: 150
                height: 45
                buttonText: "Новая игра"
                isSmall: true
                onClicked: {
                    chessEngine.startNewGame()
                    clearAllSelections()
                }
            }

            StyledButton {
                id: undoButton
                width: 150
                height: 45
                buttonText: "Отменить ход"
                isSmall: true
                enabled: chessEngine.canUndo
                onClicked: {
                    chessEngine.undoLastMove()
                    if (chessEngine.vsComputer) {
                        chessEngine.undoLastMove()
                    }
                }
            }
            StyledButton {
                buttonText: "Меню"
                isSmall: true
                width: 150
                height: 45
                onClicked: {
                    inMenu = true
                }
            }
        }
    }

    // Глобальное соединение для обновления всех списков при изменении сохранений
    Connections {
        target: chessEngine

        function onSavedGamesChanged() {
            console.log("СИГНАЛ: Изменение списка сохранений!");

            // Получаем обновленный список сохранений
            var updatedSaves = chessEngine.getSavedGames();
            console.log("Количество сохранений: " + updatedSaves.length);

            // Обновляем кнопку сохранения в игре
            if (typeof saveButton2 !== "undefined") {
                saveButton2.enabled = updatedSaves.length < 10;
            }

            // Очень важно! Принудительное обновление списка в настройках
            if (inSettings && typeof settingsSavedGamesList !== "undefined") {
                console.log("Принудительное обновление списка в настройках");
                // ПОЛНОЕ пересоздание модели
                settingsSavedGamesList.model = null;
                Qt.callLater(function() {
                    settingsSavedGamesList.model = updatedSaves;
                });
            }

            // Обновляем диалог загрузки, если он открыт
            if (typeof loadGameDialog !== "undefined" && loadGameDialog.visible) {
                console.log("Принудительное обновление диалога загрузки");
                savedGamesList.model = null;
                Qt.callLater(function() {
                    savedGamesList.model = updatedSaves;
                });
            }

            // Обновляем кнопки в настройках
            if (inSettings) {
                // Кнопка "Загрузить"
                if (typeof loadButtonInSettings !== "undefined") {
                    loadButtonInSettings.enabled = updatedSaves.length > 0 && settingsScreen.selectedSaveIndex >= 0;
                }

                // Кнопка "Удалить"
                if (typeof deleteButtonInSettings !== "undefined") {
                    deleteButtonInSettings.enabled = updatedSaves.length > 0 && settingsScreen.selectedSaveIndex >= 0;
                }

                // Кнопка "Удалить все сохранения"
                if (typeof deleteAllButtonInSettings !== "undefined") {
                    deleteAllButtonInSettings.enabled = updatedSaves.length > 0;
                }
            }
        }

        function onGameEnded(result) {
            resultDialog.text = result
            resultDialog.open()
        }

        function onPiecesChanged() {
            // Сбрасываем все выбранные фигуры и индикаторы при обновлении доски
            clearAllSelections()
            piecesRepeater.model = chessEngine.getPieces()
        }

        function onStatusChanged() {
            // Дополнительно убеждаемся, что индикаторы очищаются при смене хода
            clearAllSelections()
        }

        function onPawnPromotion(fromX, fromY, toX, toY) {
            promotionDialog.fromX = fromX
            promotionDialog.fromY = fromY
            promotionDialog.toX = toX
            promotionDialog.toY = toY
            promotionDialog.open()
        }

        function onLastMoveChanged() {
            lastMoveHighlight.visible = chessEngine.hasLastMove()
        }

        function onDifficultyChanged() {
            // Этот метод будет вызываться при изменении сложности
        }
    }

    // Диалоги

    // Диалог подтверждения удаления всех сохранений - исправление перекрытия текста
    Dialog {
        id: confirmDeleteAllDialog
        title: "Удаление всех сохранений"
        modal: true
        width: 350  // Увеличиваем ширину
        height: 170 // Увеличиваем высоту для большего пространства

        background: Rectangle {
            color: "#3D3D3D"
            border.color: "#5A5A5A"
            border.width: 2
            radius: 6
        }

        header: Rectangle {
            color: "#553322"
            height: 45
            radius: 4

            Text {
                anchors.centerIn: parent
                text: confirmDeleteAllDialog.title
                font.pixelSize: 18
                font.family: "Courier"
                font.bold: true
                color: "white"
            }
        }

        anchors.centerIn: Overlay.overlay

        // Явно задаем макет содержимого с отступами
        contentItem: Item {
            anchors.fill: parent

            Text {
                id: warningText
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: buttonsRow.top // Привязываем нижнюю границу к верхней части ряда кнопок
                    bottomMargin: 20 // Увеличиваем отступ между текстом и кнопками
                    topMargin: 50
                }
                text: "Вы уверены, что хотите удалить\nВСЕ сохранения?\nЭто действие нельзя отменить."
                font.pixelSize: 16
                font.family: "Courier"
                font.bold: true
                color: "#FF6666"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            // Выделяем строку с кнопками в отдельный элемент
            RowLayout {
                id: buttonsRow
                width: parent.width
                spacing: 20
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }

                Item { Layout.fillWidth: true }

                // Кнопка "Да"
                Rectangle {
                    width: 80
                    height: 40
                    color: confirmYesMouseArea.containsMouse ?
                           (confirmYesMouseArea.pressed ? "#8F4D4D" : "#AF6D6D") : "#9F5D5D"
                    radius: 6
                    border.color: "#FF8A8A"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Да"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: confirmYesMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            // Удаляем все сохранения
                            var count = chessEngine.getSavedGames().length;
                            for (var i = 0; i < count; i++) {
                                chessEngine.deleteGame(0); // Всегда удаляем первое сохранение
                            }

                            // Обновляем список сохранений
                            settingsSavedGamesList.model = null;
                            settingsSavedGamesList.model = chessEngine.getSavedGames();

                            // ВАЖНО: Явно сбрасываем индекс выбранного сохранения
                            settingsScreen.selectedSaveIndex = -1;

                            // Принудительно обновляем состояние кнопок
                            if (typeof loadButtonInSettings !== "undefined") {
                                loadButtonInSettings.enabled = false;
                            }
                            if (typeof deleteButtonInSettings !== "undefined") {
                                deleteButtonInSettings.enabled = false;
                            }

                            // ВАЖНО: Обновляем состояние кнопки "Удалить все сохранения"
                            if (typeof deleteAllButtonInSettings !== "undefined") {
                                deleteAllButtonInSettings.enabled = false;
                            }

                            confirmDeleteAllDialog.close();
                        }
                    }
                }

                // Кнопка "Нет"
                Rectangle {
                    width: 80
                    height: 40
                    color: confirmNoMouseArea.containsMouse ?
                           (confirmNoMouseArea.pressed ? "#4D4D6F" : "#5D5D7D") : "#6D6D8D"
                    radius: 6
                    border.color: "#8A8AFF"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Нет"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: confirmNoMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            confirmDeleteAllDialog.close();
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    Dialog {
        id: infoDialog
        title: "Инструкция"
        modal: true
        width: Math.min(parent.width * 0.8, 600)
        height: Math.min(parent.height * 0.8, 700)
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: "#664433"
            border.color: "#886644"
            border.width: 2
        }

        header: Rectangle {
            color: "#775544"
            height: 50

            Text {
                text: "ИНСТРУКЦИЯ"
                font.pixelSize: 24
                font.family: "Courier"
                font.bold: true
                color: "#FFFFFF"
                anchors.centerIn: parent
            }
        }

        contentItem: ScrollView {
            clip: true

            // Блок для ScrollView в infoDialog
            Column {
                width: infoDialog.width - 40
                spacing: 20
                padding: 20

                Text {
                    width: parent.width
                    text: "Шахматы - Руководство по игре"
                    font.pixelSize: 20
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "1. Главное меню"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• 'Одиночная игра' - игра против компьютера с выбранным уровнем сложности\n• 'Многопользовательский режим' - игра на одном устройстве, где 2 игрока ходят по очереди\n• 'Настройки' - изменение уровня сложности игры против компьютера и управление сохранениями\n• 'Выход из игры' - завершение работы приложения\n• Кнопка 'i' в правом верхнем углу - вызов данной инструкции"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "2. Игровой процесс"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• Щелкните по своей фигуре, чтобы выбрать её\n• Зеленые индикаторы покажут возможные ходы для выбранной фигуры\n• Щелкните по зеленому индикатору, чтобы сделать ход\n• Для отмены выбора фигуры щелкните по ней повторно или по любой пустой клетке\n• Текущий статус игры (чей ход) отображается в верхней части экрана\n• В режиме против компьютера, он автоматически делает ответный ход после вашего"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "3. Кнопки игрового интерфейса"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• 'Сохранить' - создает сохранение текущей партии (максимум 10 сохранений)\n• 'Новая игра' - начинает новую партию с текущими настройками\n• 'Отменить ход' - отменяет последний сделанный ход (в режиме против компьютера отменяются оба хода - ваш и компьютера)\n• 'Меню' - возврат в главное меню (текущая партия не будет автоматически сохранена)"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "4. Настройки"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• Выбор сложности компьютера:\n  - 'Легкий' (♙) - подходит для начинающих игроков\n  - 'Средний' (♘) - сбалансированный уровень сложности\n  - 'Сложный' (♕) - серьезный вызов даже для опытных игроков\n• Раздел 'Сохранения' позволяет управлять сохраненными партиями:\n  - Выберите сохранение из списка, затем используйте кнопки 'Загрузить' или 'Удалить'\n  - Кнопка 'Удалить все сохранения' позволяет очистить весь список (требует подтверждения)\n• Кнопка 'Готово' закрывает настройки и возвращает в главное меню"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "5. Сохранение и загрузка партий"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• При нажатии на кнопку 'Сохранить':\n  - Введите название для сохранения (обязательно)\n  - Нажмите кнопку 'Сохранить' или 'Отмена'\n  - Обратите внимание на счетчик доступных слотов (максимум 10 сохранений)\n• В настройках для работы с сохранениями:\n  - Выберите сохранение из списка (отображается название, режим игры, сложность и дата)\n  - Используйте кнопки 'Загрузить' или 'Удалить' для соответствующих действий"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "6. Особые ходы шахматной игры"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• Превращение пешки:\n  - При достижении пешкой противоположного края доски появится диалоговое окно\n  - Выберите фигуру, в которую хотите превратить пешку (ферзь, ладья, слон или конь)\n• Рокировка:\n  - Выберите короля, затем нажмите на клетку, куда он должен переместиться при рокировке (на две клетки влево или вправо)\n  - Ладья автоматически переместится на соответствующую позицию\n• Взятие на проходе:\n  - Если пешка соперника сделала ход на две клетки вперед, проходя мимо вашей пешки\n  - Ваша пешка может взять её 'на проходе', перемещаясь по диагонали за пешкой соперника"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "7. Завершение игры"
                    font.pixelSize: 18
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "• Мат - король находится под шахом и нет ходов, чтобы его избежать (победа атакующей стороны)\n• Пат - король не под шахом, но нет легальных ходов (ничья)\n• Ничья по правилу 50 ходов - 50 ходов подряд без взятия фигур и без хода пешками\n• Недостаточный материал для мата - на доске недостаточно фигур для объявления мата\n• Троекратное повторение позиции - одна и та же позиция повторяется три раза\n• При завершении игры появится диалоговое окно с результатом"
                    font.pixelSize: 16
                    font.family: "Courier"
                    color: "#EEEEEE"
                    wrapMode: Text.WordWrap
                }
            }
        }

        footer: Rectangle {
            color: "#664433"
            height: 60

            // Заменена кнопка на Rectangle с MouseArea
            Rectangle {
                id: closeInfoButton
                anchors.centerIn: parent
                width: 120
                height: 40
                color: closeInfoMouseArea.containsMouse ? "#886655" : "#775544"
                radius: 5
                border.color: "#886644"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "Закрыть"
                    color: "white"
                    font.pixelSize: 16
                    font.family: "Courier"
                }

                MouseArea {
                    id: closeInfoMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        infoDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: resultDialog
        title: "Игра окончена"
        modal: true

        background: Rectangle {
            color: "#828282"
            border.color: "#5A5A5A"
            border.width: 2
        }

        property string text: ""

        Label {
            text: resultDialog.text
            font.pixelSize: 16
            font.family: "Courier"
            font.bold: true
            color: "white"
        }

        footer: DialogButtonBox {
            Button {
                text: "ОК"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                background: Rectangle {
                    color: parent.hovered ? "#6D6D6D" : "#828282"
                    border.color: "#5A5A5A"
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    font.family: "Courier"
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        anchors.centerIn: Overlay.overlay

        onAccepted: {
            close()
        }
    }

    // Диалог выбора фигуры для превращения пешки
    Dialog {
        id: promotionDialog
        title: "Превращение пешки"
        modal: true
        closePolicy: Dialog.NoAutoClose
        width: 280  // Увеличена ширина
        height: 280 // Увеличена высота

        background: Rectangle {
            color: "#828282"
            border.color: "#5A5A5A"
            border.width: 2
        }

        header: Rectangle {
            color: "#6D6D6D"
            height: 40

            Text {
                anchors.centerIn: parent
                text: promotionDialog.title
                font.pixelSize: 18
                font.family: "Courier"
                font.bold: true
                color: "white"
            }
        }

        property int fromX: -1
        property int fromY: -1
        property int toX: -1
        property int toY: -1

        anchors.centerIn: Overlay.overlay

        // Сетка 2x2 для фигур
        Grid {
            anchors.centerIn: parent
            rows: 2
            columns: 2
            spacing: 20

            // Ферзь
            Rectangle {
                width: 80
                height: 80
                color: "#6D6D6D"
                border.color: "#5A5A5A"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: {
                        let side = promotionDialog.toY === 7 ? "white" : "black"
                        return resourceManager.getTexturePath(side + "Queen")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        chessEngine.promotePawn(
                            promotionDialog.fromX,
                            promotionDialog.fromY,
                            promotionDialog.toX,
                            promotionDialog.toY,
                            "queen"
                        )
                        promotionDialog.close()
                    }
                }
            }

            // Ладья
            Rectangle {
                width: 80
                height: 80
                color: "#6D6D6D"
                border.color: "#5A5A5A"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: {
                        let side = promotionDialog.toY === 7 ? "white" : "black"
                        return resourceManager.getTexturePath(side + "Rook")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        chessEngine.promotePawn(
                            promotionDialog.fromX,
                            promotionDialog.fromY,
                            promotionDialog.toX,
                            promotionDialog.toY,
                            "rook"
                        )
                        promotionDialog.close()
                    }
                }
            }

            // Слон
            Rectangle {
                width: 80
                height: 80
                color: "#6D6D6D"
                border.color: "#5A5A5A"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: {
                        let side = promotionDialog.toY === 7 ? "white" : "black"
                        return resourceManager.getTexturePath(side + "Bishop")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        chessEngine.promotePawn(
                            promotionDialog.fromX,
                            promotionDialog.fromY,
                            promotionDialog.toX,
                            promotionDialog.toY,
                            "bishop"
                        )
                        promotionDialog.close()
                    }
                }
            }

            // Конь
            Rectangle {
                width: 80
                height: 80
                color: "#6D6D6D"
                border.color: "#5A5A5A"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: {
                        let side = promotionDialog.toY === 7 ? "white" : "black"
                        return resourceManager.getTexturePath(side + "Knight")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        chessEngine.promotePawn(
                            promotionDialog.fromX,
                            promotionDialog.fromY,
                            promotionDialog.toX,
                            promotionDialog.toY,
                            "knight"
                        )
                        promotionDialog.close()
                    }
                }
            }
        }
    }

    // Улучшенный диалог сохранения партии в main.qml
    Dialog {
        id: saveGameDialog
        title: "Сохранить игру"
        modal: true
        width: 400
        height: 300

        // Улучшенный фон диалога
        background: Rectangle {
            color: "#3D3D3D"
            border.color: "#5A5A5A"
            border.width: 2
            radius: 6
        }

        header: Rectangle {
            color: "#553322"
            height: 45
            radius: 4

            Text {
                anchors.centerIn: parent
                text: saveGameDialog.title
                font.pixelSize: 20
                font.family: "Courier"
                font.bold: true
                color: "#FFFFFF"
            }
        }

        anchors.centerIn: Overlay.overlay

        // Добавляем свойство, отслеживающее количество сохранений в реальном времени
        property int availableSlots: Math.max(0, 10 - chessEngine.getSavedGames().length)
        property bool canSave: gameNameInput.text.trim().length > 0 && availableSlots > 0

        // Обновляем счётчик при открытии диалога
        onOpened: {
            availableSlots = Math.max(0, 10 - chessEngine.getSavedGames().length);
            // Если слотов уже нет, блокируем кнопку сохранения
            saveButton.enabled = gameNameInput.text.trim().length > 0 && availableSlots > 0;
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#664433"
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "Введите название сохранения:"
                    font.pixelSize: 16
                    font.family: "Courier"
                    font.bold: true
                    color: "#FFFFFF"
                }
            }

            TextField {
                id: gameNameInput
                Layout.fillWidth: true
                height: 45
                placeholderText: "Название партии"

                // Улучшаем стиль плейсхолдера
                placeholderTextColor: "#BBBBBB" // Более светлый цвет для подсказки

                background: Rectangle {
                    color: "#262626"
                    radius: 5
                    border.color: "#886644" // Использование коричневой границы для согласованности стиля
                    border.width: 2
                }

                color: "#FFFFFF" // Белый цвет для вводимого текста
                selectByMouse: true
                font.pixelSize: 16
                font.family: "Courier"
                leftPadding: 10

                onTextChanged: {
                    // Проверяем и длину текста, И наличие доступных слотов
                    saveButton.enabled = text.trim().length > 0 && saveGameDialog.availableSlots > 0;
                }
            }

            // Информационная строка с динамическим обновлением
            Text {
                id: slotsInfoText
                text: "Максимум 10 сохранений. Доступно слотов: " + saveGameDialog.availableSlots
                font.pixelSize: 14
                font.family: "Courier"
                font.bold: true
                // Цвет меняется на красный, если слотов нет
                color: saveGameDialog.availableSlots > 0 ? "#FFDD99" : "#FF6666"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // Предупреждение, если достигнут лимит
            Text {
                visible: saveGameDialog.availableSlots <= 0
                text: "Достигнут лимит сохранений! Удалите старые записи."
                font.pixelSize: 14
                font.family: "Courier"
                font.bold: true
                color: "#FF6666"  // Красный цвет для предупреждения
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                Rectangle {
                    id: saveButton
                    Layout.fillWidth: true
                    height: 45
                    // Блокируем кнопку если нет текста ИЛИ нет доступных слотов
                    enabled: gameNameInput.text.trim().length > 0 && saveGameDialog.availableSlots > 0
                    color: enabled ? (saveMouseArea.containsMouse ?
                           (saveMouseArea.pressed ? "#4D8F4D" : "#6DAF6D") : "#5D9F5D") : "#444444"
                    radius: 6
                    border.color: enabled ? "#8AFF8A" : "#555555"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Сохранить"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: saveMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (parent.enabled) {
                                if (chessEngine.saveGame(gameNameInput.text.trim())) {
                                    // Сразу после сохранения обновляем количество доступных слотов
                                    saveGameDialog.availableSlots = Math.max(0, 10 - chessEngine.getSavedGames().length);

                                    // ВАЖНО: принудительное обновление для экрана настроек
                                    // Это исправит проблему с первым сохранением
                                    var updatedSaves = chessEngine.getSavedGames();
                                    console.log("После сохранения: " + updatedSaves.length + " сохранений");

                                    // 1. Обновляем в настройках
                                    if (typeof settingsSavedGamesList !== "undefined") {
                                        // Полностью пересоздаем модель
                                        settingsSavedGamesList.model = null;
                                        settingsSavedGamesList.model = updatedSaves;
                                    }

                                    // 2. Обновляем кнопку загрузки в настройках
                                    var loadButtonsInSettings = findAllLoadButtons();
                                    for (var i = 0; i < loadButtonsInSettings.length; i++) {
                                        if (loadButtonsInSettings[i]) {
                                            loadButtonsInSettings[i].enabled = updatedSaves.length > 0;
                                        }
                                    }

                                    saveGameDialog.close();
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: cancelSaveButton
                    Layout.fillWidth: true
                    height: 45
                    color: cancelSaveMouseArea.containsMouse ?
                           (cancelSaveMouseArea.pressed ? "#8F4D4D" : "#AF6D6D") : "#9F5D5D"
                    radius: 6
                    border.color: "#FF8A8A"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Отмена"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelSaveMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            saveGameDialog.close()
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: loadGameDialog
        title: "Загрузить сохранённую партию"
        modal: true
        width: 400
        height: 500
        property int selectedGameIndex: -1

        background: Rectangle {
            color: "#3D3D3D" // Тёмный фон для лучшего контраста
            border.color: "#5A5A5A"
            border.width: 2
            radius: 6
        }

        header: Rectangle {
            color: "#553322" // Стильный заголовок как в диалоге сохранения
            height: 45
            radius: 4

            Text {
                anchors.centerIn: parent
                text: loadGameDialog.title
                font.pixelSize: 20
                font.family: "Courier"
                font.bold: true
                color: "#FFFFFF"
            }
        }

        anchors.centerIn: Overlay.overlay

        onOpened: {
            console.log("Диалог загрузки открыт, запрашиваем обновление списка сохранений");
            // Явно обновляем модель
            savedGamesList.model = null; // Сначала сбрасываем модель для полного обновления
            savedGamesList.model = chessEngine.getSavedGames();
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            // Улучшенный список сохранений
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#262626" // Темный фон для списка
                radius: 5
                border.color: "#444444"
                border.width: 1

                ListView {
                    id: savedGamesList
                    anchors.fill: parent
                    anchors.margins: 5
                    model: chessEngine.getSavedGames()
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }

                    delegate: Rectangle {
                        width: savedGamesList.width - 10
                        height: 80
                        color: loadGameDialog.selectedGameIndex === index ? "#555555" : "#3D3D3D"
                        radius: 5
                        border.color: loadGameDialog.selectedGameIndex === index ? "#886644" : "#555555"
                        border.width: loadGameDialog.selectedGameIndex === index ? 2 : 1

                        // Сохраняем ссылку на объект модели
                        property var gameData: modelData

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                loadGameDialog.selectedGameIndex = index
                                console.log("Выбрана партия: " + parent.gameData.name +
                                            ", режим: " + parent.gameData.gameMode +
                                            ", сложность: " + parent.gameData.difficulty)
                            }
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 5

                            Text {
                                text: parent.parent.gameData && parent.parent.gameData.name ?
                                      parent.parent.gameData.name : "Без названия"
                                font.pixelSize: 16
                                font.family: "Courier"
                                font.bold: true
                                color: "white"
                            }

                            Text {
                                text: {
                                    var gameData = parent.parent.gameData;
                                    if (!gameData) return "Режим: Неизвестно";

                                    var modeText = "Режим: ";
                                    modeText += gameData.gameMode === "vsComputer" ? "Против ИИ" : "Два игрока";

                                    if (gameData.gameMode === "vsComputer") {
                                        var diffText = "";
                                        if (gameData.difficulty === 1) diffText = "Легкий";
                                        else if (gameData.difficulty === 2) diffText = "Средний";
                                        else if (gameData.difficulty === 3) diffText = "Сложный";
                                        else diffText = gameData.difficulty;

                                        modeText += " | Сложность: " + diffText;
                                    }

                                    return modeText;
                                }
                                font.pixelSize: 14
                                font.family: "Courier"
                                color: "white"
                            }

                            Text {
                                text: "Дата: " + (parent.parent.gameData && parent.parent.gameData.date ?
                                                parent.parent.gameData.date : "Неизвестно")
                                font.pixelSize: 14
                                font.family: "Courier"
                                color: "white"
                            }
                        }
                    }

                    // Если список пуст
                    Text {
                        anchors.centerIn: parent
                        visible: savedGamesList.count === 0
                        text: "Нет сохранённых игр"
                        color: "#FFFFFF"
                        font.pixelSize: 16
                        font.family: "Courier"
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Выберите сохраненную партию"
                font.pixelSize: 16
                font.family: "Courier"
                color: "white"
                visible: loadGameDialog.selectedGameIndex === -1 && savedGamesList.count > 0
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Кнопка "Загрузить"
                Rectangle {
                    id: loadButton
                    Layout.fillWidth: true
                    height: 45
                    enabled: loadGameDialog.selectedGameIndex >= 0
                    color: enabled ? (loadMouseArea.containsMouse ?
                            (loadMouseArea.pressed ? "#4D8F4D" : "#6DAF6D") : "#5D9F5D") : "#444444"
                    radius: 6
                    border.color: enabled ? "#8AFF8A" : "#555555"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Загрузить"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: loadMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (parent.enabled && chessEngine.loadGame(loadGameDialog.selectedGameIndex)) {
                                loadGameDialog.close()
                                inMenu = false
                                inSettings = false
                            }
                        }
                    }
                }

                // Кнопка "Удалить"
                Rectangle {
                    id: deleteButton
                    Layout.fillWidth: true
                    height: 45
                    enabled: loadGameDialog.selectedGameIndex >= 0
                    color: enabled ? (deleteMouseArea.containsMouse ?
                            (deleteMouseArea.pressed ? "#8F4D4D" : "#AF6D6D") : "#9F5D5D") : "#444444"
                    radius: 6
                    border.color: enabled ? "#FF8A8A" : "#555555"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Удалить"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: deleteMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (parent.enabled && chessEngine.deleteGame(loadGameDialog.selectedGameIndex)) {
                                // Сбрасываем индекс выбранной игры
                                loadGameDialog.selectedGameIndex = -1
                                // Явно обновляем модель ListView
                                savedGamesList.model = null;
                                savedGamesList.model = chessEngine.getSavedGames();

                                // Обновляем список в настройках, если окно настроек открыто
                                if (inSettings && typeof settingsSavedGamesList !== "undefined") {
                                    settingsSavedGamesList.model = null;
                                    settingsSavedGamesList.model = chessEngine.getSavedGames();
                                }
                            }
                        }
                    }
                }

                // Кнопка "Отмена"
                Rectangle {
                    id: cancelLoadButton
                    Layout.fillWidth: true
                    height: 45
                    color: cancelLoadMouseArea.containsMouse ?
                           (cancelLoadMouseArea.pressed ? "#4D4D6F" : "#5D5D7D") : "#6D6D8D"
                    radius: 6
                    border.color: "#8A8AFF"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Отмена"
                        color: "white"
                        font.pixelSize: 16
                        font.family: "Courier"
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelLoadMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            loadGameDialog.selectedGameIndex = -1
                            loadGameDialog.close()
                        }
                    }
                }
            }
        }
    }

    // Диалог подтверждения удаления
    Dialog {
        id: deleteConfirmDialog
        title: "Удаление сохранения"
        modal: true

        background: Rectangle {
            color: "#3D3D3D"
            border.color: "#5A5A5A"
            border.width: 2
            radius: 6
        }

        header: Rectangle {
            color: "#553322"
            height: 45
            radius: 4

            Text {
                anchors.centerIn: parent
                text: deleteConfirmDialog.title
                font.pixelSize: 18
                font.family: "Courier"
                font.bold: true
                color: "white"
            }
        }

        anchors.centerIn: Overlay.overlay

        property int slotToDelete: -1
        property string gameName: ""

        footer: RowLayout {
            width: parent.width
            spacing: 20
            Layout.margins: 10

            Item { Layout.fillWidth: true }

            // Кнопка "Да"
            Rectangle {
                width: 80
                height: 40
                color: yesMouseArea.containsMouse ?
                       (yesMouseArea.pressed ? "#8F4D4D" : "#AF6D6D") : "#9F5D5D"
                radius: 6
                border.color: "#FF8A8A"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "Да"
                    color: "white"
                    font.pixelSize: 16
                    font.family: "Courier"
                    font.bold: true
                }

                MouseArea {
                    id: yesMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (deleteConfirmDialog.slotToDelete >= 0) {
                            chessEngine.deleteGame(deleteConfirmDialog.slotToDelete);
                        }
                        deleteConfirmDialog.accept();
                    }
                }
            }

            // Кнопка "Нет"
            Rectangle {
                width: 80
                height: 40
                color: noMouseArea.containsMouse ?
                       (noMouseArea.pressed ? "#4D4D6F" : "#5D5D7D") : "#6D6D8D"
                radius: 6
                border.color: "#8A8AFF"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "Нет"
                    color: "white"
                    font.pixelSize: 16
                    font.family: "Courier"
                    font.bold: true
                }

                MouseArea {
                    id: noMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        deleteConfirmDialog.reject();
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }

        onAccepted: {
            close();
        }

        onRejected: {
            close();
        }

        Text {
            anchors.centerIn: parent
            text: "Вы уверены, что хотите удалить\n\"" + deleteConfirmDialog.gameName + "\"?"
            font.pixelSize: 16
            font.family: "Courier"
            font.bold: true
            color: "white"
            wrapMode: Text.WordWrap
            width: 300
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
