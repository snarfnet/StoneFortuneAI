import SwiftUI

struct FortuneView: View {
    @StateObject var viewModel = FortuneViewModel()

    var body: some View {
        ZStack {
            GradientBackground()

            if viewModel.showResult {
                FortuneResultView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity
                    ))
            } else {
                FortuneInputView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.showResult)
    }
}
