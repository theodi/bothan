module Bothan
  module Dashboards

    def self.registered(app)

      app.get '/dashboards' do
        @dashboards = Dashboard.all
        @title = "Dashboards"

        erb :'dashboards/index', layout: :'layouts/full-width'
      end

      app.get '/dashboards/new' do
        protected!

        @dashboard = Dashboard.new
        @title = 'Create Dashboard'
        @metrics = Metric.all.distinct(:name).map { |m| Metric.find_by(name: m) }

        erb :'dashboards/new', layout: :'layouts/full-width'
      end

      app.get '/dashboards/:dashboard' do
        @dashboard = Dashboard.find_by(slug: params[:dashboard])
        @title = @dashboard.name

        respond_to do |wants|
          wants.html do
            erb :'dashboards/show', layout: :"layouts/dashboard"
          end
        end
      end

      app.put '/dashboards/:slug' do
        protected!

        @dashboard = Dashboard.find_by(slug: params[:slug])

        dashboard = params[:dashboard]
        dashboard[:metrics] = dashboard[:metrics].map { |m| m.last }
                                                 .each { |m| m.delete('visualisation') if m['visualisation'] == 'default' }

        @dashboard.update_attributes(dashboard)

        if @dashboard.valid?
          redirect "#{request.scheme}://#{request.host_with_port}/dashboards/#{@dashboard.slug}"
        else
          @title = 'Edit Dashboard'
          @metrics = Metric.all.distinct(:name).map { |m| Metric.find_by(name: m) }
          @errors = @dashboard.errors

          erb :'dashboards/new', layout: :'layouts/full-width'
        end
      end

      app.get '/dashboards/:dashboard/edit' do
        protected!

        @metrics = Metric.all.distinct(:name).map { |m| Metric.find_by(name: m) }
        @dashboard = Dashboard.find_by(slug: params[:dashboard])
        @title = 'Edit Dashboard'

        erb :'dashboards/new', layout: :'layouts/full-width'
      end

      app.post '/dashboards' do
        protected!
        byebug

        dashboard = params[:dashboard]
        dashboard[:metrics] = dashboard[:metrics].map { |m| m.last }
                                                 .each { |m| m.delete('visualisation') if m['visualisation'] == 'default' }

        @dashboard = Dashboard.create(dashboard)

        if @dashboard.valid?
          redirect "#{request.scheme}://#{request.host_with_port}/dashboards/#{@dashboard.slug}"
        else
          @title = 'Create Dashboard'
          @metrics = Metric.all.distinct(:name).map { |m| Metric.find_by(name: m) }
          @errors = @dashboard.errors

          erb :'dashboards/new', layout: :'layouts/full-width'
        end
      end

    end

  end
end
