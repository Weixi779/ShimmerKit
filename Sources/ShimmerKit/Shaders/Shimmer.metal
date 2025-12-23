#include <metal_stdlib>
using namespace metal;
#include <SwiftUI/SwiftUI_Metal.h>

// MARK: - 高斯衰减函数（亮度随距离衰减）
float gaussianFalloff(float x, float center, float width) {
    float sigma = width * 0.5;
    float dx = x - center;
    return exp(- (dx * dx) / (2.0 * sigma * sigma));
}

// MARK: - 伽马校正（模拟 UIKit / CoreAnimation 的色彩感知）
half3 gammaCorrect(half3 color, float gamma) {
    return pow(color, half3(1.0 / gamma));
}

[[ stitchable ]]
half4 shimmer(
    float2 position,   // 当前像素位置
    half4 color,       // 原始颜色（来自视图内容）
    float2 size,       // 渲染区域大小
    float time         // 时间（外部驱动）
) {
    // 安全检查
    if (size.x <= 0.0 || size.y <= 0.0 || color.a <= 0.0) {
        return color;
    }

    // MARK: - 参数配置
    float2 direction = normalize(float2(1.0, 0.25)); // 光带方向（右上）
    float width = 0.5;      // 光带宽度（越大越宽，单位是 UV）
    float brightness = 0.15; // 提亮幅度（中间亮度提升）
    float baseAlpha = 0.35;  // 非高亮区域的透明度
    float gamma = 2.2;       // 色彩空间修正（感知更自然）

    // MARK: - UV 归一化处理
    float2 uv = position / size;
    float projected = dot(uv, direction); // 当前点在 shimmer 方向上的投影

    // MARK: - shimmer 动画控制（带拖尾的自然节奏）
    float duration = 1.5;                // ⏱️ 总时长（秒）
    float baseT = fract(time / duration);
    float t = pow(baseT, 0.75);
    float extra = width * 2;             // 光带超出范围滑入/滑出
    float center = mix(-extra, 1.0 + extra, t); // 动态中心位置

    // MARK: - 计算亮度权重
    float weight = gaussianFalloff(projected, center, width); // ∈ [0,1]

    // MARK: - 提亮混色 + gamma 校正
    half3 rgb = mix(color.rgb, half3(1.0), half(weight * brightness));
    rgb = gammaCorrect(rgb, gamma);

    // MARK: - 透明度混合
    half alpha = half((1.0 - weight) * baseAlpha * color.a + weight * color.a);

    return half4(rgb, alpha);
}
