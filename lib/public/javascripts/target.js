function drawTarget(value, barcolour, container, datatype) {
  var metrics = {
    actual: {
      data: (value['actual'] / value['annual_target']) * 100,
      name: 'Actual progress'
    },
    annual_target: {
      data: (value['annual_target'] / Math.max(value['annual_target'], value['actual'])) * 100, // REDUNDANT REDUNDANCY
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
          '" style="background-color: ' +
          barcolour +
          '; width:' + Math.min(data['data'], 100) + '%"><span data-toggle="tooltip" title="' + data['name'] + '" class="bar-label"><span class="inner">' +
            [extras.prefix, num, extras.suffix].join('')
          + '</span></span></div>'
        )
      )

      if (metric == "annual_target") {
        container.find(
          '#' +
          div
        ).append('<div class="flagpole" style="position: absolute; left:'+ Math.min(data['data'], 100)  +'%"></div>')
      }
    })
  })

  container.find('[data-toggle="tooltip"]').tooltip()
}

function asRow(content) {
  return '<div class="row target-row">' + content + '</div>'
}
