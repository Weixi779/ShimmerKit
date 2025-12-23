//
//  ContentView.swift
//  ShimmerKitExample
//
//  Created by 孙世伟 on 2025/12/23.
//

import SwiftUI
import ShimmerKit

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.opacity(0.4))
                .frame(width: 220, height: 60)
                .shimmer()

            Text("Shimmer")
                .font(.largeTitle).bold()
                .padding()
                .background(.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                .shimmer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
