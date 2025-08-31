// ContentView.swift
// Hello iOS World! — tilts with real device motion (CoreMotion).
// Paste into your SwiftUI app. Test on a real device (iPad 8) — Simulator won't provide real motion.

import SwiftUI
import CoreMotion

// MARK: - Motion manager (ObservableObject)
final class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()
    
    // published smoothed angles (radians)
    @Published var pitch: Double = 0.0    // x-tilt
    @Published var roll: Double = 0.0     // y-tilt
    
    // smoothing (low-pass) state
    private var smoothPitch: Double = 0.0
    private var smoothRoll: Double = 0.0
    private let alpha: Double = 0.07 // smoothing strength (0..1) — lower = smoother
    
    init(updateHz: Double = 60) {
        manager.deviceMotionUpdateInterval = 1.0 / updateHz
        start()
    }
    
    deinit {
        stop()
    }
    
    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: queue) { [weak self] motion, _ in
            guard let self = self, let m = motion else { return }
            // pitch = rotation about x-axis. roll = rotation about y-axis.
            let rawPitch = m.attitude.pitch    // radians (-π..π)
            let rawRoll  = m.attitude.roll     // radians (-π..π)
            
            // low-pass filter (smooth jitter)
            self.smoothPitch = (self.alpha * rawPitch) + ((1 - self.alpha) * self.smoothPitch)
            self.smoothRoll  = (self.alpha * rawRoll)  + ((1 - self.alpha) * self.smoothRoll)
            
            // publish on main thread
            DispatchQueue.main.async {
                self.pitch = self.smoothPitch
                self.roll  = self.smoothRoll
            }
        }
    }
    
    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var motion = MotionManager()
    @State private var breathe = false
    
    // configurable limits and multipliers
    private let maxDegrees: Double = 14         // max tilt degrees on each axis
    private let responsiveness: Double = 1.0    // multiplier for how reactive it feels
    
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
            
            // THE TILTING TEXT
            Text("Hello iOS World!")
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
                // map pitch/roll to rotation3DEffect angles (degrees)
                .rotation3DEffect(
                    Angle(degrees: mappedPitchDegrees()),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.7
                )
                .rotation3DEffect(
                    Angle(degrees: mappedRollDegrees()),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.7
                )
                // subtle scale based on tilt magnitude
                .scaleEffect(1.0 + CGFloat(min(0.03, (abs(mappedPitchDegrees()) + abs(mappedRollDegrees())) / 800)))
                .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.75, blendDuration: 0.1), value: motion.pitch)
                .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.75, blendDuration: 0.1), value: motion.roll)
                .onAppear {
                    // gentle breathing when no/low motion (or just to look epic)
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        breathe.toggle()
                    }
                }
        }
    }
    
    // convert smoothed radians to clamped degrees with multiplier
    private func mappedPitchDegrees() -> Double {
        // pitch typically: + = nose up, - = nose down. invert if desired
        let degrees = motion.pitch * (180.0 / .pi) * responsiveness
        return clamp(degrees * -1.0, min: -maxDegrees, max: maxDegrees)
    }
    
    private func mappedRollDegrees() -> Double {
        let degrees = motion.roll * (180.0 / .pi) * responsiveness
        return clamp(degrees * 1.0, min: -maxDegrees, max: maxDegrees)
    }
    
    private func clamp(_ v: Double, min: Double, max: Double) -> Double {
        if v < min { return min }
        if v > max { return max }
        return v
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
