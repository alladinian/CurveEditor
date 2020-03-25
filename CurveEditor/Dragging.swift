//
//  Dragging.swift
//  MicroMove
//
//  Created by Vasilis Akoinoglou on 26/2/20.
//  Copyright © 2020 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

// MARK: - Modifier Implementation
struct Draggable: ViewModifier {
    @State var isDragging: Bool = false

    @State var offset: CGSize = .zero
    @State var dragOffset: CGSize = .zero

    var onChanged: ((CGSize) -> Void)?
    var onEnded: ((CGSize) -> Void)?

    func body(content: Content) -> some View {
        let drag = DragGesture()
        .onChanged { (value) in
            self.offset     = self.dragOffset + value.translation
            self.isDragging = true
            self.onChanged?(self.offset)
        }.onEnded { (value) in
            self.isDragging = false
            self.offset     = self.dragOffset + value.translation
            self.dragOffset = self.offset
            self.onEnded?(self.offset)
        }
        return content.offset(offset).gesture(drag)
    }
}

// MARK: - ViewBuilder Implementation
//struct DraggableView<Content>: View where Content: View {
//    let content: () -> Content
//
//    init(@ViewBuilder content: @escaping () -> Content) {
//        self.content = content
//    }
//
//    var body: some View {
//        return content().modifier(Draggable(updating: updating))
//    }
//
//}

extension View {
    func draggable(onChanged: ((CGSize) -> Void)? = nil, onEnded: ((CGSize) -> Void)? = nil) -> some View {
        return self.modifier(Draggable(onChanged: onChanged, onEnded: onEnded))
    }
}
