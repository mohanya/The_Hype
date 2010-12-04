 class InvitesController < ApplicationController
  
  layout "sessions.html.haml"
  
  def new
    @invite = Invite.new
  end

  def create
    if params[:invite][:email].empty?
     @email_empty=nil
    else
      @email_empty="empty"
    end
    @invite = Invite.new(:email => params[:invite][:email], :approved => true)
    @invite.add_inviter(current_user) if logged_in?
    respond_to do |format|
      if @invite.save and @invite.approve!
        format.js   { render :partial => 'success', :object => "Thank you for your request" }
        #format.html { redirect_to root_url }
      else
        flash[:warning] = @invite.errors.on(:email)
        format.js   { render :partial => 'error', :object => @invite}
        #format.html { render :action => :new }
      end
    end
  end

  def resend
    @invite = Invite.find(params[:id])
    @invite.sent_at = nil
    @invite.save
    @invite.send!
    respond_to do |format|
        format.html   { render :partial => 'success', :object => "Thank you for your request"}
        format.js   { render :partial => 'success', :object => "Thank you for your request"}
    end
  end

end
