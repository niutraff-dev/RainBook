import SwiftUI

struct Feature1DetailView: View {

    @ObservedObject var viewModel: Feature1DetailVM
    
    @State
    private var showDeleteAlert = false
    
    @FocusState
    private var isInputActive: Bool

    var body: some View {
        VStack {
            headerView()
            ScrollView {
                contentView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.palette(.backColor))
        .overlay(alignment: .bottom, content: buttonView)
        .navigationBarBackButtonHidden()
        .onTapGesture {
            isInputActive = false
        }
        .alert("Delete", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteAndClose()
            }
        } message: {
            Text("Are you sure you want to delete this?")
        }
    }

    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            Text(viewModel.isEditMode ? "Edit" : "Add Weather")
                .typography(.body.semibold)
                .foregroundStyle(Color.palette(.textPrimary))
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topLeading) {
            Button {
                viewModel.onBackTapped()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.palette(.black900))
                    .padding(.leading, 16)
            }
        }
    }

    @ViewBuilder
    private func weatherSection() -> some View {
        VStack(alignment: .leading) {
            Text("Weather")
                .foregroundStyle(Color.palette(.black900))
                .font(.system(size: 16, weight: .medium))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.weatherItems, id: \.iconName) { item in
                        Button {
                            viewModel.selectWeather(item)
                        } label: {
                            VStack(spacing: 4) {
                                Image(item.iconName)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                viewModel.weatherInfo.weather == item ? Color.palette(.blueColor) : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                                Text(item.name)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(Color.palette(.black900))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func contentView() -> some View {
        VStack(spacing: 16) {
            weatherSection()

            VStack(alignment: .leading) {
                Text("Rain fall (mm)")
                    .foregroundStyle(Color.palette(.black900))
                    .font(.system(size: 16, weight: .medium))

                HStack {
                    TextField("", text: Binding(
                        get: { viewModel.weatherInfo.rainFall },
                        set: { var c = viewModel.weatherInfo; c.rainFall = $0; viewModel.weatherInfo = c }
                    ))
                        .foregroundStyle(Color.palette(.textPrimary))
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .keyboardType(.decimalPad)
                        .focused($isInputActive)
                        .placeholder(
                            showPlaceHolder: viewModel.weatherInfo.rainFall.isEmpty,
                            placeholder: "Enter the amount of precipitation (mm)".localized()
                        )
                        .padding(.leading, 10)
                }
                .background(Color.palette(.white))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 16)

            dateSection()

            VStack(alignment: .leading) {
                Text("Notes")
                    .foregroundStyle(Color.palette(.black900))
                    .font(.system(size: 16, weight: .medium))

                HStack {
                    TextField("", text: Binding(
                        get: { viewModel.weatherInfo.notes },
                        set: { var c = viewModel.weatherInfo; c.notes = $0; viewModel.weatherInfo = c }
                    ))
                        .foregroundStyle(Color.palette(.textPrimary))
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .keyboardType(.default)
                        .focused($isInputActive)
                        .placeholder(
                            showPlaceHolder: viewModel.weatherInfo.notes.isEmpty,
                            placeholder: "Enter the note".localized()
                        )
                        .padding(.leading, 10)
                }
                .background(Color.palette(.white))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
        }
        .padding(.top)
        .padding(.bottom, 100)
    }

    @ViewBuilder
    private func dateSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .foregroundStyle(Color.palette(.black900))
                .font(.system(size: 16, weight: .medium))

            HStack {
               Text("Date")
                    .foregroundStyle(Color.palette(.darkBlackColor))
                
                Spacer()
                
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.weatherInfo.date },
                        set: { var c = viewModel.weatherInfo; c.date = $0; viewModel.weatherInfo = c }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(Color.palette(.blueColor))
                .foregroundStyle(Color.palette(.black900))
                .colorScheme(.light)
                
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.weatherInfo.time },
                        set: { var c = viewModel.weatherInfo; c.time = $0; viewModel.weatherInfo = c }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(Color.palette(.blueColor))
                .foregroundStyle(Color.palette(.black900))
                .colorScheme(.light)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.palette(.white))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func buttonView() -> some View {
        if !isInputActive {
            VStack(spacing: 12) {
                Button {
                    viewModel.saveAndClose()
                } label: {
                    HStack {
                        Image(.saveBtn)
                            .foregroundStyle(Color.palette(.white))
                        Text("Save")
                            .foregroundStyle(Color.palette(.white))
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color.palette(.blueColor))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.weatherInfo.isValid)

                if viewModel.isEditMode {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.palette(.error500))
                            Text("Delete")
                                .foregroundStyle(Color.palette(.error500))
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color.palette(.white))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.palette(.error500), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    NavigationStack {
        Feature1DetailView(viewModel: Feature1DetailVM(service: .init()))
    }
}
