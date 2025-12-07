// app/javascript/controllers/clipboard_controller.js
// クリップボードにテキストをコピーするStimulusコントローラ
// コピー成功/失敗のフィードバックを提供します

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ターゲット要素を定義
  static targets = ["source", "button", "feedback"]
  
  // 値を定義
  static values = {
    successMessage: { type: String, default: "Copied!" },
    errorMessage: { type: String, default: "Failed to copy" },
    feedbackDuration: { type: Number, default: 2000 }
  }
  
  // コントローラが接続されたときに呼ばれる
  connect() {
    // クリップボードAPIがサポートされているか確認
    if (!navigator.clipboard) {
      console.warn('Clipboard API not supported')
      this.disableCopy()
    }
  }
  
  // テキストをクリップボードにコピー
  async copy(event) {
    event.preventDefault()
    
    const text = this.getTextToCopy()
    
    if (!text) {
      this.showFeedback(false, 'No text to copy')
      return
    }
    
    try {
      await navigator.clipboard.writeText(text)
      this.showFeedback(true)
      this.dispatch("copied", { detail: { text } })
    } catch (err) {
      console.error('Failed to copy:', err)
      this.fallbackCopy(text)
    }
  }
  
  // コピーするテキストを取得
  getTextToCopy() {
    // sourceターゲットがある場合はその値を使用
    if (this.hasSourceTarget) {
      const source = this.sourceTarget
      
      // input/textareaの場合
      if (source.tagName === 'INPUT' || source.tagName === 'TEXTAREA') {
        return source.value
      }
      
      // その他の要素の場合はtextContentを使用
      return source.textContent.trim()
    }
    
    // data-clipboard-textがある場合はその値を使用
    const clipboardText = this.element.dataset.clipboardText
    if (clipboardText) {
      return clipboardText
    }
    
    return null
  }
  
  // フォールバック（古いブラウザ用）
  fallbackCopy(text) {
    const textArea = document.createElement('textarea')
    textArea.value = text
    textArea.style.position = 'fixed'
    textArea.style.left = '-9999px'
    textArea.style.top = '-9999px'
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()
    
    try {
      const successful = document.execCommand('copy')
      this.showFeedback(successful)
    } catch (err) {
      console.error('Fallback copy failed:', err)
      this.showFeedback(false)
    }
    
    document.body.removeChild(textArea)
  }
  
  // フィードバックを表示
  showFeedback(success, customMessage = null) {
    const message = customMessage || (success ? this.successMessageValue : this.errorMessageValue)
    
    // feedbackターゲットがある場合は更新
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = message
      this.feedbackTarget.classList.toggle('success', success)
      this.feedbackTarget.classList.toggle('error', !success)
      this.feedbackTarget.classList.add('visible')
      
      setTimeout(() => {
        this.feedbackTarget.classList.remove('visible')
      }, this.feedbackDurationValue)
    }
    
    // ボタンの状態を更新
    if (this.hasButtonTarget) {
      const originalText = this.buttonTarget.textContent
      this.buttonTarget.textContent = message
      this.buttonTarget.classList.add(success ? 'copied' : 'error')
      
      setTimeout(() => {
        this.buttonTarget.textContent = originalText
        this.buttonTarget.classList.remove('copied', 'error')
      }, this.feedbackDurationValue)
    }
  }
  
  // コピー機能を無効化
  disableCopy() {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true
      this.buttonTarget.title = 'Clipboard not supported'
    }
  }
  
  // テキストを選択（コピー前のハイライト用）
  select() {
    if (this.hasSourceTarget) {
      const source = this.sourceTarget
      
      if (source.tagName === 'INPUT' || source.tagName === 'TEXTAREA') {
        source.select()
      } else {
        const range = document.createRange()
        range.selectNodeContents(source)
        const selection = window.getSelection()
        selection.removeAllRanges()
        selection.addRange(range)
      }
    }
  }
}

// 使用例:
// <div data-controller="clipboard"
//      data-clipboard-success-message-value="Copied to clipboard!"
//      data-clipboard-feedback-duration-value="3000">
//   
//   <!-- コピー元 -->
//   <code data-clipboard-target="source">npm install my-package</code>
//   
//   <!-- コピーボタン -->
//   <button data-clipboard-target="button"
//           data-action="click->clipboard#copy">
//     Copy
//   </button>
//   
//   <!-- フィードバック表示 -->
//   <span data-clipboard-target="feedback" class="clipboard-feedback"></span>
// </div>
//
// または、data属性でテキストを指定:
// <button data-controller="clipboard"
//         data-clipboard-text="Text to copy"
//         data-action="click->clipboard#copy">
//   Copy
// </button>

