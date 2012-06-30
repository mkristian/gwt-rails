package <%= base_package %>;

import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.inject.Inject;

import <%= gwt_rails_package %>.Application;

public class <%= application_class_name %>Application implements Application {

    @Inject
    <%= application_class_name %>Application(){
    }

    public void run() {
	final SimplePanel appPanel = new SimplePanel();
	RootPanel.get().add(appPanel);
	//TODO do something here
    }
}