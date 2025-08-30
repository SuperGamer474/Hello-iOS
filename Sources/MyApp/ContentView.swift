// ContentView.swift
// Very cool "Hello iOS World" page — big style, animated, glassy vibes!
// Paste into your SwiftUI app. Enjoy! 🎨🚀

import SwiftUI

struct ContentView: View {
    @State private var bgAnimate = false
    @State private var floatPhase: CGFloat = 0
    @State private var shake = false
    @State private var tapped = false

    var body: some View {
        ZStack {
            animatedBackground
                .ignoresSafeArea()

            // floating decorative blobs behind content
            FloatingBlobs(phase: floatPhase)
                .allowsHitTesting(false)

            VStack(spacing: 28) {
                header
                glassCard
                footer
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: true)) {
                bgAnimate.toggle()
            }
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                floatPhase = 1
            }
        }
    }

    // MARK: - Components

    private var animatedBackground: some View {
        // moving multi-stop gradient
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.12, green: 0.03, blue: 0.25), location: 0.0),
                .init(color: Color(red: 0.35, green: 0.07, blue: 0.65), location: 0.35),
                .init(color: Color(red: 0.03, green: 0.40, blue: 0.60), location: 0.65),
                .init(color: Color(red: 0.02, green: 0.18, blue: 0.11), location: 1.0),
            ]),
            startPoint: bgAnimate ? .topLeading : .bottomTrailing,
            endPoint: bgAnimate ? .bottomTrailing : .topLeading
        )
        .overlay {
            // subtle starry noise using many tiny circles
            StarsOverlay()
                .blendMode(.screen)
                .opacity(0.08)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            // neon "Hello, iOS World!" headline
            Text("Hello, iOS World!")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [Color.purple, Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing)
                )
                .shadow(color: Color.purple.opacity(0.35), radius: 18, x: 0, y: 8)
                .overlay(
                    Text("Hello, iOS World!")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .strokeStyle(lineWidth: 0.8)
                        .blendMode(.overlay)
                )
                .padding(.top, 6)

            Text("A flashy demo page to flex your unsigned IPA ✨")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
        }
        .multilineTextAlignment(.center)
    }

    private var glassCard: some View {
        ZStack {
            // glassy rounded card
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 8)

            VStack(spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    // icon badge
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 64, height: 64)
                            .shadow(color: Color.purple.opacity(0.35), radius: 12, x: 0, y: 6)

                        Image(systemName: "sparkles")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(10))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        // user-provided strings, glamorised
                        Text("Unsigned IPA built by GitHub Actions 🚀")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Re-sign me later 😉")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    Spacer()
                }

                Divider().background(Color.white.opacity(0.08))

                // fun status + controls
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Label {
                            Text("Build Status")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.85))
                        } icon: {
                            Circle().frame(width: 10, height: 10).foregroundColor(.green)
                        }

                        Text("Build succeeded — 1m 30s")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button(action: {
                        // playful wiggle + temporary state
                        withAnimation(.interpolatingSpring(stiffness: 260, damping: 6)) {
                            tapped.toggle()
                            shake.toggle()
                        }
                        // revert after tiny delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                shake = false
                                tapped = false
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text(tapped ? "Queued..." : "Re-sign")
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
                                .shadow(color: Color.blue.opacity(0.35), radius: 8, x: 0, y: 6)
                        )
                        .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .rotationEffect(.degrees(shake ? 6 : 0))
                    .offset(x: shake ? -6 : 0)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: 760)
        .frame(minHeight: 170)
        .scaleEffect(tapped ? 0.995 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: tapped)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Label {
                Text("Made with SwiftUI")
                    .font(.footnote)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "swift")
                    .symbolRenderingMode(.multicolor)
                    .font(.title3)
            }
            Spacer()
            HStack(spacing: 14) {
                Image(systemName: "hammer.fill")
                Image(systemName: "sparkles")
                Image(systemName: "paperplane.fill")
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.9))
        }
        .foregroundColor(.white.opacity(0.8))
        .padding(.horizontal, 6)
    }
}

// MARK: - Floating Blobs (decorative)
fileprivate struct FloatingBlobs: View {
    var phase: CGFloat // 0 -> 1 (animated)
    var body: some View {
        GeometryReader { geo in
            ZStack {
                blob(at: CGPoint(x: geo.size.width * 0.12, y: geo.size.height * 0.18), size: 220, hue: 0.74, phaseShift: 0.0)
                blob(at: CGPoint(x: geo.size.width * 0.85, y: geo.size.height * 0.22), size: 160, hue: 0.56, phaseShift: 0.4)
                blob(at: CGPoint(x: geo.size.width * 0.6, y: geo.size.height * 0.78), size: 300, hue: 0.35, phaseShift: 0.8)
            }
            .opacity(0.28)
            .blur(radius: 28)
            .rotationEffect(.degrees(Double(phase * 20)))
        }
    }

    func blob(at point: CGPoint, size: CGFloat, hue: Double, phaseShift: CGFloat) -> some View {
        let offsetX = (sin((phase + phaseShift) * .pi * 2) * 30)
        let offsetY = (cos((phase + phaseShift) * .pi * 2) * 18)
        return Circle()
            .fill(
                LinearGradient(colors: [
                    Color(hue: hue, saturation: 0.85, brightness: 0.9),
                    Color(hue: hue + 0.08, saturation: 0.75, brightness: 0.6)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .frame(width: size, height: size)
            .position(x: point.x + offsetX, y: point.y + offsetY)
    }
}

// MARK: - Stars Overlay
fileprivate struct StarsOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                // draws many tiny sparkles
                for i in 0..<160 {
                    let x = CGFloat(i * 37 % Int(size.width))
                    let y = CGFloat((i * 73) % Int(size.height))
                    let rect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 1.0, height: 1.0))
                    context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(Double((i % 5) == 0 ? 0.9 : 0.14))))
                }
            }
        }
    }
}

// MARK: - small helper for stroke overlay
fileprivate extension View {
    func strokeStyle(lineWidth: CGFloat = 1.0) -> some View {
        self.overlay(
            self
                .foregroundColor(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.06), lineWidth: lineWidth)
                )
        )
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
