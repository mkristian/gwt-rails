package <%= activities_package %>;

<% for attribute in attributes -%>
<% if attribute.type == :belongs_to -%>
import <%= models_package %>.<%= attribute.name.classify %>;
<% end -%>
<% end -%>
import <%= places_package %>.<%= class_name %>Place;
import <%= presenters_package %>.<%= class_name %>Presenter;
<% for attribute in attributes -%>
<% if attribute.type == :belongs_to -%>
import <%= caches_package %>.<%= attribute.name.classify %>Cache;
import <%= events_package %>.<%= attribute.name.classify %>Event;
import <%= events_package %>.<%= attribute.name.classify %>EventHandler;
<% end -%>
<% end -%>

import com.google.gwt.activity.shared.AbstractActivity;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.google.inject.Inject;
import com.google.inject.assistedinject.Assisted;

import <%= gwt_rails_package %>.places.RestfulActionEnum;

public class <%= class_name %>Activity extends AbstractActivity {

    private final <%= class_name %>Place place;
    private final <%= class_name %>Presenter presenter;
<% attributes.select { |a| a.type == :belongs_to }.each do |attribute| -%>
    private final <%= attribute.name.classify.to_s.pluralize %>Cache <%= attribute.name.pluralize %>Cache;
<% end -%>
    
    @Inject
    public <%= class_name %>Activity(@Assisted <%= class_name %>Place place, <%= class_name %>Presenter presenter<% if attribute.type == :belongs_to -%>
, <%= attribute.name.classify.to_s.pluralize %>Cache <%= attribute.name.pluralize %>Cache<% end -%>) {
        this.place = place;
        this.presenter = presenter;
<% attributes.select { |a| a.type == :belongs_to }.each do |attribute| -%>
        this.<%= attribute.name.pluralize %>Cache = <%= attribute.name.pluralize %>Cache;
<% end -%>
<% for attribute in attributes -%>
<% if attribute.type == :belongsss_to -%>
    
        view.reset<%= attribute.name.classify.to_s.pluralize %>(null);
        <%= attribute.name %>RestService.index(new MethodCallback<List<<%= attribute.name.classify %>>>() {
            
            public void onSuccess(Method method, List<<%= attribute.name.classify %>> response) {
                view.reset<%= attribute.name.classify.to_s.pluralize %>(response);
            }
            
            public void onFailure(Method method, Throwable exception) {
                notice.error("failed to load <%= attribute.name.pluralize %>");
            }
        });
<% end -%>
<% end -%>
    }

    public void start(AcceptsOneWidget display, EventBus eventBus) {
        presenter.init(display<% if options[:cache] -%>, eventBus<% end -%>);
        switch(RestfulActionEnum.valueOf(place.action)){
<% unless options[:read_only] -%>
            case EDIT:
                presenter.edit(<% unless options[:singleton] -%>place.id<% end -%>);
                break;
<% end -%>
            case SHOW:
                presenter.show(<% unless options[:singleton] -%>place.id<% end -%>);
                break;
<% if ! options[:read_only] && ! options[:singleton] -%>
            case NEW:
                presenter.new<%= class_name %>();
                break;
<% end -%>
<% unless options[:singleton] -%>
            case INDEX:
            default:
                presenter.listAll();
                break;
<% end -%>
        }
    }

    @Override
    public String mayStop() {
        if (presenter.isDirty()){
            return "there are unsaved data.";
        }
        else {
            return null;
        }
    }
}
