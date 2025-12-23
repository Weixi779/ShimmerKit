import SwiftUI
import simd

/// Minimal shimmer modifier that feeds size and time into the Metal shader.
public struct ShimmerModifier: ViewModifier {
    public var config: ShimmerAlphaConfig
    private let startDate = Date()

    public init(config: ShimmerAlphaConfig = .init()) {
        self.config = config
    }

    public func body(content: Content) -> some View {
        TimelineView(.animation) { timeline in
            let time = Float(timeline.date.timeIntervalSince(startDate))

            content.visualEffect { view, proxy in
                view.colorEffect(makeShader(size: proxy.size, time: time))
            }
        }
    }

    private func makeShader(size: CGSize, time: Float) -> Shader {
        Shader(
            function: .init(library: .bundle(.module), name: "shimmer"),
            arguments: [
                .float2(size),
                .float(time),
                .float2(config.direction.x, config.direction.y),
                .float(config.bandWidth),
                .float(config.highlightStrength),
                .float(config.backgroundAlpha),
                .float(config.bandAlpha),
                .float(config.gamma),
                .float(config.duration)
            ]
        )
    }
}

public extension View {
    func shimmer(config: ShimmerAlphaConfig = .init()) -> some View {
        modifier(ShimmerModifier(config: config))
    }
}
