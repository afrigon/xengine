import Foundation

public struct Material {
    public var commonOptions: MaterialCommonOptions
    public var options: MaterialOptions
    
    public init(_ options: MaterialOptions, common: MaterialCommonOptions = .init()) {
        self.options = options
        self.commonOptions = common
    }
}
