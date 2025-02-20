import simd
import QuartzCore

struct Globals {
    
    // screen
    var width: UInt32 = 1920
    var height: UInt32 = 1080

    // camera
    var projectionMatrix: matrix_float4x4 = .init()
    var viewMatrix: matrix_float4x4 = .init()
    
    // model
    var modelMatrix: matrix_float4x4 = .init()
    var normalMatrix: matrix_float3x3 = .init()
    
    var modelViewProjectionMatrix: matrix_float4x4 = .init()

    // time
    var time: Double? = nil
    var deltaTime: Double = 0
}
