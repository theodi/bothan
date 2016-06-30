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

    drawTarget(value, '', $('#target-wrapper'))

    expect($('#target .actual-bar').attr('style')).toMatch(/width:9\./)
    expect($('#target .annual_target-bar').attr('style')).toMatch(/width:100/)
    expect($('#target .ytd_target-bar').attr('style')).toMatch(/width:44\./)

    expect($('#target .flagpole').attr('style')).toMatch(/left:100/)

    expect($('#target .actual-bar span .inner').html()).toEqual('45')
    expect($('#target .annual_target-bar span .inner').html()).toEqual('486')
    expect($('#target .ytd_target-bar span .inner').html()).toEqual('215')
  })

  it('does not show a ytd target when only the annual target is present', function(){
    value = {
      "actual": 45,
      "annual_target": 486,
    }

    drawTarget(value, '', $('#target-wrapper'))

    expect($('#target-little .ytd_target-bar').length).toEqual(0)
  })

  it('sets the bar colour', function(){
    value = {
      "actual": 45,
      "annual_target": 486,
      "ytd_target": 215
    }

    drawTarget(value, '#63635d', $('#target-wrapper'))

    expect($('#target .actual-bar')).toHaveCss({'background-color': 'rgb(99, 99, 93)'})
    expect($('#target .annual_target-bar')).toHaveCss({'background-color': 'rgb(99, 99, 93)'})
    expect($('#target .ytd_target-bar')).toHaveCss({'background-color': 'rgb(99, 99, 93)'})
  })

  it('sets the actual higher than the target if that is the case', function() {
    value = {
      "actual": 500,
      "annual_target": 486,
    }

    drawTarget(value, '', $('#target-wrapper'))

    expect($('#target .actual-bar').attr('style')).toMatch(/width:100/)
    expect($('#target .annual_target-bar').attr('style')).toMatch(/width:97\./)

    expect($('#target .flagpole').attr('style')).toMatch(/left:97\./)

    expect($('#target .actual-bar span .inner').html()).toEqual('500')
    expect($('#target .annual_target-bar span .inner').html()).toEqual('486')
  })

})
