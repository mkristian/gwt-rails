package <%= managed_package %>;

import javax.inject.Inject;
import javax.inject.Singleton;

import <%= gwt_rails_package %>.places.RestfulPlaceHistoryMapper;

@Singleton
public class <%= application_class_name %>PlaceHistoryMapper extends RestfulPlaceHistoryMapper {

    @Inject
    public <%= application_class_name %>PlaceHistoryMapper(){
    }
}
