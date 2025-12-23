#include <metal_stdlib>
using namespace metal;
#include <SwiftUI/SwiftUI_Metal.h>

// MARK: - Gaussian band weight (brightness decays with distance)
float gaussianBand(float x, float center, float bandWidth) {
    float sigma = bandWidth * 0.5;
    float dx = x - center;
    return exp(- (dx * dx) / (2.0 * sigma * sigma));
}

// MARK: - Gamma correction (closer to UIKit/CoreAnimation perception)
half3 gammaCorrect(half3 color, float gamma) {
    return pow(color, half3(1.0 / gamma));
}

[[ stitchable ]]
half4 shimmer(
    float2 position,   // Current pixel position
    half4 color,       // Source color from view content
    float2 size,       // Render area size
    float time         // Time driven externally
) {
    // Early exit for invalid inputs
    if (size.x <= 0.0 || size.y <= 0.0 || color.a <= 0.0) {
        return color;
    }

    // MARK: - Parameters (to be driven by uniforms later)
    float2 bandDirection = normalize(float2(1.0, 0.25)); // Light band direction
    float bandWidth = 0.35;   // Band width in UV space
    float brightness = 0.15; // Highlight boost toward white
    float backgroundAlpha = 0.35; // Alpha outside the highlight
    float bandAlpha = 1.0;   // Alpha at the highlight center
    float gamma = 2.2;       // Perceptual correction

    // MARK: - UV normalization
    float2 uv = position / size;
    float projectionOnBand = dot(uv, bandDirection); // Projection on shimmer direction

    // MARK: - Animation timing (soft ease)
    float duration = 1.5;                // Total duration (seconds)
    float baseT = fract(time / duration);
    float t = smoothstep(0.0, 1.0, baseT);
    float overscan = 1.0 + bandWidth * 2.0; // Overscan so the band slides fully in/out
    float bandCenter = mix(-overscan, 1.0 + overscan, t); // Moving center position

    // MARK: - Brightness weight
    float weight = gaussianBand(projectionOnBand, bandCenter, bandWidth); // ∈ [0,1]

    // MARK: - Blend toward white + gamma correction
    half3 rgb = mix(color.rgb, half3(1.0), half(weight * brightness));
    rgb = gammaCorrect(rgb, gamma);

    // MARK: - Alpha blend
    float alphaMix = mix(backgroundAlpha, bandAlpha, weight);
    half alpha = half(alphaMix * color.a);

    return half4(rgb, alpha);
}
