module Bothan
  module Helpers
    module App

      def config
        {
          title: ENV['METRICS_API_TITLE'],
          description: ENV['METRICS_API_DESCRIPTION'],
          license: {
            name: ENV['METRICS_API_LICENSE_NAME'],
            url: ENV['METRICS_API_LICENSE_URL'],
            image: license_image(ENV['METRICS_API_LICENSE_URL'])
          },
          publisher: {
            name: ENV['METRICS_API_PUBLISHER_NAME'],
            url: ENV['METRICS_API_PUBLISHER_URL']
          },
          certificate_url: ENV['METRICS_API_CERTIFICATE_URL']
        }
      end

      def license_image(url)
        match = url.match /https?:\/\/creativecommons.org\/licenses\/([a-z\-]+)\/([0-9\.]+)/
        if match
          "https://licensebuttons.net/l/#{match[1]}/#{match[2]}/88x31.png"
        else
          nil
        end
      end

      def error_406
        content_type 'text/plain'
        error 406, "Not Acceptable"
      end

      def error_400(error)
        content_type 'text/plain'
        error 400, {:status => error}.to_json
      end

    end
  end
end
