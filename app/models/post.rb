class Post < ActiveRecord::Base
  CATEGORY_TYPES = ["Lost & Found", "Jobs", "Misc"]
  belongs_to :user
  has_many :comment
  validates :title, :content, presence: true
  validates :category, inclusion: CATEGORY_TYPES
end