function growRow(td, span, cell_content) {
  var cell_content = (typeof cell_content === 'undefined') ? '<td></td>' : cell_content
  var row = td.closest("tr")
  var index = td.index()
  var old_span = (typeof td.attr('rowspan') === 'undefined') ? 1 : Number(td.attr('rowspan'))
  var table = row.parents('table')
  var content

  td.attr('rowspan', span)

  if (span > old_span) {
    // If we want to merge cells, this is easy
    var selector = "tr:lt(" + (span - 1) + ")"

    row.nextAll(selector).each(function () {
    	// Grab the content from each cell
      content = $("td:eq(" + index + ")", $(this)).html()
      $("td:eq(" + index + ")", $(this)).remove()
    })

  	// Get the next cell down
    row = $('tr:eq('+ span +')')
    // Append the content to make it look as though the cells are 'moving down'
    row.find('td:eq('+ index +')').html(content)
  } else {
    // This is where I'm having problems
    // Get the number of cells we need to put back
    count = old_span - span
    var offset = span - 1
    // Work through the rows
    for (var i=0; i < count ; i++) {
      // Get the row at the right index
      r = $(row.nextAll()[i+offset])
      if (index == 0) {
      // If we're at the beginning of a row, we need to prepend
        r.prepend(cell_content)
      } else {
      // Otherwise use nth-child to append in the right place
        r.find('td:nth-child(' + index + ')').after(cell_content)
      }
    }
  }

  return td
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
