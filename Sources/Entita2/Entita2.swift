import Logging

public enum Entita2 {
    /// Global default serializing format for all Entita2 entities
    public static var format: Entita2.Format = .JSON

    /// Global logger
    public static var logger: Logger = Logger(label: "Entita2")
}

public typealias E2 = Entita2
