import Foundation
import FoundationModels

@Generable()
struct InvoiceItem {
    var name: String
    var price: Decimal
    var quantity: Int
}

@Generable()
struct MyInvoice {
    @Guide(description: "The name of the vendor")
    var vendor: String
    @Guide(description: "List of the invoice items")
    var items: [InvoiceItem]
    @Guide(description: "total invoice amount")
    var totalAmount: Decimal
    
    var toString: String {
        "Vendor: \(vendor)\n" +
        "Items:\n" +
        items.map(\.name).joined(separator: "\n") +
        "------\n" +
        "\nTotal: \(totalAmount)"
    }
}
