public enum MaterialOptions {
    case unlitColor(UnlitColorMaterialOptions)
    case normals(NormalsMaterialOptions)
    case blinnPhong(BlinnPhongMaterialOptions)

    public var shader: String {
        switch self {
            case .unlitColor:
                "unlit_color"
            case .blinnPhong:
                "blinn_phong"
            case .normals:
                "normals"
        }
    }
}
