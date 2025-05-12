import QtQuick 2.15

Image {
    id: piece

    property int pieceX: 0
    property int pieceY: 0

    MouseArea {
        anchors.fill: parent
        drag.target: parent

        onPressed: {
            piece.z = 10 // Перемещаем фигуру на передний план

            // Показываем возможные ходы
            let legalMoves = chessEngine.getLegalMovesForPiece(pieceX, pieceY)
            if (legalMoves.length > 0) {
                moveIndicators.fromX = pieceX
                moveIndicators.fromY = pieceY
                moveIndicators.legalMoves = legalMoves
                moveIndicators.visible = true
            }
        }

        onReleased: {
            // Вычисляем клетку, на которую опускаем фигуру
            let newX = Math.floor((piece.x + piece.width / 2) / cellSize)
            let newY = Math.floor((piece.y + piece.height / 2) / cellSize)

            // Удерживаем фигуру внутри доски
            newX = Math.max(0, Math.min(7, newX))
            newY = Math.max(0, Math.min(7, newY))

            // Пытаемся сделать ход
            if (chessEngine.processMove(pieceX, pieceY, newX, newY)) {
                // Ход выполнен успешно, движок обновит фигуры
                moveIndicators.visible = false
            } else {
                // Возврат на исходную позицию
                piece.x = pieceX * cellSize
                piece.y = pieceY * cellSize
            }

            piece.z = 1 // Сбрасываем порядок по оси Z
        }
    }
}
