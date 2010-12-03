class AddPeerReviewScoreToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :peer_review_score, :float
  end

  def self.down
    remove_column :profiles, :peer_review_score
  end
end
