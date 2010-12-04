namespace :label_stats do
  desc "Create stats for label (iPhone API)"
  # IMPORTANT comment before_create :add_integer_id in LabelStat model before run
  task :update => :environment do
    LabelStat.destroy_all
    i = 1
    Label.all.each do |label|
      stat = LabelStat.first(:item_id => label.item_id, :type => label.type, :tag => label.tag)
      if stat
        stat.value += 1 
        stat.save
      else
        LabelStat.create(:item_id => label.item_id, :type => label.type, :tag => label.tag, :value => 1, :integer_id => i)
        i += 1
      end
    end
  end  
end