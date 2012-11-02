package <%= managed_package %>;

import <%= gwt_rails_package %>.Base<%= options[:place] ? '' : 'Gin' %>Module;

import com.google.gwt.core.client.GWT;
<% if options[:place] -%>
import com.google.gwt.inject.client.assistedinject.GinFactoryModuleBuilder;
import com.google.inject.name.Names;
<% end -%>
import com.google.inject.Provider;
import com.google.inject.Singleton;

public class ManagedGinModule extends Base<%= options[:place] ? '' : 'Gin' %>Module {

   @Override
    protected void configure() {
        super.configure();
<% if options[:place] -%>
        install(new GinFactoryModuleBuilder()
            .build(ActivityFactory.class));
<% end -%>
    }
}
