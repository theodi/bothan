module Bothan
  module Helpers
    module Auth

      def protected!
        return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, "Not authorized\n"
      end

      def endpoint_protected!
        error!("401 Unauthorized", 401) unless authorized?
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['METRICS_API_USERNAME'], ENV['METRICS_API_PASSWORD']]
      end

    end
  end
end
