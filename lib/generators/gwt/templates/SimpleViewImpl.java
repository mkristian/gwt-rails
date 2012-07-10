package <%= views_package %>;

import <%= base_package %>.<%= application_class_name %>Confirmation;
import <%= editors_package %>.<%= class_name %>Editor;
import <%= models_package %>.<%= class_name %>;
import <%= presenters_package %>.<%= class_name %>Presenter;

import com.google.gwt.core.client.GWT;
import com.google.gwt.editor.client.SimpleBeanEditorDriver;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.uibinder.client.UiTemplate;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.Widget;

<% if options[:gin] -%>
import javax.inject.Inject;
import javax.inject.Singleton;
<% end -%>

<% if options[:gin] -%>
@Singleton
<% end -%>
public class <%= class_name %>ViewImpl extends Composite implements <%= class_name %>View {

  @UiTemplate("<%= class_name %>View.ui.xml")
  interface Binder extends UiBinder<Widget, <%= class_name %>ViewImpl> {}

  interface EditorDriver extends SimpleBeanEditorDriver<<%= class_name %>, <%= class_name %>Editor> {}

  private final Binder BINDER = GWT.create(Binder.class);

  private final EditorDriver editorDriver = GWT.create(EditorDriver.class);

  private final <%= application_class_name %>Confirmation confirmation;  

  private <%= class_name %>Presenter presenter;
<% if options[:optimistic] -%>
  private boolean editable = false;
<% end -%>
  private boolean dirty = false;

  @UiField <%= class_name %>Editor editor;
<% unless options[:singleton] -%>
  @UiField Button list;
<% end -%>
<% unless options[:read_only] -%>
<% unless options[:singleton] -%>
  @UiField Button n_e_w;
<% end -%>
<% if options[:optimistic] -%>
  @UiField Button reload;
<% end -%>
  @UiField Button edit;
<% unless options[:singleton] -%>
  @UiField Button create;
<% end -%>
  @UiField Button save;
  @UiField Button cancel;
<% unless options[:singleton] -%>
  @UiField Button delete;
<% end -%>
<% end -%>

<% if options[:gin] -%>
  @Inject
<% end -%>
  public <%= class_name %>ViewImpl(<%= application_class_name %>Confirmation confirmation) {
      this.confirmation = confirmation;
      initWidget(BINDER.createAndBindUi(this));
      editorDriver.initialize(editor);
  }

  @Override
  public void setPresenter(<%= class_name %>Presenter presenter) {
      this.presenter = presenter;
  }

  @Override
  public void show(<%= class_name %> model){
<% if options[:optimistic] -%>
      editable = false;
<% end -%>
<% unless options[:read_only] -%>
<% unless options[:singleton] -%>
      n_e_w.setVisible(true);
      create.setVisible(false);
      delete.setVisible(true);
<% end -%>
<% if options[:optimistic] -%>
      reload.setVisible(false);
<% end -%>
      edit.setVisible(true);
      save.setVisible(false);
      cancel.setVisible(false);
<% end -%>
      editorDriver.edit(model);
      editor.setEnabled(false);
  }
<% unless options[:read_only] -%>
<% if options[:optimistic] -%>

  @Override
  public void reload(<%= class_name %> model){
      // inherit editable from screen before
<% unless options[:singleton] -%>
      n_e_w.setVisible(true);
      create.setVisible(false);
      delete.setVisible(false);
<% end -%>
      reload.setVisible(true);
      edit.setVisible(false);
      save.setVisible(false);
      cancel.setVisible(false);
      editorDriver.edit(model);
      editor.setEnabled(editable);
  }
<% end -%>

  @Override
  public void edit(<%= class_name %> model){
<% if options[:optimistic] -%>
      editable = true;
<% end -%>
<% unless options[:singleton] -%>
      n_e_w.setVisible(true);
      create.setVisible(false);
      delete.setVisible(true);
<% end -%>
<% if options[:optimistic] -%>
      reload.setVisible(false);
<% end -%>
      edit.setVisible(false);
      save.setVisible(true);
      cancel.setVisible(true);
      editorDriver.edit(model);
      editor.setEnabled(<% if options[:cache] && options[:timestamps] -%>model.getUpdatedAt() != null<% else -%>true<% end -%>);
  }
<% unless options[:singleton] -%>

  @Override
  public void new<%= class_name %>(){
<% if options[:optimistic] -%>
      editable = true;
<% end -%>
<% unless options[:singleton] -%>
      n_e_w.setVisible(false);
      create.setVisible(true);
      delete.setVisible(false);
<% end -%>
<% if options[:optimistic] -%>
      reload.setVisible(false);
<% end -%>
      edit.setVisible(false);
      save.setVisible(false);
      cancel.setVisible(false);
      editorDriver.edit(new <%= class_name %>());
      editor.setEnabled(true);
  }
<% end -%>
<% end -%>
<% if options[:cache] -%>

  @Override
  public void reset(<%= class_name %> model) {
      editorDriver.edit(model);
<% if options[:timestamps] -%>
      editor.setEnabled(editable);
<% end -%>
  }
<% end -%>
<% unless options[:singleton] -%>

  @UiHandler("list")
  void onListClick(ClickEvent event) {
      initDirty();
      presenter.listAll();
  }
<% end -%>
<% unless options[:read_only] -%>
<% unless options[:singleton] -%>

  @UiHandler("n_e_w")
  void onNewClick(ClickEvent event) {
      initDirty();
      presenter.new<%= class_name %>();
  }
  
  @UiHandler("create")
  void onCreateClick(ClickEvent event) {
      dirty = false;
      presenter.create(editorDriver.flush());
  }

  @UiHandler("delete")
  void onDeleteClick(ClickEvent event) {
      String message = editorDriver.isDirty() ?
          "really delete ? there are unsaved data !" :
          "really delete ?";
      if (confirmation.confirm(message)){
          presenter.delete(editorDriver.flush());
      }
  }
<% end -%>
<% if options[:optimistic] && !options[:read_only] -%>

  @UiHandler("reload")
  void onReloadClick(ClickEvent event) {
      dirty = false;
      if (editable) {
          presenter.edit(<% unless options[:singleton] %>editor.id.getValue()<% end -%>);
      }
      else {
          presenter.show(<% unless options[:singleton] %>editor.id.getValue()<% end -%>);
      }
  }
<% end -%>

  @UiHandler("edit")
  void onEditClick(ClickEvent event) {
      initDirty();
      presenter.edit(<% unless options[:singleton] %>editor.id.getValue()<% end -%>);
  }

  @UiHandler("save")
  void onSaveClick(ClickEvent event) {
      dirty = false;
      presenter.save(editorDriver.flush());
  }

  @UiHandler("cancel")
  void onCancelClick(ClickEvent event) {
      dirty = false;
      presenter.show(<% unless options[:singleton] %>editor.id.getValue()<% end -%>);
  }
<% end -%>

  private void initDirty(){
      dirty = <% if options[:optimistic] -%>editable && <% end -%>(editorDriver == null ? false : editorDriver.isDirty());
  }

  @Override
  public boolean isDirty() {
      return dirty;
  }
}
