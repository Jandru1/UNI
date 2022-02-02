import simpy
import random

import matplotlib.pyplot as plt
import numpy as np


class input:
    # lectura de les variables mitjançant fitxer entrada.txt

    archivo = open("entrada2.txt", "r")
    archivo.readline()
    sim_duration = int(archivo.readline())
    print("el temps de simulació és: " + str(sim_duration))
    archivo.readline()
    temps_entre_arribades = int(archivo.readline())
    print("el temps entre arribades a urgències és: " + str(temps_entre_arribades))
    archivo.readline()
    desviacio_entre_arribades = int(archivo.readline())
    print("La desviació entre arribades a urgències és: " + str(desviacio_entre_arribades))
    archivo.readline()
    qtt_metges = int(archivo.readline())
    print("la quantitat de metges que disposen les urgències és: " + str(qtt_metges))
    archivo.readline()
    qtt_sales = int(archivo.readline())
    print("la quantitat de sales d'espera que disposen les urgències és: " + str(qtt_sales))
    archivo.readline()
    capacitat_sales = int(archivo.readline())
    print("la capacitat de les sales d'espera és: " + str(capacitat_sales))
    archivo.readline()
    temps_mig_cita = int(archivo.readline())
    print("el temps mig entre les cites és: " + str(temps_mig_cita))
    archivo.readline()
    desviacio_temps_cita = int(archivo.readline())
    print("la desviació dels temps de les cites és: " + str(desviacio_temps_cita))
    archivo.close()

    pacients_totals = 0
    espera_pacients = 0
    espera_pacients_per_prioritat = [0, 0]

    pacients_en_cua = []
    temps_pacients_en_cua = []
    pacients_pediatrics_en_cua = []
    pacients_no_pediatrics_en_cua = []
    plot_temps_cua_consulta = []
    plot_pacient = []


class Pacient:
    pacients_totals = {}

    def __init__(self, env):
        input.pacients_totals += 1
        self.id = input.pacients_totals
        numero = random.randint(1, 100)
        if numero >= 80:
            self.prioritat = 2
        else:
            self.prioritat = 1
        self.temps_consulta = round(random.normalvariate(input.temps_mig_cita, input.desviacio_temps_cita))
        self.temps_consulta = 0 if self.temps_consulta < 0 \
            else self.temps_consulta

        self.temps_cua_consulta = 0
        self.time_in = env.now

        self.temps_visita_metge = 0
        self.time_out = 0


class Resources:
    def __init__(self, env, qtt_metges):
        self.metge = simpy.PriorityResource(env, capacity=qtt_metges)


class Model:

    def __init__(self):
        self.env = simpy.Environment()

    def arribada_pacients(self):
        while True:
            if input.espera_pacients < input.qtt_sales * input.capacitat_sales:
                p = Pacient(self.env)
                Pacient.pacients_totals[p.id] = p
                self.env.process(self.visita_metge(p))
            seguent_arribada = round(random.normalvariate(input.temps_entre_arribades, input.desviacio_entre_arribades))
            yield self.env.timeout(seguent_arribada)

    def visita_metge(self, p):
        with self.recurs_metge.metge.request(priority=p.prioritat) as req:
            print(
                "En el instant de temps " + str(self.env.now) + " arriba pacient " + str(p.id) + " a la sala d'espera")
            input.espera_pacients += 1
            input.espera_pacients_per_prioritat[p.prioritat - 1] += 1
            input.pacients_pediatrics_en_cua.append(input.espera_pacients_per_prioritat[0])
            input.pacients_no_pediatrics_en_cua.append(input.espera_pacients_per_prioritat[1])
            input.pacients_en_cua.append(input.espera_pacients)
            input.temps_pacients_en_cua.append(self.env.now)
            print("En el instant de temps " + str(
                self.env.now) + " els pacients que hi han a la sala d'espera son " + str(input.espera_pacients))
            print("En el instant de temps " + str(self.env.now) + " els pacients pediatrics que hi han a la sala "
                                                                  "d'espera son " + str(
                input.espera_pacients_per_prioritat[0]))
            print("En el instant de temps " + str(self.env.now) + " els pacients no pediatrics que hi han a la sala "
                                                                  "d'espera son " + str(
                input.espera_pacients_per_prioritat[1]))
            yield req
            print("En el instant de temps " + str(self.env.now) + " el pacient " + str(p.id) + " entra a consulta")
            p.temps_visita_metge = self.env.now
            p.temps_cua_consulta = self.env.now - p.time_in
            print("SELF.NOW" + str(self.env.now))
            print("TIME IN " + str(p.time_in))
            print("Temps consulta" + str(p.temps_cua_consulta))

            input.plot_temps_cua_consulta.append(p.temps_cua_consulta)
            input.plot_pacient.append(p.id)
            input.espera_pacients_per_prioritat[p.prioritat - 1] -= 1
            input.espera_pacients -= 1
            yield self.env.timeout(p.temps_consulta)
            print("En el instant de temps " + str(self.env.now) + " el pacient " + str(p.id) + " surt de consulta")
            del Pacient.pacients_totals[p.id]

    def run(self):
        self.recurs_metge = Resources(self.env, input.qtt_metges)
        self.env.process(self.arribada_pacients())
        self.env.run(until=input.sim_duration)
        self.grafics()

    def grafics(self):
        fig = plt.figure(figsize=(12, 4.5), dpi=75)
        plot1 = fig.add_subplot(121)
        x = input.temps_pacients_en_cua
        y1 = input.pacients_en_cua
        y2 = input.pacients_pediatrics_en_cua
        y3 = input.pacients_no_pediatrics_en_cua
        plot1.grid(True, which='both', lw=1, ls='--', c='.75')
        plot1.plot(x, y1, color="blue", label="pacients totals")  # totals
        plot1.plot(x, y2, color="green", label="pacients pediatrics")  # pediatrics
        plot1.plot(x, y3, color="red", label="pacients no pediatrics")  # no pediatrics
        plot1.legend(loc="upper left", frameon=False)
        plot1.set_xlabel('temps total')
        plot1.set_ylabel('pacients en cua')
        plt.tight_layout(pad=3)

        plot2 = fig.add_subplot(122)  # 1 row, 3 cols, chart position 1
        x = input.plot_pacient
        y1 = input.plot_temps_cua_consulta
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
