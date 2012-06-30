package <%= views_package %>;

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

  private <%= class_name %>Presenter presenter;
<% if options[:cache] && options[:timestamps] -%>
  private boolean editable;
<% end -%>

  @UiField <%= class_name %>Editor editor;
<% unless options[:singleton] -%>
  @UiField Button list;
<% end -%>
<% unless options[:readonly] -%>
<% unless options[:singleton] -%>
  @UiField Button n_e_w;
<% end -%>
<% if options[:optimistic] -%>
  @UiField Button reload;
<% end -%>
  @UiField Button edit;
  @UiField Button create;
  @UiField Button save;
  @UiField Button cancel;
<% unless options[:singleton] -%>
  @UiField Button delete;
<% end -%>
<% end -%>

  public <%= class_name %>ViewImpl() {
    initWidget(BINDER.createAndBindUi(this));
    editorDriver.initialize(editor);
  }

  @Override
  public void setPresenter(<%= class_name %>Presenter presenter) {
      this.presenter = presenter;
  }

  @Override
  public void show(<%= class_name %> model){
<% if options[:cache] && options[:timestamps] -%>
      editable = false;
<% end -%>
<% unless options[:readonly] -%>
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
<% unless options[:readonly] -%>
<% if options[:optimistic] -%>

  @Override
  public void reload(<%= class_name %> model){
<% unless options[:singleton] -%>
      n_e_w.setVisible(true);
      create.setVisible(false);
      delete.setVisible(true);
<% end -%>
      reload.setVisible(true);
      edit.setVisible(false);
      save.setVisible(false);
      cancel.setVisible(false);
      editorDriver.edit(model);
      editor.setEnabled(true);
  }
<% end -%>

  @Override
  public void edit(<%= class_name %> model){
<% if options[:cache] && options[:timestamps] -%>
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

  @Override
  public void new<%= class_name %>(){
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
    presenter.listAll();
  }
<% end -%>
<% unless options[:readonly] -%>
<% unless options[:singleton] -%>

  @UiHandler("n_e_w")
  void onNewClick(ClickEvent event) {
    presenter.new<%= class_name %>();
  }
  
  @UiHandler("create")
  void onCreateClick(ClickEvent event) {
    presenter.create(editorDriver.flush());
  }

  @UiHandler("delete")
  void onDeleteClick(ClickEvent event) {
      presenter.delete(editorDriver.flush());
  }
<% end -%>
<% if options[:optimistic] -%>

  @UiHandler("reload")
  void onReloadClick(ClickEvent event) {
      presenter.show(editor.id.getValue());
  }
<% end -%>

  @UiHandler("edit")
  void onEditClick(ClickEvent event) {
    presenter.edit(editor.id.getValue());
  }

  @UiHandler("save")
  void onSaveClick(ClickEvent event) {
    presenter.save(editorDriver.flush());
  }

  @UiHandler("cancel")
  void onCancelClick(ClickEvent event) {
      presenter.show(editor.id.getValue());
  }
<% end -%>
}