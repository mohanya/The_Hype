class TipsController < ApplicationController

   def create
     @tip  = Tip.new(:advice => params[:advice], :item_id => params[:item_id])
     @tip.user_id = current_user.id
     if @tip.save
        render(:partial => 'tips/tip', :object => @tip)
     else
        render(:text => "<p class='error_info'>Please post something smarter.</p>")
     end
   end

  def list
    @item = Item.find(params[:item_id])
    @ids = (params[:scope] == 'friends') ? current_user.friend_ids : []
    options = {:per_page => 4, :page => params[:tips], :order => 'score desc'}
    @tips = @ids.empty?  ? @item.tips.paginate(options) : @item.tips.paginate(options.merge(:user_id.in => @ids))
    render :partial => 'tips/tip_block', :object  => @tips
  end

  def vote
    @tip = Tip.find(params[:id])
    type = (params[:vote] == 'up') ? 1 : -1
    @vote = Vote.new(:user_id => current_user.id, :tip_id => @tip.id, :rate => type)
    if @vote.save
      @vote.score_tip
      @tip = @vote.tip
    end
    render(:text => @tip.score.to_s)
  end
end
