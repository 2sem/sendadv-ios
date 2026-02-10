import TipKit
import SwiftUI

struct AddRuleTip: Tip {
    var title: Text {
        Text("title_add_rule_tip", bundle: .main)
    }

    var message: Text? {
        Text("message_add_rule_tip", bundle: .main)
    }

    // var image: Image? {
    //     Image(systemName: "plus.circle.fill")
    // }
}
