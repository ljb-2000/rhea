module Rhea
  class BaseController < ActionController::Base
    protect_from_forgery

    layout 'rhea/layouts/application'

    helper Rhea::Helper

    around_filter :rescue_exceptions

    private

    def rescue_exceptions
      yield
    rescue Errno::ECONNREFUSED
      render_connection_exception
    rescue Rhea::Kubernetes::ServerError => e
      flash[:alert] = e.message
      render_connection_exception
    end

    def render_connection_exception
      render 'rhea/errors/index'
    end
  end
end
