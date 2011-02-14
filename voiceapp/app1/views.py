# Create your views here.
from django.http import HttpResponse
from django.shortcuts import render_to_response, get_object_or_404
#from django.contrib.auth import User

def register_me(request):
    if request.method == "POST":
        params = request.POST
        username = request.POST['sip_auth_username'] 
        domain = request.POST['domain']
        password = "abhunav"
        print "Request from:", username, password, domain 
        return render_to_response("retval.xml", dict(username=username, password=password, domain=domain))
    else:
        return render_to_response("register.html", dict())

def send_email_to_user(email):
    pass

def register(request):
    if request.method == "POST":
        username = request.POST['username'] 
        email = request.POST['email'] 
        password = request.POST['password']
        try:
            u = User.objects.get(username=username)
        except User.DoesNotExist:
            u = User.objects.create(username=username, email=email, password=password)
            send_email_to_user(u.email)
            render_to_response("register_status.html", dict(status="Success. Email sent to you email. Please confirm."))
        else:
            render_to_response("register_status.html", dict(status="Failed."))
    

def register_ad(request):
    return render_to_response("advertise.html", dict(locations=['gurgaon', 'lucknow', 'agra'],
                                              domains=['realestate', 'medicine', 'education'],
                                              specifics=['shopkeeper', 'retail', 'broker'],
                                              phoenix="abhinav"
                                              ))


















