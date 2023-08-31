import AppKit
import Rearrange

extension NSTextParagraph {
	func attributedString(in range: NSTextRange) -> NSAttributedString? {
		guard
			let contentManager = textContentManager,
			let elementRange = elementRange,
			let overlappingRange = elementRange.intersection(range)
		else {
			return nil
		}

		// compute delta
		let length = contentManager.offset(from: elementRange.location, to: elementRange.endLocation)
		guard length > 0 else { return nil }

		let start = contentManager.offset(from: elementRange.location, to: overlappingRange.location)
		guard start >= 0 else { return nil }

		let end = contentManager.offset(from: elementRange.endLocation, to: overlappingRange.endLocation)
		guard end <= 0 else { return nil }

		let trimmedRange = NSRange(location: start, length: length + end)
		guard trimmedRange.length >= 0 else { return nil }

		return attributedString.attributedSubstring(from: trimmedRange)
	}
}

extension NSTextContentManager: TextStoring {
	public var length: Int {
		offset(from: documentRange.location, to: documentRange.endLocation)
	}

	public func applyMutation(_ mutation: TextMutation) {
		guard let range = NSTextRange(mutation.range, provider: self) else {
			return
		}

		// the documentation for NSTextContentManager claims that replaceContents(in:with:) should be used by NSTextLayoutManager only, but I'm going to give it a shot anyways, because it isn't clear how to do this generally any other way.
		performEditingTransaction {
			// pure delete
			if mutation.string.isEmpty {
				replaceContents(in: range, with: [])
				return
			}

			let element = NSTextParagraph(attributedString: NSAttributedString(string: mutation.string))

			replaceContents(in: range, with: [element])
		}
	}

	public func substring(from range: NSRange) -> String? {
		guard let textRange = NSTextRange(range, provider: self) else { return nil }

		let elements = textElements(for: textRange)

		guard elements.isEmpty == false else { return nil }


		var string = ""

		for element in textElements(for: textRange) {
			guard let element = element as? NSTextParagraph else { continue }

			if let value = element.attributedString(in: textRange) {
				string += value.string
			}
		}

		return string
	}
}

import Foundation

import STTextView
import TextStory
import TextFormation


extension STTextView {
	/// Applies a mutation to the underlying `textContentManager`.
	///
	/// This method looks pretty much identical to the version for `NSTextView`.
	func applyMutation(_ mutation: TextMutation) {
		if let manager = undoManager {
			let inverse = textContentManager.inverseMutation(for: mutation)

			manager.registerUndo(withTarget: self, handler: { $0.applyMutation(inverse) })
		}

		textContentManager.applyMutation(mutation)

		didChangeText()
	}
}

extension TextStorageAdapter {
	@MainActor
	public convenience init(textView: STTextView) {
		self.init {
			textView.textContentManager.length
		} substringProvider: { range in
			textView.textContentManager.substring(from: range)
		} mutationApplier: { mutation in
			textView.textContentManager.applyMutation(mutation)
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
