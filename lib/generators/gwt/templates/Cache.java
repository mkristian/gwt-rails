package <%= caches_package %>;

import java.util.List;
<% if options[:store] -%>

import org.fusesource.restygwt.client.JsonEncoderDecoder;

import com.google.gwt.core.client.GWT;
<% end -%>
<% if options[:gin] -%>

import javax.inject.Inject;
import javax.inject.Singleton;
<% end -%>

import <%= events_package %>.<%= class_name %>Event;
import <%= models_package %>.<%= class_name %>;
<% if options[:session] -%>
import <%= models_package %>.User;
<% end -%>
import <%= restservices_package %>.<%= class_name.pluralize %>RestService;

import com.google.gwt.event.shared.EventBus;

import <%= gwt_rails_package %>.caches.AbstractModelCache<% if options[:store] -%>Store<% end -%>;
import <%= gwt_rails_package %>.events.ModelEvent;
import <%= gwt_rails_package %>.events.ModelEvent.Action;
<% if options[:session] -%>
import <%= gwt_rails_package %>.session.SessionManager;
<% end -%>

<% if options[:gin] -%>
@Singleton
<% end -%>
public class <%= class_name %>Cache<% if options[:store] -%>Store<% end -%> extends AbstractModelCache<% if options[:store] -%>Store<% end -%><<%= class_name %>>{

    private final <%= class_name.pluralize %>RestService restService;

<% if options[:store] -%>
    static interface Coder extends JsonEncoderDecoder<<%= class_name %>>{
    }
    static Coder coder = GWT.create(Coder.class);

<% end -%>
<% if options[:gin] -%>
    @Inject
<% end -%>
    <%= class_name %>Cache<% if options[:store] -%>Store<% end -%>(<% if options[:session] -%>SessionManager<User> manager, <% end -%> EventBus eventBus, <%= class_name.pluralize %>RestService restService) {
	super(<% if options[:session] -%>manager, <% end -%>eventBus<% if options[:store] -%>, coder, "<%= table_name %>"<% end -%>);
        this.restService = restService;
    }
<% if options[:timestamps] -%>

    @Override
    public <%= class_name %> getOrLoadModel(int id){
        <%= class_name %> model = get(id);
        if (model == null){
            loadModel(id);
            return newModel();
        }
        else if (model.getCreatedAt() == null) { 
            loadModel(id);
        }
        return model;
    }
<% end -%>

    @Override
    protected void loadModels() {
        restService.index(newListMethodCallback());
    }

    @Override
    protected void loadModel(int id) {
        restService.show(id, newMethodCallback());
    }

    @Override
    protected <%= class_name %> newModel() {
        return new <%= class_name %>();
    }

    @Override
    protected ModelEvent<<%= class_name %>> newEvent(List<<%= class_name %>> models, Action action) {
        return new <%= class_name %>Event(models, action);
    }

    @Override
    protected ModelEvent<<%= class_name %>> newEvent(<%= class_name %> model, Action action) {
        return new <%= class_name %>Event(model, action);
    }

    @Override
    protected ModelEvent<<%= class_name %>> newEvent(Throwable e) {
        return new <%= class_name %>Event(e);
    }
}
