// app/javascript/controllers/autosubmit_controller.js
// フォームを自動送信するStimulusコントローラ
// ユーザーが入力を停止してから指定時間後に自動的にフォームを送信します

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 500 }  // デフォルトの遅延時間（ミリ秒）
  }
  
  // ユーザーが入力するたびに呼ばれる
  submit() {
    // 既存のタイマーをクリア
    clearTimeout(this.timeout)
    
    // 新しいタイマーを設定
    this.timeout = setTimeout(() => {
      // 指定時間後にフォームを送信
      this.element.requestSubmit()
    }, this.delayValue)
  }
  
  // コントローラが切断されるときにタイマーをクリーンアップ
  disconnect() {
    clearTimeout(this.timeout)
  }
}

// 使用例:
// <form data-controller="autosubmit" data-autosubmit-delay-value="1000">
//   <input type="text" 
//          name="q" 
//          data-action="input->autosubmit#submit"
//          placeholder="Search...">
// </form>
//
// この例では、ユーザーが1秒間入力を停止するとフォームが自動送信されます
