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
    float time,        // Time driven externally
    float2 bandDirection, // Light band direction (normalized upstream)
    float bandWidth,       // Band width in UV space
    float highlightStrength, // Mix toward white, controls perceived brightness
    float backgroundAlpha,   // Alpha outside the highlight
    float bandAlpha,         // Alpha at the highlight center
    float gamma,             // Perceptual correction
    float duration           // Total animation duration (seconds)
) {
    // Early exit for invalid inputs
    if (size.x <= 0.0 || size.y <= 0.0 || color.a <= 0.0) {
        return color;
    }

    // MARK: - Normalize and clamp inputs
    bandDirection = normalize(bandDirection);
    bandWidth = max(bandWidth, 0.0001);
    highlightStrength = clamp(highlightStrength, 0.0, 1.0);
    backgroundAlpha = clamp(backgroundAlpha, 0.0, 1.0);
    bandAlpha = clamp(bandAlpha, 0.0, 1.0);
    gamma = max(gamma, 0.0001);
    duration = max(duration, 0.0001);

    // MARK: - UV normalization
    float2 uv = position / size;
    float projectionOnBand = dot(uv, bandDirection); // Projection on shimmer direction

    // MARK: - Animation timing (soft ease)
    float baseT = fract(time / duration);
    float t = smoothstep(0.0, 1.0, baseT);
    float overscan = 1.0 + bandWidth * 2.0; // Overscan so the band slides fully in/out
    float bandCenter = mix(-overscan, 1.0 + overscan, t); // Moving center position

    // MARK: - Brightness weight
    float weight = gaussianBand(projectionOnBand, bandCenter, bandWidth); // ∈ [0,1]

    // MARK: - Blend toward white + gamma correction
    float blend = clamp(weight * highlightStrength, 0.0, 1.0);
    half3 rgb = mix(color.rgb, half3(1.0), half(blend));
    rgb = gammaCorrect(rgb, gamma);

    // MARK: - Alpha blend
    float alphaMix = mix(backgroundAlpha, bandAlpha, weight);
    half alpha = half(alphaMix * color.a);

    return half4(rgb, alpha);
}
