describe('tasklist.js', function() {

  describe('tasklist', function() {

    it('lists tasks', function() {
      var fixture = setFixtures("<ul id='tasklist'></ul>")
      var tasks = [
        {
          "id": "51221151c834c4d4610022a4",
          "title": "Create 1 ODI Story",
          "due": "2013-03-31T11:00:00Z",
          "progress": 0.75,
          "no_checklist": false
        },
        {
          "id": "5122115b5be0843405002d10",
          "title": "8 interviews",
          "due": "2013-03-31T11:00:00Z",
          "progress": 0.75,
          "no_checklist": false
        }
      ]

      tasklist(tasks)

      expect(fixture).toContainHtml(
        '<li>Create 1 ODI Story <progress max="0" min="1" value="0.75" /></li>'
      )

      expect(fixture).toContainHtml(
        '<li>8 interviews <progress max="0" min="1" value="0.75" /></li>'
      )
    })

  })

});
