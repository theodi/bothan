describe Bothan::App do

  context 'Dashboards' do

    before(:each) do
      basic_authorize ENV['METRICS_API_USERNAME'], ENV['METRICS_API_PASSWORD']
    end

    let(:dashboard_hash) {
      {
        dashboard: {
          name: 'My Awesome Dashboard',
          slug: 'my-awesome-dashboard',
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
    }

    it 'creates a dashboard' do
      post '/dashboards', dashboard_hash

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
      dashboard_hash[:dashboard][:metrics][:'0'][:visualisation] = 'default'

      post '/dashboards', dashboard_hash

      dashboard = Dashboard.first

      expect(dashboard.metrics.first).to eq({
        "name" => "my-first-metric",
        "boxcolour" => "#000",
        "textcolour" => "#fff",
      })
    end

    context 'returns an error' do

      it 'if the slug is invalid' do
        dashboard_hash[:dashboard][:slug] = 'This Is TOTALLY NOT A SLUG $%£@$@$@£'
        post '/dashboards', dashboard_hash

        expect(last_request.url).to eq('http://example.org/dashboards')
        expect(last_response.body).to match(/The slug 'This Is TOTALLY NOT A SLUG \$\%\£\@\$\@\$\@\£' is invalid/)
      end

      it 'if the slug is duplicated' do
        Metric.create(name: "dashboard-0")
        Dashboard.create(name: 'Original', slug: 'my-awesome-dashboard', rows: 1, columns: 1, metrics: "dashboard-0")

        post '/dashboards', dashboard_hash

        expect(last_request.url).to eq('http://example.org/dashboards')
        expect(last_response.body).to match(/The slug 'my-awesome-dashboard' is already taken/)
      end

      [:name, :slug, :rows, :columns].each do |col|

        it "when #{col} is missing" do
          dashboard_hash[:dashboard].delete(col)

          post '/dashboards', dashboard_hash

          expect(last_request.url).to eq('http://example.org/dashboards')
          expect(last_response.body).to match(/The field #{col} can't be blank/)
        end

      end


    end

    it 'edits a dashboard' do
      Metric.create(name: "dashboard-0")
      dashboard = Dashboard.create(name: 'Original', slug: 'my-awesome-dashboard', rows: 1, columns: 1, metrics: "dashboard-0")

      put "/dashboards/#{dashboard.slug}", {
        dashboard: {
          name: 'My Awesome Dashboard',
          metrics: {
            '1': {
              name: 'my-first-metric',
              boxcolour: '#000',
              textcolour: '#fff',
              visualisation: 'number'
            }
          }
        }
      }

      dashboard = Dashboard.last

      expect(dashboard.name).to eq('My Awesome Dashboard')
      expect(dashboard.metrics.count).to eq(1)
    end

  end

end
