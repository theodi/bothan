module Bothan
  module Helpers
    module Views
      include Metrics

      def extract_title url
        regex = /http.*metrics\/([^\/]*)[\/|\.].*/
        result = url.match(regex)
        title_from_slug(result[1])
      end

      def extract_query_string qs, exclude: nil
        params = qs.split('&')
        query = {}
        params.each do |param|
          pair = param.split('=')
          query[pair[0]] = pair[1] unless pair[0] == exclude
        end
        query
      end

      def embed_iframe(params = {})
        "<iframe src='#{embed_url(params)}' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>"
      end

      def embed_url(params = {})
        params = request.params.merge(params.merge(
          {
            layout: "bare"
          }
        )).to_query
        request.scheme + '://' + request.host_with_port + request.path +  '?' + params
      end

      def dashboard_url(name, date, params)
        params = params.to_query
        "/metrics/#{name}/#{date || '*/*'}?#{params}"
      end

    end
  end
end
