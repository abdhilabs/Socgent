import SwiftUI
import UIKit

struct SelectableTextView: UIViewRepresentable {
  @State var selectedText: String = ""
  
  var text: String
  var customActionTitle: String
  var onCustomAction: (String) -> Void
  
  func makeUIView(context: Context) -> UITextView {
    let view = UITextView()
    view.font = .systemFont(ofSize: 14)
    view.isEditable = false
    view.isSelectable = true
    view.isScrollEnabled = true
    view.backgroundColor = .clear
    view.delegate = context.coordinator
    return view
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
    uiView.isEditable = false
    uiView.isSelectable = true
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  final class Coordinator: NSObject, UITextViewDelegate {
    private var parent: SelectableTextView
    
    init(_ parent: SelectableTextView) {
      self.parent = parent
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
      let range = textView.selectedRange
      guard range.length > 0, let selected = (textView.text as NSString?)?.substring(with: range) else {
        return
      }
      parent.selectedText = selected
    }
    
    func textView(_ textView: UITextView,
                  editMenuForTextIn range: NSRange,
                  suggestedActions: [UIMenuElement]) -> UIMenu? {
      let title = parent.customActionTitle
      guard !title.isEmpty, !parent.selectedText.isEmpty else { return nil }
      let action = UIAction(title: title) { [weak textView] _ in
        guard let textView else { return }
        let selected = (textView.text as NSString).substring(with: range)
        self.parent.onCustomAction(selected)
      }
      var children = suggestedActions
      children.insert(action, at: 0)
      return UIMenu(title: "", options: .displayInline, children: children)
    }
  }
}
