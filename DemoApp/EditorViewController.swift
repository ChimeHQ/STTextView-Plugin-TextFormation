import AppKit

import STTextView
import TextFormation
import TextFormationPlugin

final class EditorViewController: NSViewController {

	private var textView: STTextView!

	override func loadView() {
		let scrollView = STTextView.scrollableTextView()
		self.textView = scrollView.documentView as? STTextView
		self.view = scrollView

		// a delegate must be set for plug ins to work
		textView.delegate = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.frame.size = CGSize(width: 500, height: 500)

		let filters = [
			StandardOpenPairFilter(open: "[", close: "]")
		]

		let providers = WhitespaceProviders(
			leadingWhitespace: WhitespaceProviders.passthroughProvider,
			trailingWhitespace: WhitespaceProviders.removeAllProvider
		)

		textView.addPlugin(
			TextFormationPlugin(filters: filters, whitespaceProviders: providers)
		)

		textView.backgroundColor = .controlBackgroundColor
		textView.font = .monospacedSystemFont(ofSize: 0, weight: .regular)

		textView.string = """
		import Foundation

		func hello() {
			print("Hello World!")
		}
		"""
	}
}

extension EditorViewController: STTextViewDelegate {

}
