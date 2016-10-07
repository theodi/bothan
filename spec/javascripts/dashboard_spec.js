describe('dashboard.js', function() {

  describe('growRow', function() {

    beforeEach(function() {
      fixture = loadFixtures("dashboard.html")
    })

    it ('applies the rowspan correctly', function() {
      col = $('table td#a0')

      growRow(col, 2)

      expect($('table td#a0').attr('rowspan')).toEqual('2')
    });

    it ('pushes the cell in the next row down', function() {
      col = $('table td#a0')

      growRow(col, 2)

      expect($('#row-b #b0').length).toEqual(0)
      expect($('#row-c #c0').html()).toEqual('b0')
    })

    it ('works with a full rowspan', function() {
      col = $('table td#a0')

      growRow(col, 3)

      expect($('table td#a0').attr('rowspan')).toEqual('3')
      expect($('#row-b #b0').length).toEqual(0)
      expect($('#row-c #c0').length).toEqual(0)
    })

    it ('leaves the rest of the table alone', function() {
      col = $('table td#a0')

      growRow(col, 3)

      expect($('#row-a #a1').html()).toEqual('a1')
      expect($('#row-a #a2').html()).toEqual('a2')

      expect($('#row-b #b1').html()).toEqual('b1')
      expect($('#row-b #b2').html()).toEqual('b2')

      expect($('#row-c #c1').html()).toEqual('c1')
      expect($('#row-c #c2').html()).toEqual('c2')
    })

    it ('fills in gaps when the colspan is restored', function() {
      col = $('table td#a0')

      growRow(col, 3)
      growRow(col, 1)

      expect($('#row-a td').length).toEqual(3)
      expect($('#row-b td').length).toEqual(3)
      expect($('#row-c td').length).toEqual(3)
    })

    it('fills in gaps with a particular HTML string', function() {
      col = $('table td#a0')

      growRow(col, 3)
      growRow(col, 1, '<td>YO!</td>')

      expect($($('#row-b td')[0]).html()).toEqual('YO!')
      expect($($('#row-c td')[0]).html()).toEqual('YO!')
    })

    it('fills in gaps correctly when in the middle row', function() {
      col = $('table td#b1')

      growRow(col, 2)
      growRow(col, 1)

      expect($('#row-a td').length).toEqual(3)
      expect($('#row-b td').length).toEqual(3)
      expect($('#row-c td').length).toEqual(3)

      col = $('table td#b0')
      growRow(col, 2)
      growRow(col, 1)

      expect($('#row-a td').length).toEqual(3)
      expect($('#row-b td').length).toEqual(3)
      expect($('#row-c td').length).toEqual(3)
    })

    it ('works with a centre column', function() {
      col = $('table td#a1')

      growRow(col, 2)

      expect($('table td#a1').attr('rowspan')).toEqual('2')
      expect($('#row-b #b1').length).toEqual(0)
      expect($('#row-c #c1').html()).toEqual('b1')
    })

    it('fills in gaps in a centre column', function() {
      col = $('table td#a1')
      growRow(col, 3)
      growRow(col, 1, '<td>YO!</td>')

      expect($($('#row-b td')[1]).html()).toEqual('YO!')
      expect($($('#row-c td')[1]).html()).toEqual('YO!')
    })

    it('fills in gaps when going down to two rows from three', function() {
      col = $('table td#a2')
      growRow(col, 3)
      growRow(col, 2, '<td>YO!</td>')

      expect($($('#row-c td')[2]).html()).toEqual('YO!')
    })
  })

  describe('growCol', function() {

    beforeEach(function() {
      fixture = loadFixtures("dashboard.html")
    })

    it ('applies a colspan', function() {
      col = $('table td#a0')

      growCol(col, 2)

      expect($('table td#a0').attr('colspan')).toEqual('2')
    })

    it ('pushes the cell content into the next cell across', function() {
      col = $('table td#a0')

      growCol(col, 2)

      expect($('table td#a2').html()).toEqual('a1')
      expect($('table td#a1').length).toEqual(0)
    })

    it ('works with a full colspan', function() {
      col = $('table td#a0')

      growCol(col, 3)

      expect($('table td#a0').attr('colspan')).toEqual('3')
      expect($('table td#a1').length).toEqual(0)
      expect($('table td#a2').length).toEqual(0)
    })

    it ('leaves the rest of the table alone', function() {
      col = $('table td#a0')

      growCol(col, 3)

      expect($('#row-a #a0').html()).toEqual('a0')

      expect($('#row-b #b0').html()).toEqual('b0')
      expect($('#row-b #b1').html()).toEqual('b1')
      expect($('#row-b #b2').html()).toEqual('b2')

      expect($('#row-c #c0').html()).toEqual('c0')
      expect($('#row-c #c1').html()).toEqual('c1')
      expect($('#row-c #c2').html()).toEqual('c2')
    })

    it ('fills in gaps when the rowspan is restored', function() {
      col = $('table td#a0')

      growCol(col, 3)
      growCol(col, 1)

      expect($('#row-a td').length).toEqual(3)
    })

    it ('fills in gaps with a particular HTML string', function() {
      col = $('table td#a0')

      growCol(col, 3)
      growCol(col, 1, '<td>YO!</td>')

      expect($($('#row-a td')[1]).html()).toEqual('YO!')
      expect($($('#row-a td')[2]).html()).toEqual('YO!')
    })

    it ('fills in gaps at the right index', function() {
      col = $('table td#a1')

      growCol(col, 2)
      growCol(col, 1, '<td>YO!</td>')

      expect($($('#row-a td')[2]).html()).toEqual('YO!')
    })

    it ('works with a centre column', function() {
      col = $('table td#a1')

      growCol(col, 2)

      expect($('table td#a1').attr('colspan')).toEqual('2')
      expect($('#row-a #a2').length).toEqual(0)
    })

  })

  describe('populateIframe', function() {

    beforeEach(function() {
      loadFixtures("iframe.html")
      iframe = $('iframe')
    })

    it ('populates an iframe with a metric', function() {
      populateIframe(iframe, 'my-awesome-metric')
      expect(iframe.attr('src')).toEqual('http://example.org/metrics/my-awesome-metric/*/*?layout=bare')
    })

    it ('populates an iframe with a custom daterange', function() {
      populateIframe(iframe, 'my-awesome-metric', 'my-custom-date-range')
      expect(iframe.attr('src')).toEqual('http://example.org/metrics/my-awesome-metric/my-custom-date-range?layout=bare')
    })

    it ('retains query strings', function() {
      iframe.attr('src', 'http://example.org/metrics/my-awesome-metric/*/*?layout=bare&foo=bar')
      populateIframe(iframe, 'my-other-awesome-metric')
      expect(iframe.attr('src')).toEqual('http://example.org/metrics/my-other-awesome-metric/*/*?layout=bare&foo=bar')
    })

  })

  describe('showDates', function() {

    beforeEach(function() {
      loadFixtures("dates.html")
    })

    it('shows supported date types for a pie chart', function() {
      showDates($('.form'), 'pie')

      options = $('.date-wrapper select option')

      expect(options.length).toEqual(3)
      expect($(options[0]).val()).toEqual('*/*')
      expect($(options[1]).val()).toEqual('latest')
      expect($(options[2]).val()).toEqual('since-midnight')
    })

    it('shows supported date types for a chart', function() {
      showDates($('.form'), 'chart')

      options = $('.date-wrapper select option')

      expect(options.length).toEqual(6)
      expect($(options[0]).val()).toEqual('*/*')
      expect($(options[1]).val()).toEqual('since-beginning-of-month')
      expect($(options[2]).val()).toEqual('since-beginning-of-week')
      expect($(options[3]).val()).toEqual('since-beginning-of-year')
      expect($(options[4]).val()).toEqual('P30D/*')
      expect($(options[5]).val()).toEqual('P7D/*')
    })

    it('shows supported date types for a number', function() {
      showDates($('.form'), 'number')

      options = $('.date-wrapper select option')

      expect(options.length).toEqual(3)
      expect($(options[0]).val()).toEqual('*/*')
      expect($(options[1]).val()).toEqual('latest')
      expect($(options[2]).val()).toEqual('since-midnight')
    })

    it('shows supported date types for a target', function() {
      showDates($('.form'), 'target')

      options = $('.date-wrapper select option')

      expect(options.length).toEqual(3)
      expect($(options[0]).val()).toEqual('*/*')
      expect($(options[1]).val()).toEqual('latest')
      expect($(options[2]).val()).toEqual('since-midnight')
    })

    it('sets the index correctly', function() {
      showDates($('.form'), 'target')

      select = $('.date-wrapper select')

      expect(select.attr('name')).toEqual('dashboard[metrics][99][date]')
    })

    it('unhides the wrapper', function() {
      showDates($('.form'), 'target')

      expect($('.date-wrapper')).not.toHaveClass('hidden')
    })


  })

})
