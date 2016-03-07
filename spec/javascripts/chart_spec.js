describe('chart.js', function() {

  beforeEach(function() {
    points = {
      x: [
        '2014-11-30 00:11:09',
        '2014-12-01 00:10:56',
        '2014-12-02 00:10:07',
        '2014-12-04 16:17:29',
        '2014-12-05 16:17:08',
        '2014-12-06 16:19:46',
        '2014-12-07 16:16:41',
        '2014-12-08 16:18:56'
      ],
      y: [
        9653,
        9653,
        9655,
        10227,
        10228,
        10228,
        10228,
        10228
      ]
    }

    data = {
      x: points.x,
      y: points.y,
      type: 'scatter',
      line: {
        shape: 'spline',
        width: 2,
        smoothing: 1.3,
        color: '#000'
      }
    }

    layout = {
      title: 'My Awesome Title',
      titlefont: {
        color: '#000'
      },
      paper_bgcolor: '#fff',
      plot_bgcolor: '#fff',
      xaxis: {
        gridcolor: '#D3D3D3',
        type: 'datetime',
        tickangle: 315,
        tickformat: "%Y-%m-%d",
        tickfont: {
          color: '#000'
        }
      },
      yaxis: {
        gridcolor: '#D3D3D3',
        tickangle: 315,
        tickfont: {
          color: '#000'
        }
      },
      margin: {
        l: 70, r: 30
      }
    }

    json = {
      count: 8,
      values: [
        { time: '2014-11-30T00:11:09.000+00:00', value: 9653 },
        { time: '2014-12-01T00:10:56.000+00:00', value: 9653 },
        { time: '2014-12-02T00:10:07.000+00:00', value: 9655 },
        { time: '2014-12-04T16:17:29.000+00:00', value: 10227 },
        { time: '2014-12-05T16:17:08.000+00:00', value: 10228 },
        { time: '2014-12-06T16:19:46.000+00:00', value: 10228 },
        { time: '2014-12-07T16:16:41.000+00:00', value: 10228 },
        { time: '2014-12-08T16:18:56.000+00:00', value: 10228 }
      ]
    }

  })

  it('sets up the data', function() {
    expect(getData(points, '#000')).toEqual(data)
  })

  it('gets the layout', function() {
    expect(getLayout('My Awesome Title', '#000', '#fff')).toEqual(layout)
  })

  it('draws the chart', function() {
    spyOn(Plotly, 'newPlot')

    graph(json, 'My Awesome Title', '#000', '#fff', true)

    expect(Plotly.newPlot).toHaveBeenCalledWith('chart', [data], layout, { displayModeBar: true })
  })

});
