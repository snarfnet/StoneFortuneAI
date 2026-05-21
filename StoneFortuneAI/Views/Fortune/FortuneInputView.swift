import SwiftUI

struct FortuneInputView: View {
    @ObservedObject var viewModel: FortuneViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Text("🔮")
                        .font(.system(size: 64))
                    Text("石占い")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Text("Crystal Fortune Reading")
                        .font(.subheadline).italic()
                        .foregroundColor(Color(hex: Constants.Colors.accent).opacity(0.8))
                    Text("あなたに響くパワーストーンを見つけよう")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                // Name input
                VStack(alignment: .leading, spacing: 8) {
                    Label("お名前（任意）", systemImage: "person")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: Constants.Colors.accent))

                    TextField("名前を入力...", text: $viewModel.input.name)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)

                // Birthdate
                VStack(alignment: .leading, spacing: 8) {
                    Label("生年月日", systemImage: "calendar")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: Constants.Colors.accent))

                    DatePicker(
                        "",
                        selection: $viewModel.input.birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .colorScheme(.dark)
                }
                .padding(.horizontal, 20)

                // Concern category
                VStack(alignment: .leading, spacing: 12) {
                    Label("お悩みカテゴリ", systemImage: "heart.text.square")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: Constants.Colors.accent))
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(ConcernCategory.allCases) { category in
                            ConcernButton(
                                category: category,
                                isSelected: viewModel.input.concern == category
                            ) {
                                viewModel.input.concern = category
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Fortune button
                Button(action: { viewModel.performFortune() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.body.bold())
                        Text("占う✨")
                            .font(.headline.bold())
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: Constants.Colors.accent),
                                Color(hex: "#F0C040")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(hex: Constants.Colors.accent).opacity(0.5),
                            radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - ConcernButton
private struct ConcernButton: View {
    let category: ConcernCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(category.emoji)
                    .font(.title2)
                Text(category.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isSelected
                    ? Color(hex: Constants.Colors.accent).opacity(0.3)
                    : Color.white.opacity(0.08)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? Color(hex: Constants.Colors.accent) : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(14)
        }
    }
}
