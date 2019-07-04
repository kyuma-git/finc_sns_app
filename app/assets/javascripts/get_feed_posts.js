$(function () {
  var page = 1;
  $("#next").click(
    function () {
      page++;
      fetch(`http://localhost:3000/api/fetch_a_page_of_posts?page=${page}`)
      .then(function (response) {
        return response.json();
      })
      .then(function (posts) {
        for (let post of posts) {
          post_url = `http://localhost:3000/posts/${post.id}`   
          posted_user_url = `http://localhost:3000/users/${post.user_id}`
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
                '<div id="text" class="card-text p-3 mt-1 bg-light" style="min-height: 180px;" id="post_text">' +
                  post.text +
                '</div>' +
              '</div>' +                
            '</div>'
          ).appendTo('#posts')
        }
      });
    }
  )
})
