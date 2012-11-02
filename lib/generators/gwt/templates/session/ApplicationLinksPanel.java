package <%= base_package %>;

import javax.inject.Singleton;

import <%= models_package %>.Application;
import <%= models_package %>.User;

import de.mkristian.gwt.rails.views.LinksPanel;

@Singleton
public class ApplicationLinksPanel extends LinksPanel<User> {

    @Override
    protected void initUser(User user) {
        if (user != null) {
            for(Application app: user.applications){
                addLink(app.getName().equals("THIS") ? 
                    "users" : 
                    app.getName(), app.getUrl());
            }
            setVisible(true);
        }
        else {
            clear();
            setVisible(false);
        }
    }
}