package <%= presenters_package %>;

import org.fusesource.restygwt.client.Method;

import com.google.gwt.user.client.ui.IsWidget;
import com.google.gwt.user.client.ui.SimplePanel;

import <%= gwt_rails_package %>.DisplayErrors;

public class AbstractPresenter {

    protected final DisplayErrors errors;
    private SimplePanel panel;

    public AbstractPresenter(DisplayErrors errors){
        this.errors = errors;
    }

    public void setPanel(SimplePanel panel){
        this.panel = panel;
    }

    protected void setupWidget(IsWidget view) {
        if (panel.getWidget() != view.asWidget()){
            panel.clear();
            panel.add(view.asWidget());
        }
    }

    protected void onError(Method method, Throwable e) {
        switch(errors.getType(e)){
            case GENERAL:
            case PRECONDITIONS:
                errors.showErrors(method);
                break;
            case CONFLICT:
                throw new RuntimeException("should never have conflicts");
        }
    }
}