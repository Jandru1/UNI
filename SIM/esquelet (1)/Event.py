class Event:
    # creació d'un nou esdeveniment
    def __init__(self,object,type,time,entity):
        #objecte que processarà l'esdeveniment
        self.object = object;
        #tipus event
        self.type = type;
        #instant en que succeirà l'esdeveniment
        self.time = time;

    #Podríem delegar l'esdeveniment a l'objecte des de l'event o des del scheduler
    def tractaresdeveniment(self):
        self.object.tractaresdeveniment(self);
