package <%= views_package %>;

import java.util.List;

import <%= models_package %>.<%= class_name %>;
import <%= presenters_package %>.<%= class_name %>Presenter;

import com.google.gwt.user.client.ui.IsWidget;
<% if options[:gin] -%>
import com.google.inject.ImplementedBy;

@ImplementedBy(<%= class_name %>ListViewImpl.class)
<% end -%>
public interface <%= class_name %>ListView extends IsWidget {

    void setPresenter(<%= class_name %>Presenter presenter);

    void reset(List<<%= class_name %>> models);
}