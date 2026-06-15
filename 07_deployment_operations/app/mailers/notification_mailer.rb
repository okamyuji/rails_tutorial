# NotificationMailer
# ユーザーへの通知メールを送信するメーラーです。
class NotificationMailer < ApplicationMailer
  def notify
    @user = params[:user]
    @message = params[:message]
    mail(to: @user.email, subject: @message)
  end
end
