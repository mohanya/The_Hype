class Vote
  include MongoMapper::Document
  belongs_to :user
  belongs_to :tip
  key :_id, String 
  key :tip_id, String
  key :user_id, Integer
  key :rate, Integer
  validates_presence_of     :user_id, :tip_id
  validates_uniqueness_of   :tip_id, :scope => :user_id

  def score_tip
    new_score = self.tip.score + rate
    self.tip.update_attributes(:score => new_score)
  end
end
