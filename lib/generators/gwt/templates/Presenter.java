package <%= presenters_package %>;

<% if options[:cache] -%>
import <%= caches_package %>.<%= class_name %>Cache;
import <%= events_package %>.<%= class_name %>Event;
import <%= events_package %>.<%= class_name %>EventHandler;
<% end -%>
import <%= models_package %>.<%= class_name %>;
<% unless options[:singleton] -%>
import <%= views_package %>.<%= class_name %>ListView;
<% end -%>
import <%= views_package %>.<%= class_name %>View;
import <%= restservices_package %>.<%= class_name.pluralize %>RestService;

<% if options[:gin] -%>
import javax.inject.Inject;
<% else -%>
import com.google.gwt.core.client.GWT;
<% end -%>
<% if options[:cache] -%>
import com.google.gwt.event.shared.EventBus;
<% end -%>

import org.fusesource.restygwt.client.Method;
import org.fusesource.restygwt.client.MethodCallback;

import <%= gwt_rails_package %>.DisplayErrors;
<% if options[:cache] -%>
import de.mkristian.gwt.rails.events.ModelEvent;
import de.mkristian.gwt.rails.events.ModelEvent.Action;
<% end -%>

public class <%= class_name %>Presenter extends AbstractPresenter {

    private final <%= class_name %>View view;
<% unless options[:singleton] -%>
    private final <%= class_name %>ListView listView;
<% end -%>
    private final <%= class_name.pluralize %>RestService service<% unless options[:gin] -%> = GWT.create(<%= class_name.pluralize %>RestService.class)<% end -%>;
<% if options[:cache] -%>
    private final <%= class_name %>Cache cache;
<% end -%>

<% if options[:gin] -%>
    @Inject
<% end -%>
    public <%= class_name %>Presenter(DisplayErrors errors, <%= class_name %>View view<% unless options[:singleton] -%>, <%= class_name %>ListView listView<% end -%><% if options[:gin] -%>, <%= class_name.pluralize %>RestService service<% end -%><% if options[:cache] -%>, 
           EventBus eventBus, CarCache cache<% end -%>){
        super(errors);
        this.view = view;
        this.view.setPresenter(this);
<% unless options[:singleton] -%>
        this.listView = listView;
        this.listView.setPresenter(this);
<% end -%>
<% if options[:gin] -%>
        this.service = service;
<% end -%>
<% if options[:cache] -%>
        this.cache = cache;
        eventBus.addHandler(CarEvent.TYPE, new <%= class_name %>EventHandler(){
            @Override
            public void onModelEvent(ModelEvent<<%= class_name %>> event) {
                if (event.getAction() == Action.LOAD) {
                    if (event.getModel() != null) {
                        <%= class_name %>Presenter.this.view.reset(event.getModel());
                    }
<% unless options[:singleton] -%>
                    if (event.getModels() != null) {
                        CarPresenter.this.listView.reset(event.getModels());
                    }
<% end -%>
                }
            }
        });
<% end -%>
    }
<% if ! options[:singleton] && ! options[:readonly] -%>

    public void create(<%= class_name %> model){
        service.create(model, new MethodCallback<<%= class_name %>>() {
            @Override
            public void onSuccess(Method method, <%= class_name %> model) {
<% if options[:cache] -%>
                cache.onCreate(method, model);
<% end -%>
                view.show(model);
            }
            @Override
            public void onFailure(Method method, Throwable e) {
<% if options[:cache] -%>
                cache.onError(method, e);
<% end -%>
                onError(method, e);
            }
          });
    }
<% end -%>
<% unless options[:readonly] -%>

    public void save(final <%= class_name %> model){
        service.update(model, new MethodCallback<<%= class_name %>>() {
            @Override
            public void onSuccess(Method method, <%= class_name %> model) {
<% if options[:cache] -%>
                cache.onUpdate(method, model);
<% end -%>
                view.show(model);
            }
            @Override
            public void onFailure(Method method, Throwable e) {
<% if options[:cache] -%>
                cache.onError(method, e);
<% end -%>
                onError(model, method, e);
            }
          });
    }
<% end -%>
<% if ! options[:singleton] && ! options[:readonly] -%>

    public void delete(final <%= class_name %> model){
        service.destroy(model, new MethodCallback<Void>() {
            @Override
            public void onSuccess(Method method, Void none) {
<% if options[:cache] -%>
                cache.onDestroy(method, model);
<% end -%>
                listAll();
            }
            @Override
            public void onFailure(Method method, Throwable e) {
<% if options[:cache] -%>
                cache.onError(method, e);
<% end -%>
                onError(model, method, e);
            }
          });
    }
<% end -%>
<% unless options[:singleton] -%>

    public void listAll(){
        setupWidget(listView);
        listView.reset(cache.getOrLoadModels());
    }
<% end -%>
<% unless options[:readonly] -%>

    public void new<%= class_name %>(){
        setupWidget(view);
        view.new<%= class_name %>();
    }
<% end -%>

    public void show(<% unless options[:singleton] -%>int id<% end -%>){
        setupWidget(view);
<% if options[:cache] -%>
        view.show(cache.getOrLoadModel(id));
<% else -%>
        service.show(<% unless options[:singleton] -%>id, <% end -%>new MethodCallback<<%= class_name %>>() {
            @Override
            public void onSuccess(Method method, <%= class_name %> model) {
                view.show(model);
            }
            @Override
            public void onFailure(Method method, Throwable e) {
                onError(method, e);   
            }
          });
<% end -%>
    }
<% unless options[:readonly] -%>

    public void edit(<% unless options[:singleton] -%>int id<% end -%>){
        setupWidget(view);
<% if options[:cache] -%>
        view.edit(cache.getOrLoadModel(id));
<% else -%>
        service.show(<% unless options[:singleton] -%>id, <% end -%>new MethodCallback<<%= class_name %>>() {
            @Override
            public void onSuccess(Method method, <%= class_name %> model) {
                view.edit(model);
            }
            @Override
            public void onFailure(Method method, Throwable e) {
                onError(method, e);   
            }
          });
<% end -%>
    }
<% end -%>

    private void onError(final Car model, Method method, Throwable e) {
<% if options[:optimistic] -%>
        switch(errors.getType(e)){
            case GENERAL:
            case PRECONDITIONS:
                errors.showErrors(method);
                break;
            case CONFLICT:
                errors.show("Conflict - data was modified by someone else. Please reload the data.");
                view.reload(model);
                break;
        }
<% else -%>
        onError(method, e);
<% end -%>
    }
}