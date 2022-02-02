import simpy
import random
import salabim as sim
import matplotlib.pyplot as plt
import numpy as np


class input:
    # lectura de les variables mitjançant fitxer entrada.txt

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

    clients_totals = 0
    espera_clients = 0
 #espera_pacients_per_prioritat = [0, 0]

    clients_esperant = []
    temps_clients_esperant = []
#    pacients_pediatrics_en_cua = []
#    pacients_no_pediatrics_en_cua = []
    plot_temps_cua_barberia = []
    plot_client = []
    barbers_disponibles = 1;
    sillas_rentar = 2
    sillas_tallar = 3
    i = 0
    j = 0


class Client:
    clients_totals = {}

    def __init__(self, env):
        input.clients_totals += 1
        self.id = input.clients_totals
        #numero = random.randint(1, 100)
        #if numero >= 80:
        #    self.prioritat = 2
        #else:
        #    self.prioritat = 1
        self.temps_proces_tallar = round(random.normalvariate(input.temps_tallar, input.desv_temps_tallar))
        self.temps_proces_tallar = 0 if self.temps_proces_tallar < 0 \
            else self.temps_proces_tallar

        self.temps_proces_rentar = round(random.normalvariate(input.temps_rentar, input.desv_temps_rentar))
        self.temps_proces_rentar = 0 if self.temps_proces_rentar < 0 \
            else self.temps_proces_rentar

        self.temps_cua_barberia = 0
        self.time_in = env.now

        self.temps_arriba_peluquer = 0
        self.time_out = 0

class Resources:

    def __init__(self, env, qqt_barbers):
        print("ENTRO AQUI")
        self.barber = simpy.PriorityResource(env, capacity=qqt_barbers)
        print("SALGO AQUI")


class Model:

    def __init__(self):
        print("HOLA?")
        self.env = sim.Environment();

    def arribada_clients(self):
        print("HHHHHHHHHHHHHH")
        while True:
            if input.espera_clients < input.capacitat_sala:
                c = Client(self.env)
                Client.clients_totals[c.id] = c
                self.env.process(self.tallar_cabell(c))
            seguent_arribada = round(random.normalvariate(input.temps_entre_arribades, input.desviacio_entre_arribades))
            yield self.env.timeout(seguent_arribada)

    def tallar_cabell(self, c):
        with self.recurs_barber.barber.request() as req:
            print(
                "En el instant de temps " + str(self.env.now) + " arriba pacient " + str(c.id) + " a la sala d'espera")
            input.espera_clients += 1
        #    input.espera_pacients_per_prioritat[p.prioritat - 1] += 1
        #    input.pacients_pediatrics_en_cua.append(input.espera_pacients_per_prioritat[0])
        #    input.pacients_no_pediatrics_en_cua.append(input.espera_pacients_per_prioritat[1])
            input.clients_esperant.append(input.espera_clients)
            input.temps_clients_esperant.append(self.env.now)
            print("En el instant de temps " + str(
                self.env.now) + " els clients que hi han a la sala d'espera son " + str(input.espera_clients))
        #    print("En el instant de temps " + str(self.env.now) + " els pacients pediatrics que hi han a la sala "
        #                                                          "d'espera son " + str(
        #        input.espera_pacients_per_prioritat[0]))
        #    print("En el instant de temps " + str(self.env.now) + " els pacients no pediatrics que hi han a la sala "
        #                                                          "d'espera son " + str(
        #        input.espera_pacients_per_prioritat[1]))
            yield req
            print("soy el cliente "+ str(c.id) + " y barberos = ", str(input.barbers_disponibles))
            if input.sillas_tallar > 0:
                input.sillas_tallar-=1
                print("En el instant de temps " + str(self.env.now) + " el client " + str(c.id) + " se sienta en la silla")
                print("SILLAS Tallar DISPONIBLES " + str(input.sillas_tallar))
                if input.barbers_disponibles >0:
                    print("En el instant de temps " + str(self.env.now) + " el client " + str(c.id) + " empiezan a cortarle el pelo")
                    input.barbers_disponibles-=1;
                    print("soy el cliente "+ str(c.id) + " y barberos = ", str(input.barbers_disponibles));
                    c.temps_arriba_peluquer = self.env.now
                    c.temps_cua_barberia = self.env.now - c.time_in
                    input.plot_temps_cua_barberia.append(c.temps_cua_barberia)
                    input.plot_client.append(c.id)
                #    input.espera_pacients_per_prioritat[p.prioritat - 1] -= 1
                    input.espera_clients -= 1
                    yield self.env.timeout(c.temps_proces_tallar)
                    print("En el instant de temps " + str(self.env.now) + " el client " + str(c.id) + " s'ha acabat de tallar el cabell")
                    input.sillas_tallar+=1
                    self.env.process(self.rentar_cabell(c))
                    input.barbers_disponibles += 1;
                    del Client.clients_totals[c.id]

    def rentar_cabell(self, c):
        print("SILLAS RENTAR DISPONIBLES " + str(input.sillas_rentar))
        if input.sillas_rentar > 0:
            input.sillas_rentar-=1
            print("En el instant de temps " + str(self.env.now) + " el client " + str(c.id) + " entra a rentarse el cabell")
            yield self.env.timeout(c.temps_proces_rentar)
            print("En el instant de temps " + str(self.env.now) + " el client " + str(c.id) + " s'ha acabat de rentar el cabell")
            input.sillas_rentar+=1


    def run(self):
        self.recurs_barber = Resources(self.env, input.qqt_barbers)
        self.arribada_clients()
        print("HAGO LA ARRIBADA")
        print("acaba run")
        self.grafics()

    def grafics(self):
        fig = plt.figure(figsize=(12, 4.5), dpi=75)
        plot1 = fig.add_subplot(121)
        x = input.temps_clients_esperant
        y1 = input.clients_esperant
    #    y2 = input.pacients_pediatrics_en_cua
    #    y3 = input.pacients_no_pediatrics_en_cua
        plot1.grid(True, which='both', lw=1, ls='--', c='.75')
        plot1.plot(x, y1, color="blue", label="pacients totals")  # totals
    #    plot1.plot(x, y2, color="green", label="pacients pediatrics")  # pediatrics
    #    plot1.plot(x, y3, color="red", label="pacients no pediatrics")  # no pediatrics
        plot1.legend(loc="upper left", frameon=False)
        plot1.set_xlabel('temps total')
        plot1.set_ylabel('pacients en cua')
        plt.tight_layout(pad=3)

        plot2 = fig.add_subplot(122)  # 1 row, 3 cols, chart position 1
        x = input.plot_client
        y1 = input.plot_temps_cua_barberia
        plot2.grid(True, which='both', lw=1, ls='--', c='.75')
        plot2.scatter(x, y1, marker= "1", color="purple", label="pacients totals")  # totals
        plot2.legend(loc="upper left", frameon=False)
        plot2.set_xlabel('pacient id')
        plot2.set_ylabel('temps d espera')
        plt.tight_layout(pad=3)
        plt.show()


if __name__ == '__main__':
    model = Model()
    model.run()
