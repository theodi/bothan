function titleize(text) {
  var words = text.split('-')
  return words.map(function(word) {
    return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
  }).join(' ')
}

function addTitle(title) {
  $('h1#title').html(titleize(title));
}

function tasklist(tasks) {
  $(tasks).each(function(i, task) {
    var progress = ' <progress max="0" min="1" value="'+ task.progress +'" />'
    var li = '<li>' + task.title + progress +'</li>';
    $('#tasklist').append(li)
  })
}
