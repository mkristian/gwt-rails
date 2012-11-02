package <%= presenters_package %>;

import javax.inject.Inject;
import javax.inject.Singleton;

import <%= base_package %>.<%= application_class_name %>Application;
import <%= models_package %>.User;
import <%= restservices_package %>.SessionRestService;

import org.fusesource.restygwt.client.Method;
import org.fusesource.restygwt.client.MethodCallback;

import com.google.gwt.core.client.GWT;

import <%= gwt_rails_package %>.Notice;
import <%= gwt_rails_session_package %>.Authentication;
import <%= gwt_rails_session_package %>.LoginView;
import <%= gwt_rails_session_package %>.Session;
import <%= gwt_rails_session_package %>.SessionHandler;
import <%= gwt_rails_session_package %>.SessionManager;

@Singleton
public class LoginPresenter implements LoginView.Presenter{

    private final SessionRestService service;
    private final SessionManager<User> sessionManager;
    private final Notice notice;

    @Inject
    public LoginPresenter(final SessionRestService service,
            final SessionManager<User> sessionManager,
            final Notice notice) {
        this.service = service;
        this.sessionManager = sessionManager;
        this.notice = notice;
    }

    public void init(final <%= application_class_name %>Application app){
        sessionManager.addSessionHandler(new SessionHandler<User>() {
            
            @Override
            public void timeout() {
                notice.info("timeout");
                logout();
            }
                
            @Override
            public void logout() {
                app.stopSession();
                service.destroy(new MethodCallback<Void>() {
                    public void onSuccess(Method method, Void response) {
                    }
                    public void onFailure(Method method, Throwable exception) {
                    }
                });
            }
                
            @Override
            public void login(User user) {
                app.startSession(user);
            }
            
            @Override
            public void accessDenied() {
                notice.error("access denied");
            }
        });        
    }

    public void login(final String login, final String password) {
        Authentication authentication = new Authentication(login, password);
        service.create(authentication, new MethodCallback<Session<User>>() {

            public void onSuccess(Method method, Session<User> session) {
                GWT.log("logged in: " + login);
                sessionManager.login(session);
            }

            public void onFailure(Method method, Throwable exception) {
                GWT.log("login failed: " + exception.getMessage(), exception);
                sessionManager.accessDenied();
            }
        });
    }

    public void resetPassword(final String login) {
        Authentication authentication = new Authentication(login);
        service.resetPassword(authentication, new MethodCallback<Void>() {

            public void onSuccess(Method method, Void result) {
                notice.info("new password was sent to your email address");
            }

            public void onFailure(Method method, Throwable exception) {
                notice.error("could not reset password - username/email unknown");
            }
        });
    }
}