<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
<% attributes.select {|attr| attr.reference? }.each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
<% if !accessible_attributes.empty? -%>
  attr_accessible <%= accessible_attributes.map {|a| ":#{a.name}" }.sort.join(', ') %>
<% else -%>
  # attr_accessible :title, :body
<% end -%>
<% attributes.select {|attr| [:has_one, :has_many].include?(attr.type) }.each do |attribute| -%>
  <%= attribute.type %> :<%= attribute.name.singularize %>
<% end -%>
<% if options[:modified_by] -%>
  belongs_to :modified_by, :class_name => "<%= options[:modified_by] -%>"
  validates :modified_by_id, :presence => true
<% end -%>
<% if options[:singleton] -%>
  def self.instance
    self.first || self.new
  end
<% end -%>
end
<% end -%>
