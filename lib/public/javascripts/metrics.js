function plotlyDate(isoDate) {
  var regex = /^(\d\d\d\d-\d\d-\d\d)T(\d\d:\d\d:\d\d).*/
  var result = isoDate.match(regex)
  return result.slice(1, 3).join(' ')
}

function mapDates(isoDates) {
  return isoDates.map(
    function(date) {
      return plotlyDate(date)
    }
  )
}

function extractY(hash) {
  return Object.keys(hash)[1]
}

function getPoints(metrics) {
  var x = []
  var y = []

  x = metrics.map(function(metric) {
    return plotlyDate(metric['time'])
  })

  y = metrics.map(function(metric) {
    return metric[extractY(metric)]
  })

  return {
    x: x, y: y
  }
}
