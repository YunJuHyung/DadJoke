//
//  AddGagView.swift
//  DadJoke
//
//  Created by Claude Code
//

import SwiftUI

struct AddGagView: View {
    @State private var title = ""
    @State private var content = ""
    @State private var selectedCategory = "동물"
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    let categories = ["동물", "음식", "일상", "말장난", "기타"]

    var body: some View {
        
        NavigationView {
            ZStack {
                // 노트 느낌 배경
                Color(#colorLiteral(red: 0.9882352941, green: 0.9490196078, blue: 0.8509803922, alpha: 1)) // 연한 베이지/크림색
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }

                ScrollView {
                    VStack(spacing: 25) {
                        // 안내 문구
                        VStack(spacing: 10) {
                            Text("😄")
                                .font(.system(size: 50))

                            Text("새로운 아재개그를 공유해주세요!")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)

                            Text("제출된 개그는 검토 후 추가됩니다")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 80)

                        // 입력 폼
                        VStack(spacing: 20) {
                            // 질문 입력
                            VStack(alignment: .leading, spacing: 8) {
                                Text("질문")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.brown)

                                TextEditor(text: $title)
                                    .frame(height: 100)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.brown.opacity(0.3), lineWidth: 1)
                                    )
                            }

                            // 답변 입력
                            VStack(alignment: .leading, spacing: 8) {
                                Text("답변")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.brown)

                                TextEditor(text: $content)
                                    .frame(height: 100)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.brown.opacity(0.3), lineWidth: 1)
                                    )
                            }

                            // 카테고리 선택
                            VStack(alignment: .leading, spacing: 8) {
                                Text("카테고리")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.brown)

                                Picker("카테고리", selection: $selectedCategory) {
                                    ForEach(categories, id: \.self) { category in
                                        Text(category).tag(category)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.white)
                                .cornerRadius(8)
                            }

                            // 제출 버튼
                            Button(action: {
                                submitGag()
                            }) {
                                HStack {
                                    if isSubmitting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                        Text("개그 제출하기")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                    }
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
                            .disabled(isSubmitting || title.isEmpty || content.isEmpty)
                            .opacity((isSubmitting || title.isEmpty || content.isEmpty) ? 0.6 : 1.0)
                            .padding(.top, 10)
                        }
                        .padding(25)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .alert("성공!", isPresented: $showSuccessAlert) {
                Button("확인", role: .cancel) {
                    // 입력 필드 초기화
                    title = ""
                    content = ""
                    selectedCategory = "동물"
                }
            } message: {
                Text("새로운 개그가 제출되었습니다!\n검토 후 추가될 예정입니다.")
            }
            .alert("오류", isPresented: $showErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func submitGag() {
        guard !title.isEmpty, !content.isEmpty else { return }

        Task {
            isSubmitting = true

            do {
                try await GagAPIService.shared.addGag(
                    title: title,
                    content: content,
                    category: selectedCategory
                )
                showSuccessAlert = true
            } catch {
                errorMessage = "개그 제출에 실패했습니다.\n\(error.localizedDescription)"
                showErrorAlert = true
            }

            isSubmitting = false
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddGagView()
}
