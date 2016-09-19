import Cocoa

/*private let outputQueue = { () -> DispatchQueue in
    let queue = DispatchQueue(
    //let queue = dispatch_queue_create("org.carthage.carthage.outputQueue", DISPATCH_QUEUE_SERIAL)
    dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
    
    atexit_b {
        dispatch_barrier_sync(queue) {}
    }
    
    return queue
}()*/

private let outputQueue = { () -> DispatchQueue in
    let queue = DispatchQueue(label: "org.giginet.toybox.outputQueue")
    let globalQueue = DispatchQueue.global()
    queue.setTarget(queue: globalQueue)
    atexit_b {
        queue.sync(flags: .barrier) { }
    }
    return queue
}()

/// A thread-safe version of Swift's standard println().
internal func println() {
    outputQueue.async {
        Swift.print()
    }
}

/// A thread-safe version of Swift's standard println().
internal func println<T>(object: T) {
    outputQueue.async {
        Swift.print(object)
    }
}

/// A thread-safe version of Swift's standard print().
internal func print<T>(object: T) {
    outputQueue.async {
        Swift.print(object, terminator: "")
    }
}
