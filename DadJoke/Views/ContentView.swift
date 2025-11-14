//
//  ContentView.swift
//  DadJoke
//
//  Created by 윤주형 on 11/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject var viewModel: GagViewModel

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
                        .rotationEffect(.degrees(viewModel.isAnimating ? 360 : 0))

                    Text("아재개그")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.top, 60)

                Spacer()

                // 로딩 중이거나 개그 카드 영역
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                } else if viewModel.availableGags.isEmpty {
                    // 모든 개그를 확인한 경우
                    VStack(spacing: 20) {
                        Text("🎉")
                            .font(.system(size: 60))

                        Text("오늘의 모든 개그를 확인했습니다!")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("새로운 개그를 추가해주세요")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(40)
                } else {
                    // 개그 카드 영역 전체
                    VStack(spacing: 20) {
                        // 질문 카드
                        HStack(alignment: .top, spacing: 12) {
                            Text("Q.")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)

                            Text(viewModel.currentGag?.title ?? "개그를 불러올 수 없습니다")
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
                    if let content = viewModel.currentGag?.content, viewModel.isAnswerRevealed {
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
                    .scaleEffect(viewModel.isAnimating ? 1.05 : 1.0)
                }

                Spacer()

                // 버튼 영역 (로딩이 완료된 경우만)
                if !viewModel.isLoading {
                    VStack(spacing: 20) {
                    // 정답 확인 버튼 (답변이 숨겨져 있을 때만 표시)
                    if !viewModel.isAnswerRevealed && viewModel.currentGag != nil {
                        Button(action: {
                            viewModel.revealAnswer()
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
                        viewModel.moveToNextGag()
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
                        ActionButton(icon: "heart", color: .pink, isActive: viewModel.isLiked) {
                            viewModel.toggleLike()
                        }
                        ActionButton(icon: "square.and.arrow.up", color: .blue, isActive: false) {
                            // 추후 공유하기 추가
                        }

                        // 북마크 버튼
                        Button(action: {
                            viewModel.toggleBookmark()
                        }) {
                            Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 22))
                                .foregroundColor(.yellow)
                                .frame(width: 60, height: 60)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .task {
            await viewModel.fetchGags()
        }
    }
}

// 하단 액션 버튼 컴포넌트
struct ActionButton: View {
    let icon: String
    let color: Color
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // 액션 추가 예정
            Image(systemName: isActive ? "\(icon).fill" : icon)
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
    ContentView(viewModel: GagViewModel())
}
