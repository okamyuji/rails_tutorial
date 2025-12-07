// app/javascript/controllers/flash_controller.js
// フラッシュメッセージを制御するStimulusコントローラ
// 自動消去、手動消去、アニメーションを実装します

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 値を定義
  static values = {
    autoDismiss: { type: Boolean, default: true },
    dismissAfter: { type: Number, default: 5000 }  // ミリ秒
  }
  
  // コントローラが接続されたときに呼ばれる
  connect() {
    // フェードインアニメーション
    this.element.classList.add('flash-enter')
    
    requestAnimationFrame(() => {
      this.element.classList.add('flash-enter-active')
    })
    
    // 自動消去が有効な場合はタイマーを設定
    if (this.autoDismissValue) {
      this.scheduleAutoDismiss()
    }
    
    // プログレスバーを表示（自動消去の場合）
    if (this.autoDismissValue) {
      this.showProgressBar()
    }
  }
  
  // コントローラが切断されたときに呼ばれる
  disconnect() {
    this.clearTimers()
  }
  
  // フラッシュメッセージを消去する
  dismiss() {
    this.clearTimers()
    
    // フェードアウトアニメーション
    this.element.classList.add('flash-leave')
    this.element.classList.add('flash-leave-active')
    
    // アニメーション完了後に要素を削除
    this.element.addEventListener('transitionend', () => {
      this.element.remove()
    }, { once: true })
    
    // フォールバック（トランジションが発火しない場合）
    setTimeout(() => {
      if (this.element.parentNode) {
        this.element.remove()
      }
    }, 300)
  }
  
  // 自動消去をスケジュール
  scheduleAutoDismiss() {
    this.dismissTimeout = setTimeout(() => {
      this.dismiss()
    }, this.dismissAfterValue)
  }
  
  // プログレスバーを表示
  showProgressBar() {
    const progressBar = document.createElement('div')
    progressBar.className = 'flash-progress'
    progressBar.style.animationDuration = `${this.dismissAfterValue}ms`
    this.element.appendChild(progressBar)
  }
  
  // マウスオーバー時に自動消去を一時停止
  pause() {
    if (this.autoDismissValue && this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
      
      // プログレスバーのアニメーションを一時停止
      const progressBar = this.element.querySelector('.flash-progress')
      if (progressBar) {
        progressBar.style.animationPlayState = 'paused'
      }
    }
  }
  
  // マウスアウト時に自動消去を再開
  resume() {
    if (this.autoDismissValue) {
      // プログレスバーのアニメーションを再開
      const progressBar = this.element.querySelector('.flash-progress')
      if (progressBar) {
        progressBar.style.animationPlayState = 'running'
      }
      
      // 残り時間で再スケジュール（簡易実装）
      this.scheduleAutoDismiss()
    }
  }
  
  // タイマーをクリア
  clearTimers() {
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
    }
  }
}

// 使用例:
// <div class="flash-message" 
//      data-controller="flash"
//      data-flash-auto-dismiss-value="true"
//      data-flash-dismiss-after-value="5000"
//      data-action="mouseenter->flash#pause mouseleave->flash#resume">
//   <span class="flash-content">Message here</span>
//   <button data-action="click->flash#dismiss">×</button>
// </div>
//
// CSS:
// .flash-enter { opacity: 0; transform: translateY(-20px); }
// .flash-enter-active { opacity: 1; transform: translateY(0); transition: all 0.3s; }
// .flash-leave { opacity: 1; }
// .flash-leave-active { opacity: 0; transform: translateY(-20px); transition: all 0.3s; }
// .flash-progress { 
//   position: absolute; bottom: 0; left: 0; height: 3px; 
//   background: currentColor; animation: progress linear forwards; 
// }
// @keyframes progress { from { width: 100%; } to { width: 0%; } }

