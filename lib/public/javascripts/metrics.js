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
  return {
    x: metrics.map(function(metric) {
      return plotlyDate(metric['time'])
    }),
    y: y = metrics.map(function(metric) {
      return metric[extractY(metric)]
    })
  }
}

function extractTitle(url) {
  var regex = /http.*metrics\/([^\/]*)\/.*/
  var result = url.match(regex)
  var words = result[1].split('-')
  return words.map(function(word) {
    return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
  }).join(' ')
}
