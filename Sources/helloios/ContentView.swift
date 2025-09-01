// ContentView.swift
// Hello iOS! — static, no CoreMotion tilt, but keeps all the cool styling.

import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @State private var breathe = false
    
    var body: some View {
        ZStack {
            // background
            LinearGradient(
                gradient: Gradient(colors: [Color(red:0.05, green:0.02, blue:0.18),
                                           Color(red:0.18, green:0.03, blue:0.40),
                                           Color(red:0.03, green:0.30, blue:0.45)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // decorative blobs
            FloatingBlobs(phase: breathe ? 1 : 0)
                .blendMode(.screen)
                .ignoresSafeArea()
                .opacity(0.34)
            
            // particle sparkle
            ParticleField()
                .ignoresSafeArea()
                .opacity(0.14)
            
            // THE TEXT (no tilt!)
            Text("Hello iOS!")
                .font(.system(size: 56, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(colors: [Color.purple, Color.blue, Color.cyan, Color.white],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
                .shadow(color: Color.purple.opacity(0.22), radius: 36, x: 0, y: 10)
                .shadow(color: Color.blue.opacity(0.14), radius: 80, x: 0, y: 20)
                .onAppear {
                    // gentle breathing just for vibe
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        breathe.toggle()
                    }
                }
        }
    }
}

// MARK: - Floating blobs (same decorative helpers)
fileprivate struct FloatingBlobs: View {
    var phase: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            ZStack {
                blob(at: CGPoint(x: geo.size.width * 0.18, y: geo.size.height * 0.16), size: 320, hue: 0.77, phaseShift: 0.0)
                blob(at: CGPoint(x: geo.size.width * 0.86, y: geo.size.height * 0.22), size: 220, hue: 0.55, phaseShift: 0.35)
                blob(at: CGPoint(x: geo.size.width * 0.62, y: geo.size.height * 0.78), size: 420, hue: 0.33, phaseShift: 0.8)
            }
            .blur(radius: 36)
            .opacity(0.95)
            .rotationEffect(.degrees(Double(phase * 18)))
        }
    }
    func blob(at point: CGPoint, size: CGFloat, hue: Double, phaseShift: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(gradient: Gradient(colors: [
                    Color(hue: hue, saturation: 0.9, brightness: 0.92),
                    Color(hue: hue + 0.06, saturation: 0.7, brightness: 0.55)
                ]), center: .center, startRadius: 10, endRadius: size * 0.6)
            )
            .frame(width: size, height: size)
            .position(x: point.x + CGFloat(sin((phase + phaseShift) * .pi * 2) * 40),
                      y: point.y + CGFloat(cos((phase + phaseShift) * .pi * 2) * 26))
            .opacity(0.95)
    }
}

// MARK: - Particle field via Canvas
fileprivate struct ParticleField: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for i in 0..<90 {
                    let angle = Double(i) * 23.7 + now * (0.04 + Double(i % 5) * 0.01)
                    let radius = 0.35 * min(size.width, size.height) * (0.18 + Double((i % 7)) * 0.06)
                    let x = size.width * 0.5 + CGFloat(cos(angle) * radius)
                    let y = size.height * 0.5 + CGFloat(sin(angle) * radius * 0.6)
                    let alpha = 0.08 + 0.6 * (0.5 + 0.5 * sin(now * (0.6 + Double(i % 3) * 0.2) + Double(i)))
                    let rect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 1.2, height: 1.2))
                    context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(Double(alpha * 0.1))))
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
