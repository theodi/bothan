module Bothan
  module Helpers
    module Dashboard

      def sanitize_metrics(dashboard)

        dashboard[:metrics].delete_if {|k,v| !v.has_key?("name")}
        dashboard[:metrics] = dashboard[:metrics].map { |m| m.last }.each { |m| m.delete('visualisation') if m['visualisation'] == 'default' }
        dashboard
      end

    end
  end
end
