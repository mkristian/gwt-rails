package <%= base_package %>;

import javax.inject.Inject;

import <%= managed_package %>.ActivityFactory;
import <%= places_package %>.LoginPlace;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.place.shared.Place;

import <%= gwt_rails_package %>.Notice;
import <%= gwt_rails_package %>.places.RestfulPlace;
import <%= gwt_rails_package %>.session.Guard;
import <%= gwt_rails_package %>.session.NeedsAuthorization;
import <%= gwt_rails_package %>.session.NoAuthorization;

public class SessionActivityPlaceActivityMapper extends ActivityPlaceActivityMapper {

    private final Guard guard;

    @Inject
    public SessionActivityPlaceActivityMapper(ActivityFactory factory, Guard guard, Notice notice) {
        super(factory, notice);
        this.guard = guard;
    }

    public Activity getActivity(Place place) {
        return pessimisticGetActivity(place);
    }

    /**
     * pessimistic in the sense that default is authorisation, only the places
     * which implements {@link NoAuthorization} will be omitted by the check.
     */
    protected Activity pessimisticGetActivity(Place place) {
        if (!(place instanceof NoAuthorization)) {
            if(guard.hasSession()){
                if(!guard.isAllowed((RestfulPlace<?,?>)place)){
                    notice.warn("nothing to see");
                    return null;
                }
                //TODO move into a dispatch filter or callback filter
                guard.resetCountDown();
            }
            else {
                return LoginPlace.LOGIN.create(factory);
            }
        }
        return super.getActivity(place);
    }

    /**
     * optimistic in the sense that default is no authorisation, only the places
     * which implements {@link NeedsAuthorization} will be checked.
     */
    protected Activity optimisticGetActivity(Place place) {
        if (place instanceof NeedsAuthorization) {
            if(guard.hasSession()){
                if(!guard.isAllowed((RestfulPlace<?,?>)place)){
                    notice.warn("nothing to see");
                    return null;
                }
            }
            else {
                return LoginPlace.LOGIN.create(factory);
            }
        }
        return super.getActivity(place);
    }
}
