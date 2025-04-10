# app/controllers/dashboard_controller.rb
class DashboardController < InertiaController
  def index
    authorize! :read, :dashboard  # Explicitly authorize
  end
end
