public protocol GameComponent: GameUpdatable, Toggleable {
    var parent: GameObject? { get set }
    var name: String { get }
}
