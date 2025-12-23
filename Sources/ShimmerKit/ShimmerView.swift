import SwiftUI

/// Minimal shimmer modifier that feeds size and time into the Metal shader.
public struct ShimmerModifier: ViewModifier {
    private let startDate = Date()

    public init() {}

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
                .float(time)
            ]
        )
    }
}

public extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
