import AppKit
import Foundation

import STTextView
import TextStory
import TextFormation

private final class TextStoringAdapter: TextStoring {
	weak var textView: STTextView?

	var length: Int {
		MainActor.assumeIsolated {
			// this works around a duplicate public 'length' method defined on NSTextContentStorage in STTextView
			(textView?.contentStorage as TextStoring?)?.length ?? 0
		}
	}

	init(textView: STTextView) {
		self.textView = textView
	}

	func substring(from range: NSRange) -> String? {
		MainActor.assumeIsolated {
			textView?.contentStorage?.substring(from: range)
		}
	}

	func applyMutation(_ mutation: TextStory.TextMutation) {
		MainActor.assumeIsolated {
			guard let textView, let contentStorage = textView.contentStorage else {
				return
			}

			if let manager = textView.undoManager {
				let inverse = contentStorage.inverseMutation(for: mutation)

				manager.registerUndo(withTarget: self, handler: { adapter in
					contentStorage.performEditingTransaction {
						adapter.applyMutation(inverse)
					}
				})
			}

			textView.textWillChange(nil)

			contentStorage.performEditingTransaction {
				contentStorage.applyMutation(mutation)
			}

			textView.didChangeText()
		}
	}
}

private extension STTextView {
	var contentStorage: NSTextContentStorage? {
		textContentManager as? NSTextContentStorage
	}
}

extension TextInterfaceAdapter {

	@MainActor
	public convenience init(textView: STTextView) {
		self.init(
            getSelection: { textView.textSelection },
            setSelection: { textView.textSelection = $0 },
			storage: TextStoringAdapter(textView: textView)
		)
	}
}

