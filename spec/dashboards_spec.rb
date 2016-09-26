describe MetricsApi do

  context 'Dashboards' do

    it 'creates a dashboard' do

      post '/dashboards', {
        dashboard: {
          name: 'My Awesome Dashboard',
          rows: 2,
          columns: 2,
          metrics: {
            '0': {
              name: 'my-first-metric',
              boxcolour: '#000',
              textcolour: '#fff',
              visualisation: 'number'
            },
            '1': {
              name: 'my-second-metric',
              boxcolour: '#fff',
              textcolour: '#000',
              visualisation: 'number'
            },
            '2': {
              name: 'my-third-metric',
              boxcolour: '#111',
              textcolour: '#222',
              visualisation: 'number'
            },
            '3': {
              name: 'my-fourth-metric',
              boxcolour: '#ccc',
              textcolour: '#ddd',
              visualisation: 'number'
            }
          }

        }
      }

      follow_redirect!

      expect(last_request.url).to eq('http://example.org/dashboards/my-awesome-dashboard')

      dashboard = Dashboard.first

      expect(Dashboard.all.count).to eq(1)
      expect(dashboard.name).to eq('My Awesome Dashboard')
      expect(dashboard.slug).to eq('my-awesome-dashboard')
      expect(dashboard.rows).to eq(2)
      expect(dashboard.columns).to eq(2)
      expect(dashboard.metrics.count).to eq(4)
      expect(dashboard.metrics.first).to eq({
        "name" => "my-first-metric",
        "boxcolour" => "#000",
        "textcolour" => "#fff",
        "visualisation" => "number"
      })
    end

    it 'does not specify a visualisation if default is set' do
      post '/dashboards', {
        dashboard: {
          name: 'My Awesome Dashboard',
          rows: 1,
          columns: 1,
          metrics: {
            '0': {
              name: 'my-first-metric',
              boxcolour: '#000',
              textcolour: '#fff',
              visualisation: 'default'
            }
          }
        }
      }

      dashboard = Dashboard.first

      expect(dashboard.metrics.first).to eq({
        "name" => "my-first-metric",
        "boxcolour" => "#000",
        "textcolour" => "#fff",
      })
    end

  end

end
