class ReviewsController < ApplicationController
  before_filter :login_required, :except => [:show]
  before_filter :find_item
  
  include ApplicationHelper
  
  def show
    @review = Review.find(params[:id])
    @partial_title = "[#{@review.overall_score}] #{@review.first_word_list}"
    @page_description = "#{@review.short_description} #{@review.description}"
    @page_image_src = score_image_url(@review.overall_score)
  end
  
  def new
    @review = @item.reviews.build
    @item_favorite = ItemFavorite.first(:item_id => @item.id, :user_id => current_user.id, :favorite => true)
    case @item.category.api_source
      when "product" : render 'reviews/new/product', :layout => false and return
      when "music-artist" : render 'reviews/new/music', :layout => false and return
      when "music-album" : render 'reviews/new/music', :layout => false and return
      when "music-track" : render 'reviews/new/music', :layout => false and return
      when "movie" : render 'reviews/new/movie', :layout => false and return
      when "event" : render 'reviews/new/event', :layout => false and return
      when "person" : render 'reviews/new/person', :layout => false and return
      when "place" : render 'reviews/new/place', :layout => false and return
      when "web" : render 'reviews/new/web', :layout => false and return
      else render 'reviews/new/product', :layout => false and return
    end

  end
  
  def create
    @user = current_user
    @review = @item.reviews.build(params[:review].merge({:item_category_id => @item.category_id}))
    @review.user_id = current_user.id
    respond_to do |format|
      if @review.save 
        Label.delay.create_many_with_type(@review.id, @item.id, @user.id, 'pro', params[:pro_list]) 
        Label.delay.create_many_with_type(@review.id, @item.id, @user.id, 'con', params[:con_list]) 
        flash[:notice] = "Your Hype has been saved" unless request.xhr?
        if params[:tweet_hype].to_s == "true" and  @review.user.twitter? 
          @review.delay.get_tweeted
          flash[:notice] += " and it will be tweeted on Twitter"
        elsif  params[:tweet_hype].to_s == "true"
           redirect_to  "/apis/twitter/auth?from=#{item_path(@review.item_id)}" and return
        end
        format.html {redirect_to item_url(@item)} if params[:from_wizard].empty?
        format.js {render(:json => {:status => "ok", :rating => @item.score.round.to_f.to_s, :message => "Your hype has been saved"}.to_json)}
      else
        flash[:warning] = "There was an issue saving your Hype:\n"
         unless @review.errors.empty?
          (flash[:warning] = @review.errors.on(:item_id))
        end
        
        format.html {redirect_to item_url(@item)} if params[:from_wizard].empty?
        format.js {render(:json => {:status => "error", :message => flash[:warning]}.to_json)}
      end
    end
  end

  def list
    @ids = (params[:scope] == 'friends') ? current_user.friend_ids : false
    options = {:per_page => 8, :page => params[:reviews]}
    @reviews = @ids ? @item.reviews.paginate(options.merge(:user_id.in => @ids)) : @item.reviews.paginate(options)
    render :partial => 'reviews/review_block', :object  => @reviews
  end

  protected
  
  def find_item
    @item = Item.first(:id =>params[:item_id], :select => 'id, name, category_id')
  end

end
