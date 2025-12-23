import Foundation
import simd

/// Configuration for the alpha-driven shimmer effect.
public struct ShimmerAlphaConfig: Sendable {
    /// Direction of the band; will be normalized in shader for safety.
    public var direction: simd_float2
    /// Band width as a fraction of the view (UV space).
    public var bandWidth: Float
    /// How strongly to mix toward white at the highlight.
    public var highlightStrength: Float
    /// Alpha outside the highlight band.
    public var backgroundAlpha: Float
    /// Alpha at the highlight center.
    public var bandAlpha: Float
    /// Gamma correction applied to the output color.
    public var gamma: Float
    /// Total duration of one shimmer pass (seconds).
    public var duration: Float

    public init(
        direction: simd_float2 = simd_float2(1.0, 0.25),
        bandWidth: Float = 0.35,
        highlightStrength: Float = 0.15,
        backgroundAlpha: Float = 0.35,
        bandAlpha: Float = 1.0,
        gamma: Float = 2.2,
        duration: Float = 1.5
    ) {
        self.direction = direction
        self.bandWidth = bandWidth
        self.highlightStrength = highlightStrength
        self.backgroundAlpha = backgroundAlpha
        self.bandAlpha = bandAlpha
        self.gamma = gamma
        self.duration = duration
    }
}
