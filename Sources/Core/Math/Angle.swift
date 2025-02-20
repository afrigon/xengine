public struct Angle: Comparable, Equatable, Hashable, Sendable {
    private enum AngleValue: Hashable {
        case degrees(Float)
        case radians(Float)
    }
    
    private let value: AngleValue
    
    public var degrees: Float {
        switch value {
            case let .degrees(value):
                value
            case let .radians(value):
                (value / .pi) * 180
        }
    }
    
    public var radians: Float {
        switch value {
            case let .degrees(value):
                (value / 180) * .pi
            case let .radians(value):
                value
        }
    }
    
    public init(radians: Float) {
        value = .radians(radians)
    }
    
    public init(degrees: Float) {
        value = .degrees(degrees)
    }
    
    public static func degrees(_ value: Float) -> Angle {
        .init(degrees: value)
    }
    
    public static func radians(_ value: Float) -> Angle {
        .init(radians: value)
    }
    
    public static func < (lhs: Angle, rhs: Angle) -> Bool {
        lhs.degrees < rhs.degrees
    }
    
    public static func == (lhs: Angle, rhs: Angle) -> Bool {
        lhs.degrees == rhs.degrees
    }
}
