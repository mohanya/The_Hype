class ActivityComment < Comment
  belongs_to :activity
  acts_as_tree
end
