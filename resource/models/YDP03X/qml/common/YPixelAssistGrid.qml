import QtQuick 2.12

Item
{
    id: id_pixel_assist_grid_line
    clip: true
    anchors.fill: parent
    property int spacingLength: 20  // 方格大小
    property var lineWidth: 0.5   // 线宽度
//    property var edgeDistance: 0.5 //边缘距离
    property bool leftToRight: true // true 从左向右,从上到下画  false 从右向左，从下向上画


    Canvas
    {
        id: id_canvas
        anchors.fill: parent
        antialiasing: true
        property bool drawable: false
        function drawLine(ctx, color, width, startX, startY, endX, endY)
        {
            ctx.strokeStyle = color
            ctx.lineWidth = width
            ctx.beginPath()
            ctx.moveTo(startX, startY)
            ctx.lineTo(endX, endY)
            ctx.closePath()
            ctx.stroke()
        }

        onPaint:
        {
            var ctx = getContext("2d")
            ctx.fillStyle = "#10FFFFFF"
            ctx.fillRect(0, 0, width, height)

            if(leftToRight){
                for(let i = 0; i < width; i += spacingLength)
                    drawLine(ctx, "#7266fc", lineWidth,i+lineWidth, 0, i+lineWidth, height)
                for(let j = 0; j < height; j += spacingLength)
                    drawLine(ctx, "#7266fc", lineWidth, 0, j + lineWidth, width, j + lineWidth)
            }else{
                for(let i = width; i >= 0; i -= spacingLength)
                    drawLine(ctx, "#7266fc", lineWidth,i-lineWidth, 0, i-lineWidth, height)
                for(let j = height; j >=0; j -= spacingLength)
                    drawLine(ctx, "#7266fc", lineWidth, width, j - lineWidth, 0, j - lineWidth)

            }


        }
    }
}
