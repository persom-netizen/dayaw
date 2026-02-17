from flask import request, Response
# Added 'expose' to the import
from flask_admin import Admin, AdminIndexView, expose 
from flask_admin.contrib.sqla import ModelView

# --- SECURITY LOGIC ---
ADMIN_USERNAME = 'admin'
ADMIN_PASSWORD = 'admin123'

def check_auth(username, password):
    return username == ADMIN_USERNAME and password == ADMIN_PASSWORD

def authenticate():
    return Response(
        'Mali ang login!', 401,
        {'WWW-Authenticate': 'Basic realm="Login Required"'})

class SecuredModelView(ModelView):
    column_display_pk = True
    def is_accessible(self):
        auth = request.authorization
        return auth and check_auth(auth.username, auth.password)
    def inaccessible_callback(self, name, **kwargs):
        return authenticate()

class SecuredIndexView(AdminIndexView):
    def is_accessible(self):
        auth = request.authorization
        return auth and check_auth(auth.username, auth.password)
    def inaccessible_callback(self, name, **kwargs):
        return authenticate()

    # ADD THIS PART TO MAKE HOME WORK
    @expose('/')
    def index(self):
        return self.render('admin/index.html')

# --- INITIALIZATION FUNCTION ---
def setup_admin(app, db, models):
    # This correctly points to your template
    admin = Admin(app, name='DAYAW Admin', index_view=SecuredIndexView(template='admin/index.html'))
    
    # Register your models here
    admin.add_view(SecuredModelView(models.SignUp, db.session, name="Users", category="Accounts"))
    admin.add_view(SecuredModelView(models.Alaala, db.session, name="Trivia (Alaala)"))
    admin.add_view(SecuredModelView(models.Salita, db.session, name="Word (Salita)"))
    admin.add_view(SecuredModelView(models.Post, db.session, name="Feed Posts", category="Community"))
    
    return admin