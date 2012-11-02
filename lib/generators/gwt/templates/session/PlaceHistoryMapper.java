package <%= managed_package %>;

import javax.inject.Inject;
import javax.inject.Singleton;

import <%= gwt_rails_package %>.places.SessionRestfulPlaceHistoryMapper;
import <%= gwt_rails_package %>.session.HasSession;

@Singleton
public class <%= application_class_name %>PlaceHistoryMapper extends SessionRestfulPlaceHistoryMapper {

    @Inject
    public <%= application_class_name %>PlaceHistoryMapper(HasSession session){
        super(session);
    }
}
