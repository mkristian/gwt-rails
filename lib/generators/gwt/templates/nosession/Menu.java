package <%= managed_package %>;

import javax.inject.Inject;
import javax.inject.Singleton;

import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.place.shared.PlaceController;

import static <%= gwt_rails_package %>.places.RestfulActionEnum.*;

import <%= gwt_rails_package %>.views.Menu;

@Singleton
public class <%= application_class_name %>Menu extends Menu {

    @Inject
    <%= application_class_name %>Menu(final PlaceController placeController){
        super(placeController);
    }
}
