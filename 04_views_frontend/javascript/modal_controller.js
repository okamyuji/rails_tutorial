// app/javascript/controllers/modal_controller.js
// モーダルダイアログを制御するStimulusコントローラ
// 開閉、キーボード操作、フォーカストラップを実装します

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ターゲット要素を定義
  static targets = ["dialog", "backdrop", "content", "closeButton"]
  
  // 値を定義
  static values = {
    open: { type: Boolean, default: false },
    closeOnBackdrop: { type: Boolean, default: true },
    closeOnEscape: { type: Boolean, default: true }
  }
  
  // コントローラが接続されたときに呼ばれる
  connect() {
    // キーボードイベントのハンドラをバインド
    this.handleKeydown = this.handleKeydown.bind(this)
    
    // 初期状態を設定
    if (this.openValue) {
      this.show()
    }
  }
  
  // コントローラが切断されたときに呼ばれる
  disconnect() {
    // イベントリスナーをクリーンアップ
    document.removeEventListener('keydown', this.handleKeydown)
    this.enableBodyScroll()
  }
  
  // モーダルを表示する
  show(event) {
    if (event) {
      event.preventDefault()
    }
    
    this.openValue = true
    
    // モーダル要素を表示
    if (this.hasDialogTarget) {
      this.dialogTarget.classList.remove('hidden')
      this.dialogTarget.setAttribute('aria-hidden', 'false')
    }
    
    // バックドロップを表示
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove('hidden')
    }
    
    // ボディのスクロールを無効化
    this.disableBodyScroll()
    
    // キーボードイベントを監視
    document.addEventListener('keydown', this.handleKeydown)
    
    // フォーカスをモーダル内に移動
    this.trapFocus()
    
    // カスタムイベントを発火
    this.dispatch("opened")
  }
  
  // モーダルを非表示にする
  hide(event) {
    if (event) {
      event.preventDefault()
    }
    
    this.openValue = false
    
    // モーダル要素を非表示
    if (this.hasDialogTarget) {
      this.dialogTarget.classList.add('hidden')
      this.dialogTarget.setAttribute('aria-hidden', 'true')
    }
    
    // バックドロップを非表示
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add('hidden')
    }
    
    // ボディのスクロールを有効化
    this.enableBodyScroll()
    
    // キーボードイベントの監視を停止
    document.removeEventListener('keydown', this.handleKeydown)
    
    // トリガー要素にフォーカスを戻す
    if (this.triggerElement) {
      this.triggerElement.focus()
    }
    
    // カスタムイベントを発火
    this.dispatch("closed")
  }
  
  // モーダルの表示/非表示を切り替える
  toggle(event) {
    if (event) {
      this.triggerElement = event.currentTarget
    }
    
    if (this.openValue) {
      this.hide(event)
    } else {
      this.show(event)
    }
  }
  
  // バックドロップクリック時の処理
  backdropClick(event) {
    // コンテンツ部分のクリックは無視
    if (this.hasContentTarget && this.contentTarget.contains(event.target)) {
      return
    }
    
    // closeOnBackdropが有効な場合のみ閉じる
    if (this.closeOnBackdropValue) {
      this.hide(event)
    }
  }
  
  // キーボードイベントの処理
  handleKeydown(event) {
    // Escapeキーで閉じる
    if (event.key === 'Escape' && this.closeOnEscapeValue) {
      this.hide()
    }
    
    // Tabキーでフォーカストラップ
    if (event.key === 'Tab') {
      this.handleTabKey(event)
    }
  }
  
  // Tabキーの処理（フォーカストラップ）
  handleTabKey(event) {
    const focusableElements = this.getFocusableElements()
    
    if (focusableElements.length === 0) {
      event.preventDefault()
      return
    }
    
    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]
    
    // Shift+Tabで最初の要素から離れようとした場合
    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault()
      lastElement.focus()
    }
    // Tabで最後の要素から離れようとした場合
    else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault()
      firstElement.focus()
    }
  }
  
  // フォーカス可能な要素を取得
  getFocusableElements() {
    const selector = [
      'a[href]',
      'button:not([disabled])',
      'input:not([disabled])',
      'textarea:not([disabled])',
      'select:not([disabled])',
      '[tabindex]:not([tabindex="-1"])'
    ].join(', ')
    
    const container = this.hasContentTarget ? this.contentTarget : this.element
    return Array.from(container.querySelectorAll(selector))
  }
  
  // フォーカスをモーダル内にトラップ
  trapFocus() {
    const focusableElements = this.getFocusableElements()
    
    if (focusableElements.length > 0) {
      // 閉じるボタンがあれば優先、なければ最初のフォーカス可能要素
      if (this.hasCloseButtonTarget) {
        this.closeButtonTarget.focus()
      } else {
        focusableElements[0].focus()
      }
    }
  }
  
  // ボディのスクロールを無効化
  disableBodyScroll() {
    this.previousOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'
  }
  
  // ボディのスクロールを有効化
  enableBodyScroll() {
    document.body.style.overflow = this.previousOverflow || ''
  }
  
  // openValueが変更されたときに呼ばれる
  openValueChanged() {
    if (this.openValue) {
      this.show()
    } else {
      this.hide()
    }
  }
}

// 使用例:
// <div data-controller="modal" 
//      data-modal-close-on-backdrop-value="true"
//      data-modal-close-on-escape-value="true">
//   
//   <!-- トリガーボタン -->
//   <button data-action="click->modal#toggle">Open Modal</button>
//   
//   <!-- モーダルダイアログ -->
//   <div data-modal-target="dialog" 
//        class="hidden fixed inset-0 z-50"
//        aria-hidden="true"
//        role="dialog"
//        aria-modal="true">
//     
//     <!-- バックドロップ -->
//     <div data-modal-target="backdrop"
//          data-action="click->modal#backdropClick"
//          class="fixed inset-0 bg-black bg-opacity-50"></div>
//     
//     <!-- コンテンツ -->
//     <div data-modal-target="content"
//          class="relative bg-white rounded-lg p-6 mx-auto mt-20 max-w-lg">
//       <button data-modal-target="closeButton"
//               data-action="click->modal#hide"
//               class="absolute top-4 right-4">×</button>
//       <h2>Modal Title</h2>
//       <p>Modal content goes here...</p>
//     </div>
//   </div>
// </div>

