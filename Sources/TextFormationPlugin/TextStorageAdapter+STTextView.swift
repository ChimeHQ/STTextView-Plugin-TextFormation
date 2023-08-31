import AppKit
import Foundation

import STTextView
import TextStory
import TextFormation

extension STTextView {
	fileprivate var contentStorage: NSTextContentStorage? {
		textContentManager as? NSTextContentStorage
	}

	func applyMutation(_ mutation: TextMutation) {
		guard let contentStorage = contentStorage else { return }

		if let manager = undoManager {
			let inverse = contentStorage.inverseMutation(for: mutation)

			manager.registerUndo(withTarget: self, handler: {
				$0.applyMutation(inverse)
			})
		}

		contentStorage.applyMutation(mutation)

		didChangeText()
	}
}

extension TextStorageAdapter {
	@MainActor
	public convenience init(textView: STTextView) {
		self.init {
			// this works around a duplicate public 'length' method defined on NSTextContentStorage in STTextView
			(textView.contentStorage as TextStoring?)?.length ?? 0
		} substringProvider: { range in
			textView.contentStorage?.substring(from: range)
		} mutationApplier: { mutation in
			textView.applyMutation(mutation)
		}
	}
}

extension TextInterfaceAdapter {
	@MainActor
	public convenience init(textView: STTextView) {
		self.init(
			getSelection: { textView.selectedRange() },
			setSelection: { textView.setSelectedRange($0) },
			storage: TextStorageAdapter(textView: textView)
		)
	}
}
