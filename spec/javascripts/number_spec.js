describe('number.js', function() {
  beforeEach(function() {
    fixture = setFixtures("<div id='number-wrapper'><div id='number'></div></div>")
    spyOn(window, 'countUp')
  })

  describe('with multiple values', function() {
    beforeEach(function() {
      json = {
        count: 51,
        values: [
          {
            time: "2016-02-03T11:27:35.000+00:00",
            value: 221
          },
          {
            time: "2016-02-03T12:27:33.000+00:00",
            value: 222
          },
          {
            time: "2016-02-03T13:27:30.000+00:00",
            value: 223
          },
          {
            time: "2016-02-03T14:27:35.000+00:00",
            value: 224
          }
        ]
      }
    })

    it('applies a number and title', function() {
      number(json, 'My Awesome Title', $('#number-wrapper'), '', '', 'YYYY-MM-DD HH:mm')
      expect($('#number h1').html()).toEqual('My Awesome Title')
      expect($('#number h2').html()).toEqual('224')
      expect($('#number small').html()).toEqual('Last updated: 2016-02-03 14:27')
    })

    it('adds a percent sign', function() {
      number(json, 'My Awesome Title', $('#number-wrapper'), 'percentage', '', 'YYYY-MM-DD HH:mm')
      expect(window.countUp).toHaveBeenCalledWith(224, {
        useEasing : true,
        useGrouping : false,
        separator : ',',
        decimal : '.',
        suffix: '%',
        prefix: ''
      }, $('#number-wrapper'))
    })

    it('adds a pound sign', function() {
      number(json, 'My Awesome Title', $('#number-wrapper'), 'currency', '', 'YYYY-MM-DD HH:mm')
      expect(window.countUp).toHaveBeenCalledWith(224, {
        useEasing : true,
        useGrouping : false,
        separator : ',',
        decimal : '.',
        suffix: '',
        prefix: '£'
      }, $('#number-wrapper'))    })
  })

  describe('with single value', function() {
    beforeEach(function() {
      json = {
        _id: {
          $oid: "54aa73b7ef922c5d1001781e"
        },
        name: "github-outgoing-pull-requests",
        time: "2015-01-05T11:21:27.000+00:00",
        value: 2
      }
    })

    it('applies a number and title', function() {
      number(json, 'My Awesome Title', $('#number-wrapper'), '', '', 'YYYY-MM-DD HH:mm')
      expect($('#number h1').html()).toEqual('My Awesome Title')
      expect($('#number h2').html()).toEqual('2')
      expect($('#number small').html()).toEqual('Last updated: 2015-01-05 11:21')
    })
  })


});
