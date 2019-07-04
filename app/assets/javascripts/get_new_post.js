$(function () {
  $(document).on('ajax:success', 'form', function () {
    var formdata = new FormData(this);
    let url = `http://localhost:3000/posts`
    fetch(url, {
      method: 'POST',
      body: formdata,
    })
      .then(function (response) {
        return response.text();
      })
      .then(function (post_data) {
        post = JSON.parse(post_data)
        post_url = `http://localhost:3000/posts/${post.id}`
        posted_user_url = `http://localhost:3000/users/${post.user_id}`
        image_data = JSON.parse(post.images[0].image_data).small.id
        $(
          '<div class="card m-2" style="width: 50%; min-height: 250px; position:relative; left: 25%;">' +
          '<div class="card-body">' +
          '<div class="row" style="padding: 0 16px;">' +
          '<div class="col-md-10">' +
          '<div class="card-title mb-2">' +
          '<a href="' + posted_user_url + '">' +
          post.user.name +
          '</a>' +
          '</div>' +
          '</div>' +
          '<div class="col-md-2">' +
          '<a href="' + post_url + '">' +
          '<button type="button" class="post-btn btn btn-light" style="font-size: 10px;">' +
          '詳細' +
          '</button>' +
          '</a>' +
          '</div>' +
          '</div>' +
          '<img src="/uploads/store/' + image_data + '"/>' +
          '<div class="card-text p-3 mt-1 bg-light" style="min-height: 180px;" id="post_text">' +
          post.text +
          '</div>' +
          '</div>' +
          '</div>'
        ).appendTo('#new_post')
      });
      $('.post-create')[0].reset();
  })
  $(document).on('ajax:error', 'form', function () {
    alert('テキストを入力してください');
  });
});