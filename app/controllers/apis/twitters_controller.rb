class Apis::TwittersController < ApplicationController
  
  before_filter(:link_client)

  def new  
    begin
      oauth_token = session['oauth_request_token_token']
      oauth_secret = session['oauth_request_token_secret']

      access_token = @oauth.authorize_from_request(oauth_token, oauth_secret, params[:oauth_verifier])


      profile = current_user.profile
      profile.twitter_token = access_token[0]
      profile.twitter_secret = access_token[1]

      raise 'Could not save user' if !profile.save


      session['oauth_request_token_token'] = nil
      session['oauth_request_token_secret'] = nil

      flash[:notice] = 'your account has been linked from Twitter'
    rescue => err
      flash[:notice] = err.message
#      flash[:error] = 'There was an error during processing the response from Twitter.'
    end

    redirect_to(session[:twitter_callback])
  end

  def auth
    if params[:from] == 'wizard'
      act = scope_path(current_user, 'settings')
    elsif params[:from] == 'profile'
      act = user_path(current_user)
    elsif params[:from] == 'settings'      
      act = scope_path current_user.id
    else
      act = params[:from]
    end    
    session[:twitter_callback] = act

    begin
      request_token = @oauth.request_token(:oauth_callback => @twitter_keys['callback'])

      session['oauth_request_token_token'] = request_token.token
      session['oauth_request_token_secret'] = request_token.secret

      redirect_to request_token.authorize_url
    rescue => err
      flash[:notice] = err.message
      redirect_to(act)
    end
  end

  def unlink
    user = User.find(current_user.id)
    user.unlink_twitter
    flash[:notice] = "your account has been unlinked from Twitter"

    redirect_to(scope_path(user, 'settings'))
  end

  def show
     @text = params[:text]
     @item = Item.find(params[:item_id])
     #@result = []
     #params.each do |k,v|
     #  @result << "#{k} -> #{v}<br />"
     #end

     #@test = @result.join(", ")
     #@item = Item.first(:id => 'first', :select => 'name')
     render(:partial => 'shared/twitter_box')
  end

  def tweet
     current_user.delay.tweet(params[:tweet_text]) 
     render(:text  => "<div class='notice_message tweeted'>Good news, your tweet got tweeted.</div>")
  end

  private

  def link_client
    get_twitter_keys()
    @oauth = Twitter::OAuth.new(@twitter_keys['token'], @twitter_keys['secret'])
  end

  def post_to_twitter
  end
end
