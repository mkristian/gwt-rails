require 'rest-client'
require 'json'

module RestClient
  class Resource
    def delete(payload, additional_headers={}, &block)
      headers = (options[:headers] || {}).merge(additional_headers)
      Request.execute(options.merge(
              :method => :delete,
              :url => url,
              :payload => payload,
              :headers => headers), &(block || @block))
    end
  end
end

class TestRestClient

  def initialize(root, prefix = root, port = ENV['TEST_PORT'] || 3000)
    @r = RestClient::Resource.new("http://localhost:#{port}/#{prefix}")
    @root = root.to_s
  end

  def resource(params)
    if params && params['id']
      @r[params['id']]
    else
      @r
    end
  end

  def all
    JSON.load(@r.get)
  end

  def size
    all.size
  end

  def retrieve(params = nil)
    JSON.load(resource(params).get())[@root]
  end

  def create(params = {})
    JSON.load(@r.post({@root => params}))[@root]
  end

  def update(params)
    JSON.load(resource(params).put({@root => params}))[@root]
  end

  def delete(params)
    resource(params).delete({@root => params})
  end

end
