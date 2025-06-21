import SwiftUI
import FoundationModels
import PhotosUI

struct ContentView: View {
    @State private var reply: String = ""
    private let provider = PaymentsProvider()
    
    // New state variables for image picking
    @State private var pickedImage: Image? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var pickedUIImage: UIImage? = nil
    private let ocrScanner = OCRScanner()
    
    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Pick an image", systemImage: "photo")
            }
            .onChange(of: selectedPhoto) { oldValue, newValue in
                guard let item = newValue else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        pickedUIImage = uiImage
                        pickedImage = Image(uiImage: uiImage)
                        // Run OCR
                        do {
                            reply = "Detecting invoice..."
                            let json = try await ocrScanner.scanInvoice(from: uiImage)
                            let prompt = """
                            The following is data extracted from an invoice image using OCR. Each item in the JSON array contains a recognized word with its text and its normalized (0–1) x, y position in the image.

                            Your task is to analyze this data and extract key invoice information such as:
                            - Supplier Name
                            - Invoice Date
                            - Invoice Number
                            - Line Items (description, quantity, unit price, total)
                            - Subtotal, Tax, Total Amount

                            Use the position data to help associate text into fields and rows. If possible, return a structured Swift dictionary or JSON object with these fields.

                            Here is the OCR data:
                            """ + json
                            reply = "Performing LLM task..."
                            let response = try await provider.session.respond(to: prompt, generating: MyInvoice.self)
                            reply = response.content.toString
                        } catch {
                            reply = error.localizedDescription
                        }
                    }
                }
            }
            
            ScrollView {
                
                // Display picked image if any
                if let pickedImage = pickedImage {
                    pickedImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.vertical)
                }
                
                Text(reply)
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
