.pragma library

function clampedTargetY(originY, contentHeight, viewportHeight, itemY) {
    var maxY = Math.max(originY, originY + contentHeight - viewportHeight);
    return Math.max(originY, Math.min(itemY, maxY));
}
