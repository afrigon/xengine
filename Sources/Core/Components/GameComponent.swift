public protocol GameComponent: GameUpdatable {
    var parent: GameObject? { get set }
    var enabled: Bool { get set }
    var name: String { get }
}
