function graph(title, json, textcolour, boxcolour, plotly_modebar, datatype) {
  $('#chart').height($(window).height())

  var extras = getExtras(datatype)
  var points = getPoints(json['values'], extras)

  if (typeof(points['y'][0]) == 'object') {
    var data = multiplePoints(points)
  } else {
    var data = singlePoint(points)
  }

  var layout = getLayout(title, textcolour, boxcolour)

  Plotly.newPlot(
    'chart',
    data,
    layout,
    { displayModeBar: JSON.parse(plotly_modebar) }
  );
}

function multiplePoints(points) {
  var data = []
  var yKeys = Object.keys(points['y'][0])
  var yCount = yKeys.length

  for (y = 0; y < yCount; y++) {
    var vals = []

    for (i = 0; i < points['y'].length; i++) {
      vals.push(points['y'][i][yKeys[y]])
    }

    data.push({
      x: points['x'],
      y: vals,
      name: yKeys[y],
      type: 'scatter',
      line: {
        shape: 'spline',
        width: 2,
        smoothing: 1.3,
      },
    })
  }

  return data
}

function singlePoint(points, textcolour) {
  return [{
    x: points['x'],
    y: points['y'],
    text: points['text'],
    hoverinfo: 'text',
    type: 'scatter',
    line: {
      shape: 'spline',
      width: 2,
      smoothing: 1.3,
      color: textcolour
    },
  }]
}

function getLayout(title, textcolour, boxcolour) {
  return {
    paper_bgcolor: boxcolour,
    plot_bgcolor: boxcolour,
    xaxis: {
      gridcolor: '#D3D3D3',
      type: 'datetime',
      tickangle: 315,
      tickfont: {
        color: textcolour
      }
    },
    yaxis: {
      gridcolor: '#D3D3D3',
      tickangle: 315,
      tickfont: {
        color: textcolour
      }
    },
    margin: {
      l: 30, r: 30, t: 60, b: 80
    }
  }
}
