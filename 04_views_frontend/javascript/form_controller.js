// app/javascript/controllers/form_controller.js
// フォーム操作を制御するStimulusコントローラ
// 動的なフィールドの追加・削除、バリデーション、送信制御を実装します

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ターゲット要素を定義
  static targets = [
    "template",     // 新規フィールドのテンプレート
    "container",    // フィールドを追加するコンテナ
    "item",         // 各フィールドアイテム
    "submit",       // 送信ボタン
    "counter"       // アイテム数表示
  ]
  
  // 値を定義
  static values = {
    maxItems: { type: Number, default: 10 },
    minItems: { type: Number, default: 1 },
    confirmRemove: { type: Boolean, default: false }
  }
  
  // コントローラが接続されたときに呼ばれる
  connect() {
    this.updateCounter()
    this.updateRemoveButtons()
  }
  
  // 新しいフィールドを追加する
  add(event) {
    event.preventDefault()
    
    // 最大数に達している場合は追加しない
    if (this.itemTargets.length >= this.maxItemsValue) {
      this.showError(`Maximum ${this.maxItemsValue} items allowed`)
      return
    }
    
    // テンプレートから新しいフィールドを生成
    const template = this.templateTarget.innerHTML
    const uniqueId = new Date().getTime()
    const newContent = template.replace(/NEW_RECORD/g, uniqueId)
    
    // コンテナに追加
    this.containerTarget.insertAdjacentHTML('beforeend', newContent)
    
    // 新しく追加されたアイテムにフォーカス
    const newItem = this.containerTarget.lastElementChild
    const firstInput = newItem.querySelector('input, textarea, select')
    if (firstInput) {
      firstInput.focus()
    }
    
    this.updateCounter()
    this.updateRemoveButtons()
    
    // カスタムイベントを発火
    this.dispatch("added", { detail: { item: newItem } })
  }
  
  // フィールドを削除する
  remove(event) {
    event.preventDefault()
    
    // 最小数を下回る場合は削除しない
    if (this.itemTargets.length <= this.minItemsValue) {
      this.showError(`Minimum ${this.minItemsValue} item(s) required`)
      return
    }
    
    // 確認ダイアログ
    if (this.confirmRemoveValue) {
      if (!confirm('Are you sure you want to remove this item?')) {
        return
      }
    }
    
    // 削除対象のアイテムを取得
    const item = event.target.closest('[data-form-target="item"]')
    
    if (item) {
      // _destroyフィールドがある場合は値を設定（accepts_nested_attributes_for用）
      const destroyField = item.querySelector('input[name*="_destroy"]')
      if (destroyField) {
        destroyField.value = '1'
        item.style.display = 'none'
      } else {
        // 要素を完全に削除
        item.remove()
      }
      
      this.updateCounter()
      this.updateRemoveButtons()
      
      // カスタムイベントを発火
      this.dispatch("removed", { detail: { item: item } })
    }
  }
  
  // アイテム数を更新する
  updateCounter() {
    if (this.hasCounterTarget) {
      const visibleItems = this.itemTargets.filter(item => item.style.display !== 'none')
      this.counterTarget.textContent = visibleItems.length
    }
  }
  
  // 削除ボタンの状態を更新する
  updateRemoveButtons() {
    const visibleItems = this.itemTargets.filter(item => item.style.display !== 'none')
    const canRemove = visibleItems.length > this.minItemsValue
    
    visibleItems.forEach(item => {
      const removeBtn = item.querySelector('[data-action*="remove"]')
      if (removeBtn) {
        removeBtn.disabled = !canRemove
        removeBtn.classList.toggle('disabled', !canRemove)
      }
    })
    
    // 追加ボタンの状態も更新
    const addBtn = this.element.querySelector('[data-action*="add"]')
    if (addBtn) {
      const canAdd = visibleItems.length < this.maxItemsValue
      addBtn.disabled = !canAdd
      addBtn.classList.toggle('disabled', !canAdd)
    }
  }
  
  // フォーム送信前のバリデーション
  validate(event) {
    const visibleItems = this.itemTargets.filter(item => item.style.display !== 'none')
    
    // 各アイテムの必須フィールドをチェック
    let isValid = true
    visibleItems.forEach(item => {
      const requiredFields = item.querySelectorAll('[required]')
      requiredFields.forEach(field => {
        if (!field.value.trim()) {
          isValid = false
          field.classList.add('is-invalid')
        } else {
          field.classList.remove('is-invalid')
        }
      })
    })
    
    if (!isValid) {
      event.preventDefault()
      this.showError('Please fill in all required fields')
    }
    
    return isValid
  }
  
  // エラーメッセージを表示する
  showError(message) {
    // 既存のエラーメッセージを削除
    const existingError = this.element.querySelector('.form-controller-error')
    if (existingError) {
      existingError.remove()
    }
    
    // 新しいエラーメッセージを表示
    const errorDiv = document.createElement('div')
    errorDiv.className = 'form-controller-error alert alert-danger'
    errorDiv.textContent = message
    this.element.insertBefore(errorDiv, this.element.firstChild)
    
    // 3秒後に自動的に消す
    setTimeout(() => {
      errorDiv.remove()
    }, 3000)
  }
  
  // フォームをリセットする
  reset(event) {
    event.preventDefault()
    
    if (confirm('Are you sure you want to reset the form?')) {
      // 追加されたアイテムを削除（最小数を維持）
      const visibleItems = this.itemTargets.filter(item => item.style.display !== 'none')
      
      while (visibleItems.length > this.minItemsValue) {
        const item = visibleItems.pop()
        item.remove()
      }
      
      // 残ったアイテムの入力をクリア
      this.itemTargets.forEach(item => {
        const inputs = item.querySelectorAll('input, textarea, select')
        inputs.forEach(input => {
          if (input.type !== 'hidden') {
            input.value = ''
          }
        })
      })
      
      this.updateCounter()
      this.updateRemoveButtons()
      
      this.dispatch("reset")
    }
  }
}

// 使用例:
// <div data-controller="form" 
//      data-form-max-items-value="5"
//      data-form-min-items-value="1"
//      data-form-confirm-remove-value="true">
//   
//   <template data-form-target="template">
//     <div data-form-target="item" class="nested-fields">
//       <input type="text" name="article[images_attributes][NEW_RECORD][url]" required>
//       <input type="text" name="article[images_attributes][NEW_RECORD][caption]">
//       <input type="hidden" name="article[images_attributes][NEW_RECORD][_destroy]" value="0">
//       <button type="button" data-action="click->form#remove">Remove</button>
//     </div>
//   </template>
//   
//   <div data-form-target="container">
//     <!-- 既存のアイテムがここに表示される -->
//   </div>
//   
//   <p>Items: <span data-form-target="counter">0</span></p>
//   <button type="button" data-action="click->form#add">Add Item</button>
//   <button type="submit" data-action="click->form#validate">Save</button>
// </div>

