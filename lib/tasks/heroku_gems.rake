namespace :gems do
  desc "Generate .gems file for Heroku"
  task :heroku_spec => :environment do
    require 'open-uri'
    # We are using heroku stack "bamboo-ree-1.8.7" and it has no gems preinstalled  
    # you can check the stack "running heroku stack" from project directory
    #
    # installed_gems = []
    #     url = "http://installed-gems.heroku.com/"
    #     open(url).read.scan(/<li>(\w+) [^<]*<\/li>/) do |w| 
    #       installed_gems << w.first
    #     end
    
    gems = Rails.configuration.gems
    
    # output .gems
    dot_gems = File.join(RAILS_ROOT, ".gems")
    File.open(dot_gems, "w") do |f|
      output = []
      output << "rails --version '#{RAILS_GEM_VERSION}'"
      output << "gluestick --version '= 0.3.1'"
      gems.each do |gem|
        # We skip this step as described above
        # next if installed_gems.include?(gem.name)
        spec = "#{gem.name} --version '#{gem.version_requirements.to_s}'"
        spec << " --source #{gem.source}" if gem.source
        output << spec
      end
      output.sort!
      f.write output.join("\n")
      puts output.join("\n")
    end
  end
end