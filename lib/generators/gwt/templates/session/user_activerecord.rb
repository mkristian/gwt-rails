class User < ActiveRecord::Base

  attr_accessor :groups, :applications

  validates :login, :presence => true

  record_timestamps = false

end
