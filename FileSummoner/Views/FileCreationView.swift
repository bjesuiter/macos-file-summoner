import SwiftUI

struct FileCreationView: View {
    @State private var filename: String = "newFile.txt"
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""

    let directoryPath: String
    let onCancel: () -> Void
    let onSuccess: (String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text("create_new_file")
                        .font(.headline)
                    Text(directoryPath)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.head)
                }

                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("filename_label")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("filename_placeholder", text: $filename)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        createFile()
                    }
            }

            if showingError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                    Spacer()
                }
            }

            Divider()

            HStack {
                Spacer()

                Button("button_cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button("button_create") {
                    createFile()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 420)
    }

    private func createFile() {
        guard let validatedFilename = FileService.validateFilename(filename) else {
            showError(NSLocalizedString("error_invalid_filename", comment: ""))
            return
        }

        let result = FileService.createFile(at: directoryPath, named: validatedFilename)

        switch result {
        case .success:
            onSuccess(validatedFilename)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}
