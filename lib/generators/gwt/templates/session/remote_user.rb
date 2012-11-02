class RemoteUser < ActiveResource::Base
  self.site = <%= application_class_name %>::Application.config.remote_service_url
  self.headers['X-SERVICE-TOKEN'] = <%= application_class_name %>::Application.config.remote_service_token

  self.element_name = "user"
end
