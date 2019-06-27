# frozen_string_literal: true

module CommentsHelper
  def author?(comment)
    return false unless current_user
    current_user.id == comment.user_id
  end
end
