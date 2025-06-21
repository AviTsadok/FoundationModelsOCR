# 🧾 Invoice Extraction Demo with Vision & Foundation Models

This is a lightweight iOS demo that shows how to extract structured data from an **invoice image** using the power of:

- 🔍 Apple's **Vision framework** for text recognition
- 🧠 **Foundation Models** for parsing structured data using on-device LLMs
- ✅ Safe and strongly typed output using `@Generable` and `@Guide`

---

## 📸 What It Does

This app demonstrates the end-to-end pipeline:

1. You provide or capture an image of an invoice
2. The app uses **Vision** to extract the printed text from the image
3. That raw text is sent into Apple’s on-device **Foundation Model**
4. The model returns structured data representing the invoice, using Swift types

---

## 📦 Output Model

The structured output is defined using the `@Generable` macro and `@Guide` descriptions to guide the LLM:

```swift
@Generable
struct InvoiceItem {
    var name: String
    var price: Decimal
    var quantity: Int
}

@Generable
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
