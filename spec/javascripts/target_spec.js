describe('target.js', function() {
  beforeEach(function() {
    fixture = loadFixtures("target.html")
  })

  it('sets the correct width with both targets', function(){
    value = {
      "actual": 45,
      "annual_target": 486,
      "ytd_target": 215
    }

    drawTarget(value, '')

    expect($('#target .actual-bar')).toHaveClass('col-md-2')
    expect($('#target .annual_target-bar')).toHaveClass('col-md-12')
    expect($('#target .ytd_target-bar')).toHaveClass('col-md-6')

    expect($('#target-little .actual-bar')).toHaveClass('col-xs-2')
    expect($('#target-little .annual_target-bar')).toHaveClass('col-xs-12')
    expect($('#target-little .ytd_target-bar')).toHaveClass('col-xs-6')

    expect($('#target .actual-bar span').html()).toEqual('45')
    expect($('#target .annual_target-bar span').html()).toEqual('486')
    expect($('#target .ytd_target-bar span').html()).toEqual('215')
  })

  it('does not show a ytd target when only the annual target is present', function(){
    value = {
      "actual": 45,
      "annual_target": 486,
    }

    drawTarget(value, '')

    expect($('#target-little .ytd_target-bar').length).toEqual(0)
  })

  it('sets the bar colour', function(){
    value = {
      "actual": 45,
      "annual_target": 486,
      "ytd_target": 215
    }

    drawTarget(value, '#63635d')

    expect($('#target .actual-bar')).toHaveCss({'background-color': 'rgb(99, 99, 93)'})
    expect($('#target .annual_target-bar')).toHaveCss({'background-color': 'rgb(99, 99, 93)'})
    expect($('#target .ytd_target-bar')).toHaveCss({'background-color': 'rgb(99, 99, 93)'})
  })

})
