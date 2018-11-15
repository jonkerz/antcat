class ApplicationController < ActionController::Base
  NotAuthorized = Class.new(StandardError)

  protect_from_forgery with: :exception

  before_action :save_location, :set_user_for_feed
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit

  skip_before_action :verify_authenticity_token
  before_action :cors_preflight_check
  after_action :cors_set_access_control_headers

  delegate :is_editor?, :is_at_least_helper?, :is_superadmin?, to: :current_user, prefix: 'user', allow_nil: true
  helper_method :user_is_editor?, :user_is_at_least_helper?, :user_is_superadmin?

  rescue_from NotAuthorized do |exception|
    render plain: "You need the '#{exception.message}' permission to do that :(", status: :forbidden
  end

  if Rails.env.development?
    rescue_from RSolr::Error::ConnectionRefused do
      render plain: "Start Solr: `bundle exec rake sunspot:solr:start RAILS_ENV=development`"
    end
  end

  def user_for_paper_trail
    current_user&.id
  end

  def root_redirect_for_active_admin _exception
    redirect_to root_url
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :name, :password, :password_confirmation, :remember_me])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :username, :email, :password, :remember_me])
      devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :name, :password, :password_confirmation, :current_password])
    end

  private

    # Save location so that we can redirect back to the previous page after signing in/out.
    def save_location
      unless request.xhr? || request.url =~ %r{/users/}
        session[:user_return_to] = request.url
      end
    end

    def set_user_for_feed
      User.current = current_user
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
      headers['Access-Control-Max-Age'] = "1728000"
    end

    def cors_preflight_check
      if request.method == 'OPTIONS'
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
        headers['Access-Control-Max-Age'] = '1728000'

        render plain: ''
      end
    end

    # TODO: Rename to `ensure_user_is_editor`?
    def ensure_can_edit_catalog
      authenticate_user!
      raise NotAuthorized, "editor" unless user_is_editor?
    end

    def ensure_user_is_at_least_helper
      authenticate_user!
      raise NotAuthorized, "helper" unless user_is_at_least_helper?
    end

    def authenticate_superadmin
      authenticate_user!
      raise NotAuthorized, "superadmin" unless user_is_superadmin?
    end
end
