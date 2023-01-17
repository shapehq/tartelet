import SwiftUI

struct VirtualMachineCountPicker: View {
    @Binding var selection: Int

    var body: some View {
        Picker(L10n.Settings.VirtualMachine.count, selection: $selection) {
            ForEach(VirtualMachineCount.allCases) { count in
                Text(count.title).tag(count.rawValue)
            }
        }.pickerStyle(.segmented)
    }
}
