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
                if transaction.type == .redeem, let emoji = transaction.note {
                    Text(emoji)
                        .font(.title2)
                } else {
                    Image(systemName: transaction.type == .add ? "plus.circle.fill" : "minus.circle.fill")
                        .foregroundStyle(transaction.type == .add ? .green : .orange)
                        .font(.title2)
                }
            }
            .frame(width: 40)

            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.type == .add ? "Added" : "Redeemed")
                    .font(.headline)
                Text(transaction.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            Text(transaction.type == .add ? "+\(transaction.amount)" : "-\(transaction.amount)")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(transaction.type == .add ? .green : .orange)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
