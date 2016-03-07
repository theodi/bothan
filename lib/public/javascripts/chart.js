function getData(points, textcolour) {
  return {
    x: points.x,
    y: points.y,
    type: 'scatter',
    line: {
      shape: 'spline',
      width: 2,
      smoothing: 1.3,
      color: textcolour
    }
  }
}

function getLayout(title, textcolour, boxcolour) {
  return {
    title: title,
    titlefont: {
      color: textcolour
    },
    paper_bgcolor: boxcolour,
    plot_bgcolor: boxcolour,
    xaxis: {
      gridcolor: '#D3D3D3',
      type: 'datetime',
      tickangle: 315,
      tickformat: "%Y-%m-%d",
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
      l: 70, r: 30
    }
  }
}

function graph(json, title, textcolour, boxcolour, plotly_modebar) {
  var points = getPoints(json['values'])
  var data = getData(points, textcolour)
  var layout = getLayout(title, textcolour, boxcolour)

  Plotly.newPlot(
    'chart',
    [ data ],
    layout,
    { displayModeBar: plotly_modebar }
  );
}
