class Inbox::MessagesController < ApplicationController
  
  before_filter :login_required

  layout "profile.html.haml"
  def unread
    @messages = current_user.received_messages.newest.unread.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html { render :action => :index } 
    end
  end

  def index
    @messages = current_user.received_messages.newest.paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @message = Message.find(params[:id])
    if @message.receiver == current_user
      @message.update_attribute(:read, true)
    end

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @message = Message.new
    @message.sender = current_user
    @message.receiver=User.find(params[:user_id]) if params[:user_id]
    respond_to do |format|
      format.html # new.html.erb
      format.js { render :layout => false }
    end
  end
  
  def reply
    existing_message = Message.find(params[:id])
    
    @message = Message.new_reply(existing_message)
    respond_to do |format|
      format.html { render :action => "new" }
      format.js   { render :action => "new", :layout => false }
    end
  end


  # POST /messages
  # POST /messages.xml
  def create
    @message = Message.new(params[:message])
    @message.sender = current_user
    respond_to do |format|
      if @message.save
        UserMailer.deliver_email_notice(@message.receiver, @message.sender) if @message.receiver.profile.email_notice
        format.html { 
            flash[:notice] = 'Message was successfully created.'
            redirect_to(inbox_messages_url) 
            }
        format.js   { render :text => "<div class='notice_message'>Message was successfully created</div>"}
      else
        format.html { render :action => "new" }
        format.js   { render :action => "new", :layout => false }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.xml
  def destroy
    
    @message = Message.find(params[:id])
    next_message = @message.older_message
    @message.destroy

    respond_to do |format|
      format.html do
        if next_message && params[:from_show]
          redirect_to(inbox_message_url(next_message))
        else
          redirect_to(inbox_messages_url)
        end
      end
      format.xml  { head :ok }
    end
  end
end

