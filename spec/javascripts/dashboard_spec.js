describe('dashboard.js', function() {
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

})
