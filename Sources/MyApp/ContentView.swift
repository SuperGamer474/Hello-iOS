// ContentView.swift
// "Hello iOS World!" — all style, no extra text.
// Drop into a SwiftUI app (iOS 15+ recommended).

import SwiftUI

struct ContentView: View {
    @State private var animate = false
    @State private var floatPhase: CGFloat = 0

    var body: some View {
        ZStack {
            // animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.02, blue: 0.18),
                    Color(red: 0.18, green: 0.03, blue: 0.40),
                    Color(red: 0.03, green: 0.30, blue: 0.45)
                ]),
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.linear(duration: 10).repeatForever(autoreverses: true), value: animate)

            // soft moving blobs for depth (no text)
            FloatingBlobs(phase: floatPhase)
                .blendMode(.screen)
                .ignoresSafeArea()
                .opacity(0.35)

            // subtle starry particles using Canvas
            ParticleField()
                .ignoresSafeArea()
                .opacity(0.18)

            // MAIN TEXT — only this string is shown
            Text("Hello iOS World!")
                .font(.system(size: 56, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                // neon gradient fill
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.purple, Color.blue, Color.cyan, Color.white],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                // soft inner glow effect
                .overlay(
                    Text("Hello iOS World!")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .blur(radius: 8)
                        .opacity(0.18)
                )
                // glass halo behind
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(LinearGradient(colors: [Color.white.opacity(0.16), Color.white.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.45), radius: 20, x: 0, y: 10)
                )
                // neon outer glow
                .shadow(color: Color.purple.opacity(0.22), radius: 40, x: 0, y: 10)
                .shadow(color: Color.blue.opacity(0.18), radius: 80, x: 0, y: 20)
                // 3D tilt + pulse
                .rotation3DEffect(.degrees(animate ? 6 : -6), axis: (x: 10, y: 6, z: 0))
                .scaleEffect(animate ? 1.02 : 0.98)
                .animation(.spring(response: 1.2, dampingFraction: 0.6), value: animate)
                .onAppear {
                    animate = true
                    withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                        floatPhase = 1
                    }
                }
        }
    }
}

// MARK: - Floating blobs (decorative depth)
fileprivate struct FloatingBlobs: View {
    var phase: CGFloat // 0 -> 1 (animated)
    var body: some View {
        GeometryReader { geo in
            ZStack {
                blob(at: CGPoint(x: geo.size.width * 0.18, y: geo.size.height * 0.16), size: 300, hue: 0.75, phaseShift: 0.0)
                blob(at: CGPoint(x: geo.size.width * 0.85, y: geo.size.height * 0.2), size: 220, hue: 0.55, phaseShift: 0.35)
                blob(at: CGPoint(x: geo.size.width * 0.65, y: geo.size.height * 0.8), size: 420, hue: 0.33, phaseShift: 0.8)
            }
            .blur(radius: 36)
            .opacity(0.95)
            .rotationEffect(.degrees(Double(phase * 18)))
        }
    }

    func blob(at point: CGPoint, size: CGFloat, hue: Double, phaseShift: CGFloat) -> some View {
        // gentle orbital offset
        let offsetX = (sin((phase + phaseShift) * .pi * 2) * 40)
        let offsetY = (cos((phase + phaseShift) * .pi * 2) * 26)
        return Circle()
            .fill(
                RadialGradient(gradient: Gradient(colors: [
                    Color(hue: hue, saturation: 0.9, brightness: 0.9),
                    Color(hue: hue + 0.06, saturation: 0.7, brightness: 0.55)
                ]), center: .center, startRadius: 10, endRadius: size * 0.6)
            )
            .frame(width: size, height: size)
            .position(x: point.x + offsetX, y: point.y + offsetY)
            .opacity(0.95)
    }
}

// MARK: - Particle field via Canvas
fileprivate struct ParticleField: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                // create many tiny sparkle dots, animated by time
                for i in 0..<120 {
                    let angle = Double(i) * 23.7 + now * (0.05 + Double(i % 5) * 0.01)
                    let radius = 0.35 * min(size.width, size.height) * (0.2 + Double((i % 7)) * 0.07)
                    let x = size.width * 0.5 + CGFloat(cos(angle) * radius)
                    let y = size.height * 0.5 + CGFloat(sin(angle) * radius * 0.6)
                    let alpha = 0.18 + 0.6 * (0.5 + 0.5 * sin(now * (0.6 + Double(i % 3) * 0.2) + Double(i)))
                    let rect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 1.2, height: 1.2))
                    context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(Double(alpha * 0.12))))
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
