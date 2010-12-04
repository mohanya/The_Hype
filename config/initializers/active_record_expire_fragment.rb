class ActiveRecord::Base
  def expire_fragment(*args)
      ActionController::Base.new.expire_fragment(*args)
  end
end

