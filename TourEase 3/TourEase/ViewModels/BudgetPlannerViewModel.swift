import Foundation
import SwiftData
import Observation

@Observable
final class BudgetPlannerViewModel {
    var input = BudgetInput()
    var tripLabel: String = ""
    var breakdown: BudgetBreakdown
    var didSave = false
    var saveError: String?

    private let calculator: BudgetCalculating

    init(calculator: BudgetCalculating = DefaultBudgetCalculator()) {
        self.calculator = calculator
        // Use a fresh BudgetInput() (same value `input`'s default holds)
        // rather than reading `self.input` here — the @Observable macro
        // backs stored properties with an observation registrar, so
        // touching `self.input` before every stored property is set
        // triggers "self used before all stored properties initialized."
        self.breakdown = calculator.calculate(BudgetInput())
    }

    /// Recomputed on every form change — the calculation is pure/cheap
    /// (no I/O), so there's no need to gate it behind a button.
    func recalculate() {
        breakdown = calculator.calculate(input)
        didSave = false
    }

    @MainActor
    func saveBudget(context: ModelContext) {
        let record = BudgetRecord(tripLabel: tripLabel, input: input, breakdown: breakdown)
        context.insert(record)
        do {
            try context.save()
            didSave = true
            saveError = nil
        } catch {
            saveError = "Couldn't save this budget. Try again."
        }
    }
}
