class PeerReviewsController < ApplicationController
  before_filter :login_required
  before_filter :find_review

  def create
    peer_review = PeerReview.new do |p|
      p.user = current_user
      p.review = @review
      p.helpful_review = params[:direction] == PeerReview.helpful
    end

    if peer_review.save
      flash[:notice] = 'Successfully created peer review'
    else
      flash[:error] = 'Failed to create peer review - ' + peer_review.errors.full_messages.join(" , ")
    end

    redirect_to [@review.item, @review]
  end

  private

  def find_review
    @review = Review.find(params[:review_id])
  end
end
