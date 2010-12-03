class Inbox::NoticesController < ApplicationController  
  before_filter :login_required
  layout "profile.html.haml"

  def index
    @notices = current_user.notices.all(:order => 'created_at DESC')
    for notice in @notices do
        notice.update_attribute(:deleted_at, Time.now)
    end
    Notice.delay.remove
  end
end
