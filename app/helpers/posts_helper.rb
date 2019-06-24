# frozen_string_literal: true

module PostsHelper
  def author?(post)
    return false unless current_user
    current_user.id == post.user_id
  end

  def logged_in_user_feed_posts
    following_posts = current_user.fetch_following_user_posts
    @posts = Post.my_posts(current_user).or(following_posts).order(created_at: :desc)
  end

  def unlogged_in_user_feed_posts
    @posts = Post.where(publishing_policy: :unlimited).order(created_at: :desc)
  end
end
