class Post < ApplicationRecord

  enum browse_status: { everyone: 1, only_friends: 2, inly_myself: 3 }
end
