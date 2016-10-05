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

  it ('works with a centre column', function() {
    col = $('table td#a1')

    growRow(col, 2)

    expect($('table td#a1').attr('rowspan')).toEqual('2')
    expect($('#row-b #b1').length).toEqual(0)
    expect($('#row-c #c1').html()).toEqual('b1')
  })

})
