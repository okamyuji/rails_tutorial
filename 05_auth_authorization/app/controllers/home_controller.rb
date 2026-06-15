class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    skip_authorization
    @articles = Article.published.includes(:user).recent.limit(5)
  end
end
