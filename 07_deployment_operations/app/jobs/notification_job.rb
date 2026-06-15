# NotificationJob
# 記事の公開通知などを非同期で送信するジョブです。
# Solid Queueで実行されます。
class NotificationJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(user, message)
    NotificationMailer.with(user: user, message: message).notify.deliver_now
  end
end
