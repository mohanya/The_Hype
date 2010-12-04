class Friends::TwittersController < ApplicationController
  before_filter(:login_required)

  def new
  end

  def create
    begin
      current_user.twitt!(params[:twitt_body])

      flash[:notice] = "Your twitt has been sent"
    rescue => err
      error = err.message
    end

    respond_to do |format|
      format.js do 
        if !error
          render(:json => {:status => 'ok', :message => 'Your twitt has been sent'}.to_json)
        else
          render(:json => {:status => 'error', :message => error}.to_json)
        end
      end
    end
  end
end
