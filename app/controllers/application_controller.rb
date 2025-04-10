# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_request_details
  before_action :authenticate

  # Add CanCanCan authorization check
  # This will automatically authorize actions based on controller name
  # For non-RESTful actions or custom logic, use `authorize!` manually in the action.
  # Consider `check_authorization unless: :devise_controller?` if using Devise
  check_authorization unless: :skippable_controller?

  # Handle Access Denied exceptions
  rescue_from CanCan::AccessDenied do |exception|
    # Respond appropriately, e.g., redirect or render an error page
    # For Inertia, redirecting with a flash message is common
    redirect_to root_path, alert: exception.message # Or dashboard_path if more appropriate
  end

  private

  # Make Current.user available to CanCanCan
  def current_user
    Current.user
  end

  # Tell CanCanCan where to get the ability object (defaults to Ability.new(current_user))
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def authenticate
    redirect_to sign_in_path unless perform_authentication
  end

  def require_no_authentication
    return unless perform_authentication

    flash[:notice] = "You are already signed in"
    redirect_to root_path
  end

  def perform_authentication
    Current.session ||= Session.find_by_id(cookies.signed[:session_token])
    # Ensure Current.user is set if session exists
    Current.user if Current.session
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end

  # Define controllers where authorization should be skipped
  def skippable_controller?
    # Controllers handling public access, authentication, etc.
    # Add Devise controllers here if using Devise: devise_controller?
    %w[HomeController SessionsController UsersController Identity::EmailVerificationsController Identity::PasswordResetsController InertiaRails::StaticController DashboardController].include?(controller_name.camelize + "Controller") ||
      (defined?(Rails::HealthController) && self.is_a?(Rails::HealthController)) # Skip Rails health check
  end
end
