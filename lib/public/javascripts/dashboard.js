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

function showVisualisations(selector, metric) {
  selector.find('.default').prop('checked', true)
  selector.find('.input-group label').addClass('hidden')
  $.each(metric.data('visualisations').split(','), function( index, value ) {
    selector.find('.' + value).removeClass('hidden')
  });
  selector.removeClass('hidden')
}

function showDates(selector, type) {
  selector.find('.date').remove()

  var template = $('#date-template').clone()
  var index = selector.find('.index').val()
  var wrapper = selector.find('.date-wrapper')

  template.removeAttr('id')
  template.removeClass('hidden')
  template.attr('name', 'dashboard[metrics]['+ index +'][date]')

  template.find('option').each(function(i, option) {
    $options = $(option)
    if ($options.data('support').split(',').indexOf(type) == -1) {
      $options.remove()
    }
  })

  wrapper.append(template)
  wrapper.removeClass('hidden')
}

function populateIframe(iframe, metric, daterange) {
  var daterange = (typeof daterange === 'undefined') ? '/*/*' : '/' + daterange;
  var uri = URI(iframe.attr('src'))
  var qs = uri.search() !== '' ? uri.search() : '?layout=bare'
  var baseURL = iframe.data('base-url')
  var url = baseURL + metric + daterange + qs;
  iframe.attr('src', url)
  iframe.removeClass('hidden')
}

function setSrc(iframe, params) {
  var uri = URI(iframe.attr('src'))
  uri.removeQuery(Object.keys(params));
  url = uri.addQuery(params).toString();
  iframe.attr('src', url)
}

function updateSelects(table, row_num, col_num) {
  this.row_num = row_num
  this.col_num = col_num

  var self = this

  // Populate the rowspan selector
  table.find('select.height-selector option').remove()

  $.each(table.find('select.height-selector'), function() {
    select = $(this)
    tr = $(this).closest('tr')
    index = tr.index()

    options = []

    for (var i = self.row_num - index; i > 0; i--) {
      options.push(i)
    }

    $.each(options.reverse(), function() {
      select.append('<option>'+ this +'</option>')
    })
  })

  // Populate the colspan selector
  table.find('select.width-selector option').remove()

  $.each(table.find('select.width-selector'), function() {
    select = $(this)
    td = $(this).closest('td')
    index = td.index()

    options = []

    for (var i = self.col_num - index; i > 0; i--) {
      options.push(i)
    }

    $.each(options.reverse(), function() {
      select.append('<option>'+ this +'</option>')
    })
  })
}

function buildTable(row_num, col_num) {
  table = $('#dashboard');

  form = $('#metric-template').clone();
  form.removeClass('hidden')

  row_template = $('<tr></tr>');
  col_template = '<td>'+ form.html() +'</td>';

  for (var i=0; i<col_num; i++) { row_template.append(col_template) };

  current_rows = table.find('tr').length;

  if (current_rows == 0) {
    // If there are no rows, this is easy
    for (var i=0; i<row_num; i++) {
      row = row_template.clone()

      row.appendTo(table);
    };
  } else {
    // Otherwise, we need to append / remove columns and rows
    rows = table.find('tr');

    // If we need to add rows
    if (rows.length <= row_num) {
      var i = 0;

      // Loop through each row
      for (i; i < current_rows; i++) {
        row = $(rows[i]);
        row_cols = $(row).find('td').length;

        if (col_num >= row_cols) {
          // Append columns to the existing rows
          col_count = col_num - row_cols;
          for (var count=0; count<col_count; count++) { row.append(col_template) };
        } else {
          // Remove columns from the existing rows
          col_count = row_cols - col_num;
          selector = "td:nth-last-child(-n+"+ col_count +")";
          row.find(selector).remove();
        }
      }

      // Append new rows
      if (i <= row_num) {
        for (i; i < row_num; i++) { row_template.clone().appendTo(table) };
      }
    } else {
      // Remove rows
      row_count = rows.length - row_num;
      selector = "tr:nth-last-child(-n+"+ row_count +")";
      table.find(selector).remove();
    }
  }

  updateSelects(table, row_num, col_num)
  // Show the table
  table.removeClass('hidden');

  setInputs(table)
  setPickers()
}

function populateTable(metrics) {
  $.each(metrics, function(i, metric) {
    var table = $('#dashboard');

    var panel = $(table.find('td')[i])
    var iframe = panel.find('iframe')
    var type = (typeof metric.visualisation === 'undefined') ? 'default' : metric.visualisation;

    panel.find('.metric').val(metric.name)

    panel.find('[name=boxcolourpicker]').val('#' + metric.boxcolour)
    panel.find('.boxcolour').val(metric.boxcolour)

    panel.find('[name=textcolourpicker]').val('#' + metric.textcolour)
    panel.find('.textcolour').val(metric.textcolour)

    populateIframe(iframe, metric.name)
    showVisualisations(panel.find('.visualisations'), panel.find(":selected"))

    panel.find('[value="'+ type +'"].visualisation').prop("checked", true)

    if (metric.height) {
      panel.find('.height').val(metric.height)
      panel.find('.height-selector').val(metric.height)
      growRow(panel, metric.height)
    }

    if (metric.width) {
      panel.find('.width').val(metric.width)
      panel.find('.width-selector').val(metric.width)
      growCol(panel, metric.width)
    }

    var params = {
      boxcolour: metric.boxcolour,
      textcolour: metric.textcolour,
      type: metric.visualisation
    }

    setSrc(iframe, params);
  })
}

function setPickers() {
  var picker = $(document).find('.colourpicker').colorpicker()

  picker.on('changeColor', function(ev){
    var iframe = $(this).parents().eq(1).find('iframe')
    var baseURL = iframe.data('base-url')

    $(this).next('input').val(ev.color.toHex().replace('#', ''));

    if ($.inArray('textcolour', ev.target.classList) >= 0) {
      var textcolour = ev.color.toHex()
      var boxcolour = $(this).parents().eq(1).find('input.boxcolour').val()
    } else {
      var textcolour = $(this).parents().eq(1).find('input.textcolour').val()
      var boxcolour = ev.color.toHex()
    }

    params = {
      boxcolour: boxcolour.replace('#', ''),
      textcolour: textcolour.replace('#', '')
    }

    setSrc(iframe, params);
  });
}

function setInputs(table) {
  $.each(table.find('tr'), function(i, row) {
    $(row).find('.row').val(i + 1)
    $.each($(row).find('td'), function(n, col) {
      if ($(col).find('.col').val() == '') {
        $(col).find('.col').val(n + 1)
      }
    })
  })

  $.each(table.find('td'), function(i, col) {
    $(col).find('.metric').attr('name', 'dashboard[metrics]['+ i +'][name]')
    $(col).find('.boxcolour').attr('name', 'dashboard[metrics]['+ i +'][boxcolour]')
    $(col).find('.textcolour').attr('name', 'dashboard[metrics]['+ i +'][textcolour]')
    $(col).find('.visualisation').attr('name', 'dashboard[metrics]['+ i +'][visualisation]')
    $(col).find('.row').attr('name', 'dashboard[metrics]['+ i +'][row]')
    $(col).find('.col').attr('name', 'dashboard[metrics]['+ i +'][col]')
    $(col).find('.height').attr('name', 'dashboard[metrics]['+ i +'][height]')
    $(col).find('.width').attr('name', 'dashboard[metrics]['+ i +'][width]')
    $(col).find('.date').attr('name', 'dashboard[metrics]['+ i +'][date]')
    $(col).find('.title').attr('name', 'dashboard[metrics]['+ i +'][title]')
    $(col).find('.index').val(i)
  })
}
