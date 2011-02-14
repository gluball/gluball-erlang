from django.conf.urls.defaults import *
from django.contrib import admin
from django.contrib import databrowse
from django.contrib.auth.decorators import login_required
import settings
admin.autodiscover()


urlpatterns = patterns('',
    (r'^', include('app1.urls')),
    (r'^media/(?P<path>.*)$', 'django.views.static.serve',
            {'document_root': settings.BASEDIR+'/media'}),
)
