describe('metrics.js', function() {
  describe('plotlyDate', function() {
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

    it('extracts the y-axis field', function() {
      expect(extractY(
        { time: '2014-11-30T00:11:09.000+00:00', value: 9653 }
      )).toEqual('value')
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

      expect(getPoints(metrics)).toEqual(
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
          ]
        }
      )
    })

    it('extracts a title from a URL', function() {
      expect(
        extractTitle(
          'http://localhost:9292/metrics/certificated-datasets/2013-01-01T00:00:00/2016-02-01T00:00:00'
        )
      ).toEqual(
        'Certificated Datasets'
      )
    })
  })
})
