class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :admin_namespace?

  def admin_namespace?
    self.class.module_parent == Admin
  end

  def current_company
    @current_company ||= current_user.company if user_signed_in?
  end

  helper_method :current_company
end
