class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Add CSRF protection
  protect_from_forgery with: :exception
  
  # Skip CSRF for API requests
  skip_before_action :verify_authenticity_token, if: :json_request?
  
  # Add authentication helpers
  helper_method :current_user, :user_signed_in?
  
  # Add authorization method
  def authorize_resource(resource)
    unless current_user && (current_user.admin? || resource.user_id == current_user.id)
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
  
  private
  
  def authenticate_user!
    redirect_to login_path, alert: "Please sign in to access this page." unless user_signed_in?
  end
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def user_signed_in?
    current_user.present?
  end
  
  def json_request?
    request.format.json?
  end
end
