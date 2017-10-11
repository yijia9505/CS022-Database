""" Basic blog using webpy 0.3 """
import web
import model

### Url mappings

urls = (
    '/index', 'Index',
    '/contactus', 'Contactus',
    '/checkorder', 'ViewOrders',
    '/vieworder/(\d+)', 'ViewOrder',
    '/view_vehicle/(\d+)', 'ViewVehicle',
    '/new_customer', 'NewCustomer',
    '/delete/(\d+)', 'Delete',
    '/edit/(\d+)', 'Edit',
    '/successreg','Successreg',
    '/cancel_order/(\d+)','CancelOrder',
    '/getreservation','StartReserve',
    '/successreserve','Successreserve',
    '/successcancel','Successcancel',
)


### Templates
t_globals = {
    'datestr': web.datestr
}
render = web.template.render('templates', globals=t_globals)

class ViewOrders:
    form = web.form.Form(
        web.form.Textbox('phone', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Your Phone:"),
        web.form.Button('Check'),
    )

    def GET(self):
        form = self.form()
        return render.checkorders(form)

    def POST(self):
        form = self.form()
        if not form.validates():
            return render.checkorders(form)
        raise web.seeother('/vieworder/'+str(form.d.phone))

class Successcancel:
    def GET(self):
        return render.successcancel()

class Successreg:
    def GET(self):
        return render.successreg()

class Successreserve:
    def GET(self):
        return render.successreserve()

class Index:
    def GET(self):
        return render.index()

class Contactus:
    def GET(self):
        return render.contactus();

class CancelOrder:
    def GET(self,i):
        """canel tipical order by customer"""
        model.cancel_order_by_id(int(i))
        raise web.seeother('/successcancel')        


class ViewVehicle:
    def GET(self, i):
        """ View vehicle"""
        vehicles = model.get_vehicle_inoffice(int(i))
        return render.view_vehicle(vehicles)

class StartReserve:

    form = web.form.Form(
        web.form.Textbox('phone', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            size=30,
            description="Your Phone:"),
        web.form.Textbox('type', web.form.notnull, 
            rows=30, 
            description="Vehicle type:"),
        web.form.Textbox('gettime', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="When to get:"),
        web.form.Textbox('returntime', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="When to return:"),
        web.form.Textbox('getoffice', web.form.notnull, 
            rows=30, 
            description="Get office:"),
        web.form.Textbox('returnoffice',web.form.notnull,
            rows=30,
            description="Return office:"),
        web.form.Button('Confirm'),
    )

    def GET(self):
        form = self.form()
        return render.getreservation(form)

    def POST(self):
        form = self.form()
        if not form.validates():
            return render.getreservation(form)
        office = form.d.getoffice;
        if office=='Shanghai':
            goffice_id=1
        elif office=='Beijin':
            goffice_id=3
        elif office=='Guangzhou':
            goffice_id=2
        elif office=='Fujian':
            goffice_id=4
        else:
            goffice_id=100
        office = form.d.returnoffice
        if office=='Shanghai':
            roffice_id=1
        elif office=='Beijin':
            roffice_id=3
        elif office=='Guangzhou':
            roffice_id=2
        elif office=='Fujian':
            roffice_id=4
        else:
            roffice_id=100      
        if (int(form.d.gettime) > int(form.d.returntime)) or (int(form.d.returntime) > 25000000) or (int(form.d.gettime) < 20100000)or (goffice_id==100) or (roffice_id==100):
            return render.invalidinput()
        num=model.find_vehicle_number(int(form.d.gettime),int(form.d.returntime),goffice_id,roffice_id,str(form.d.type));
        number = num[0].num
        if number==0:
            return render.no_free_car()
        result = model.find_vehicle(int(form.d.gettime),int(form.d.returntime),goffice_id,roffice_id,str(form.d.type))
        ppnum = model.get_phone_number(form.d.phone);
        if ppnum[0].pnum==0:
            return render.phonenotexist();
        model.new_reserve(int(form.d.gettime),int(form.d.returntime),goffice_id,roffice_id,result[0].liscense,int(form.d.phone))
        raise web.seeother('/successreserve')


class NewCustomer:
    form = web.form.Form(
        web.form.Textbox('name', web.form.notnull, 
            size=30,
            description="Your name:"),
        web.form.Textbox('phone', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Your Phone:"),
		web.form.Textbox('address', web.form.notnull, 
            rows=30, 
            description="Your Address:"),
		web.form.Textbox('liscense', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Your Driving License:"),
        web.form.Button('Register'),
    )

    def GET(self):
        form = self.form()
        return render.new_customer(form)

    def POST(self):
        form = self.form()
        if not form.validates():
            return render.new_customer(form)
        phone_num=model.get_phone_number(form.d.phone)
        if not phone_num[0].pnum==0:
            return render.phoneexist()
        model.new_customer(form.d.name, form.d.phone,form.d.address,form.d.liscense)
        raise web.seeother('/successreg')

class ViewOrder:
    def GET(self, phone):
        """ View tipical Order"""
        orders = model.get_customer_reservation(int(phone))
        number =model.get_customer_reservation_number(int(phone)) 
        if number[0].num==0:
            return render.no_order()
        return render.view_order(orders)

class Delete:
    def POST(self, id):
        model.del_post(int(id))
        raise web.seeother('/')


class Edit:
    def GET(self, id):
        post = model.get_post(int(id))
        form = New.form()
        form.fill(post)
        return render.edit(post, form)
    def POST(self, id):
        form = New.form()
        post = model.get_post(int(id))
        if not form.validates():
            return render.edit(post, form)
        model.update_post(int(id), form.d.title, form.d.content)
        raise web.seeother('/')


app = web.application(urls, globals())

if __name__ == '__main__':
    app.run()
