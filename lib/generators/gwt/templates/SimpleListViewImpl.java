package <%= views_package %>;

import <%= models_package %>.<%= class_name %>;
import <%= presenters_package %>.<%= class_name %>Presenter;

import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.uibinder.client.UiTemplate;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.Widget;
 
import static de.mkristian.gwt.rails.places.RestfulActionEnum.SHOW;
<% unless options[:read_only] -%>
import static de.mkristian.gwt.rails.places.RestfulActionEnum.EDIT;
import static de.mkristian.gwt.rails.places.RestfulActionEnum.DESTROY;
<% end -%>

import <%= gwt_rails_package %>.places.RestfulActionEnum;
import <%= gwt_rails_package %>.views.ModelButton;

<% if options[:gin] -%>
import javax.inject.Inject;
import javax.inject.Singleton;
<% end -%>

<% if options[:gin] -%>
@Singleton
<% end -%>
public class <%= class_name %>ListViewImpl extends Composite implements <%= class_name %>ListView {

    @UiTemplate("<%= class_name %>ListView.ui.xml")
    interface Binder extends UiBinder<Widget, <%= class_name %>ListViewImpl> {}

    private static Binder BINDER = GWT.create(Binder.class);

    private <%= class_name %>Presenter presenter;

<% unless options[:readonly] -%>
    @UiField Button n_e_w;
<% end -%>
    @UiField FlexTable list;

<% if options[:gin] -%>
    @Inject
<% end -%>
    public <%= class_name %>ListViewImpl() {
        initWidget(BINDER.createAndBindUi(this));
    }

    @Override
    public void setPresenter(<%= class_name %>Presenter presenter) {
        this.presenter = presenter;
    }
<% unless options[:readonly] -%>

    @UiHandler("n_e_w")
    void onNewClick(ClickEvent event) {
        presenter.new<%= class_name %>();
    }
<% end -%>
    
    private final ClickHandler clickHandler = new ClickHandler() {
        
        @SuppressWarnings("unchecked")
        public void onClick(ClickEvent event) {
            ModelButton<Car> button = (ModelButton<Car>)event.getSource();
            switch(button.action){
                case SHOW: presenter.show(button.model.id); break; 
<% unless options[:readonly] -%>
                case EDIT: presenter.edit(button.model.id); break; 
                case DESTROY: presenter.delete(button.model); break; 
<% end -%>
            }
        }
    };
 
    private Button newButton(RestfulActionEnum action, Car model){
        ModelButton<Car> button = new ModelButton<Car>(action, model);
        button.addClickHandler(clickHandler);
        return button;
    }

    @Override
    public void reset(List<Car> models) {
        list.removeAllRows();
        list.setText(0, 0, "Id");
<% index = 0 -%>
<% attributes.each do |attribute| -%>
<%   if !(attribute.type == :text && options[:read_only]) -%>
<%     index = index + 1 -%>
        list.setText(0, <%= index %>, "<%= attribute.name.humanize -%>");
<%   end -%>
<% end -%>
        list.getRowFormatter().addStyleName(0, "gwt-rails-model-list-header");
        if (models != null) {
            int row = 1;
            for(Car model: models){
                setRow(row, model);
                row++;
            }
        }
    }

    private void setRow(int row, Car model) {
        list.setText(row, 0, model.getId() + "");
<% index = 0 -%>
<% attributes.each do |attribute| -%>
<%   if attribute.type != :has_one && attribute.type != :has_many -%>
<%     name = attribute.name.camelcase.sub(/^(.)/){ $1.downcase } -%>
<%     if !(attribute.type == :text && options[:read_only]) -%>
<%       index = index + 1 -%>
        list.setText(row, <%= index %>, model.get<%= name.camelcase %>()<%= attribute.type == :has_one || attribute.type == :belongs_to ? ' == null ? "-" : model.get' + name.camelcase + '().toDisplay()' : ' + ""' %>);
<%     end -%>
<%   end -%>
<% end -%>

        list.setWidget(row, <%= index + 1 %>, newButton(SHOW, model));
<% unless options[:readonly] -%>
        list.setWidget(row, <%= index + 2 %>, newButton(EDIT, model));
        list.setWidget(row, <%= index + 3 %>, newButton(DESTROY, model));
<% end -%>
    }
}