public enum KeyframeValue<T> {
    case value(T)
    case runtime((Float) -> T)
}
