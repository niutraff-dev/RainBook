import SwiftUI

struct Onboarding2View: View {

    @ObservedObject var viewModel: Onboarding2VM

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Image(.onb2)
                   
                VStack(spacing: 20) {
                    Text("onboarding.step2.title".localized())
                        .bold()
                        .font(.title)
                        .foregroundStyle(Color.palette(.black900))
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding.step2.description".localized())
                        .fontWeight(.regular)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.palette(.black900))
                        .multilineTextAlignment(.center)
                }
            }
          
            Spacer()

            Button {
                viewModel.onNextTapped()
            } label: {
                Text("onboarding.getStarted".localized())
                    .typography(.body.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.palette(.blueColor))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.palette(.backColor))
    }
}

#Preview {
    Onboarding2View(viewModel: Onboarding2VM())
}
