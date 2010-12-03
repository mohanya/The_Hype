class AddSubscriberJob < Struct.new(:email, :name)
  def perform
    cm = CampaignMonitor.new(SiteSetting.first.cm_api_key)
    cm.add_subscriber(SiteSetting.first.cm_subscribers_list, email, name)
  end
end