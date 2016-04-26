function applyNumber(title, date, number, element) {
  var content = '<h1>' + title + '</h1>'
  content += '<h2>' + number + '</h2>'
  content += '<small>Last updated: ' + date + '</small>'

  element.find('#number').html(content)

  var options = {
    useEasing : true,
    useGrouping : true,
    separator : ',',
    decimal : '.'
  }

  countUp(number, options, element)
}

function countUp(number, options, element) {
  var countup = new CountUp(element.find("#metric-value")[0], 0, number, 0, 1, options);
  countup.start();
}

function number(json, title, element) {
  if (json.values) {
    var last = json.values[json.values.length - 1]
    var date = moment(last['time']).format('YYYY-MM-DD HH:mm')
    var number = extractY(last.value)
  } else {
    var number = extractY(json.value)
    var date = moment(json.time).format('YYYY-MM-DD HH:mm')
  }

  applyNumber(title, date, number, element)
}
