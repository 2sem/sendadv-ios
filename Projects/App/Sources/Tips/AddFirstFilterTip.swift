import TipKit
import SwiftUI

struct AddFirstFilterTip: Tip {
	var title: Text {
		Text("tip.addFilter.title".localized())
	}

	var message: Text? {
		Text("tip.addFilter.message".localized())
	}

	var image: Image? {
		Image(systemName: "plus.circle.fill")
	}
}
