function applyNumber(title, date, number, element, datatype, description) {
  var content = '<h1 data-tip="'+ description +'">' + title + '</h1>'
  content += '<h2>' + number + '</h2>'
  content += '<small>Last updated: ' + date + '</small>'

  element.find('#number').html(content)

  num = scaleNumber(number)
  extras = getExtras(datatype, num.suffix)

  var options = {
    useEasing : true,
    useGrouping : false,
    separator : ',',
    decimal : '.',
    suffix: extras.suffix,
    prefix: extras.prefix
  }

  countUp(num.number, options, element)
}

function countUp(number, options, element) {
  var places = (parseInt(number) === number) ? 0 : 1
  var countup = new CountUp(element.find("h2")[0], 0, number, places, 1, options);
  countup.start();
}

function number(json, title, element, datatype, description) {
  if (json.values) {
    var last = json.values[json.values.length - 1]
    var date = moment(last['time']).format('YYYY-MM-DD HH:mm')
    var number = extractY(last.value)
  } else {
    var number = extractY(json.value)
    var date = moment(json.time).format('YYYY-MM-DD HH:mm')
  }

  applyNumber(title, date, number, element, datatype, description)
}
