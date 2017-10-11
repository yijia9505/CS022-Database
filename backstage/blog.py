""" Basic blog using webpy 0.3 """
import web
import model

### Url mappings

urls = (
    '/', 'Index',
	'/view_orders', 'ViewOrders',
	'/view_order/(.+)', 'ViewOrder',
    '/view_vehicle/(\d+)', 'ViewVehicle',
    '/new_customer', 'NewCustomer',
    '/delete/(\d+)', 'Delete',
    '/edit/(\d+)', 'Edit',
	'/start_reserve','StartReserve',
	'/contact_us','Contact',
	'/cancel_order/(\d+)','CancelOrder',
	'/rent_car','RentCar',
	'/new_car','NewCar',
	'/return_car','ReturnCar',
	'/view_return','ViewReturn',
	'/sell_vehicle/(\d+)','Sellcar',
	'/view_rent','ViewRent',
)


### Templates
t_globals = {
    'datestr': web.datestr
}
render = web.template.render('templates', base='base', globals=t_globals)

class Contact:
	def GET(self):
		return render.contact_us()

class Index:

    def GET(self):
        """ Show page """
        offices = model.get_office()
        return render.index(offices)

class ViewReturn:
	def GET(self):
		orders = model.get_return_order()
		return render.view_return(orders)
class ViewRent:
	def GET(self):
		orders = model.get_rent_order()
		return render.view_rent(orders)

class ReturnCar:
    form = web.form.Form(
        web.form.Textbox('reserveid', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30,
            description="Reserve ID:"),
        web.form.Textbox('liscense', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30,
            description="Vehicle liscense:"),
        web.form.Textbox('date', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Return Date:"),
        web.form.Textbox('gasremain', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Remained Gas:"),
        web.form.Textbox('dis',web.form.notnull,
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Distance Measure:"),

        web.form.Button('Confirm'),
    )

    def GET(self):
        form = self.form()
        return render.return_car(form)

    def POST(self):
        form = self.form()
        if not form.validates():
            return render.return_car(form)
     
        flag = model.finish_checkreservation(int(form.d.reserveid))
        if (flag[0].n<1):
            mess='Invalid Reservation ID!'
            return render.error(mess)
        lis = model.finish_checkliscense(int(form.d.reserveid))
        if (lis[0].n!=form.d.liscense):
            mess='Wrong License or Reservation ID!'
            return render.error(mess)
        price = model.finish_order(int(form.d.reserveid),int(form.d.liscense),int(form.d.gasremain),int(form.d.dis),int(form.d.date))
        return render.final_price(price)
		

class ViewVehicle:

    def GET(self, i):
        """ View vehicle"""
        vehicles = model.get_vehicle_inoffice(int(i))
        return render.view_vehicle(vehicles)

class CancelOrder:
	def GET(self,i):
		"""canel tipical order by customer"""
		model.cancel_order_by_id(int(i))
		raise web.seeother('/view_orders')


class Sellcar:
	def GET(self,i):
		model.delete_car(int(i))
		raise web.seeother('/')
	


class ViewOrder:
    def GET(self, state):
        """ View tipical Order"""
        orders = model.get_customer_reservation(str(state))
        flag = 0;
        if ((str(state)!='reserved')&(str(state)!='finished')&(str(state)!='rent')):
            flag = 1
        
        return render.view_order(orders,flag)


class ViewOrders:

    form = web.form.Form(
        web.form.Textbox('state', web.form.notnull, 
            rows=30, 
            description="State of the reservation order:"),
        web.form.Button('Check'),
    )

    def GET(self):
        form = self.form()
        return render.view_orders(form)

    def POST(self):
        form = self.form()
        if not form.validates():
            return render.view_orders(form)
		
        raise web.seeother('/view_order/'+str(form.d.state))

class NewCar:
    form = web.form.Form(
        web.form.Textbox('type', web.form.notnull, 
            rows=30, 
            description="Vehicle Type:"),
        web.form.Textbox('buy_year', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Buy Year:"),
        web.form.Textbox('price', web.form.notnull,
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Price:"),
        web.form.Textbox('gas', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Gas Capacity:"),
        web.form.Textbox('office', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Office ID:"),
   
        web.form.Button('Confirm'),

    )

    def GET(self):
        form = self.form()
        return render.new_car(form)

    def POST(self):
        form = self.form()
        if not form.validates():
            return render.new_car(form)
        if (form.d.type!='mid-size')&(form.d.type!='economy')&(form.d.type!='compact')&(form.d.type!='standard')&(form.d.type!='fullsize')&(form.d.type!='premium')&(form.d.type!='luxury')&(form.d.type!='SUV')&(form.d.type!='van'):
            mess = 'Wrong Vehicle Type!'
            return render.error(mess)
        if ((int(form.d.office)>4)|(int(form.d.office)<1)):
            mess = 'Wrong office ID!'
            return render.error(mess)
        model.insert_vehicle(str(form.d.type),int(form.d.buy_year),int(form.d.price),int(form.d.gas),int(form.d.office))
        raise web.seeother('/')

	


class RentCar:

    form = web.form.Form(
        web.form.Textbox('reserveid', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Reservation id:"),
        web.form.Textbox('cardid', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Credit Card Number:"),
        web.form.Textbox('expiretime', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Card Expire Time:"),
        web.form.Textbox('price', web.form.notnull, 
            web.form.regexp('\d+','Must be an integer'),
            rows=30, 
            description="Paid price:"),
        web.form.Button('Confirm'),
    )

    def GET(self):
        form = self.form()
        return render.rent_car(form)

    def POST(self):
        form = self.form()
        if not form.validates():
            return render.rent_car(form)
        flag = model.rent_checkreservation(int(form.d.reserveid))
        if (flag[0].n<1):
            mess = 'Invalid Reservation ID!'
            return render.error(mess)

        model.insert_rent(int(form.d.reserveid),int(form.d.cardid),int(form.d.expiretime),int(form.d.price))
        raise web.seeother('/view_order/rent')





app = web.application(urls, globals())

if __name__ == '__main__':
    app.run()
