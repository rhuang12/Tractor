import SwiftUI

struct HistoryView: View {
    @State private var data = DataManager.shared.load()

    var body: some View {
        List {
            if data.transactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions",
                    systemImage: "clock",
                    description: Text("Your transaction history will appear here")
                )
            } else {
                ForEach(data.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .navigationTitle("History")
        .onAppear {
            data = DataManager.shared.load()
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            // Icon/emoji
            Group {
                if let note = transaction.note, (transaction.type == .redeem || transaction.type == .lapse) {
                    Text(String(note.prefix(2)))  // Get just the emoji
                        .font(.title2)
                } else {
                    Image(systemName: iconName)
                        .foregroundStyle(iconColor)
                        .font(.title2)
                }
            }
            .frame(width: 40)

            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(titleText)
                    .font(.headline)
                if transaction.type == .lapse, let note = transaction.note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(transaction.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            Text(amountText)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(amountColor)
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch transaction.type {
        case .add: return "plus.circle.fill"
        case .redeem: return "minus.circle.fill"
        case .lapse: return "arrow.counterclockwise.circle.fill"
        }
    }

    private var iconColor: Color {
        switch transaction.type {
        case .add: return .green
        case .redeem: return .orange
        case .lapse: return .blue
        }
    }

    private var titleText: String {
        switch transaction.type {
        case .add: return "Added"
        case .redeem: return "Redeemed"
        case .lapse: return "Lapsed"
        }
    }

    private var amountText: String {
        switch transaction.type {
        case .add, .lapse: return "+\(transaction.amount)"
        case .redeem: return "-\(transaction.amount)"
        }
    }

    private var amountColor: Color {
        switch transaction.type {
        case .add: return .green
        case .redeem: return .orange
        case .lapse: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
