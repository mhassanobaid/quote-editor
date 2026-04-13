class ApplicationController < ActionController::Base
  include Pundit
  before_action :authenticate_user!, unless: :admin_namespace?
  rescue_from Pundit::NotAuthorizedError do
    redirect_to root_path, alert: "You are not authorized"
  end

  def admin_namespace?
    params[:controller].start_with?("admin/") ||
    params[:controller].start_with?("active_admin/")
  end

  def current_company
    @current_company ||= current_user.company if user_signed_in?
  end

  helper_method :current_company
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
end
