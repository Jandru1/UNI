import salabim as sim
import random
import matplotlib.pyplot as plt


class input(sim.Component):

	archivo = open("entrada.txt", "r")
	archivo.readline()
	sim_duration = int(archivo.readline())
	print("el temps de simulació és: " + str(sim_duration))
	archivo.readline()
	temps_tallar = int(archivo.readline())
	print("el temps per a tellar el cabell és: " + str(temps_tallar))
	archivo.readline()
	desviacio_entre_arribades = int(archivo.readline())
	print("La desviació entre arribades a la peluqueria és: " + str(desviacio_entre_arribades))
	archivo.readline()
	qqt_barbers = int(archivo.readline())
	print("la quantitat de barbers el primer torn és: " + str(qqt_barbers))
	archivo.readline()
	qqt_barbers2 = int(archivo.readline())
	print("la quantitat de barbers el segon torn és: " + str(qqt_barbers2))
	archivo.readline()
	qqt_barbers3 = int(archivo.readline())
	print("la quantitat de barbers el tercer torn és: " + str(qqt_barbers3))
	archivo.readline()
	capacitat_sala = int(archivo.readline())
	print("la capacitat de la salas d'espera és: " + str(capacitat_sala))
	archivo.readline()
	temps_rentar = int(archivo.readline())
	print("el temps de neteja és: " + str(temps_rentar))
	archivo.readline()
	temps_deixar_desperar = int(archivo.readline())
	print("el temps que tarden els clients en deixar d'esperar i marxar és: " + str(temps_deixar_desperar))
	archivo.readline()
	qqt_cadires_talla = int(archivo.readline())
	print("la quantitat de cadires per tallar és: " + str(qqt_cadires_talla))
	archivo.readline()
	qqt_cadires_rentar = int(archivo.readline())
	print("la quantitat de cadires per rentar és: " + str(qqt_cadires_rentar))
	archivo.readline()
	desv_temps_tallar = int(archivo.readline())
	print("la desviació per a tallar el cabell és: " + str(desv_temps_tallar))
	archivo.readline()
	desv_temps_rentar = int(archivo.readline())
	print("la desviació per a rentar és: " + str(desv_temps_rentar))
	archivo.readline()
	temps_entre_arribades = int(archivo.readline())
	print("el temps entre arribades a la peluqueria és: " + str(temps_entre_arribades))
	archivo.close()

	holahola = 0
	clients_totals = 0
	espera_clients = 0
	marxa_client = 0
	clients_esperant = []
	temps_clients_esperant = []

	temps_client_marxar = []
	clients_que_marxen = []
	plot_temps_cua_barberia = []
	plot_client = []
	barbers_disponibles = 1;
	sillas_rentar = 2
	sillas_tallar = 3
	i = 0
	j = 0

	increment_barber1 = 0
	increment_barber2 = 0



class Client(sim.Component):
	a=0
	clients_totals = {}
	num_tot=0
	id = 0
	time_in = 0
	temps_proces_rentar = 0
	temps_proces_tallar = 0
	temps_cua_barberia = 0
	temps_arriba_peluquer = 0
	a = 0
	def process(self):
		input.clients_totals += 1

		self.id = input.clients_totals

		self.temps_proces_tallar = round(random.normalvariate(input.temps_tallar, input.desv_temps_tallar))
		self.temps_proces_tallar = 0 if self.temps_proces_tallar < 0 \
		else self.temps_proces_tallar

		self.temps_proces_rentar = round(random.normalvariate(input.temps_rentar, input.desv_temps_rentar))
		self.temps_proces_rentar = 0 if self.temps_proces_rentar < 0 \
		else self.temps_proces_rentar

		self.temps_cua_barberia = 0
		a = self.env.to_minutes(env.now)
		self.time_in = a

		self.temps_arriba_peluquer = 0
		self.time_out = 0

class Model(sim.Component):
	def arribada_clients(self):

		while True:
			if self.env.to_minutes(self.env.now) >= 180 and input.increment_barber1 == 0:
				input.barbers_disponibles+=1
				input.increment_barber1 = 1
				print("Se une un barbero")

			elif self.env.to_minutes(self.env.now) >= 420 and input.increment_barber2 == 0:
				input.barbers_disponibles+=2
				input.increment_barber2 = 1
				print("Se une un barbero")

			if input.espera_clients < input.capacitat_sala:
				c = Client()
				print()
				yield self.hold(1)
				Client.clients_totals[c.id] = c #[client1][client2][client3].....
				waitingline.add(c)
				print(
				"En el instant de temps " + str(self.env.to_minutes(self.env.now)) + " arriba client " + str(c.id) + " a la peluqueria")
				input.espera_clients += 1
				input.clients_esperant.append(input.espera_clients)
				input.temps_clients_esperant.append(self.env.to_minutes(self.env.now))
				print("En el instant de temps " + str(
				self.env.to_minutes(self.env.now)) + " els clients que hi han a la sala d'espera son " + str(input.espera_clients))
				if input.barbers_disponibles>0:
					TC = Tallar_Cabell(client = waitingline[0])
					TC.activate(process='tallar_cabell')

				else:
					cl = waitingline[0]
					temps_inicial = waitingline[0].time_in
					cl.temps_cua_barberia =self.env.to_minutes(self.env.now) - cl.time_in

					if cl.temps_cua_barberia >= 50:
						print("A l'instant de temps " + str(self.env.to_minutes(self.env.now)) + " el client " + str(waitingline[0].id) + " s'ha cansat d'esperar. 'Lentorros!!', ha dit despres d'esperar " + str(cl.temps_cua_barberia) + " minuts")
						waitingline.pop()
						input.marxa_client += 1
						input.clients_que_marxen.append(input.marxa_client)
						input.temps_client_marxar.append(self.env.to_minutes(self.env.now))



			else:
				TC = Tallar_Cabell(client = waitingline[0])
				if input.barbers_disponibles>0:
					TC.activate(process='tallar_cabell')

			seguent_arribada = round(random.normalvariate(input.temps_entre_arribades, input.desviacio_entre_arribades))
			print("SEGUENT ARRIBADA"+str(seguent_arribada))
			yield self.hold(seguent_arribada)



class Tallar_Cabell(sim.Component):
	def setup(self, client):
		self.c = client
	def tallar_cabell(self):
		waitingline.pop()
		print("En el instant de temps " + str(self.env.to_minutes(self.env.now)) + " el client " + str(self.c.id) + " empiezan a cortarle el pelo")
		input.barbers_disponibles-=1;
		self.c.temps_arriba_peluquer = self.env.now
		self.c.temps_cua_barberia = self.env.to_minutes(self.env.now) - self.c.time_in
		input.plot_temps_cua_barberia.append(self.c.temps_cua_barberia)
		input.plot_client.append(self.c.id)
		input.espera_clients -= 1
		yield self.hold(self.c.temps_proces_tallar)
		print("En el instant de temps " + str(self.env.to_minutes(self.env.now)) + " el client " + str(self.c.id) + " s'ha acabat de tallar el cabell")
		input.sillas_tallar+=1
		RC = Rentar_Cabell(client = self.c)
		RC.activate(process='rentar_cabell')




class Rentar_Cabell(sim.Component):
	def setup(self, client):
		self.c = client

	def rentar_cabell(self):
		if input.sillas_rentar > 0:
			input.sillas_rentar-=1
			print("En el instant de temps " + str(self.env.to_minutes(self.env.now)) + " el client " + str(self.c.id) + " entra a rentarse el cabell")
			yield self.hold(self.c.temps_proces_rentar)
			print("En el instant de temps " + str(self.env.to_minutes(self.env.now)) + " el client " + str(self.c.id) + " s'ha acabat de rentar el cabell")
			input.sillas_rentar+=1
			input.barbers_disponibles += 1;
			print("En el instant de temps " + str(self.env.to_minutes(self.env.now)) + "El cliente "+ str(self.c.id) + " se marcha satisfecho")
			del Client.clients_totals[self.c.id]

class Grafics(sim.Component):
	def grafics(self):
		fig = plt.figure(figsize=(12, 4.5), dpi=75)
		plot1 = fig.add_subplot(131)
		x = input.temps_clients_esperant
		y1 = input.clients_esperant
		plot1.grid(True, which='both', lw=1, ls='--', c='.75')
		plot1.plot(x, y1, color="blue", label="clients totals")
		plot1.legend(loc="upper left", frameon=False)
		plot1.set_xlabel('temps total')
		plot1.set_ylabel('clients a la cua')
		plt.tight_layout(pad=3)

		plot2 = fig.add_subplot(132)
		x = input.plot_client
		y1 = input.plot_temps_cua_barberia
		print("tamaño de x "+ str(len(x)))
		print("tamaño de y1 "+ str(len(y1)))
		plot2.grid(True, which='both', lw=1, ls='--', c='.75')
		plot2.scatter(x, y1, marker= "1", color="purple", label="clients totals")
		plot2.legend(loc="upper left", frameon=False)
		plot2.set_xlabel('client id')
		plot2.set_ylabel('temps d espera')

		plot3 = fig.add_subplot(133)
		x = input.temps_client_marxar
		y1 = input.clients_que_marxen
		plot3.grid(True, which='both', lw=1, ls='--', c='.75')
		plot3.plot(x, y1, color="blue", label="clients totals")
		plot3.legend(loc="upper left", frameon=False)
		plot3.set_xlabel('temps total')
		plot3.set_ylabel('clients que marxen')
		plt.tight_layout(pad=3)

		plt.show()

env = sim.Environment(trace=True,time_unit ='minutes')

Model = Model()
Model.activate(process='arribada_clients')

waitingline=sim.Queue('waitingline')
env.run(720)

g = Grafics()
g.activate(process='grafics')
env.run(1)





#print("Id de cliente es = " + str(Cliente2.id))
#print("el valor de holahola es "+str(input.holahola))
