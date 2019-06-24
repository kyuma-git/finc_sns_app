# frozen_string_literal: true

module PostsHelper
  def author?(post)
    return false unless current_user

    current_user.id == post.user_id
  end

  def logined_user_feed_posts
    myposts = Post.where(user_id: current_user.id).pluck(:id)
    following_posts = current_user.retrieve_posts.pluck(:id)
    post_ids = myposts.concat(following_posts)
    @posts = Post.where(id: post_ids).order(created_at: :desc)
  end

  def unlogined_user_feed_posts
    @posts = Post.where(publishing_policy: :unlimited).order(created_at: :desc)
  end
end
