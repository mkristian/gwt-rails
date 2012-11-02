package <%= views_package %>;

import <%= models_package %>.<%= class_name %>;
import <%= presenters_package %>.<%= class_name %>Presenter;

import com.google.gwt.user.client.ui.IsWidget;
<% if options[:gin] -%>
import com.google.inject.ImplementedBy;

@ImplementedBy(<%= class_name %>ViewImpl.class)
<% end -%>
public interface <%= class_name %>View extends IsWidget {

    void setPresenter(<%= class_name %>Presenter presenter);

    void show(<%= class_name %> model);
<% unless options[:read_only] -%>
<% if options[:optimistic] -%>

    void reload(<%= class_name %> model);
<% end -%>

    void edit(<%= class_name %> model);
<% end -%>
<% if ! options[:singleton] && ! options[:read_only] -%>

    void new<%= class_name %>();
<% end -%>
<% if options[:cache] -%>

    void reset(<%= class_name %> model);
<% end -%>
<% if options[:place] -%>

    boolean isDirty();
<% end -%>
}
