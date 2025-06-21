import FoundationModels
import SwiftUI


@Observable
class PaymentsProvider {
    let session: LanguageModelSession
    
    init() {
        let instructions = "Your job to provide sis to help the use parse scanned invoices"
        self.session = LanguageModelSession(instructions: instructions)
    }
}
