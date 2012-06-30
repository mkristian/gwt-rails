package <%= caches_package %>;

import java.util.List;

import javax.inject.Inject;
import javax.inject.Singleton;

import <%= events_package %>.<%= class_name %>Event;
import <%= models_package %>.<%= class_name %>;
<% if options[:session] -%>
import <%= models_package %>.User;
<% end -%>
import <%= restservices_package %>.<%= class_name.pluralize %>RestService;

import com.google.gwt.event.shared.EventBus;

import <%= gwt_rails_package %>.caches.AbstractModelCache;
import <%= gwt_rails_package %>.events.ModelEvent;
import <%= gwt_rails_package %>.events.ModelEvent.Action;
<% if options[:session] -%>
import <%= gwt_rails_package %>.session.SessionManager;
<% end -%>

<% if options[:gin] -%>
@Singleton
<% end -%>
public class <%= class_name %>Cache extends AbstractModelCache<<%= class_name %>>{

    private final <%= class_name.pluralize %>RestService restService;

<% if options[:gin] -%>
    @Inject
<% end -%>
    <%= class_name %>Cache(<% if options[:session] -%>SessionManager<User> manager, <% end -%> EventBus eventBus, <%= class_name.pluralize %>RestService restService) {
        super(<% if options[:session] -%>manager, <% end -%>eventBus);
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
        // TODO something with the throwable e
        return new <%= class_name %>Event((<%= class_name %>)null, Action.ERROR);
    }
}