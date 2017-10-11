import web, datetime

db = web.database(dbn='mysql', db='new_schema', user='root', pw='123123')

def get_office():
    return db.select('office')

def get_vehicle_inoffice(id):
    try:
        return db.query('select city, type, liscense, distance, gas_capacity from office_has_vehicle,office, vehicle where office_office_id = $id and office_id = $id and liscense = vehicle_liscense and stage = "in office"', vars=locals())
    except IndexError:
        return None

def find_vehicle_number(gettime,returntime,office,roffice,tyype):
	office_car = db.query('select liscense from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype',vars=locals())
	if office==roffice:
		otherRt = db.query('select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense',vars=locals())
		other_car = db.query('select aa.liscense as liscense from (select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense) aa where aa.gettime > $gettime',vars=locals())
		number = db.query('select count(*) as num from ((select liscense from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype) UNION (select aa.liscense as liscense from (select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense) aa where aa.gettime > $gettime)) xx ',vars=locals())
		return number
	return db.query('select count(liscense) as num from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype',vars=locals())

def find_vehicle(gettime,returntime,office,roffice,tyype):
	office_car = db.query('select min(liscense) as liscense from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype',vars=locals())
	if office==roffice:
		otherRt = db.query('select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense',vars=locals())
		other_car = db.query('select aa.liscense as liscense from (select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense) aa where aa.gettime > $gettime',vars=locals())
		result = db.query('select min(xx.liscense) as liscense from ((select liscense from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype) UNION (select aa.liscense as liscense from (select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense) aa where aa.gettime > $gettime)) xx ',vars=locals())
		return result
	return office_car

def cal_price_sp(starttime,finishtime,liscense):
	velis=liscense
	gts=starttime
	rts=finishtime
	price=db.query('select price as pr from vehicle where liscense=$velis',vars=locals())
	days=365*((rts//10000)-(gts//10000))+((rts%100)-(gts%100))+30*((rts//100%100)-(gts//100%100))
	return days*price[0].pr//1000

def new_reserve(gettime,returntime,goffice_id,roffice_id,liscense,phone):
	price = cal_price_sp(gettime,returntime,liscense)
	db.query('insert into reserve(price,get_time,return_time,get_office,return_office,vehicle_liscense,customer_phone) value($price,$gettime,$returntime,$goffice_id,$roffice_id,$liscense,$phone)',vars=locals())
	db.query('update vehicle set stage="reserved" where liscense=$liscense and stage!="out"',vars=locals())
	 
def cancel_order_by_id(id):
	db.query('update reserve set state="canceled" where reserve_id=$id',vars=locals())
	num = db.query('select count(*) as n from reserve where vehicle_liscense in (select vehicle_liscense from reserve where reserve_id=$id) and state="reserved"',vars=locals())
	if num[0].n==0:
		db.query('update vehicle set stage="in office" where liscense in (select vehicle_liscense from reserve where reserve_id=$id)',vars=locals())

def get_customer_reservation(phone):
		return db.query('select reserve.price as price, reserve_id, customer_phone, vehicle_liscense, type, get_time,get_office,return_time,return_office,  state from reserve, vehicle where customer_phone=$phone and liscense = vehicle_liscense',vars=locals())

def get_customer_reservation_number(phone):
		return db.query('select count(*) as num from reserve, vehicle where customer_phone=$phone and liscense = vehicle_liscense',vars=locals())

def get_phone_number(phone):
		return db.query('select count(*) as pnum from customer where phone=$phone',vars=locals())

def new_customer(name, phone,address,liscense):
    db.insert('customer', name=name, phone=phone, address=address, driving_license=liscense)

def del_post(id):
    db.delete('entries', where="id=$id", vars=locals())

def update_post(id, title, text):
    db.update('entries', where="id=$id", vars=locals(),
        title=title, content=text)
