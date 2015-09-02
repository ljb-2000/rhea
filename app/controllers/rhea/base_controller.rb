module Rhea
  class BaseController < ActionController::Base
    protect_from_forgery

    layout 'rhea/layouts/application'

    helper Rhea::Helper

    around_filter :rescue_connection_exceptions

    private

    def rescue_connection_exceptions
      yield
    rescue Errno::ECONNREFUSED
      render_connection_exception
    end

    def render_connection_exception
      render 'rhea/errors/index'
    end
  end
end
