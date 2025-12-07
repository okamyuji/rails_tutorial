// app/javascript/controllers/counter_controller.js
// カウンターを制御するStimulusコントローラ
// 値の増減とリアクティブな更新を実装します

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ターゲット要素を定義
  static targets = ["count", "display"]
  
  // 値を定義（HTMLのdata属性から取得）
  static values = {
    count: { type: Number, default: 0 },
    min: { type: Number, default: 0 },
    max: { type: Number, default: 100 },
    step: { type: Number, default: 1 }
  }
  
  // コントローラが接続されたときに呼ばれる
  connect() {
    this.updateDisplay()
  }
  
  // カウントを増加させる
  increment() {
    if (this.countValue < this.maxValue) {
      this.countValue += this.stepValue
    }
  }
  
  // カウントを減少させる
  decrement() {
    if (this.countValue > this.minValue) {
      this.countValue -= this.stepValue
    }
  }
  
  // カウントをリセットする
  reset() {
    this.countValue = this.minValue
  }
  
  // カウントを特定の値に設定する
  setCount(event) {
    const newValue = parseInt(event.target.value, 10)
    if (!isNaN(newValue)) {
      this.countValue = Math.max(this.minValue, Math.min(this.maxValue, newValue))
    }
  }
  
  // 値が変更されたときに自動的に呼ばれる（Stimulus Value機能）
  countValueChanged() {
    this.updateDisplay()
    
    // カスタムイベントを発火（他のコンポーネントに通知）
    this.dispatch("changed", { detail: { count: this.countValue } })
  }
  
  // 表示を更新する
  updateDisplay() {
    // displayターゲットがある場合は更新
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = this.countValue
    }
    
    // countターゲットがある場合も更新（input要素用）
    if (this.hasCountTarget) {
      this.countTarget.value = this.countValue
    }
    
    // 境界値に達した場合のスタイル変更
    this.updateBoundaryStyles()
  }
  
  // 境界値に達した場合のスタイルを更新
  updateBoundaryStyles() {
    const atMin = this.countValue <= this.minValue
    const atMax = this.countValue >= this.maxValue
    
    // 増減ボタンの無効化
    const decrementBtn = this.element.querySelector('[data-action*="decrement"]')
    const incrementBtn = this.element.querySelector('[data-action*="increment"]')
    
    if (decrementBtn) {
      decrementBtn.disabled = atMin
      decrementBtn.classList.toggle('disabled', atMin)
    }
    
    if (incrementBtn) {
      incrementBtn.disabled = atMax
      incrementBtn.classList.toggle('disabled', atMax)
    }
  }
}

// 使用例:
// <div data-controller="counter" 
//      data-counter-count-value="0"
//      data-counter-min-value="0"
//      data-counter-max-value="10"
//      data-counter-step-value="1">
//   <button data-action="click->counter#decrement">-</button>
//   <span data-counter-target="display">0</span>
//   <button data-action="click->counter#increment">+</button>
//   <button data-action="click->counter#reset">Reset</button>
// </div>
//
// または入力フィールド付き:
// <div data-controller="counter" data-counter-count-value="5">
//   <input type="number" 
//          data-counter-target="count"
//          data-action="input->counter#setCount">
// </div>

