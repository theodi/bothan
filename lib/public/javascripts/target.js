function drawTarget(value, barcolour, container, datatype) {
  var metrics = {
    actual: {
      data: (value['actual'] / value['annual_target']) * 100,
      name: 'Actual progress'
    },
    annual_target: {
      data: (value['annual_target'] / value['annual_target']) * 100, // REDUNDANT REDUNDANCY
      name: 'Annual target'
    }
  }

  if (value['ytd_target']) {
    metrics['ytd_target'] = {
      data: (value['ytd_target'] / value['annual_target']) * 100,
      name: 'Year-to-date target'
    }
  }

  var sizes = {
    'target': 'md',
    'target-little': 'xs'
  }

  $.each(sizes, function(div, size) {
    $.each(metrics, function(metric, data) {
      var number = scaleNumber(value[metric])
      var num = number.number + number.suffix
      var extras = getExtras(datatype)

      container.find(
        '#' +
        div
      ).append(
        asRow(
          '<div class="' +
          metric +
          '-bar with-target ' +
          asColumns(
            data['data'], size
          ) +
          '" style="background-color: ' +
          barcolour +
          '"><span data-toggle="tooltip" title="' + data['name'] + '" class="bar-label">' +
            [extras.prefix, num, extras.suffix].join('')
          + '</span></div>'
        )
      )
    })
  })

  container.find('[data-toggle="tooltip"]').tooltip()
}

function asRow(content) {
  return '<div class="row target-row">' + content + '</div>'
}
