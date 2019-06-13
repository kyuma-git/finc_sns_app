json.extract! comment, :id, :text, :browse_status, :user_id, :post_id, :created_at, :updated_at
json.url comment_url(comment, format: :json)
