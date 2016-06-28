describe('chart.js', function() {

  it('gets data for a single point', function() {
    points = {
      x: ['1', '2', '3', '4'],
      y: ['30', '40', '55', '2'],
      text: ['1', '2', '3', '4']
    }

    expect(singlePoint(points, '#000')).toEqual([
      {
        x: ['1', '2', '3', '4'],
        y: ['30', '40', '55', '2'],
        text: ['1', '2', '3', '4'],
        hoverinfo: 'text',
        type: 'scatter',
        line: {
          shape: 'spline',
          width: 2,
          smoothing: 1.3,
          color: '#000'
        },
      }
    ])
  })

  it('gets data for multiple points', function() {
    points = {
      x: ['1', '2', '3', '4'],
      y: [
        {
          thing1: 11,
          thing2: 21,
          thing3: 31,
          thing4: 41
        },
        {
          thing1: 12,
          thing2: 22,
          thing3: 32,
          thing4: 42
        },
        {
          thing1: 13,
          thing2: 23,
          thing3: 33,
          thing4: 43
        }
      ]
    }

    expect(multiplePoints(points)).toEqual([
      {
        x: ['1', '2', '3', '4'],
        y: [11, 12, 13],
        name: 'thing1',
        type: 'scatter',
        line: {
          shape: 'spline',
          width: 2,
          smoothing: 1.3,
        },
      },
      {
        x: ['1', '2', '3', '4'],
        y: [21, 22, 23],
        name: 'thing2',
        type: 'scatter',
        line: {
          shape: 'spline',
          width: 2,
          smoothing: 1.3,
        },
      },
      {
        x: ['1', '2', '3', '4'],
        y: [31, 32, 33],
        name: 'thing3',
        type: 'scatter',
        line: {
          shape: 'spline',
          width: 2,
          smoothing: 1.3,
        },
      },
      {
        x: ['1', '2', '3', '4'],
        y: [41, 42, 43],
        name: 'thing4',
        type: 'scatter',
        line: {
          shape: 'spline',
          width: 2,
          smoothing: 1.3,
        },
      }
    ])
  })

})
