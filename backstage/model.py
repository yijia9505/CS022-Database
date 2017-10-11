import web, datetime

db = web.database(dbn='mysql', db='new_schema', user='root', pw='123123')

def get_office():
    return db.select('office')

def get_vehicle_inoffice(id):
    try:
        return db.query('select city, type, liscense, distance, gas_capacity,stage,buy_year,price from office_has_vehicle,office, vehicle where office_office_id = $id and office_id = $id and liscense = vehicle_liscense', vars=locals())
    except IndexError:
        return None

def rent_checkreservation(id):
	return db.query('select count(*) as n from reserve where reserve_id=$id and state="reserved"',vars=locals())
def finish_checkreservation(id):
	return db.query('select count(*) as n from reserve where reserve_id=$id and state="rent"',vars=locals())

def finish_checkliscense(id):
	return db.query('select vehicle_liscense as n from reserve where reserve_id=$id and state="rent"',vars=locals())

def get_return_order():
	return db.query('select * from back order by return_id desc')

def get_rent_order():
	return db.query('select * from rent order by rent_id desc')


def cal_price_sp(starttime,finishtime,liscense):
	velis=liscense
	gts=starttime
	rts=finishtime
	price=db.query('select price as pr from vehicle where liscense=$velis',vars=locals())
	days=365*((rts//10000)-(gts//10000))+((rts%100)-(gts%100))+30*((rts//100%100)-(gts//100%100))
	return days*price[0].pr//100


def delete_car(id):
	db.query('delete from vehicle where liscense=$id',vars=locals())



def finish_order(reserveid,liscense,gasremain,dis,date):
	ree=db.query('select * from reserve where reserve_id=$reserveid',vars=locals())
	gas_c = db.query('select gas_capacity as n from vehicle where liscense = $liscense',vars=locals())
	db.query('update vehicle set distance = $dis where liscense = $liscense',vars=locals())
	gas_cap = gas_c[0].n
	full_gas = (gas_cap == gasremain)
	re=ree[0]
	phone = re.customer_phone
	getoffice = re.get_office
	gettime = re.get_time
	returnoffice = re.return_office
	returntime = date
	price = cal_price_sp(gettime,returntime,liscense)  
	db.query('insert into back(customer_phone,vehicle_liscense,reserve_id,return_office,return_time,gas_remain,price,full_gas) value($phone,$liscense,$reserveid,$returnoffice,$date,$gasremain,$price,$full_gas)',vars=locals())
	db.query('update reserve set state="finished" where reserve_id=$reserveid',vars=locals())
	"""judge car state"""
	result = db.query('select count(*) as n from reserve where vehicle_liscense=$liscense and state="reserved"',vars=locals())
	if result[0].n ==0:
		db.query('update vehicle set stage = "in office" where liscense=$liscense',vars=locals())
	else:
		db.query('update vehicle set stage = "reserved" where liscense=$liscense',vars=locals())
	"""judge office"""
	if getoffice!=returnoffice:
		db.query('update office_has_vehicle set office_office_id=$returnoffice where vehicle_liscense=$liscense',vars=locals())
	return price

def insert_vehicle(tyype,buy_year,price,gas,office):
	db.query('insert into vehicle(type,buy_year,price,gas_capacity,stage) value($tyype,$buy_year,$price,$gas,"in office")',vars=locals())
	num = db.query('select max(liscense) as n from vehicle')
	db.query('insert into office_has_vehicle value($office,$num[0].n)',vars=locals())

def insert_rent(reserveid,cardid,expiretime,price):
	ree=db.query('select * from reserve where reserve_id=$reserveid',vars=locals())
	re=ree[0]
	phone = re.customer_phone
	vehicle_liscense = re.vehicle_liscense
	getoffice = re.get_office
	gettime = re.get_time
	db.query('insert into rent(customer_phone,vehicle_liscense,get_office,get_time,paid_price,card_id,card_expire,reserve_id) value ($phone,$vehicle_liscense,$getoffice,$gettime,$price,$cardid,$expiretime,$reserveid)',vars=locals())
	db.query('update reserve set state="rent" where reserve_id = $reserveid',vars=locals())
	db.query('update vehicle set stage="out" where liscense=$vehicle_liscense',vars=locals())
	return None

def find_vehicle_number(gettime,returntime,office,roffice,tyype):
	office_car = db.query('select liscense from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype',vars=locals())
	if office==roffice:
		otherRt = db.query('select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense',vars=locals())
		other_car = db.query('select aa.liscense as liscense from (select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense) aa where aa.gettime > $gettime',vars=locals())
		number = db.query('select count(*) as num from ((select liscense from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype) UNION (select aa.liscense as liscense from (select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense) aa where aa.gettime > $gettime)) xx ',vars=locals())
		return number
	return db.query('select count(liscense) from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype',vars=locals())

def find_vehicle(gettime,returntime,office,roffice,tyype):
	office_car = db.query('select min(liscense) from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype',vars=locals())
	if office==roffice:
		otherRt = db.query('select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense',vars=locals())
		other_car = db.query('select aa.liscense as liscense from (select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense) aa where aa.gettime > $gettime',vars=locals())
		result = db.query('select min(xx.liscense) as liscense from ((select liscense from vehicle, office_has_vehicle where office_office_id = $office and liscense = vehicle_liscense and stage = "in office" and type=$tyype) UNION (select aa.liscense as liscense from (select v.liscense as liscense, min(get_time) as gettime from vehicle v, office_has_vehicle ov,reserve r where ov.office_office_id=$office and v.liscense = ov.vehicle_liscense and v.stage="reserved" and r.vehicle_liscense = v.liscense and r.state!="finished" and v.type=$tyype group by v.liscense) aa where aa.gettime > $gettime)) xx ',vars=locals())
		return result
	return office_car
	
def new_reserve(gettime,returntime,goffice_id,roffice_id,liscense,phone):
	db.query('insert into reserve(get_time,return_time,get_office,return_office,vehicle_liscense,customer_phone) value($gettime,$returntime,$goffice_id,$roffice_id,$liscense,$phone)',vars=locals())
	db.query('update vehicle set stage="reserved" where liscense=$liscense and stage!="out"',vars=locals())
	 
def cancel_order_by_id(id):
	db.query('update reserve set state="canceled" where reserve_id=$id',vars=locals())
	num = db.query('select count(*) as n from reserve where vehicle_liscense in (select vehicle_liscense from reserve where reserve_id=$id) and state="reserved"',vars=locals())
	if num[0].n==0:
		db.query('update vehicle set stage="in office" where liscense in (select vehicle_liscense from reserve where reserve_id=$id)',vars=locals())


def get_customer_reservation(state):
	if state=='reserved': 		
		return db.query('select reserve_id, customer_phone, vehicle_liscense, type, get_time,get_office,return_time,return_office,  state from reserve, vehicle where state=$state and liscense = vehicle_liscense order by reserve_id desc',vars=locals())
	elif state=='rent':
		return db.query('select x.reserve_id as reserve_id, x.customer_phone as customer_phone, x.vehicle_liscense as vehicle_liscense, type, x.get_time as get_time,x.get_office as get_office,x.return_time as return_time,x.return_office as return_office, x.state as state, y.paid_price as pprice, y.card_id as cardid from reserve x, rent y,vehicle where x.state=$state and liscense=x.vehicle_liscense and x.reserve_id = y.reserve_id order by x.reserve_id desc',vars=locals())
	elif state=='finished':
		return db.query('select x.reserve_id as reserve_id, x.customer_phone as customer_phone, x.vehicle_liscense as vehicle_liscense, type, x.get_time as get_time,x.get_office as get_office,x.return_time as return_time,x.return_office as return_office, x.state as state, y.price as pprice, y.gas_remain as gas from reserve x, back y,vehicle where x.state=$state and liscense=x.vehicle_liscense and x.reserve_id = y.reserve_id order by x.reserve_id desc',vars=locals())
	elif state=='canceled':
		return db.query('select reserve_id, customer_phone, vehicle_liscense, type, get_time,get_office,return_time,return_office,  state from reserve, vehicle where state=$state and liscense = vehicle_liscense order by reserve_id desc',vars=locals())
	else:
		return db.query('select reserve_id, customer_phone, vehicle_liscense, type, get_time,get_office,return_time,return_office, state from reserve, vehicle where liscense = vehicle_liscense order by reserve_id desc',vars=locals())




def new_customer(name, phone,address,liscense):
    db.insert('customer', name=name, phone=phone, address=address, driving_license=liscense)


