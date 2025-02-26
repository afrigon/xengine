public struct AnimationClip {
    var length: Float?

    // TODO: refactor this system to animate any GameComponent properties ?
    var tracks: [String: AnimationTrack]
    
    public init(length: Float? = nil, tracks: [String : AnimationTrack]) {
        self.length = length
        self.tracks = tracks
    }
}
