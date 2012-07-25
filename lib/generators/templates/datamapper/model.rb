class <%= class_name %><%= "< #{options[:parent].classify}" if options[:parent] %>

<% unless options[:parent] -%>
  include DataMapper::Resource

  property :id, Serial
<% end %>
<% attributes.select {|attr| !attr.reference? }.each do |attribute| -%>
  property :<%= attribute.name -%>, <%= attribute.type_class %>
<% end -%>
<% attributes.select {|attr| attr.reference? }.each do |attribute| -%>

  belongs_to :<%= attribute.name -%>
<% end -%>
<% if options[:modified_by] -%>

  belongs_to :modified_by, :class_name => "<%= options[:modified_by] -%>"
<% end -%>
<% if options[:timestamps] -%>

  timestamps :at
<% end -%>
<% if options[:singleton] -%>

  def self.instance
    self.first || self.new
  end
<% end -%>
end
