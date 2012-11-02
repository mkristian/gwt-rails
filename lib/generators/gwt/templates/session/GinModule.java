package <%= base_package %>;

import <%= base_package %>.<%= application_class_name %>Application;
import <%= base_package %>.<%= application_class_name %>Confirmation;
<% if options[:place] -%>
import <%= base_package %>.SessionActivityPlaceActivityMapper;
import <%= managed_package %>.<%= application_class_name %>PlaceHistoryMapper;
<% end -%>
import <%= managed_package %>.ManagedGinModule;
import <%= models_package %>.User;
import <%= presenters_package %>.LoginPresenter;
import <%= views_package %>.LoginViewImpl;

<% if options[:place] -%>
import com.google.gwt.activity.shared.ActivityMapper;
<% end -%>
<% if options[:place] -%>
import com.google.gwt.place.shared.PlaceController.Delegate;
import com.google.gwt.place.shared.PlaceHistoryMapper;
<% end -%>
import com.google.inject.Key;
import com.google.inject.Singleton;
import com.google.inject.TypeLiteral;

import <%= gwt_rails_package %>.Application;
import <%= gwt_rails_session_package %>.Guard;
import <%= gwt_rails_session_package %>.HasSession;
import <%= gwt_rails_session_package %>.LoginView;
import <%= gwt_rails_session_package %>.SessionManager;

public class <%= application_class_name %>GinModule extends ManagedGinModule {

    @Override
    protected void configure() {
        super.configure();
        bind(Application.class).to(<%= application_class_name %>Application.class);
        bind(LoginView.Presenter.class).to(LoginPresenter.class);
        bind(Guard.class).to(Key.get(new TypeLiteral<SessionManager<User>>() {})).in(Singleton.class);
        bind(HasSession.class).to(Key.get(new TypeLiteral<SessionManager<User>>() {})).in(Singleton.class);
<% if options[:place] -%>
        bind(PlaceHistoryMapper.class).to(<%= application_class_name %>PlaceHistoryMapper.class).in(Singleton.class);
        bind(ActivityMapper.class).to(SessionActivityPlaceActivityMapper.class).in(Singleton.class);
        bind(Delegate.class).to(<%= application_class_name %>Confirmation.class);
<% end -%>
        bind(<%= application_class_name %>Confirmation.class);
        bind(LoginView.class).to(LoginViewImpl.class);
    }
}
