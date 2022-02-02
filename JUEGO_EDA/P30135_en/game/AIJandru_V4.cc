#include <iostream>
#include <vector>
#include <queue>
#include <stack>
using namespace std;



//CON DISTANCIAS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//1 worker va a por la comida que necesito
//Cuando la reina esta sola busca la comida que necesita

#include "Player.hh"
/**
 * Write the name of your player and save this file
 * with the same name and .cc extension.
 */
#define PLAYER_NAME Jandruns

// DISCLAIMER: The following Demo player is *not* meant to do anything
// sensible. It is provided just to illustrate how to use the API.
// Please use AINull.cc as a template for your player.

struct PLAYER_NAME : public Player {

  /**
   * Factory: returns a new instance of this class.
   * Do not modify this function.
   */
  static Player* factory () {
    return new PLAYER_NAME;
  }
  Dir default_dir;
  typedef vector<vector<char> > Matrix;
  typedef vector<vector<int> > Distanciax;
  typedef vector<vector<bool> > Visitadesx;
  typedef vector<vector<Dir> > Direcciox;
  typedef vector<vector<bool> > NoSuicidisPlz;

  const vector<NutrientType> nutrients = { Carbohydrate, Protein, Lipid };

  struct Position {
      int r, c, d;
      Position(int r, int c, int d) {
          this->r = r;
          this->c = c;
          this->d = d;
      }
  };

bool alguien_lleva_x_alimento(int n, int worker) {
      vector<int> my_worker_ids = workers(me());
      vector<int> perm = random_permutation(my_worker_ids.size());

      BonusType alimento;
      if(n == 0) alimento = Bread;
      else if (n == 1) alimento = Leaf;
      else alimento = Seed;

      for (int k = 0; k < int(perm.size()); ++k) {
        int worker_id = my_worker_ids[perm[k]];
        if (pos_ok(ant(worker_id).pos) and cell(ant(worker_id).pos).bonus == alimento and worker_id != worker) return true;
      }
      return false;
}

bool valid_position_ffQ (const Visitadesx &V, Pos p) {
    if(pos_ok(p) and cell(p).bonus == None and cell(p).type != Water and not V[p.i][p.j] and ((cell(p).id != -1 and ant(cell(p).id).type == Queen and ant(cell(p).id).player == me()) or cell(p).id == -1)) return true;
    else return false;
  }

bool valid_position_closetoQueen (Pos p) {
    for(int i = 0; i < 4; ++i) {
      Pos aux = p + Dir(i);
      if(pos_ok(aux) and cell(aux).id != -1 and ant(cell(aux).id).type == Queen and ant(cell(aux).id).player == me()) return true;
      for(int j = 0; j < 4; ++j) {
        Pos aux2 = aux + Dir(j);
        if(pos_ok(aux2) and cell(aux2).id != -1 and ant(cell(aux2).id).type == Queen and ant(cell(aux2).id).player == me()) return true;
        }
    }
    return false;
}
/*
bool valid_position_closetoQueen (Pos p) {
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    if(pos_ok(aux) and cell(aux).id != -1 and ant(cell(aux).id).type == Queen and ant(cell(aux).id).player == me()) return true;
  }
  if(pos_ok(p+Up+Right) and cell(p+Up+Right).id != -1 and ant(cell(p+Up+Right).id).type == Queen and ant(cell(p+Up+Right).id).player == me()) return true;
  else if(pos_ok(p+Up+Left) and cell(p+Up+Left).id != -1 and ant(cell(p+Up+Left).id).type == Queen and ant(cell(p+Up+Left).id).player == me()) return true;
  else if(pos_ok(p+Down+Right) and cell(p+Down+Right).id != -1 and ant(cell(p+Down+Right).id).type == Queen and ant(cell(p+Down+Right).id).player == me()) return true;
  else if(pos_ok(p+Down+Left) and cell(p+Down+Left).id != -1 and ant(cell(p+Down+Left).id).type == Queen and ant(cell(p+Down+Left).id).player == me()) return true;
  else return false;
}
*/
/*
int distancia_hasta_Queen(Pos p) {
    Visitadesx Visitades (board_rows(), vector<bool>(board_cols(), false));
    queue< Pos > posicions;
    Distanciax distancia (board_rows(), vector<int>(board_cols()));
    posicions.push(p);
    distancia[p.i][p.j] = 0;
    Visitades[p.i][p.j] = true;
    int dist;
    int i = 0;
    while (!posicions.empty()) {
      Pos actual = posicions.front();
      cout << "es el bucle numero " << i << endl;
      int f = actual.i;
      int c = actual.j;
      cout << "fila " << f << "colimna " << c << endl;
      dist = distancia[f][c];
            //Left
      if (cell(actual).id != 1 and ant(cell(actual).id).type == Queen) return dist;
      if (pos_ok(actual + Left) and cell(actual+Left).type != Water and not Visitades[f][c-1]) {
        posicions.push(actual + Left);
        distancia[f][c-1] = dist +1;
        Visitades[f][c-1] = true;
      }
      //Right
      if (pos_ok(actual + Right) and cell(actual+Right).type != Water and not Visitades[f][c+1]) {
        posicions.push(actual + Right);
        distancia[f][c+1] = dist + 1;
        Visitades[f][c+1] = true;
      }
      //Down
      if (pos_ok(actual + Down) and cell(actual+Down).type != Water and not Visitades[f+1][c]){
        posicions.push(actual + Down);
        distancia[f+1][c] = dist+1;
        Visitades[f+1][c] = true;
      }
      //Right
      if (pos_ok(actual + Up) and cell(actual+Up).type != Water and not Visitades[f-1][c]){
        posicions.push(actual + Up);
        distancia[f-1][c] = dist + 1;
        Visitades[f-1][c] = true;
      }
      posicions.pop();
      ++i;
    }
    //No vertexes found
    return -1;
  }
*/
bool em_falta_x_aliment(int queen_id) {
  if (ant(queen_id).reserve[0] == 0) return true;
  if (ant(queen_id).reserve[1] == 0) return true;
  if (ant(queen_id).reserve[2] == 0) return true;
  return false;
}

int que_aliment_em_falta(int queen_id) {
  if (ant(queen_id).reserve[0] == 0) return 0;
  else if (ant(queen_id).reserve[1] == 0) return 1;
  else if (ant(queen_id).reserve[2] == 0) return 2;
  else return 3;
}

bool posValida(Position& p, Visitadesx &v) {
  Pos p2;
  p2.i = p.r;
  p2.j = p.c;
  return (pos_ok(p2) and not v[p.r][p.c] and cell(p2).type != Water);
  //  return p.r >= 0 and p.r < m.size() and p.c >= 0 and p.c < m[p.r].size() and not v[p.r][p.c] and m[p.r][p.c] != 'X';
}

int distancia_hasta_Queen(Position start) {
  Visitadesx encolados (board_rows(), vector<bool>(board_cols(), false));
  queue<Position> Q;
  Q.push(start);
  encolados[start.r][start.c] = true;
  while (not Q.empty()) {
      Position p = Q.front();
      Q.pop();
      Pos p2;
      p2.i = p.r;
      p2.j = p.c;
      if (pos_ok(p2) and cell(p2).id != -1 and ant(cell(p2).id).type == Queen and ant(cell(p2).id).player == me()) return p.d;
      Position up(p.r - 1, p.c, p.d + 1);
      if (posValida(up, encolados)) {
          Q.push(up);
          encolados[up.r][up.c] = true;
      }
      Position down(p.r + 1, p.c, p.d + 1);
      if (posValida(down, encolados)) {
          Q.push(down);
          encolados[down.r][down.c] = true;
      }
      Position left(p.r, p.c - 1, p.d + 1);
      if (posValida(left, encolados)) {
          Q.push(left);
          encolados[left.r][left.c] = true;
      }
      Position right(p.r, p.c + 1, p.d + 1);
      if (posValida(right, encolados)) {
          Q.push(right);
          encolados[right.r][right.c] = true;
      }
  }
  return -1;
}

void No_Suicidis_plz (NoSuicidisPlz &V, Dir d, Pos p){
  if (d == Right) V[p.i][p.j+1] = true;
  else if (d == Left) V[p.i][p.j-1] = true;
  else if (d == Down) V[p.i+1][p.j] = true;
  else if (d == Up) V[p.i-1][p.j] = true;

}

bool posicio_perillosa(Pos p, int worker_id, const NoSuicidisPlz &V){
  if(pos_ok(p) and V[p.i][p.j] == true)  return true;
  else return false;
}

int pos_valid_poner_huevos(Pos p) {
  for(int i = 0; i < 4; ++i){
    Pos aux = p + Dir(i);
    if(pos_ok(aux) and cell(aux).type != Water and cell(aux).id == -1) return i;
  }
  return 4;
}

void pon_huevos_Queen(int queen_id, bool &ha_puesto_huevo) {
  int carb, prot, lip;
  vector<int> my_worker_ids = workers(me()); //vector con ids de trabajadores
  int m = my_worker_ids.size();
  vector<int> my_soldier_ids = soldiers(me());
  int n = my_soldier_ids.size();

  carb = ant(queen_id).reserve[0];
  prot = ant(queen_id).reserve[1];
  lip = ant(queen_id).reserve[2];
  if(round() >= 225) {
    if (carb >= 1 and prot >= 1 and lip >= 1) {
      int d = pos_valid_poner_huevos(ant(queen_id).pos);
      if (d != 4) {
        lay(queen_id,Dir(d), Worker);
        ha_puesto_huevo = true;
      }
    }
  }
  else {
    if(m <= 3) {
      if (carb >= 1 and prot >= 1 and lip >= 1) {
        int d = pos_valid_poner_huevos(ant(queen_id).pos);
        if (d != 4) {
          lay(queen_id,Dir(d), Worker);
          ha_puesto_huevo = true;
        }
      }
    }
    else if(n <= 1 ) {
      if (carb >= 3 and prot >= 3 and lip >= 3) {
      int d = pos_valid_poner_huevos(ant(queen_id).pos);
      if (d != 4) {
        lay(queen_id,Dir(d), Soldier);
        ha_puesto_huevo = true;
        }
      }
    }
    else {
      if (carb >= 3 and prot >= 3 and lip >= 3) {
        int d = pos_valid_poner_huevos(ant(queen_id).pos);
        if (d != 4) {
            lay(queen_id,Dir(d), Soldier);
            ha_puesto_huevo = true;
        }
      }
      else if (carb >= 1 and prot >= 1 and lip >= 1) {
        int d = pos_valid_poner_huevos(ant(queen_id).pos);
        if (d != 4) {
          lay(queen_id,Dir(d), Worker);
          ha_puesto_huevo = true;
        }
      }
    }
  }
}

void WFF_radio_Queen (Visitadesx &V) {
  vector<int> my_queen_ids = queens(me());
  int queen_id = my_queen_ids[0];
  Pos p = ant(queen_id).pos;
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    if(pos_ok(aux)) V[aux.i][aux.j] = true;
    for(int j = 0; j < 4; ++j) {
      Pos aux2 = aux + Dir(j);
      if(pos_ok(aux2) and pos_ok(aux)) V[aux2.i][aux2.j] =  true;
      }
    }
  }
/*
void WFF_radio_Queen (Visitadesx &V) {
  vector<int> my_queen_ids = queens(me());
  int queen_id = my_queen_ids[0];
  Pos p_Queen = ant(queen_id).pos;
  for(int i = 0; i < 4; ++i) {
    Pos aux = p_Queen + Dir(i);
    if(pos_ok(aux)) V[aux.i][aux.j] = true;
  }
  if (pos_ok(p_Queen+Up+Right)) V[(p_Queen+Up+Right).i][(p_Queen+Up+Right).j] = true;
  if (pos_ok(p_Queen+Up+Left)) V[(p_Queen+Up+Left).i][(p_Queen+Up+Left).j] = true;
  if (pos_ok(p_Queen+Down+Right)) V[(p_Queen+Down+Right).i][(p_Queen+Down+Right).j] = true;
  if (pos_ok(p_Queen+Down+Left)) V[(p_Queen+Down+Left).i][(p_Queen+Down+Left).j] = true;
}
*/
void Queen_takes_food(int queen_id, Pos p, bool &ha_comido, NoSuicidisPlz &NoSuicidis){
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    Dir d = Dir(i);
    if (pos_ok(aux) and cell(aux).type != Water and cell(aux).bonus != None and cell(aux).id == -1 and not posicio_perillosa(aux, queen_id, NoSuicidis)) {
      ha_comido = true;
      move(queen_id, Dir(i));
      No_Suicidis_plz(NoSuicidis, Dir(i), p);
    }
  }
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    for(int j = 0; j < 4; ++j) {
        Pos aux2 = aux + Dir(j);
        if (pos_ok(aux2) and cell(aux2).type != Water and pos_ok(aux) and cell(aux).type != Water and cell(aux).id == -1 and cell(aux2).bonus != None and cell(aux2).id == -1 and not posicio_perillosa(aux, queen_id, NoSuicidis) and not posicio_perillosa(aux2, queen_id, NoSuicidis)){
              ha_comido = true;
              move(queen_id, Dir(i));
              No_Suicidis_plz(NoSuicidis, Dir(i), p);
            }
          }
        }
    }
/*
void Queen_takes_food(int queen_id, Pos p, bool &ha_comido, NoSuicidisPlz &NoSuicidis){
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    if (pos_ok(aux) and cell(aux).bonus != None and cell(aux).id == -1 and not posicio_perillosa(aux, queen_id, NoSuicidis)) {
      ha_comido = true;
      move(queen_id, Dir(i));
      No_Suicidis_plz(NoSuicidis, Dir(i), p);
      }
  }

  if(not ha_comido){
    if(pos_ok(p+Up+Right) and cell(p+Up+Right).bonus != None) {
      if(pos_ok(p+Up) and cell(p+Up).id == -1 and not posicio_perillosa(p + Up, queen_id, NoSuicidis)) {
        ha_comido = true;
        move(queen_id, Up);
        No_Suicidis_plz(NoSuicidis, Up, p);
        }
      else if(pos_ok(p+Right) and cell(p+Right).bonus == -1 and not posicio_perillosa(p + Right, queen_id, NoSuicidis)) {
        ha_comido = true;
        move(queen_id, Right);
        No_Suicidis_plz(NoSuicidis, Right, p);
        }
    }

    else if(pos_ok(p+Up+Left) and cell(p+Up+Left).bonus != None) {
      if(pos_ok(p+Up) and cell(p+Up).id == -1 and not posicio_perillosa(p + Up, queen_id, NoSuicidis)) {
        ha_comido = true;
        move(queen_id, Up);
        No_Suicidis_plz(NoSuicidis, Up, p);
        }
      else if(pos_ok(p+Left) and cell(p+Left).bonus == -1 and not posicio_perillosa(p + Left, queen_id, NoSuicidis)) {
        ha_comido = true;
        move(queen_id, Left);
        No_Suicidis_plz(NoSuicidis, Left, p);
        }
    }

    else if(pos_ok(p+Down+Right) and cell(p+Down+Right).bonus != None) {
      if(pos_ok(p+Down) and cell(p+Down).id == -1 and not posicio_perillosa(p + Down, queen_id, NoSuicidis)) {
        ha_comido = true;
        move(queen_id, Down);
        No_Suicidis_plz(NoSuicidis, Down, p);
        }
      else if(pos_ok(p+Right) and cell(p+Right).bonus == -1 and not posicio_perillosa(p + Right, queen_id, NoSuicidis)) {
        ha_comido = true;
        move(queen_id, Right);
        No_Suicidis_plz(NoSuicidis, Right, p);
        }
    }
    else if(pos_ok(p+Down+Left) and cell(p+Down+Left).bonus != None) {
      if(pos_ok(p+Left) and cell(p+Left).id == -1 and not posicio_perillosa(p + Left, queen_id, NoSuicidis)) {
        ha_comido = true;
        move(queen_id, Left);
        No_Suicidis_plz(NoSuicidis, Left, p);
        }
      else if(pos_ok(p+Down) and cell(p+Down).bonus == -1 and not posicio_perillosa(p + Down, queen_id, NoSuicidis)) {
        ha_comido = true;
        move(queen_id, Down);
        No_Suicidis_plz(NoSuicidis, Down, p);
        }
    }
  }
}
*/
bool posicio_perillosa_soldiers(Pos p, int soldier_id){
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    if (pos_ok(aux) and cell(aux).id != -1 and ant(cell(aux).id).type != Worker and (ant(cell(aux).id).type == Queen or (ant(cell(aux).id).type == Soldier and ant(cell(aux).id).life <= ant(soldier_id).life)) and ant(cell(aux).id).player != me()) return true;
  }
  return false;
}

bool posicio_perillosa_soldiers_kamikazes(Pos p, int soldier_id){
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    if (pos_ok(aux) and cell(aux).id != -1 and (ant(cell(aux).id).type == Queen or (ant(cell(aux).id).type == Soldier and ant(cell(aux).id).life < ant(soldier_id).life)) and ant(cell(aux).id).player != me()) return true;
  }
  return false;
}

bool posicio_perillosa_enemics(Pos p, int worker_id){
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    if (pos_ok(aux) and cell(aux).id != -1 and cell(aux).id != worker_id and ant(cell(aux).id).player != me()) return true;
  }
  return false;
}

bool posicio_perillosa_Queen(Pos p, int queen_id) {
    for(int i = 0; i < 4; ++i) {
      Pos aux = p + Dir(i);
      if (pos_ok(aux) and cell(aux).id != -1 and cell(aux).id !=queen_id and ant(cell(aux).id).player != me() and ant(cell(aux).id).type == Queen) return true;
    }
    return false;
}

bool valid_position_soldiers (const Visitadesx &V, Pos p) {
  return (pos_ok(p) and cell(p).type != Water and not V[p.i][p.j] and ((cell(p).id != -1  and ant(cell(p).id).player != me() ) or cell(p).id == -1));
}

bool valid_position_Queen(const Visitadesx &V, Pos p) {
  return (pos_ok(p) and cell(p).type != Water and not V[p.i][p.j] and ((cell(p).id != -1  and ant(cell(p).id).player != me() and ant(cell(p).id).type != Queen) or cell(p).id == -1));
}

bool soldat_adjacent(Pos p, int soldier_id) {
  for(int i = 0; i < 4; ++i){
    Pos aux = p + Dir(i);
    if (pos_ok(aux) and cell(aux).id != -1 and ant(cell(aux).id).type == Soldier and ant(cell(aux).id).life > ant(soldier_id).life and ant(cell(aux).id).player != me()) return true;
  }
  return false;
}

int dir_soldat_adjacent(Pos p, int soldier_id) {
  for(int i = 0; i < 4; ++i){
    Pos aux = p + Dir(i);
    if (pos_ok(aux) and cell(aux).id != -1 and ant(cell(aux).id).type == Soldier and ant(cell(aux).id).life > ant(soldier_id).life and ant(cell(aux).id).player != me()) return i;
  }
  return -1;
}

bool worker_adjacent(Pos p, int worker_id){
  for(int i = 0; i < 4; ++i){
    Pos aux = p + Dir(i);
    if (pos_ok(aux) and cell(aux).id != -1 and ant(cell(aux).id).type == Worker and ant(cell(aux).id).life > ant(worker_id).life and ant(cell(aux).id).player != me()) return true;
  }
  return false;
}

int dir_worker_adjacent(Pos p, int worker_id){
  for(int i = 0; i < 4; ++i){
    Pos aux = p + Dir(i);
    if (pos_ok(aux) and cell(aux).id != -1 and ant(cell(aux).id).type == Worker and ant(cell(aux).id).life > ant(worker_id).life and ant(cell(aux).id).player != me()) return i;
  }
  return -1;
}

bool tiene_mas_workers_que_yo(Pos p, Dir d) {
  int player = ant(cell(p+d).id).player;
  vector <int> workerenemic = workers(player);
  vector <int> my_workers = workers(me());
  if(workerenemic.size() > my_workers.size()) return true;
  else return false;
}

Dir bfs_soldiers(int soldier_id, Pos p, const NoSuicidisPlz &NoSuicidis) {
  Visitadesx Visitades (board_rows(), vector<bool>(board_cols(), false));
  Direcciox Direccions (board_rows(), vector<Dir>(board_cols()));
  queue< Pos > posicions;
  posicions.push(p);
  Visitades[p.i][p.j] = true;
  if (soldat_adjacent(p, soldier_id)) return Dir(dir_soldat_adjacent(p, soldier_id));
  bool prim = true;

  while (not posicions.empty()) {
    Pos actual = posicions.front();
    posicions.pop();
    if (pos_ok(actual) and cell(actual).id != -1 and ant(cell(actual).id).type == Worker and ant(cell(actual).id).player != me()) return Direccions[actual.i][actual.j];
    Pos aux;
    for(int i = 0; i < 4; ++i){
      aux = actual + Dir(i);
       if (pos_ok(aux) and valid_position_soldiers(Visitades, aux)) {
        if (prim) Direccions[aux.i][aux.j] = Dir(i);
        else Direccions[aux.i][aux.j] = Direccions[actual.i][actual.j];
        if ((posicio_perillosa(aux, soldier_id, NoSuicidis) == false) and not posicio_perillosa_soldiers(aux,soldier_id)) posicions.push(aux);
        Visitades[aux.i][aux.j] = true;
        }
      }
      prim = false;
    }
    return Dir(4);
  }

Dir bfs_food_for_Queen (int worker_id, Pos p,const NoSuicidisPlz &NoSuicidis) {
  Visitadesx Visitades (board_rows(), vector<bool>(board_cols(), false));
  Direcciox Direccions (board_rows(), vector<Dir>(board_cols()));
  queue< Pos > posicions;
  posicions.push(p);
  Visitades[p.i][p.j] = true;
  int f = posicions.front().i;
  int c = posicions.front().j;

  if (pos_ok(p + Right) and valid_position_ffQ(Visitades, p+Right)) {
      if(posicio_perillosa(p + Right, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Right, worker_id)) posicions.push(p + Right);
      Visitades[f][c+1] = true;
      Direccions[f][c+1] = Right;
      if (cell(p + Right).id != -1 and ant(cell(p + Right).id).type == Queen and ant(cell(p + Right).id).player == me()) leave(worker_id);
    }
  if (pos_ok(p + Left) and valid_position_ffQ(Visitades, p+Left)) {
    if(posicio_perillosa(p + Left, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Left, worker_id))posicions.push(p + Left);
    Visitades[f][c-1] = true;
    Direccions[f][c-1] = Left;
    if (cell(p + Left).id != -1 and ant(cell(p + Left).id).type == Queen and ant(cell(p + Left).id).player == me())  leave(worker_id);

  }
  if (pos_ok(p + Down) and valid_position_ffQ(Visitades, p+Down)) {
      if(posicio_perillosa(p + Down, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Down, worker_id)) posicions.push(p + Down);
    Visitades[f+1][c] = true;
    Direccions[f+1][c] = Down;
    if (cell(p + Down).id != -1 and ant(cell(p + Down).id).type == Queen and ant(cell(p + Down).id).player == me())  leave(worker_id);
    }

  if (pos_ok(p + Up) and valid_position_ffQ(Visitades, p+Up)) {
     if(posicio_perillosa(p + Up, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Up, worker_id))posicions.push(p + Up);
    Visitades[f-1][c] = true;
    Direccions[f-1][c] = Up;
    if (cell(p + Up).id != -1 and ant(cell(p + Up).id).type == Queen and ant(cell(p + Up).id).player == me())  leave(worker_id);
    }

    for(int i = 0; i < 4; ++i) {
      Pos aux = p + Dir(i);
      Dir d = Dir(i);
      if (pos_ok(aux)  and valid_position_ffQ(Visitades, aux) and cell(aux).id != -1 and ant(cell(aux).id).type == Queen and ant(cell(aux).id).player == me()) leave(worker_id);
      for(int j = 0; j < 4; ++j) {
        Pos aux2 = aux + Dir(j);
        if (pos_ok(aux2) and pos_ok(aux) and valid_position_ffQ(Visitades, aux2) and valid_position_ffQ(Visitades, aux) and cell(aux2).id != -1 and ant(cell(aux2).id).type == Queen and ant(cell(aux2).id).player == me()) leave(worker_id);
        }
      }
/*

  if (pos_ok(p + Up + Right) and valid_position_ffQ(Visitades, p+Right + Up)) {
      if (cell(p + Right+ Up).id != -1 and ant(cell(p + Right + Up).id).type == Queen and ant(cell(p + Right + Up).id).player == me()) leave(worker_id);
      }

    if (pos_ok(p + Up + Left) and valid_position_ffQ(Visitades, p+Left + Up)) {
        if (cell(p + Left+ Up).id != -1 and ant(cell(p + Left + Up).id).type == Queen and ant(cell(p + Left + Up).id).player == me()) leave(worker_id);
      }

    if (pos_ok(p + Down + Right) and valid_position_ffQ(Visitades, p+Right + Down)) {
          if (cell(p + Right+ Down).id != -1 and ant(cell(p + Right + Down).id).type == Queen and ant(cell(p + Right + Down).id).player == me()) leave(worker_id);
        }

    if (pos_ok(p + Down + Left) and valid_position_ffQ(Visitades, p+Left + Down)) {
          if (cell(p + Left+ Down).id != -1 and ant(cell(p + Left + Down).id).type == Queen and ant(cell(p + Left + Down).id).player == me()) leave(worker_id);
        }
*/
  posicions.pop();

  while (not posicions.empty()) {

    Pos actual = posicions.front();
    int f = actual.i;
    int c = actual.j;
    posicions.pop();

      if (pos_ok(actual + Right) and valid_position_ffQ(Visitades, actual+Right)) {
          if(posicio_perillosa(actual + Right, worker_id, NoSuicidis) == false)posicions.push(actual + Right);
          Visitades[f][c+1] = true;
          Direccions[f][c+1] = Direccions[actual.i][actual.j];
          if (cell(actual + Right).id != -1 and ant(cell(actual + Right).id).type == Queen and ant(cell(actual + Right).id).player == me()) return Direccions[f][c+1];
      }

      if (pos_ok(actual + Left) and valid_position_ffQ(Visitades, actual + Left)) {
         if(posicio_perillosa(actual + Left, worker_id, NoSuicidis) == false)posicions.push(actual + Left);
        Visitades[f][c-1] = true;
        Direccions[f][c-1] = Direccions[actual.i][actual.j];
        if (cell(actual + Left).id != -1 and ant(cell(actual + Left).id).type == Queen and ant(cell(actual + Left).id).player == me()) return Direccions[f][c-1];
      }

      if (pos_ok(actual + Down) and valid_position_ffQ(Visitades, actual + Down)) {
        if(posicio_perillosa(actual+ Down, worker_id, NoSuicidis) == false) posicions.push(actual + Down);
        Visitades[f+1][c] = true;
        Direccions[f+1][c] =  Direccions[actual.i][actual.j];
        if (cell(actual + Down).id != -1 and ant(cell(actual + Down).id).type == Queen and ant(cell(actual + Down).id).player == me()) return Direccions[f+1][c];
      }

      if (pos_ok(actual + Up) and valid_position_ffQ(Visitades, actual + Up)) {
        if(posicio_perillosa(actual + Up, worker_id, NoSuicidis) == false) posicions.push(actual + Up);
        Visitades[f-1][c] = true;
        Direccions[f-1][c] =  Direccions[actual.i][actual.j];
        if (cell(actual + Up).id != -1 and ant(cell(actual + Up).id).type == Queen and ant(cell(actual + Up).id).player == me())  return Direccions[f-1][c];

    }
  }
  return Dir(4);
}

Dir bfs_workers_for_food (int worker_id, Pos p, const NoSuicidisPlz &NoSuicidis) {
    Visitadesx Visitades (board_rows(), vector<bool>(board_cols(), false));
    Direcciox Direccions (board_rows(), vector<Dir>(board_cols()));
    queue< Pos > posicions;
    posicions.push(p);
    Visitadesx ZonaQueen (board_rows(), vector<bool>(board_cols(), false));
    WFF_radio_Queen(ZonaQueen);
    Visitades[p.i][p.j] = true;
    if (worker_adjacent(p, worker_id) and not tiene_mas_workers_que_yo(p, Dir(dir_worker_adjacent(p, worker_id)))) return Dir(dir_worker_adjacent(p, worker_id));
    int f = posicions.front().i;
    int c = posicions.front().j;


    if (pos_ok(p + Right) and not Visitades[f][c+1] and cell(p+Right).type != Water and cell(p + Right).id == -1) {
      Visitades[f][c+1] = true;
      Direccions[f][c+1] = Right;
      if (posicio_perillosa(p + Right, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Right, worker_id)) {
          posicions.push(p + Right);
          if ((cell(p + Right).bonus != None) and  not ZonaQueen[(p+Right).i][(p+Right).j]) return Direccions[f][c+1];
         }
      }

    if (pos_ok(p + Left) and not Visitades[f][c-1] and cell(p + Left).type != Water and cell(p + Left).id == -1) {
      Visitades[f][c-1] = true;
      Direccions[f][c-1] = Left;
      if (posicio_perillosa(p + Left, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Left, worker_id)) {
        posicions.push(p + Left);
        if (cell(p + Left).bonus != None and  not ZonaQueen[(p+Left).i][(p+Left).j]) return Direccions[f][c-1];
      }
    }
    if (pos_ok(p + Down) and not Visitades[f+1][c] and cell(p + Down).type != Water and cell(p + Down).id == -1) {
      Visitades[f+1][c] = true;
      Direccions[f+1][c] = Down;
      if (posicio_perillosa(p + Down, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Down, worker_id)){
       posicions.push(p + Down);
        if (cell(p + Down).bonus != None and  not ZonaQueen[(p+Down).i][(p+Down).j]) return Direccions[f+1][c];
      }
    }
    if (pos_ok(p + Up) and not Visitades[f-1][c] and cell(p + Up).type != Water and cell(p + Up).id == -1) {
      Visitades[f-1][c] = true;
      Direccions[f-1][c] = Up;
      if (posicio_perillosa(p + Up, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Up, worker_id)){
         posicions.push(p + Up);
         if (cell(p + Up).bonus != None and  not ZonaQueen[(p+Up).i][(p+Up).j]) return Direccions[f-1][c];
       }
    }

    posicions.pop();

    while (not posicions.empty()) {

      Pos actual = posicions.front();
      int f = actual.i;
      int c = actual.j;

      posicions.pop();

        if (pos_ok(actual + Right) and not Visitades[f][c+1] and cell(actual+Right).type != Water and cell(actual + Right).id == -1) {
            if (posicio_perillosa(actual + Right, worker_id, NoSuicidis) == false) posicions.push(actual + Right);
            Visitades[f][c+1] = true;
            Direccions[f][c+1] = Direccions[actual.i][actual.j];
            if (cell(actual + Right).bonus != None and not ZonaQueen[(actual+Right).i][(actual+Right).j]) return Direccions[f][c+1];
        }

        if (pos_ok(actual + Left) and not Visitades[f][c-1] and cell(actual+Left).type != Water and cell(actual + Left).id == -1) {
          if (posicio_perillosa(actual + Left, worker_id, NoSuicidis) == false) posicions.push(actual + Left);
          Visitades[f][c-1] = true;
          Direccions[f][c-1] = Direccions[actual.i][actual.j];
          if (cell(actual + Left).bonus != None  and not ZonaQueen[(actual+Left).i][(actual+Left).j]) return Direccions[f][c-1];
        }

        if (pos_ok(actual + Down) and not Visitades[f+1][c] and cell(actual+Down).type != Water and cell(actual + Down).id == -1) {
          if (posicio_perillosa(actual + Down, worker_id,NoSuicidis) == false) posicions.push(actual + Down);
          Visitades[f+1][c] = true;
          Direccions[f+1][c] =  Direccions[actual.i][actual.j];
          if (cell(actual + Down).bonus != None and not ZonaQueen[(actual+Down).i][(actual+Down).j]) return Direccions[f+1][c];
        }

        if (pos_ok(actual + Up) and not Visitades[f-1][c] and cell(actual+Up).type != Water and cell(actual + Up).id == -1) {
          if (posicio_perillosa(actual + Up, worker_id,NoSuicidis) == false) posicions.push(actual + Up);
          Visitades[f-1][c] = true;
          Direccions[f-1][c] =  Direccions[actual.i][actual.j];
          if (cell(actual + Up).bonus != None and not ZonaQueen[(actual+Up).i][(actual+Up).j]) return Direccions[f-1][c];
      }
    }
    return Dir(4);
}

Dir bfs_workers_for_x_alimento(int worker_id, Pos p, const NoSuicidisPlz &NoSuicidis, int n){
  Visitadesx Visitades (board_rows(), vector<bool>(board_cols(), false));
  Direcciox Direccions (board_rows(), vector<Dir>(board_cols()));
  queue< Pos > posicions;
  posicions.push(p);
  WFF_radio_Queen(Visitades);
  Visitades[p.i][p.j] = true;
  if (worker_adjacent(p, worker_id) and not tiene_mas_workers_que_yo(p, Dir(dir_worker_adjacent(p, worker_id)))) return Dir(dir_worker_adjacent(p, worker_id));

  BonusType alimento;
  if(n == 0) alimento = Bread;
  else if (n == 1) alimento = Leaf;
  else alimento = Seed;

  int f = posicions.front().i;
  int c = posicions.front().j;

  //direccions.push(Up);//No importa, es para el primer front que tacharemos;
  if (pos_ok(p + Right) and not Visitades[f][c+1] and cell(p+Right).type != Water and cell(p + Right).id == -1) {
    Visitades[f][c+1] = true;
    Direccions[f][c+1] = Right;
    if (posicio_perillosa(p + Right, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Right, worker_id)) {
        posicions.push(p + Right);
        if (cell(p + Right).bonus == alimento) return Direccions[f][c+1];
       }
    }

  if (pos_ok(p + Left) and not Visitades[f][c-1] and cell(p + Left).type != Water and cell(p + Left).id == -1) {
    Visitades[f][c-1] = true;
    Direccions[f][c-1] = Left;
    if (posicio_perillosa(p + Left, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Left, worker_id)) {
      posicions.push(p + Left);
      if (cell(p + Left).bonus == alimento)  Direccions[f][c-1];
    }
  }
  if (pos_ok(p + Down) and not Visitades[f+1][c] and cell(p + Down).type != Water and cell(p + Down).id == -1) {
    Visitades[f+1][c] = true;
    Direccions[f+1][c] = Down;
    if (posicio_perillosa(p + Down, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Down, worker_id)){
     posicions.push(p + Down);
      if (cell(p + Down).bonus == alimento) return Direccions[f+1][c];
    }
  }
  if (pos_ok(p + Up) and not Visitades[f-1][c] and cell(p + Up).type != Water and cell(p + Up).id == -1) {
    Visitades[f-1][c] = true;
    Direccions[f-1][c] = Up;
    if (posicio_perillosa(p + Up, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Up, worker_id)){
       posicions.push(p + Up);
       if (cell(p + Up).bonus == alimento) return Direccions[f-1][c];
     }
  }

  posicions.pop();

  while (not posicions.empty()) {

    Pos actual = posicions.front();
    int f = actual.i;
    int c = actual.j;

    posicions.pop();

      if (pos_ok(actual + Right) and not Visitades[f][c+1] and cell(actual+Right).type != Water and cell(actual + Right).id == -1) {
          if (posicio_perillosa(actual + Right, worker_id, NoSuicidis) == false) posicions.push(actual + Right);
          Visitades[f][c+1] = true;
          Direccions[f][c+1] = Direccions[actual.i][actual.j];
          if (cell(actual + Right).bonus == alimento) return Direccions[f][c+1];
      }

      if (pos_ok(actual + Left) and not Visitades[f][c-1] and cell(actual+Left).type != Water and cell(actual + Left).id == -1) {
        if (posicio_perillosa(actual + Left, worker_id, NoSuicidis) == false) posicions.push(actual + Left);
        Visitades[f][c-1] = true;
        Direccions[f][c-1] = Direccions[actual.i][actual.j];
        if (cell(actual + Left).bonus == alimento) return Direccions[f][c-1];
      }

      if (pos_ok(actual + Down) and not Visitades[f+1][c] and cell(actual+Down).type != Water and cell(actual + Down).id == -1) {
        if (posicio_perillosa(actual + Down, worker_id,NoSuicidis) == false) posicions.push(actual + Down);
        Visitades[f+1][c] = true;
        Direccions[f+1][c] =  Direccions[actual.i][actual.j];
        if (cell(actual + Down).bonus == alimento) return Direccions[f+1][c];
      }

      if (pos_ok(actual + Up) and not Visitades[f-1][c] and cell(actual+Up).type != Water and cell(actual + Up).id == -1) {
        if (posicio_perillosa(actual + Up, worker_id,NoSuicidis) == false) posicions.push(actual + Up);
        Visitades[f-1][c] = true;
        Direccions[f-1][c] =  Direccions[actual.i][actual.j];
        if (cell(actual + Up).bonus == alimento) return Direccions[f-1][c];
    }
  }
  return Dir(4);
}

Dir bfs_Queen_for_food (int queen_id, Pos p, const NoSuicidisPlz &NoSuicidis) {
  Visitadesx Visitades (board_rows(), vector<bool>(board_cols(), false));
  Direcciox Direccions (board_rows(), vector<Dir>(board_cols()));
  queue< Pos > posicions;
  posicions.push(p);
  Visitades[p.i][p.j] = true;
  int n = que_aliment_em_falta(queen_id);
  BonusType alimento;
  BonusType alimento2;
  if(n == 0) {
    alimento = Bread;
    alimento2 = Leaf;
  }
  else if (n == 1){
     alimento = Leaf;
     alimento2 = Seed;
   }
  else {
    alimento = Seed;
    alimento2 = Bread;
  }
  bool prim = true;

  while (not posicions.empty()) {
    Pos actual = posicions.front();
    posicions.pop();

    if (pos_ok(actual) and (cell(actual).bonus == alimento or cell(actual).bonus == alimento2)) return Direccions[actual.i][actual.j];
    Pos aux;
    for(int i = 0; i < 4; ++i){
      aux = actual + Dir(i);
       if (pos_ok(aux) and valid_position_Queen(Visitades, aux)) {
        if (prim) Direccions[aux.i][aux.j] = Dir(i);
        else Direccions[aux.i][aux.j] = Direccions[actual.i][actual.j];
        if (not posicio_perillosa (aux, queen_id, NoSuicidis) and not posicio_perillosa_Queen(aux, queen_id)) posicions.push(aux);
        Visitades[aux.i][aux.j] = true;
        }
      }
      prim = false;
    }
    return Dir(4);
  }

Dir bfs_Queen_for_food2 (int queen_id, Pos p, const NoSuicidisPlz &NoSuicidis) {
    Visitadesx Visitades (board_rows(), vector<bool>(board_cols(), false));
    Direcciox Direccions (board_rows(), vector<Dir>(board_cols()));
    queue< Pos > posicions;
    posicions.push(p);
    Visitades[p.i][p.j] = true;

    bool prim = true;

    while (not posicions.empty()) {
      Pos actual = posicions.front();
      posicions.pop();

      if (pos_ok(actual) and (cell(actual).bonus != None)) return Direccions[actual.i][actual.j];
      Pos aux;
      for(int i = 0; i < 4; ++i){
        aux = actual + Dir(i);
         if (pos_ok(aux) and valid_position_Queen(Visitades, aux)) {
          if (prim) Direccions[aux.i][aux.j] = Dir(i);
          else Direccions[aux.i][aux.j] = Direccions[actual.i][actual.j];
          if (not posicio_perillosa (aux, queen_id, NoSuicidis) and not posicio_perillosa_Queen(aux, queen_id)) posicions.push(aux);
          Visitades[aux.i][aux.j] = true;
          }
        }
        prim = false;
      }
      return Dir(4);
    }

Dir bfs_soldiers_kamikaze(int soldier_id, Pos p, const NoSuicidisPlz &NoSuicidis){
  Visitadesx Visitades (board_rows(), vector<bool>(board_cols(), false));
  Direcciox Direccions (board_rows(), vector<Dir>(board_cols()));
  queue< Pos > posicions;
  posicions.push(p);
  Visitades[p.i][p.j] = true;
  bool prim = true;

  while (not posicions.empty()) {
    Pos actual = posicions.front();
    posicions.pop();
    if (pos_ok(actual) and cell(actual).id != -1 and ant(cell(actual).id).type == Soldier and ant(cell(actual).id).player != me() and ant(cell(actual).id).life >= ant(soldier_id).life) return Direccions[actual.i][actual.j];
    Pos aux;
    for(int i = 0; i < 4; ++i){
      aux = actual + Dir(i);
       if (pos_ok(aux) and valid_position_soldiers(Visitades, aux)) {
        if (prim) Direccions[aux.i][aux.j] = Dir(i);
        else Direccions[aux.i][aux.j] = Direccions[actual.i][actual.j];
        if ((posicio_perillosa(aux, soldier_id, NoSuicidis) == false) and not posicio_perillosa_soldiers_kamikazes(aux,soldier_id)) posicions.push(aux);
        Visitades[aux.i][aux.j] = true;
        }
      }
      prim = false;
    }
    return Dir(4);
  }

void Queen_Kills (int queen_id, Pos p, bool &ha_matado, NoSuicidisPlz &NoSuicidis) {
  for(int i = 0; i < 4; ++i) {
  Pos aux = p + Dir(i);
  if (pos_ok(aux) and cell(aux).id != -1 and ant(cell(aux).id).player != me() and ant(cell(aux).id).type != Queen) {
    ha_matado = true;
    move(queen_id, Dir(i));
    No_Suicidis_plz(NoSuicidis, Dir(i), p);
    }
  }
}

void kamikaze(Pos p, NoSuicidisPlz &V, int worker_id) {
  Dir d = bfs_soldiers(worker_id, p, V);
  move(worker_id, d);
  No_Suicidis_plz(V, d, p);
}

void kamikaze_soldiers(Pos p, NoSuicidisPlz &V, int soldier_id) {
  Dir d = bfs_soldiers_kamikaze (soldier_id, p, V);
  move(soldier_id, d);
  No_Suicidis_plz(V, d, p);
}

int que_player_soy(vector<int> V) {
  vector<int> V2;
  for(int i = 0; i < 4;++i) {
    V2 = workers(i);
    if(V == V2) return i;
  }
  return -1;
}

void vector_jugadores(int n, vector<int> &players) {
  int j = 0;
  for(int i = 0; i < 4; ++i) {
    if(n != i) {
      players[j] = i;
      ++j;
    }
  }
}

virtual void play () {
    // Command my workers in random order.
    vector<int> my_worker_ids = workers(me()); //vector con ids de trabajadores
    int n = que_player_soy(my_worker_ids);
    vector<int> players(3);
    vector_jugadores(n,players);
    vector<int> perm = random_permutation(my_worker_ids.size());
    vector<int> my_queen_ids = queens(me());
    vector<int> my_soldier_ids = soldiers(me());
    vector<int> perm_Sldr = random_permutation(my_soldier_ids.size());

    NoSuicidisPlz V (board_rows(), vector<bool>(board_cols(), false));
    int queen_id = my_queen_ids[0];
    Pos p_Queen = ant(queen_id).pos;

            //WORKERS
    for (int k = 0; k < int(perm.size()); ++k) {
      int worker_id = my_worker_ids[perm[k]];
      Ant worker = ant(worker_id);
      Pos p = worker.pos;
      Cell c = cell(p);
      int n = -1;
      if (c.bonus != None) {
        if (valid_position_closetoQueen(p)) {
          if(em_falta_x_aliment(queen_id))  n = que_aliment_em_falta(queen_id);
          if(n >= 0 and k == 0 and not alguien_lleva_x_alimento(n, worker_id)) {
                Dir d = bfs_workers_for_x_alimento(worker_id, p, V, n);
                move(worker_id, d);
                No_Suicidis_plz(V,d,p);
              }
          else {
            Dir d = bfs_workers_for_food(worker_id, p, V);
            move(worker_id, d);
            No_Suicidis_plz(V,d,p);
          }
        }
        else if (worker.bonus != None) {
          Position Position_Worker(p.i,p.j,0);
          int dist = distancia_hasta_Queen(Position_Worker);
          if(ant(cell(p).id).life >= dist) kamikaze(p, V, worker_id);
          else {
            Dir d = bfs_food_for_Queen(worker_id, p, V);
            move (worker_id, d);
            No_Suicidis_plz(V,d,p);
          }
        }
        else {
         take(worker_id);
       }
     }
      else if (worker.bonus != None) {
        Position Position_Worker(p.i,p.j,0);
        int dist = distancia_hasta_Queen(Position_Worker);
        if(ant(cell(p).id).life < dist) kamikaze(p, V, worker_id);
        else {
          Dir d = bfs_food_for_Queen(worker_id, p, V);
          move (worker_id, d);
          No_Suicidis_plz(V,d,p);
        }
      }
      else {
        if(em_falta_x_aliment(queen_id))  n = que_aliment_em_falta(queen_id);
        if(n >= 0 and k == 0 and not alguien_lleva_x_alimento(n, worker_id)) {
              Dir d = bfs_workers_for_x_alimento(worker_id, p, V, n);
              move(worker_id, d);
              No_Suicidis_plz(V,d,p);
            }
        else {
          Dir d = bfs_workers_for_food(worker_id, p, V);
          move(worker_id, d);
          No_Suicidis_plz(V, d, p);
        }
      }
    }

    //QUEEN
    bool ha_matado = false;
    Queen_Kills(queen_id, p_Queen, ha_matado, V);
    if(ha_matado == false){
      bool ha_comido = false;
      Queen_takes_food(queen_id, p_Queen, ha_comido, V);
      if (ha_comido == false){
        bool ha_puesto_huevo = false;
        pon_huevos_Queen(queen_id, ha_puesto_huevo);
        if(not ha_puesto_huevo){
          if (my_worker_ids.empty()){
            Dir d_queen = bfs_Queen_for_food (queen_id, p_Queen, V);
            move(queen_id, d_queen);
            No_Suicidis_plz(V, d_queen, p_Queen);
          }
          else if(my_worker_ids.size() <= 1) {
            Dir d_queen = bfs_Queen_for_food2 (queen_id, p_Queen, V);
            move(queen_id, d_queen);
            No_Suicidis_plz(V, d_queen, p_Queen);
          }
        }
      }
    }

          //SOLDIERS
    for (int k = 0; k < int(perm_Sldr.size()); ++k) {
      int soldier_id = my_soldier_ids[perm_Sldr[k]];
      Ant soldier = ant(soldier_id);
      Pos p_soldier = soldier.pos;

      if(workers(players[1]).empty() and workers(players[0]).empty() and workers(players[2]).empty()) kamikaze_soldiers(p_soldier, V, soldier_id);
      else {
        Dir d_soldier = bfs_soldiers(soldier_id, p_soldier,V);
        move(soldier_id, d_soldier);
        No_Suicidis_plz(V, d_soldier, p_soldier);
      }
    }
  };
};
/**
 * Do not modify the following line.
 */
RegisterPlayer(PLAYER_NAME);
