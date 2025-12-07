// app/javascript/controllers/tabs_controller.js
// タブナビゲーションを制御するStimulusコントローラ
// タブの切り替え、キーボードナビゲーション、URLハッシュ連携を実装します

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ターゲット要素を定義
  static targets = ["tab", "panel"]
  
  // 値を定義
  static values = {
    activeIndex: { type: Number, default: 0 },
    useHash: { type: Boolean, default: false }
  }
  
  // コントローラが接続されたときに呼ばれる
  connect() {
    // URLハッシュから初期タブを設定
    if (this.useHashValue) {
      const hash = window.location.hash.slice(1)
      const hashIndex = this.findTabIndexByHash(hash)
      if (hashIndex >= 0) {
        this.activeIndexValue = hashIndex
      }
    }
    
    // 初期状態を設定
    this.showTab(this.activeIndexValue)
    
    // ハッシュ変更イベントを監視
    if (this.useHashValue) {
      this.handleHashChange = this.handleHashChange.bind(this)
      window.addEventListener('hashchange', this.handleHashChange)
    }
  }
  
  // コントローラが切断されたときに呼ばれる
  disconnect() {
    if (this.useHashValue) {
      window.removeEventListener('hashchange', this.handleHashChange)
    }
  }
  
  // タブをクリックしたときの処理
  select(event) {
    event.preventDefault()
    
    const tab = event.currentTarget
    const index = this.tabTargets.indexOf(tab)
    
    if (index >= 0) {
      this.activeIndexValue = index
    }
  }
  
  // キーボードナビゲーション
  keydown(event) {
    let newIndex = this.activeIndexValue
    
    switch (event.key) {
      case 'ArrowLeft':
      case 'ArrowUp':
        event.preventDefault()
        newIndex = this.activeIndexValue - 1
        if (newIndex < 0) {
          newIndex = this.tabTargets.length - 1
        }
        break
        
      case 'ArrowRight':
      case 'ArrowDown':
        event.preventDefault()
        newIndex = this.activeIndexValue + 1
        if (newIndex >= this.tabTargets.length) {
          newIndex = 0
        }
        break
        
      case 'Home':
        event.preventDefault()
        newIndex = 0
        break
        
      case 'End':
        event.preventDefault()
        newIndex = this.tabTargets.length - 1
        break
        
      default:
        return
    }
    
    this.activeIndexValue = newIndex
    this.tabTargets[newIndex].focus()
  }
  
  // activeIndexValueが変更されたときに呼ばれる
  activeIndexValueChanged() {
    this.showTab(this.activeIndexValue)
    
    // URLハッシュを更新
    if (this.useHashValue) {
      const tab = this.tabTargets[this.activeIndexValue]
      const hash = tab.getAttribute('data-tabs-hash') || tab.id
      if (hash) {
        history.replaceState(null, null, `#${hash}`)
      }
    }
    
    // カスタムイベントを発火
    this.dispatch("changed", { detail: { index: this.activeIndexValue } })
  }
  
  // 指定されたインデックスのタブを表示
  showTab(index) {
    // すべてのタブとパネルを非アクティブに
    this.tabTargets.forEach((tab, i) => {
      const isActive = i === index
      
      // タブの状態を更新
      tab.classList.toggle('active', isActive)
      tab.setAttribute('aria-selected', isActive.toString())
      tab.setAttribute('tabindex', isActive ? '0' : '-1')
    })
    
    // パネルの表示/非表示を切り替え
    this.panelTargets.forEach((panel, i) => {
      const isActive = i === index
      
      panel.classList.toggle('hidden', !isActive)
      panel.setAttribute('aria-hidden', (!isActive).toString())
    })
  }
  
  // ハッシュからタブのインデックスを検索
  findTabIndexByHash(hash) {
    if (!hash) return -1
    
    return this.tabTargets.findIndex(tab => {
      return tab.getAttribute('data-tabs-hash') === hash || tab.id === hash
    })
  }
  
  // ハッシュ変更時の処理
  handleHashChange() {
    const hash = window.location.hash.slice(1)
    const index = this.findTabIndexByHash(hash)
    if (index >= 0) {
      this.activeIndexValue = index
    }
  }
  
  // 次のタブに移動
  next() {
    let newIndex = this.activeIndexValue + 1
    if (newIndex >= this.tabTargets.length) {
      newIndex = 0
    }
    this.activeIndexValue = newIndex
  }
  
  // 前のタブに移動
  previous() {
    let newIndex = this.activeIndexValue - 1
    if (newIndex < 0) {
      newIndex = this.tabTargets.length - 1
    }
    this.activeIndexValue = newIndex
  }
}

// 使用例:
// <div data-controller="tabs" 
//      data-tabs-active-index-value="0"
//      data-tabs-use-hash-value="true">
//   
//   <!-- タブリスト -->
//   <div role="tablist">
//     <button data-tabs-target="tab"
//             data-tabs-hash="overview"
//             data-action="click->tabs#select keydown->tabs#keydown"
//             role="tab"
//             aria-selected="true"
//             aria-controls="panel-overview">
//       Overview
//     </button>
//     <button data-tabs-target="tab"
//             data-tabs-hash="details"
//             data-action="click->tabs#select keydown->tabs#keydown"
//             role="tab"
//             aria-selected="false"
//             aria-controls="panel-details"
//             tabindex="-1">
//       Details
//     </button>
//     <button data-tabs-target="tab"
//             data-tabs-hash="settings"
//             data-action="click->tabs#select keydown->tabs#keydown"
//             role="tab"
//             aria-selected="false"
//             aria-controls="panel-settings"
//             tabindex="-1">
//       Settings
//     </button>
//   </div>
//   
//   <!-- タブパネル -->
//   <div data-tabs-target="panel" 
//        id="panel-overview" 
//        role="tabpanel">
//     Overview content...
//   </div>
//   <div data-tabs-target="panel" 
//        id="panel-details" 
//        role="tabpanel" 
//        class="hidden"
//        aria-hidden="true">
//     Details content...
//   </div>
//   <div data-tabs-target="panel" 
//        id="panel-settings" 
//        role="tabpanel" 
//        class="hidden"
//        aria-hidden="true">
//     Settings content...
//   </div>
// </div>

