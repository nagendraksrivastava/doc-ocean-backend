class ActiveRecord::Base
  def self.current_user=(user)
    @@current_user = user
  end

  def self.current_user
    @@current_user
  end

  def current_user
    @@current_user
  end
end
