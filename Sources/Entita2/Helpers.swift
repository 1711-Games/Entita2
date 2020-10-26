import NIO

internal extension EventLoop {
    @usableFromInline
    var future: EventLoopFuture<Void> {
        self.makeSucceededFuture(Void())
    }
}
