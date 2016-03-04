function applyNumber(title, date, number) {
  var content = '<h1>' + title + '</h1>'
  content += '<span id="metric-value">' + number + '</span>'
  content += '<br/><small>Last updated: ' + date + '</small>'

  $('#number').html(content)

  var options = {
    useEasing : true,
    useGrouping : true,
    separator : ',',
    decimal : '.'
  }

  countUp(number)
}

function countUp(number) {
  var countup = new CountUp("metric-value", 0, number, 0, 1, options);
  countup.start();
}

function number(json, title) {
  if (json.values) {
    var last = json.values[json.values.length - 1]
    var date = moment(last['time']).format('YYYY-MM-DD HH:mm')
    var number = extractY(last.value)
  } else {
    var number = extractY(json.value)
    var date = moment(json.time).format('YYYY-MM-DD HH:mm')
  }

  applyNumber(title, date, number)
}
