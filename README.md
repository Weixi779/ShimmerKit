# ShimmerKit

Swift Package providing a Metal-powered shimmer effect for SwiftUI (iOS 17+).

## Usage

```swift
import ShimmerKit

struct SkeletonRow: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.2))
            .frame(height: 64)
            .shimmer()
    }
}
```

The `shimmer` modifier feeds view size and time into the Metal `shimmer` shader. You can pass `ShimmerAlphaConfig` to tweak direction, band width, alpha endpoints, highlight strength, gamma, and duration.
