require 'ixtlan/guard/abstract_session'
<% if options[:remote_users] -%>
require 'heartbeat'
<% end -%>

class Session < Ixtlan::Guard::AbstractSession
  extend ActiveModel::Naming

  # TODO bug in babel which do need to use attributes instead of value when decending the object tree
  def attributes
    {'idle_session_timeout' => idle_session_timeout, 'permissions' => permissions}
  end

  def errors # needed for respond_with
    []
  end

  def self.authenticate(login, password)
    begin
      auth = Authentication.create(:login => login, :password => password)
<% if options[:remote_users] -%>
      user = User.find_by_login(auth.login)
      if user.nil?
        heart = Heartbeat.new
        heart.beat User
        user = User.find_by_login(auth.login)
        raise "user #{auth.login} not found" unless user
      end
<% else -%>
      user = User.new
      user.login = auth.login
<% end -%>
      user.name = auth.name
      user.groups = auth.groups
<% if options[:remote_users] -%>
      user.applications = auth.applications
<% end -%>
      user
    rescue ActiveResource::ResourceNotFound
      result = User.new
      result.log = "access denied #{login}" # error message
      result
    rescue ActiveResource::UnauthorizedAccess
      result = User.new
      result.log = "access denied #{login}" # error message
      result
    end
  end
end

# only dev mod without SSO needs a dummy authentication
if <%= application_class_name %>::Application.config.remote_service_url =~ /localhost/ && !(ENV['SSO'] == 'true' || ENV['SSO'] == '')

  class InvalidString < String
    def valid?(*args)
      false
    end
    def to_log
      self
    end
  end

  module DummyAuthentication

    def self.included(session)

      session.class_eval do
        def self.authenticate(login, password)
          result = User.new
          if password.blank?
            result = InvalidString.new("no password given with login: #{login}")
          elsif login.blank?
            result = InvalidString.new("no login given")
          elsif password == "behappy"
            if u = User.get!(1)
              result = u
            else
              result.login = login
              result.name = login.humanize
              result.id = 1
              result.updated_at = DateTime.now
            end
            result.groups = [Group.new('name' => login)]
            result.applications = []
          else
            result = InvalidString.new("wrong password for login: #{login}")
          end
          result
        end
      end
    end
  end

  Session.send(:include, DummyAuthentication)
end
