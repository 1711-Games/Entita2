public extension Entita2 {
    enum E: Error {
        case SaveError(String)
        case IndexError(String)
        case CastError(String)
    }
}
