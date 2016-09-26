import Cocoa

private let outputQueue = { () -> DispatchQueue in
    let queue = DispatchQueue(label: "org.giginet.toybox.outputQueue")
    let globalQueue = DispatchQueue.global()
    queue.setTarget(queue: globalQueue)
    atexit_b {
        queue.sync(flags: .barrier) { }
    }
    return queue
}()

internal func println() {
    Swift.print()
}

internal func println<T>(object: T) {
    Swift.print(object)
}

internal func print<T>(object: T) {
    Swift.print(object, terminator: "")
}
