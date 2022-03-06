//
//  DismissGesture.swift
//
//
//  Created by Yang Xu on 2022/3/5
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

/// Gesture for dismiss Container View
///
/// Container View's dismiss gesture has higher priority than OverlayContainer
///
///     container           containerView           result
///         nil               nil                     nil
///         none              none                    nil
///         tap               nil                     tap
///         tap               none                    nil
///         tap               swipeLeft               swipeLeft
///         nil               tap                     tap
///         nil               none                    nil
///
///   Convert gesture to AnyGesture<Void> when using customGesture
///
///      let gesture = LongPressGesture(minimumDuration: 1, maximumDistance: 5).eraseToAnyGestureForDismiss()
///
public enum ContainerViewDismissGesture {
    case tap
    case doubleTap
    case swipeLeft
    case swipeRight
    case swipeUp
    case swipeDown
    case customGesture(AnyGesture<Void>)
    case none
}

extension ContainerViewDismissGesture {
    /// generate dismiss gesture with execution closure
    ///
    /// The dismiss Action not only includes the cancellation action of Overlay Container view,
    /// but also the dismiss closure specified by user
    func generateGesture(with dismissAction: @escaping () -> Void) -> AnyGesture<Void>? {
        switch self {
        case .tap:
            return TapGesture(count: 1).onEnded { _ in dismissAction() }.eraseToAnyGestureForDismiss()
        case .doubleTap:
            return TapGesture(count: 2).onEnded { _ in dismissAction() }.eraseToAnyGestureForDismiss()
        case .customGesture(let gesture):
            return gesture.onEnded { _ in dismissAction() }.eraseToAnyGestureForDismiss()
        case .none:
            return nil
        case .swipeUp, .swipeDown, .swipeLeft, .swipeRight:
            return SwipeGesture(minimumDistance: 10, coordinateSpace: .global)
                .onEnded { direction in
                    switch (direction, self) {
                    case (.left, .swipeLeft):
                        dismissAction()
                    case (.right, .swipeRight):
                        dismissAction()
                    case (.up, .swipeUp):
                        dismissAction()
                    case (.down, .swipeDown):
                        dismissAction()
                    default:
                        break
                    }
                }
                .eraseToAnyGestureForDismiss()
        }
    }
}

public extension Gesture {
    /// Erase SwiftUI Gesture to AnyGesture , and convert value to Void.
    func eraseToAnyGestureForDismiss() -> AnyGesture<Void> {
        AnyGesture(map { _ in () })
    }
}

/// Swipe Gesture
struct SwipeGesture: Gesture {
    enum Direction: String {
        case left, right, up, down
    }

    typealias Value = Direction

    private let minimumDistance: CGFloat
    private let coordinateSpace: CoordinateSpace

    init(minimumDistance: CGFloat = 10, coordinateSpace: CoordinateSpace = .local) {
        self.minimumDistance = minimumDistance
        self.coordinateSpace = coordinateSpace
    }

    var body: AnyGesture<Value> {
        AnyGesture(
            DragGesture(minimumDistance: minimumDistance, coordinateSpace: coordinateSpace)
                .map { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height

                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount < 0 { return .left } else { return .right }
                    } else {
                        if verticalAmount < 0 { return .up } else { return .down }
                    }
                }
        )
    }
}