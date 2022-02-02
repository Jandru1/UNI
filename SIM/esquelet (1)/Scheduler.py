from Server import *
from Source import *
from event import *;


class Scheduler:

    currentTime = 0
    eventList = []
    ...

    def __init__(self):
        # creació dels objectes que composen el meu model
        self.source = Source()
        self.Server = Server()
        self.Queue = Queue()
        self.Server2 = Server()

        self.source.crearConnexio(server)
        self.Server.crearConnexio(server2, queue)

        self.simulationStart=Event(self,'SIMULATION_START', 0,null)
        self.eventList.append(simulationStart)

    def run(self):
        #configurar el model per consola, arxiu de text...
        self.configurarModel()

        #rellotge de simulacio a 0
        self.currentTime=0
        #bucle de simulació (condició fi simulació llista buida)
        while self.eventList:
            #recuperem event simulacio
            event=self.eventList.donamEsdeveniment
            #actualitzem el rellotge de simulacio
            self.currentTime=event.time
            # deleguem l'acció a realitzar de l'esdeveniment a l'objecte que l'ha generat
            # també podríem delegar l'acció a un altre objecte
            event.objecte.tractarEsdeveniment(event)

        #recollida d'estadístics
        self.recollirEstadistics()

    def afegirEsdeveniment(self,event):
        #inserir esdeveniment de forma ordenada
        self.eventList.inserirEvent(event)

    def tractarEsdeveniment(self,event):
        if (event.tipus=="SIMULATION_START"):
            print("hola")
            # comunicar a tots els objectes que cal preparar-se


if __name__ == "__main__":
    scheduler = Scheduler()
    scheduler.run()
