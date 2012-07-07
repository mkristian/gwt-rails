package <%= base_package %>;
<% if options[:gin] -%>

import javax.inject.Inject;
import javax.inject.Singleton;
<% end -%>

import org.fusesource.restygwt.client.Method;

import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.google.gwt.user.client.ui.Label;

import de.mkristian.gwt.rails.ErrorHandler;
import de.mkristian.gwt.rails.Notice;

@Singleton
public class <%= application_class_name %>ErrorHandler extends ErrorHandler {

    private AcceptsOneWidget display;

    @Inject
    public <%= application_class_name %>ErrorHandler(Notice notice) {
        super(notice);
    }

    public void setDisplay(AcceptsOneWidget display){
        this.display = display;
    }

    // @Override
    // protected void generalError(Method method) {
    //     show("Error");
    // }

    // @Override
    // protected void undefinedStatus(Method method) {
    //     if (method != null) {
    //         show("Error: " + method.getResponse().getStatusText());
    //     }
    //     else {
    //         show("Error");
    //     }
    // }

    // @Override
    // protected void conflict(Method method) {
    //     show("Conflict! Data was modified by someone else. Please reload the data.");
    // }

    // @Override
    // protected void unprocessableEntity(Method method) {
    //     showErrors(method);
    // }

    // @Override
    // protected void forbidden(Method method) {
    // 	display.setWidget(new Label("Forbidden."));
    // }

    @Override
    protected void notFound(Method method) {
    	display.setWidget(new Label("Resource Not Found."));
    }
}