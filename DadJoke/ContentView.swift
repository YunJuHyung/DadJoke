//
//  ContentView.swift
//  DadJoke
//
//  Created by 윤주형 on 11/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var gags: [Gag] = []
    @State private var currentGag: Gag?
    @State private var isAnswerRevealed = false
    @State private var isAnimating = false
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()  // 배경을 전체 화면으로 확장

            VStack(spacing: 40) {
                // 헤더
                VStack(spacing: 8) {
                    Text("😂")
                        .font(.system(size: 60))
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))

                    Text("아재개그")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.top, 60)

                Spacer()

                // 개그 카드 영역 전체
                VStack(spacing: 20) {
                    // 질문 카드
                    HStack(alignment: .top, spacing: 12) {
                        Text("Q.")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)

                        Text(currentGag?.title ?? "버튼을 눌러서\n아재개그를 확인하세요! 😄")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    )

                    // 답변 카드 (항상 표시)
                    if let content = currentGag?.content, isAnswerRevealed {
                        HStack(alignment: .top, spacing: 12) {
                            Text("A.")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)

                            Text(content)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )
                    }
                }
                .padding(.horizontal, 40)  // 양쪽 여백 증가
                .scaleEffect(isAnimating ? 1.05 : 1.0)

                Spacer()

                // 버튼 영역
                VStack(spacing: 20) {
                    // 정답 확인 버튼 (답변이 숨겨져 있을 때만 표시)
                    if !isAnswerRevealed && currentGag != nil {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isAnswerRevealed = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("정답 확인")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 40)
                    }

                    // 다음 개그 버튼
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isAnimating = true
                            isAnswerRevealed = false
                        }

                        currentGag = gags.randomElement()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                isAnimating = false
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("다음 개그")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)

                    // 하단 액션 버튼들
                    HStack(spacing: 15) {
                        ActionButton(icon: "heart", color: .pink)
                        ActionButton(icon: "square.and.arrow.up", color: .blue)
                        ActionButton(icon: "bookmark", color: .yellow)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
        .task {
            // MockGagAPIService를 통해 개그 데이터 로드
            do {
                let response = try await MockGagAPIService.shared.fetchGags()
                gags = response.gags
                currentGag = gags.randomElement()
            } catch {
                print("개그 데이터 로드 실패: \(error)")
            }
        }
    }
}

// 하단 액션 버튼 컴포넌트
struct ActionButton: View {
    let icon: String
    let color: Color

    var body: some View {
        Button(action: {
            // 액션 추가 예정
        }) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    ContentView()
}
