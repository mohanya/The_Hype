namespace :vlad do
  
  desc 'Import bootstrap files'
  remote_task :setup_bootstrap, :roles => :db do
    run "#{latest_release}/script/runner -e production #{latest_release}/lib/data/make_the_site.rb"
  end
  
  desc 'First deploy of a bootstrap app'
  task :first_deploy => ['vlad:deploy', 'vlad:setup_bootstrap']
  
end