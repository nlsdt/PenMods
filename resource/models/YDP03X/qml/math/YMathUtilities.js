

let kISBNMaxLength = 13

function showView(viewloader) {
    if (viewloader === null) { return }
    if (!(viewloader instanceof Loader)) { return }
    if (viewloader.active === true) { return }
    viewloader.active = true
}

function closeView(viewloader) {
    if (viewloader === null) { return }
    if (!(viewloader instanceof Loader)) { return }
    if (viewloader.active === false) { return }
    viewloader.active = false
}
