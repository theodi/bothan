function growRow(td, span) {
  var row = td.closest("tr")
  var index = td.index()
  var old_span = (typeof td.attr('rowspan') === 'undefined') ? 1 : Number(col.attr('rowspan'))
  var table = row.parents('table')
  var content

  td.attr('rowspan', span)

  if (span > old_span) {
    var selector = "tr:lt(" + (span - 1) + ")"

    row.nextAll(selector).each(function () {
      content = $("td:eq(" + index + ")", $(this)).html()
      $("td:eq(" + index + ")", $(this)).remove()
    })

    row = $('tr:eq('+ span +')')
    row.find('td:eq('+ index +')').html(content)
  } else {
    var selector = "tr:gt(" + (span - 1) + ")"

    table.find(selector).each(function () {
      $(this).append('<td></td>')
    })
  }
}

function growCol() {

}
