import Foundation

public protocol GameUpdatable {
    func update(input: Input, delta: Double)
}
