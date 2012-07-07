package <%= presenters_package %>;

import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.google.gwt.user.client.ui.IsWidget;

import <%= base_package %>.<%= application_class_name %>ErrorHandler;

public class AbstractPresenter {

    protected final <%= application_class_name %>ErrorHandler errors;
    private AcceptsOneWidget display;

    public AbstractPresenter(<%= application_class_name %>ErrorHandler errors){
        this.errors = errors;
    }

    public void setDisplay(AcceptsOneWidget display){
        this.display = display;
        this.errors.setDisplay(display);
    }

    protected void setWidget(IsWidget view) {
        display.setWidget(view.asWidget());
    }
}
