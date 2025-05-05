import SwiftUI

/// Кнопка для вызова файлового пикера, отображающая иконку документа.
struct FilePickerButton: View {
    // MARK: - Properties
    
    /// Действие, выполняемое при нажатии на кнопку.
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "doc.fill")
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 8))
        }
    }
}

// MARK: - Preview

#Preview {
    FilePickerButton(action: { print("Button tapped") })
}
