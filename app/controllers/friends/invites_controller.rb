class Friends::InvitesController < ApplicationController
  before_filter(:login_required)
  
  def create
    if !params[:emails].empty? and !params[:email_body].empty?
      emails_amount = params[:emails].length
      #Move to background job on production
      #Delayed::Job.enqueue(EmailJob.new(params[:emails], params[:email_body], current_user))

      #For development and staging only
      email_job = EmailJob.new(params[:emails], params[:email_body], current_user)
      email_job.perform()

      message = "Your invitation has been sent to #{emails_amount} user(s)"
    end

    respond_to do |format|
      format.js {render(:json => {:status => "ok", :message => message}.to_json)}
    end
  end
end
