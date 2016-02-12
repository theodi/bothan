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

function extractY(hash, xpath) {
  xpath = (xpath == undefined ? '//value' : xpath)
  return JSON.search(hash, xpath)[0]
}

function getPoints(metrics, xpath) {
  return {
    x: metrics.map(function(metric) {
      return plotlyDate(metric['time'])
    }),
    y: y = metrics.map(function(metric) {
      return extractY(metric, xpath)
    })
  }
}

function extractData(hash, xpath) {
  xpath = (xpath == undefined ? '//value' : xpath)
  return JSON.search(hash, xpath)[0]
}

function extractValues(hash, xpath) {
  result = extractData(hash, xpath)
  keys = extractKeys(hash, xpath)
  return keys.map(function(key) {
    return result[key]
  })
}

function extractKeys(hash, xpath) {
  result = extractData(hash, xpath)
  return Object.keys(result)
}

function extractTitle(url) {
  var regex = /http.*metrics\/([^\/]*)[\/|\.].*/
  var result = url.match(regex)
  var words = result[1].split('-')
  return words.map(function(word) {
    return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
  }).join(' ')
}

function snipExtension(path) {
  var bits = path.split('.')
  return bits.slice(0, bits.length - 1).join('.')
}

function extractNumber(hash) {
  subject = hash['value']

  if($.isNumeric(subject)) {
    return subject
  }

  if(!subject) {
    return getRandom(unknowns())
  }

  if('total' in subject) {
    return subject['total']
  }

  if(subject.constructor === Array) {
    return getRandom(unknowns())
  }

// if all else fails...
  return getRandom(unknowns())
}

function unknowns() {
  return [
    'Unknown',
    'Uncharted',
    'Undiscovered',
    'Ineffable',
    'Transcendent',
    'Ethereal'
  ]
}

function getRandom(array) {
  return array[Math.floor(Math.random() * array.length)]
}

function asColumns(percentage, type) {
  type = typeof type !== 'undefined' ? type : 'md';
  var cols = Math.ceil(12 * (percentage / 100))
  if(percentage === 0) {
    cols = 1
  }
  return 'col-' + type + '-' + Math.min(cols, 12)
}

function scaleNumber(number) {
  if(number > 999999) {
    return rounding(number, 1000000) + 'M'
  }

  if(number > 999) {
    return rounding(number, 1000) + 'K'
  }

  return number
}

function rounding(number, scale) {
  return (
    Math.round(
      (
        (
          number / scale
        ) - Math.floor(
          number / scale
        )
      ) * 10
    ) / 10
  ) + Math.floor(
    number / scale
  )
}

function lastOrOnlyValue(json) {
  var values = json['values']
  var last
  if(values === undefined) {
    var last = json['value']
  } else {
    var last = values[values.length - 1]['value']
  }

  return last
}
