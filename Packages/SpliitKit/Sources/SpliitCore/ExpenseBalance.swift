import SpliitAPI

/// Where a single expense leaves one participant: what they paid, less what their share of it
/// comes to.
///
/// The share comes from `ExpenseShares`, so these figures add up, expense by expense, to the
/// participant's total on the balances tab.
public enum ExpenseBalance {

    /// In the group's minor units: positive when the expense leaves the participant owed, negative
    /// when it leaves them owing, zero when they paid exactly their own share. Nil when they
    /// neither paid it nor were in it — not involved, which is a different thing from even.
    public static func of(_ participantID: String, in expense: ExpenseListItem) -> Int? {
        let shares = ExpenseShares.shares(
            expenseId: expense.id,
            amount: expense.amount,
            splitMode: expense.splitMode,
            paidFor: expense.paidFor.map {
                ExpenseDetails.PaidFor(participantId: $0.participant.id, shares: $0.shares)
            }
        )
        let share = shares[participantID]
        let didPay = expense.paidBy.id == participantID
        guard didPay || share != nil else { return nil }
        return (didPay ? expense.amount : 0) - (share ?? 0)
    }
}
