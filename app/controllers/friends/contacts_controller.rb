class Friends::ContactsController < ApplicationController

  before_filter(:login_required)

  def new
  end
  
  def create
    begin
      @contacts = Contacts::Gmail.new(params[:login], params[:password]).contacts.each{|e| e[0].nil? ? e << e[1].first.capitalize : e << e[0].first.capitalize}.sort_by{|e| e[2]}
    rescue => err
      error = err.message
    end

    respond_to do |format|
      if !error
        format.js {render(:json => {:status => "ok", :emails => @contacts}.to_json)}
      else
        format.js {render(:json => {:status => "error", :message => error}.to_json)}
      end
    end
  end

end
