//
//  ViewFrameInfoModifier.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/12
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

struct ViewFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

struct GetFrameInfoModifier: ViewModifier {
    @Binding var bindingValue: CGRect
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ViewFrameKey.self, value: proxy.frame(in: .global))
                        .onPreferenceChange(ViewFrameKey.self, perform: { frame in
                            self.bindingValue = frame
                        })
                }
            )
    }
}

extension View {
    /// get the current view frame information to binding value
    func getCurrentViewFrameInfo(to bindingValue: Binding<CGRect>) -> some View {
        modifier(GetFrameInfoModifier(bindingValue: bindingValue))
    }
}

// CompositeContainerEnvironmentValue

extension OverlayContainer {
    func compositeContainerEnvironmentValue(
        containerName: String,
        containerConfiguration: ContainerConfigurationProtocol,
        containerFrame: CGRect,
        dismissAction: @escaping () -> Void
    ) -> ContainerEnvironment {
        ContainerEnvironment(
            containerName: containerName,
            containerFrame: containerFrame,
            containerViewDisplayType: containerConfiguration.displayType,
            containerViewQueueType: containerConfiguration.queueType,
            dismiss: dismissAction
        )
    }
}