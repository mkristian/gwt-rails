class User
  
  attr_accessor :login, :name, :groups

  def attributes
    {'login' => login, 'name' => name, 'groups' => groups.collect { |g| g.attributes } }
  end

  def initialize(attributes = {})
    @login = attributes['login']
    @name = attributes['name']
    @groups = (attributes['groups'] || []).collect {|g| Group.new g }
  end

end
