package <%= managed_package %>;

import com.google.gwt.activity.shared.Activity;
import com.google.inject.name.Named;

import <%= places_package %>.LoginPlace;

public interface ActivityFactory {
    @Named("login") Activity create(LoginPlace place);
}