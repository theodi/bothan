describe('metrics.js', function() {
  it('makes a date that plotly can understand', function() {
    expect(plotlyDate('2013-12-31T23:59:59.000+00:00')).toEqual(
      '2013-12-31 23:59:59'
    )
  })

  it('fixes a whole array of datestamps', function() {
    var isoDates = [
      '2016-01-22T19:10:03.000+00:00',
      '2016-01-23T19:10:35.000+00:00',
      '2016-01-24T19:10:03.000+00:00',
      '2016-01-26T15:21:47.000+00:00',
      '2016-01-28T16:22:39.000+00:00',
      '2016-01-30T00:27:34.000+00:00',
      '2016-01-31T00:27:37.000+00:00'
    ]

    expect(mapDates(isoDates)).toEqual(
      [
        '2016-01-22 19:10:03',
        '2016-01-23 19:10:35',
        '2016-01-24 19:10:03',
        '2016-01-26 15:21:47',
        '2016-01-28 16:22:39',
        '2016-01-30 00:27:34',
        '2016-01-31 00:27:37'
      ]
    )
  })

  it('extracts multiple values for a pie chart', function() {
    var hash = {
      total: {
        male: 24,
        female: 37
      }
    }

    expect(extractValues(hash, '//total')).toEqual([24, 37])
  })

  it('extracts multiple keys for a pie chart', function() {
    var hash = {
      total: {
        male: 24,
        female: 37
      }
    }

    expect(extractKeys(hash, '//total')).toEqual(['male', 'female'])
  })

  it('transforms an array of keys->values into two arrays', function() {
    var metrics = [
      { time: '2014-11-30T00:11:09.000+00:00', value: 9653 },
      { time: '2014-12-01T00:10:56.000+00:00', value: 9653 },
      { time: '2014-12-02T00:10:07.000+00:00', value: 9655 },
      { time: '2014-12-04T16:17:29.000+00:00', value: 10227 },
      { time: '2014-12-05T16:17:08.000+00:00', value: 10228 },
      { time: '2014-12-06T16:19:46.000+00:00', value: 10228 },
      { time: '2014-12-07T16:16:41.000+00:00', value: 10228 },
      { time: '2014-12-08T16:18:56.000+00:00', value: 10228 }
    ]

    expect(getPoints(metrics, { prefix: '', suffix: ''})).toEqual(
      {
        x: [
          '2014-11-30 00:11:09',
          '2014-12-01 00:10:56',
          '2014-12-02 00:10:07',
          '2014-12-04 16:17:29',
          '2014-12-05 16:17:08',
          '2014-12-06 16:19:46',
          '2014-12-07 16:16:41',
          '2014-12-08 16:18:56'
        ],
        y: [
          9653,
          9653,
          9655,
          10227,
          10228,
          10228,
          10228,
          10228
        ],
        text: [
          '9653',
          '9653',
          '9655',
          '10227',
          '10228',
          '10228',
          '10228',
          '10228'
        ]
      }
    )
  })

  it ('adds a prefix to some text', function() {
    var metrics = [
      { time: '2014-11-30T00:11:09.000+00:00', value: 123 },
      { time: '2014-12-01T00:10:56.000+00:00', value: 456 },
    ]
  
    expect(getPoints(metrics, { prefix: '£', suffix: ''})).toEqual({
      x: [
        '2014-11-30 00:11:09',
        '2014-12-01 00:10:56',
      ],
      y: [
        123,
        456
      ],
      text: [
        '£123',
        '£456'
      ]
    })
  })
  
  it ('adds a suffix to some text', function() {
    var metrics = [
      { time: '2014-11-30T00:11:09.000+00:00', value: 123 },
      { time: '2014-12-01T00:10:56.000+00:00', value: 456 },
    ]
  
    expect(getPoints(metrics, { prefix: '', suffix: '%'})).toEqual({
      x: [
        '2014-11-30 00:11:09',
        '2014-12-01 00:10:56',
      ],
      y: [
        123,
        456
      ],
      text: [
        '123%',
        '456%'
      ]
    })
  })

  it('extracts a title from a URL', function() {
    expect(
      extractTitle(
        'http://localhost:9292/metrics/certificated-datasets/2013-01-01T00:00:00/2016-02-01T00:00:00'
      )
    ).toEqual(
      'Certificated Datasets'
    )

    expect(
      extractTitle(
        'http://localhost:9292/metrics/2013-q1-completed-tasks.json'
      )
    ).toEqual(
      '2013 Q1 Completed Tasks'
    )
  })

  it('snips an extension', function() {
    expect(snipExtension('http://some.long.url/with/a/path.json')).toEqual('http://some.long.url/with/a/path')
  })

  describe('gets a number or a fails nicely', function() {
    beforeEach(function() {
      spyOn(jasmine.getGlobal(), 'unknowns').and.returnValue(['Unknown'])
    })

    it('gets a plain number', function () {
      is_a_number = {
        value: 667
      }

      expect(extractNumber(is_a_number)).toEqual(667)
    })


    it('responds nicely to a null', function() {
      is_a_null = {
        value: null
      }

      expect(extractNumber(is_a_null)).toEqual('Unknown')
    })

    it('responds nicely to an empty array', function() {
      is_an_empty_array = {
        value: [ ]
      }

      expect(extractNumber(is_an_empty_array)).toEqual('Unknown')
    })

    it('responds nicely to a complex array', function() {
      is_membership_count = {
        value: {
          total: 149,
          by_level: {
            supporter: 142,
            partner: 5,
            sponsor: 2
          }
        }
      }

      expect(extractNumber(is_membership_count)).toEqual(149)
    })

    it('responds nicely in the face of monumentally unreasonable provocation', function() {
      is_a_pathological_edge_case = {
        value: {
          '2016-01-01/2016-12-31': 2440,
          '2016-01-01/2018-12-31': 2440
        }
      }

      expect(extractNumber(is_a_pathological_edge_case)).toEqual('Unknown')
    })
  })

  describe('get a number as a bootstrap column width', function() {
    it('gets a 12 for 100%', function() {
      expect(asColumns(100)).toEqual('col-md-12')
    })

    it('gets a 1 for 0%', function() {
      expect(asColumns(0)).toEqual('col-md-1')
    })

    it('gets a 6 for 50%', function() {
      expect(asColumns(50)).toEqual('col-md-6')
    })

    it('goes to a maximum of 12 columns', function() {
      expect(asColumns(120)).toEqual('col-md-12')
    })
  })

  describe('scale numbers appropriately', function() {
    it('does nothing with a number in normal range', function() {
      expect(scaleNumber(100)).toEqual({number: 100, suffix: ''})
    })

    describe('thousands', function() {
      it('represents thousands correctly', function() {
        expect(scaleNumber(4000)).toEqual({number: (4).toFixed(1), suffix: 'K'})
      })

      it('with fractional parts', function() {
        expect(scaleNumber(6300)).toEqual({ number: '6.3', suffix: 'K' })
      })

      it('with sensible rounding', function() {
        expect(scaleNumber(89754)).toEqual({ number: '89.8', suffix: 'K' })
      })
    })

    describe('millions', function() {
      it('represents millions correctly', function() {
        expect(scaleNumber(12000000)).toEqual({ number: '12.0', suffix: 'M' })
      })

      it('with sensible rounding', function() {
        expect(scaleNumber(35656421)).toEqual({ number: '35.7', suffix: 'M' })
      })
    })

    describe('with a currency', function() {
      it('adds a currency symbol', function() {
        expect(scaleNumber(35656421, true)).toEqual({ number: '35.7', suffix: 'M' })
      })
    })
  })

  describe('attempts to extract values intelligently', function() {
    it('from a string', function() {
      metric = 150
      expect(extractY(metric)).toEqual(150)
    })

    it('from an object', function() {
      metric = {
        total: 150,
        by_thing: {
          thing_1: 1,
          thing_2: 2,
          thing_3: 3,
        }
      }
      expect(extractY(metric)).toEqual(150)
    })
  })

  describe('get either the last value or the only value', function() {
    single_metric = {
      name: "i-am-skynet",
      time: "1997-08-29T02:14:00.000-05:00",
      value: {
        actual: 3526939.9699999997,
        annual_target: 5939066.66666667,
        ytd_target: 5939066.66666667
      }
    }

    it('gets the value', function() {
      expect(lastOrOnlyValue(single_metric)).toEqual(
        {
          actual: 3526939.9699999997,
          annual_target: 5939066.66666667,
          ytd_target: 5939066.66666667
        }
      )
    })

    list_of_metrics = {
      count: 3,
      values: [
        {
          time: "2016-01-29T00:28:23.000+00:00",
          value: {
            actual: 0,
            annual_target: 0,
            ytd_target: 0,
            breakdown: { }
          }
        },
        {
          time: "2016-01-29T01:27:44.000+00:00",
          value: {
            actual: 0,
            annual_target: 0,
            ytd_target: 0,
            breakdown: { }
          }
        },
        {
          time: "2016-01-29T02:27:54.000+00:00",
          value: {
            actual: 0,
            annual_target: 0,
            ytd_target: 0,
            breakdown: { }
          }
        }
      ]
    }

    it('gets the last value', function() {
      expect(lastOrOnlyValue(list_of_metrics)).toEqual(
        {
          actual: 0,
          annual_target: 0,
          ytd_target: 0,
          breakdown: { }
        }
      )
    })
  })

  describe('embedding', function() {
    beforeEach(function() {
      spyOn(window, 'updateWindowURL');
      url = "http://example.org/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00?layout=bare&type=chart"
      setFixtures("<div id='iframe_embed'><iframe src='"+ url +"'></iframe></div><div id='embed'><textarea data-url='"+ url +"'></textarea></div>")
    })

    it('sets embed code', function() {
      setEmbedCode()

      expect($('#embed textarea').val()).toEqual("<iframe src='"+ url +"' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>")
      expect($('#iframe_embed iframe').attr('src')).toEqual(url)
    })

    it('updates embed code', function() {
      updatePage({
        boxcolour: '000',
        textcolour: 'fff'
      })

      expect($('#embed textarea').val()).toEqual("<iframe src='http://example.org/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00?layout=bare&type=chart&boxcolour=000&textcolour=fff' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>")
      expect($('#iframe_embed iframe').attr('src')).toEqual(url)
      expect(updateWindowURL).toHaveBeenCalledWith('Jasmine suite', 'http://example.org/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00?type=chart&boxcolour=000&textcolour=fff');
    })

    it('updates colours', function() {
      url = "http://example.org/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00?layout=bare&type=chart&boxcolour=000&textcolour=fff"
      setFixtures("<div id='iframe_embed'><iframe src='"+ url +"'></iframe></div><div id='embed'><textarea data-url='"+ url +"'></textarea></div>")

      updatePage({
        boxcolour: '111',
        textcolour: 'ccc'
      })
      expect($('#embed textarea').val()).toEqual("<iframe src='http://example.org/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00?layout=bare&type=chart&boxcolour=111&textcolour=ccc' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>")
      expect($('#iframe_embed iframe').attr('src')).toEqual('http://example.org/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00?layout=bare&type=chart&boxcolour=111&textcolour=ccc')
      expect(updateWindowURL).toHaveBeenCalledWith('Jasmine suite', 'http://example.org/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00?type=chart&boxcolour=111&textcolour=ccc');
    })

    it('updates data', function() {
      url = "http://example.org/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00?layout=bare&type=chart&boxcolour=000&textcolour=fff"
      setFixtures("<div id='iframe_embed'><iframe src='"+ url +"'></iframe></div><div id='embed'><textarea data-url='"+ url +"'></textarea></div>")

      updatePage({}, '2015-02-02T09:27:29+00:00', '2015-03-03T09:27:29+00:00')

      new_url = 'http://example.org/metrics/my-awesome-metric/2015-02-02T09:27:29+00:00/2015-03-03T09:27:29+00:00?layout=bare&type=chart&boxcolour=000&textcolour=fff'

      expect($('#embed textarea').val()).toEqual("<iframe src='"+ new_url +"' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>")
      expect($('#iframe_embed iframe').attr('src')).toEqual(new_url)
      expect(updateWindowURL).toHaveBeenCalledWith('Jasmine suite', 'http://example.org/metrics/my-awesome-metric/2015-02-02T09:27:29+00:00/2015-03-03T09:27:29+00:00?type=chart&boxcolour=000&textcolour=fff');
    })
  })
})
