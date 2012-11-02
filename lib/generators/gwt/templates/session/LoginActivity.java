package <%= activities_package %>;

import javax.inject.Inject;

import <%= places_package %>.LoginPlace;

import com.google.gwt.activity.shared.AbstractActivity;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.google.inject.assistedinject.Assisted;

import <%= gwt_rails_session_package %>.LoginView;

public class LoginActivity extends AbstractActivity {

    private final LoginView view;

    @Inject
    public LoginActivity(@Assisted LoginPlace place,
            LoginView view,
            LoginView.Presenter presenter) {
        view.setPresenter(presenter);
        this.view = view;
    }

    public void start(AcceptsOneWidget display, EventBus eventBus) {
        display.setWidget(view.asWidget());
    }
}