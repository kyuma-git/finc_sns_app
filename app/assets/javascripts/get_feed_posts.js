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
          url = `http://localhost:3000/posts/${post.id}`
          $(
            '<div class="card m-2" style="width: 50%; min-height: 250px; position:relative; left: 25%;">' +
              '<div class="card-body">' +
                '<div class="row" style="padding: 0 16px;">' +
                  '<div class="col-md-10">' +
                    '<div class="card-title mb-2">' +
                      '<span>' +
                        post.user.name +
                      '</span>' +
                    '</div>' +
                  '</div>' +
                  '<div class="col-md-2">' +
                  '<a href="' + url + '">' +
                    '<button type="button" class="post-btn btn btn-light" style="font-size: 10px;">' +
                      '詳細' +
                    '</button>' +
                  '</a>' +
                  '</div>' +
                '</div>' +
                '<div class="card-text p-3 mt-1 bg-light" style="min-height: 180px;" id="post_text">' +
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
