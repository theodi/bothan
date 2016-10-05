function growRow(td, span, cell_content) {
  var cell_content = (typeof cell_content === 'undefined') ? '<td></td>' : cell_content
  var row = td.closest("tr")
  var index = td.index()
  var old_span = (typeof td.attr('rowspan') === 'undefined') ? 1 : Number(td.attr('rowspan'))
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

    table.find(selector).each(function() {
      if (index == 0) {
        $(this).prepend(cell_content)
      } else {
        $(this).find('td:nth-child(' + index + ')').after(cell_content)
      }
    })
  }
}

function growCol(td, span, cell_content) {
  var cell_content = (typeof cell_content === 'undefined') ? '<td></td>' : cell_content
  var table = td.parents('table')
  var row = td.closest("tr")
  var index = td.index()
  var old_span = (typeof td.attr('colspan') === 'undefined') ? 1 : Number(td.attr('colspan'))
  var selector = "td:lt(" + (span - 1) + ")";
  var content

  td.attr('colspan', span)

  if (span > old_span) {
    td.nextAll(selector).each(function() {
      content = $(this).html()
      $(this).remove()
    })

    row.find("td:eq(" + (span - 1) + ")").html(content)
  } else {

    num = 0

    $.each(row.find('td'), function() {
      col = $(this)
      span = (typeof col.attr('colspan') === 'undefined') ? 1 : Number(col.attr('colspan'));
      num += span
    })

    if (num < numCol(table)) {
      for (var count=0; count < (numCol(table) - num) ; count++) { row.append(cell_content) };
    }

  }

  return td
}

function numCol(table) {
    var maxColNum = 0;

    var i=0;
    var trs = $(table).find("tr");

    for ( i=0; i<trs.length; i++ ) {
      maxColNum = Math.max(maxColNum, getColForTr(trs[i]));
    }

    return maxColNum;
}

function getColForTr(tr) {

    var tds = $(tr).find("td");

    var numCols = 0;

    var i=0;
    for ( i=0; i<tds.length; i++ ) {
        var span = $(tds[i]).attr("colspan");

        if ( span )
            numCols += parseInt(span);
        else {
            numCols++;
        }
    }
    return numCols;
}
