module ActionController
  class Responder

    def api_behavior(error)
      raise error unless resourceful?
      if get? || put?
        display resource
      elsif post?
        display resource, :status => :created, :location => api_location
      else
        head :no_content
      end
    end
  end
end
