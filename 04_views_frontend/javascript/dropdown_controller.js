// app/javascript/controllers/dropdown_controller.js
// ドロップダウンメニューを制御するStimulusコントローラ

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  // メニューの表示/非表示を切り替える
  toggle(event) {
    event.preventDefault()
    this.menuTarget.classList.toggle("hidden")
  }
  
  // メニューを非表示にする
  hide(event) {
    // クリックされた要素がドロップダウンの外側の場合、メニューを閉じる
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
  
  // コントローラがDOMに接続されたときに呼ばれる
  connect() {
    // ドキュメント全体でクリックを監視
    this.hideHandler = this.hide.bind(this)
    document.addEventListener("click", this.hideHandler)
  }
  
  // コントローラがDOMから切断されたときに呼ばれる
  disconnect() {
    // イベントリスナーをクリーンアップ
    document.removeEventListener("click", this.hideHandler)
  }
}

// 使用例:
// <div data-controller="dropdown">
//   <button data-action="click->dropdown#toggle">Menu</button>
//   <div data-dropdown-target="menu" class="hidden">
//     <a href="#">Item 1</a>
//     <a href="#">Item 2</a>
//   </div>
// </div>
