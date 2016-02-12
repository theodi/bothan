function tasklist(tasks) {
  $(tasks).each(function(i, task) {
    var progress = ' <progress max="0" min="1" value="'+ task.progress +'" />'
    var li = '<li>' + task.title + progress +'</li>';
    $('#tasklist').append(li)
  })
}
