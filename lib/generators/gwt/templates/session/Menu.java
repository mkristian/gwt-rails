package <%= managed_package %>;

import javax.inject.Inject;
import javax.inject.Singleton;

import com.google.gwt.place.shared.PlaceController;

import static <%= gwt_rails_package %>.places.RestfulActionEnum.*;

import <%= gwt_rails_package %>.session.Guard;
import <%= gwt_rails_package %>.views.SessionMenu;

@Singleton
public class <%= application_class_name %>Menu extends SessionMenu {

    @Inject
    <%= application_class_name %>Menu(final PlaceController placeController,
                        final Guard guard){
        super(placeController, guard);
    }
}
