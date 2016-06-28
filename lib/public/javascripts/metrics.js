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


function extractY(metric) {
  if (typeof(metric) == "number") {
    return metric
  } else if(typeof(metric) == "object") {
    k = Object.keys(metric)[0]
    return metric[k]
  }
}

function getPoints(metrics, xpath) {
  return {
    x: metrics.map(function(metric) {
      return plotlyDate(metric['time'])
    }),
    y: y = metrics.map(function(metric) {
      return extractY(metric['value'])
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
    return {
      number: rounding(number, 1000000),
      suffix: 'M'
    }
  }

  if(number > 999) {
    return {
      number: rounding(number, 1000),
      suffix: 'K'
    }
  }
  return {
    number: number,
    suffix: ''
  }

}

function rounding(number, scale) {
  return (number / scale).toFixed(1)
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

function setEmbedCode() {
  embed = $('#embed textarea')
  embed.val(embedCode(embed.data().url))
}

function updatePage(params, from, to) {
  uri = URI($('#iframe_embed iframe').attr('src'))

  if (from !== undefined || to !== undefined) {
    uri = updateDates(uri, from, to)
  }

  uri.removeQuery(Object.keys(params))
  url = uri.addQuery(params).toString();

  updateEmbedCode(url)
  updateIframe(url)
  updateWindowURL(document.title, uri.removeQuery(['layout', 'plotly_modebar']).toString())
  updateJSON(url)
}

function updateEmbedCode(url) {
  $('#embed textarea').val(embedCode(url))
}

function updateIframe(url) {
  $('#iframe_embed iframe').attr('src', url)
}

function updateWindowURL(title, url) {
  history.pushState({}, title, url)
}

function updateJSON(url) {
  $.get(url, function(data) {
    $('#json pre').html(JSON.stringify(data, null, ' '))
  }, "json")
}

function updateDates(uri, from, to) {
  path = uri.path().split('/').slice(0,3)
  path.push(from)
  if (to !== undefined) path.push(to)
  uri.path(path.join('/'))
  return uri
}

function embedCode(url) {
  return "<iframe src='"+ url +"' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>"
}
