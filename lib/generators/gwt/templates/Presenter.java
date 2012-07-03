<% indent = options[:place] ? ' ' * 4 : '' -%>
package <%= presenters_package %>;

import <%= base_package %>.<%= application_class_name %>ErrorHandler;
<% if options[:cache] -%>
import <%= caches_package %>.<%= class_name %>Cache;
import <%= events_package %>.<%= class_name %>Event;
import <%= events_package %>.<%= class_name %>EventHandler;
<% end -%>
import <%= models_package %>.<%= class_name %>;
<% if options[:place] -%>
import <%= places_package %>.<%= class_name %>Place;
<% end -%>
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
<% if options[:place] -%>
import com.google.gwt.place.shared.PlaceController;
<% end -%>
import com.google.gwt.user.client.ui.AcceptsOneWidget;

import org.fusesource.restygwt.client.Method;
import org.fusesource.restygwt.client.MethodCallback;

<% if options[:cache] -%>
import <%= gwt_rails_package %>.ErrorHandler.Type;
import <%= gwt_rails_package %>.events.ModelEvent;
<% end -%>
<% if options[:place] -%>
import <%= gwt_rails_package %>.places.RestfulActionEnum;
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
<% if options[:place] -%>
    private final PlaceController places;
<% end -%>

<% if options[:gin] -%>
    @Inject
<% end -%>
    public <%= class_name %>Presenter(<%= application_class_name %>ErrorHandler errors, <%= class_name %>View view<% unless options[:singleton] -%>, <%= class_name %>ListView listView<% end -%><% if options[:gin] -%>, <%= class_name.pluralize %>RestService service<% end -%><% if options[:cache] -%>, 
	   <%= class_name %>Cache cache<% end -%><% if options[:place] -%>, PlaceController places<% end -%>){
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
<% end -%>
<% if options[:place] -%>
        this.places = places;
<% end -%>
    }

    public void init(AcceptsOneWidget display<% if options[:cache] -%>, EventBus eventBus<% end -%>){
        setDisplay(display);
<% if options[:cache] -%>
        eventBus.addHandler(<%= class_name %>Event.TYPE, new <%= class_name %>EventHandler(){
            @Override
            public void onModelEvent(ModelEvent<<%= class_name %>> event) {
                switch(event.getAction()){
                    case LOAD:
                        if (event.getModel() != null) {
                            view.reset(event.getModel());
                        }
<% unless options[:singleton] -%>
                        if (event.getModels() != null) {
                            listView.reset(event.getModels());
                        }
<% end -%>
                        break;
                    case ERROR:
                        errors.onError(null, errors.getType(event.getThrowable()));
                        break;
                }
            }
        });
<% end -%>
    }
<% if ! options[:singleton] && ! options[:readonly] -%>

    public void create(final <%= class_name %> model){
        service.create(model, new MethodCallback<<%= class_name %>>() {
            @Override
            public void onSuccess(Method method, <%= class_name %> model) {
<% if options[:cache] -%>
                cache.onCreate(method, model);
<% end -%>
<% if options[:place] -%>
                places.goTo(new <%= class_name %>Place(model, RestfulActionEnum.SHOW));
<% else -%>
                view.show(model);
<% end -%>
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
<% unless options[:readonly] -%>

    public void save(final <%= class_name %> model){
        service.update(model, new MethodCallback<<%= class_name %>>() {
            @Override
            public void onSuccess(Method method, <%= class_name %> model) {
<% if options[:cache] -%>
                cache.onUpdate(method, model);
<% end -%>
<% if options[:place] -%>
                places.goTo(new <%= class_name %>Place(model, RestfulActionEnum.SHOW));
<% else -%>
                view.show(model);
<% end -%>
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
<% if options[:place] -%>
                <%= class_name %>Place next = new <%= class_name %>Place(RestfulActionEnum.INDEX);
                if (places.getWhere().equals(next)) {
                    listView.reset(cache.getOrLoadModels());
                }
                else {
                    places.goTo(next);
                }
<% else -%>
                listAll();
<% end -%>
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
<% if options[:place] -%>
        <%= class_name %>Place next = new <%= class_name %>Place(RestfulActionEnum.INDEX);
        if (places.getWhere().equals(next)) {
<% end -%>
        <%= indent -%>setWidget(listView);
        <%= indent -%>listView.reset(cache.getOrLoadModels());
<% if options[:place] -%>
        }
        else {
            places.goTo(next);
        }
<% end -%>
    }
<% end -%>
<% unless options[:readonly] -%>

    public void new<%= class_name %>(){
<% if options[:place] -%>
        <%= class_name %>Place next = new <%= class_name %>Place(RestfulActionEnum.NEW);
        if (places.getWhere().equals(next)) {
<% end -%>
        <%= indent -%>setWidget(view);
        <%= indent -%>view.new<%= class_name %>();
<% if options[:place] -%>
        }
        else {
            places.goTo(next);
        }
<% end -%>
    }
<% end -%>

    public void show(<% unless options[:singleton] -%>int id<% end -%>){
<% if options[:place] -%>
        <%= class_name %>Place next = new <%= class_name %>Place(id, RestfulActionEnum.SHOW);
        if (places.getWhere().equals(next)) {
<% end -%>
        <%= indent -%>setWidget(view);
<% if options[:cache] -%>
        <%= indent -%>view.show(cache.getOrLoadModel(id));
<% else -%>
        <%= indent -%>service.show(<% unless options[:singleton] -%>id, <% end -%>new MethodCallback<<%= class_name %>>() {
            <%= indent -%>@Override
            <%= indent -%>public void onSuccess(Method method, <%= class_name %> model) {
                <%= indent -%>view.show(model);
            <%= indent -%>}
            <%= indent -%>@Override
            <%= indent -%>public void onFailure(Method method, Throwable e) {
                <%= indent -%>onError(method, e);   
            <%= indent -%>}
          <%= indent -%>});
<% end -%>
<% if options[:place] -%>
        }
        else {
            places.goTo(next);
        }
<% end -%>
    }
<% unless options[:readonly] -%>

    public void edit(<% unless options[:singleton] -%>int id<% end -%>){
<% if options[:place] -%>
        <%= class_name %>Place next = new <%= class_name %>Place(id, RestfulActionEnum.EDIT);
        if (places.getWhere().equals(next)) {
<% end -%>
        <%= indent %>setWidget(view);
<% if options[:cache] -%>
        <%= indent %>view.edit(cache.getOrLoadModel(id));
<% else -%>
        <%= indent %>service.show(<% unless options[:singleton] -%>id, <% end -%>new MethodCallback<<%= class_name %>>() {
            <%= indent %>@Override
            <%= indent %>public void onSuccess(Method method, <%= class_name %> model) {
                <%= indent %>view.edit(model);
            <%= indent %>}
            <%= indent %>@Override
            <%= indent %>public void onFailure(Method method, Throwable e) {
                <%= indent %>onError(method, e);   
            <%= indent %>}
          <%= indent %>});
<% end -%>
<% if options[:place] -%>
        }
        else {
            places.goTo(next);
        }
<% end -%>
    }
<% end -%>

    private void onError(final <%= class_name %> model, Method method, Throwable e) {
        Type type = errors.getType(e);
<% if options[:optimistic] -%>
        if (type == Type.CONFLICT){
            cache.purge(model);
            view.reload(model);
        }
<% end -%>
        errors.onError(method, type);
    }
<% if options[:place] -%>

    public boolean isDirty() {
        return view.isDirty();
    }
<% end -%>
}