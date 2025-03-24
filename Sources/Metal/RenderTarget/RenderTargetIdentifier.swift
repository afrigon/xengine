enum RenderTargetIdentifier: Hashable {
    case color
    case depth
    case normal
    case postSwapA
    case postSwapB
    case output
    case named(String)
}
