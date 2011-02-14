from django.conf.urls.defaults import *
from django.contrib import admin
from django.contrib import databrowse
from django.contrib.auth.decorators import login_required

admin.autodiscover()


urlpatterns = patterns('',
    (r'^$', 'voiceapp.app1.views.register_me'),
    (r'^reg_advertiser/$', 'voiceapp.app1.views.register_ad'),
)
