//
//  CurveEditorView.swift
//  MicroMove
//
//  Created by Vasilis Akoinoglou on 26/2/20.
//  Copyright © 2020 Vasilis Akoinoglou. All rights reserved.
//

import SwiftUI

struct CurveShape: Shape {
    let cp0, cp1: RelativePoint
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 0, y: rect.size.height))
            p.addCurve(to: CGPoint(x: rect.size.width, y: 0),
                       control1: cp0 * rect.size,
                       control2: cp1 * rect.size)
        }
    }
}

struct ControlPointHandle: View {
    private let size: CGFloat = 20
    var body: some View {
        Circle()
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
        )
            .offset(x: -size/2, y: -size/2)
    }
}

struct CurveEditorView: View {

    private let initialPoint0: CGSize = .init(width: 0.4, height: 0.3)
    private let initialPoint1: CGSize = .init(width: 0.6, height: 0.6)

    @State private var offsetPoint0: CGSize = .zero
    @State private var offsetPoint1: CGSize = .zero

    private var curvePoint0: RelativePoint {
        (initialPoint0 + offsetPoint0).toPoint
    }

    private var curvePoint1: RelativePoint {
        (initialPoint1 + offsetPoint1).toPoint
    }

    @Binding var controlPoint1: RelativePoint
    @Binding var controlPoint2: RelativePoint

    var body: some View {

        let primaryColor   = Color.blue
        let secondaryColor = primaryColor.opacity(0.7)

        return GeometryReader { reader in
            Color.white

            CurveShape(cp0: self.curvePoint0, cp1: self.curvePoint1)
                .stroke(primaryColor, lineWidth: 4)

            Path { p in
                p.move(to: CGPoint(x: 0, y: 1 * reader.size.height))
                p.addLine(to: self.curvePoint0 * reader.size)
            }.stroke(secondaryColor, lineWidth: 2)

            Path { p in
                p.move(to: CGPoint(x: 1 * reader.size.width, y: 0))
                p.addLine(to: self.curvePoint1 * reader.size)
            }.stroke(secondaryColor, lineWidth: 2)

            ControlPointHandle()
                .offset(self.initialPoint0 * reader.size)
                .foregroundColor(primaryColor)
                .draggable(onChanged: { (size) in
                    self.offsetPoint0 = size / reader.size
                    self.controlPoint1 = self.curvePoint0
                })

            ControlPointHandle()
                .offset(self.initialPoint1 * reader.size)
                .foregroundColor(primaryColor)
                .draggable(onChanged: { (size) in
                    self.offsetPoint1 = size / reader.size
                    self.controlPoint2 = self.curvePoint1
                })
        }
        .aspectRatio(contentMode: .fit)
        .onAppear {
            self.controlPoint1 = self.curvePoint0
            self.controlPoint2 = self.curvePoint1
        }
    }
}

struct TimingCurveView: View {
    @State var value: CGFloat = 0

    @State var cp1: RelativePoint = .zero
    @State var cp2: RelativePoint = .zero

    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var animation: Animation {
        Animation.timingCurve(
            Double(cp1.x),
            Double(1 - cp1.y),
            Double(cp2.x),
            Double(1 - cp2.y),
            duration: 2
        )
    }

    var body: some View {
        VStack {
            CurveEditorView(controlPoint1: $cp1, controlPoint2: $cp2)
                .aspectRatio(contentMode: .fill)
            Spacer()
            GeometryReader { reader in
                Circle()
                    .position(x: 0, y: 6)
                    .offset(x: self.value * reader.size.width, y: 0)
                    .frame(height: 12)
            }.frame(height: 40)
        }
        .onReceive(timer) { _ in
            self.value = 0
            withAnimation(self.animation) {
                self.value = 1
            }
        }
    }
}

struct CurveEditorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ControlPointHandle()//.frame(width: 40, height: 40).padding()
            CurveShape(cp0: .init(x: 0.4, y: 0.3), cp1: .init(x: 0.6, y: 0.6))
                .stroke(Color.blue, lineWidth: 4)
            CurveEditorView(controlPoint1: .constant(.init(x: 0.4, y: 0.3)), controlPoint2: .constant(.init(x: 0.6, y: 0.6)))
            TimingCurveView().frame(width: 400)
        }//.padding()
    }
}
