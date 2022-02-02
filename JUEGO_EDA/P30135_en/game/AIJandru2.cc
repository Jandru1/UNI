#include <iostream>
#include <vector>
#include <queue>
#include <stack>
using namespace std;


typedef vector<vector<char> > Matrix;
typedef vector<vector<bool> > Visitadesx;



#include "Player.hh"
/**
 * Write the name of your player and save this file
 * with the same name and .cc extension.
 */
#define PLAYER_NAME Jandru_v3

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

  typedef vector<vector<Dir> > Direcciox;
  typedef vector<vector<bool> > NoSuicidisPlz;

  const vector<NutrientType> nutrients = { Carbohydrate, Protein, Lipid };
/*
  bool valid_position (Pos p, const Visitadesx &V){
      if (not V[p.i][p.j] and cell(p).type != Water and cell(p).id == -1) return true;
    }
*/

  /*
  bool valid_position_Queen (const Visitadesx&V, Pos p) {
    return (cell(p).type != Water and not V[p.i][p.j] and cell(p).id == -1);
  }
  */
bool valid_position_ffQ (const Visitadesx &V, Pos p) {
    if(cell(p).bonus == None and cell(p).type != Water and not V[p.i][p.j] and ((cell(p).id != -1 and ant(cell(p).id).type == Queen and ant(cell(p).id).player == me()) or cell(p).id == -1)) return true;
    else return false;
  }

bool hi_ha_Queen(Pos p) {
  if(cell(p).id != -1 and ant(cell(p).id).type == Queen and ant(cell(p).id).player == me()) return true;
  else return false;
}

bool valid_position_closetoQueen (Pos p) {
  if (hi_ha_Queen(p + Right)) return true;
  else if(hi_ha_Queen(p + Left)) return true;
  else if(hi_ha_Queen(p + Down)) return true;
  else if(hi_ha_Queen(p + Up)) return true;
  else if(hi_ha_Queen(p + Up + Left)) return true;
  else if(hi_ha_Queen(p + Up + Right)) return true;
  else if(hi_ha_Queen(p + Down + Left)) return true;
  else if(hi_ha_Queen(p + Down + Right)) return true;
  else return false;
}

void No_Suicidis_plz (NoSuicidisPlz &V, Dir d, Pos p){
  if (d == Right) V[p.i][p.j+1] = true;
  else if (d == Left) V[p.i][p.j-1] = true;
  else if (d == Down) V[p.i+1][p.j] = true;
  else if (d == Up) V[p.i-1][p.j] = true;

}

bool posicio_perillosa(Pos p, int worker_id, const NoSuicidisPlz &V){
  if(V[p.i][p.j] == true)  return true;
  else return false;
}
/*
bool posicio_perillosa_ffQ(Pos p, int worker_id) {
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    if ((cell(aux).id != -1 and cell(aux).id != worker_id) and ant(cell(aux).id).type != Queen) return true;
  }
  return false;
}
*/
int pos_valid_poner_huevos(Pos p) {
  for(int i = 0; i < 4; ++i){
    Pos aux = p + Dir(i);
    if(cell(aux).id == -1) return i;
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

  if(m <= 2) {
    if (carb >= 1 and prot >= 1 and lip >= 1) {
      int d = pos_valid_poner_huevos(ant(queen_id).pos);
      if (d != 4) {
        lay(queen_id,Dir(d), Worker);
        ha_puesto_huevo = true;
      }
    }
  }
  else if(n <= 1) {
    if (carb >= 3 and prot >= 3 and lip >= 3) {
    int d = pos_valid_poner_huevos(ant(queen_id).pos);
    if (d != 4) {
      lay(queen_id,Dir(d), Worker);
      ha_puesto_huevo = true;
    }
    lay(queen_id,Dir(d), Soldier);
    ha_puesto_huevo = true;
    }
  }
  else {
    if (carb >= 1 and prot >= 1 and lip >= 1) {
      int d = pos_valid_poner_huevos(ant(queen_id).pos);
      if (d != 4) {
        lay(queen_id,Dir(d), Worker);
        ha_puesto_huevo = true;
      }
      lay(queen_id,Dir(d), Worker);
      ha_puesto_huevo = true;
    }
  }
}

void WFF_radio_Queen (Visitadesx &V) {
  vector<int> my_queen_ids = queens(me());
  int queen_id = my_queen_ids[0];
  Pos p_Queen = ant(queen_id).pos;
  if (pos_ok(p_Queen + Right)) V[(p_Queen+Right).i][(p_Queen+Right).j] = true;
  if(pos_ok(p_Queen + Left))V[(p_Queen+Left).i][(p_Queen+Left).j] = true;
  if(pos_ok(p_Queen + Down)) V[(p_Queen+Down).i][(p_Queen+Down).j] = true;
  if(pos_ok(p_Queen + Up)) V[(p_Queen+Up).i][(p_Queen+Up).j] = true;;
  if(pos_ok(p_Queen + Up + Left)) V[(p_Queen+Up+Left).i][(p_Queen+Up+Left).j] = true;
  if(pos_ok(p_Queen + Up + Right)) V[(p_Queen+Up+Right).i][(p_Queen+Up+Right).j] = true;
  if(pos_ok(p_Queen + Down + Left)) V[(p_Queen+Down+Left).i][(p_Queen+Down+Left).j] = true;
  if(pos_ok(p_Queen + Down + Right)) V[(p_Queen+Down+Right).i][(p_Queen+Down+Right).j] = true;
}

void Queen_takes_food(int queen_id, Pos p, bool &ha_comido, NoSuicidisPlz &NoSuicidis) {
  for(int i = 0; i < 4; ++i) {
  Pos aux = p + Dir(i);
  if (cell(aux).bonus != None and cell(aux).id == -1 and not posicio_perillosa(p, queen_id, NoSuicidis)) {
    ha_comido = true;
    move(queen_id, Dir(i));
    No_Suicidis_plz(NoSuicidis, Dir(i), p);
    }
    }
  }

bool posicio_perillosa_soldiers(Pos p, int soldier_id){
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    if (cell(aux).id != -1 and ant(cell(aux).id).type != Worker and ant(cell(aux).id).player != me()) return true;
  }
  return false;
}

bool posicio_perillosa_enemics(Pos p, int worker_id){
  for(int i = 0; i < 4; ++i) {
    Pos aux = p + Dir(i);
    if (cell(aux).id != -1 and ant(cell(aux).id).player != me()) return true;
  }
  return false;
}

bool valid_position_soldiers (const Visitadesx &V, Pos p) {
  return (cell(p).type != Water and not V[p.i][p.j] and ((cell(p).id != -1  and ant(cell(p).id).player != me() ) or cell(p).id == -1));
}

Dir bfs_soldiers(int soldier_id, Pos p, const NoSuicidisPlz &NoSuicidis) {
  Visitadesx Visitades (board_rows(), vector<bool>(board_cols(), false));
  Direcciox Direccions (board_rows(), vector<Dir>(board_cols()));
  queue< Pos > posicions;
  posicions.push(p);
  Visitades[p.i][p.j] = true;

  bool prim = true;

  while (not posicions.empty()) {
    Pos actual = posicions.front();
    posicions.pop();

    if(cell(actual).id != -1 and ant(cell(actual).id).type == Worker and ant(cell(actual).id).player != me()) return Direccions[actual.i][actual.j];
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
    if(posicio_perillosa(p + Left, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Left, worker_id)) posicions.push(p + Left);
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


  if (pos_ok(p + Up + Right) and valid_position_ffQ(Visitades, p+Up+Right)) {
     if(posicio_perillosa(p + Up + Right, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Up + Right, worker_id))posicions.push(p + Up + Right);
    Visitades[f-1][c+1] = true;
    Direccions[f-1][c+1] = Up;
    if (cell(p + Up + Right).id != -1 and ant(cell(p + Up + Right).id).type == Queen and ant(cell(p + Up + Right).id).player == me())  leave(worker_id);

  }
  if (pos_ok(p + Up + Left) and valid_position_ffQ(Visitades, p+Up+Left)) {
     if(posicio_perillosa(p + Up+Left, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Up+Left, worker_id))posicions.push(p + Up+Left);
    Visitades[f-1][c-1] = true;
    Direccions[f-1][c-1] = Up;
    if (cell(p + Up + Left).id != -1 and ant(cell(p + Up + Left).id).type == Queen and ant(cell(p + Up + Left).id).player == me())  leave(worker_id);

  }
  if (pos_ok(p + Down + Right) and valid_position_ffQ(Visitades, p+Down+Right)) {
     if(posicio_perillosa(p + Down + Right, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Down+Right, worker_id))posicions.push(p +Down+Right);
    Visitades[f+1][c+1] = true;
    Direccions[f+1][c+1] = Down;
    if (cell(p + Down+Right).id != -1 and ant(cell(p + Down+Right).id).type == Queen and ant(cell(p + Down+Right).id).player == me())  leave(worker_id);

  }
  if (pos_ok(p + Down+Left) and valid_position_ffQ(Visitades, p+Down+Left)) {
     if(posicio_perillosa(p + Down +Left, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(p+Down+Left, worker_id))posicions.push(p + Down+Left);
    Visitades[f+1][c-1] = true;
    Direccions[f+1][c-1] = Down;
    if (cell(p + Down+Left).id != -1 and ant(cell(p +Down+Left).id).type == Queen and ant(cell(p + Down+Left).id).player == me())  leave(worker_id);

  }

  posicions.pop();

  while (not posicions.empty()) {

    Pos actual = posicions.front();
    int f = actual.i;
    int c = actual.j;
    posicions.pop();

      if (pos_ok(actual + Right) and valid_position_ffQ(Visitades, actual+Right)) {
          if(posicio_perillosa(actual + Right, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(actual+Right, worker_id)) posicions.push(actual + Right);
          Visitades[f][c+1] = true;
          Direccions[f][c+1] = Direccions[actual.i][actual.j];
          if (cell(actual + Right).id != -1 and ant(cell(actual + Right).id).type == Queen and ant(cell(actual + Right).id).player == me()) return Direccions[f][c+1];
      }

      if (pos_ok(actual + Left) and valid_position_ffQ(Visitades, actual + Left)) {
         if(posicio_perillosa(actual + Left, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(actual+Left, worker_id))posicions.push(actual + Left);
        Visitades[f][c-1] = true;
        Direccions[f][c-1] = Direccions[actual.i][actual.j];
        if (cell(actual + Left).id != -1 and ant(cell(actual + Left).id).type == Queen and ant(cell(actual + Left).id).player == me()) return Direccions[f][c-1];
      }

      if (pos_ok(actual + Down) and valid_position_ffQ(Visitades, actual + Down)) {
        if(posicio_perillosa(actual+ Down, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(actual+Down, worker_id)) posicions.push(actual + Down);
        Visitades[f+1][c] = true;
        Direccions[f+1][c] =  Direccions[actual.i][actual.j];
        if (cell(actual + Down).id != -1 and ant(cell(actual + Down).id).type == Queen and ant(cell(actual + Down).id).player == me()) return Direccions[f+1][c];
      }

      if (pos_ok(actual + Up) and valid_position_ffQ(Visitades, actual + Up)) {
        if(posicio_perillosa(actual + Up, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(actual+Up, worker_id)) posicions.push(actual + Up);
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
    WFF_radio_Queen(Visitades);
    Visitades[p.i][p.j] = true;

    int f = posicions.front().i;
    int c = posicions.front().j;

    //direccions.push(Up);//No importa, es para el primer front que tacharemos;
    if (pos_ok(p + Right) and not Visitades[f][c+1] and cell(p+Right).type != Water and cell(p + Right).id == -1) {
      Visitades[f][c+1] = true;
      Direccions[f][c+1] = Right;
      if (posicio_perillosa(p + Right, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Right, worker_id)) {
          posicions.push(p + Right);
          if (cell(p + Right).bonus != None) return Direccions[f][c+1];
         }
      }

    if (pos_ok(p + Left) and not Visitades[f][c-1] and cell(p + Left).type != Water and cell(p + Left).id == -1) {
      Visitades[f][c-1] = true;
      Direccions[f][c-1] = Left;
      if (posicio_perillosa(p + Left, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Left, worker_id)) {
        posicions.push(p + Left);
        if (cell(p + Left).bonus != None) return Direccions[f][c-1];
      }
    }
    if (pos_ok(p + Down) and not Visitades[f+1][c] and cell(p + Down).type != Water and cell(p + Down).id == -1) {
      Visitades[f+1][c] = true;
      Direccions[f+1][c] = Down;
      if (posicio_perillosa(p + Down, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Down, worker_id)){
       posicions.push(p + Down);
        if (cell(p + Down).bonus != None) return Direccions[f+1][c];
      }
    }
    if (pos_ok(p + Up) and not Visitades[f-1][c] and cell(p + Up).type != Water and cell(p + Up).id == -1) {
      Visitades[f-1][c] = true;
      Direccions[f-1][c] = Up;
      if (posicio_perillosa(p + Up, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(p+Up, worker_id)){
         posicions.push(p + Up);
         if (cell(p + Up).bonus != None) return Direccions[f-1][c];
       }
    }

    posicions.pop();

    while (not posicions.empty()) {

      Pos actual = posicions.front();
      int f = actual.i;
      int c = actual.j;

      posicions.pop();

        if (pos_ok(actual + Right) and not Visitades[f][c+1] and cell(actual+Right).type != Water and cell(actual + Right).id == -1) {
            if (posicio_perillosa(actual + Right, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(actual+Right, worker_id)) posicions.push(actual + Right);
            Visitades[f][c+1] = true;
            Direccions[f][c+1] = Direccions[actual.i][actual.j];
            if (cell(actual + Right).bonus != None) return Direccions[f][c+1];
        }

        if (pos_ok(actual + Left) and not Visitades[f][c-1] and cell(actual+Left).type != Water and cell(actual + Left).id == -1) {
          if (posicio_perillosa(actual + Left, worker_id, NoSuicidis) == false and not posicio_perillosa_enemics(actual+Left, worker_id)) posicions.push(actual + Left);
          Visitades[f][c-1] = true;
          Direccions[f][c-1] = Direccions[actual.i][actual.j];
          if (cell(actual + Left).bonus != None) return Direccions[f][c-1];
        }

        if (pos_ok(actual + Down) and not Visitades[f+1][c] and cell(actual+Down).type != Water and cell(actual + Down).id == -1) {
          if (posicio_perillosa(actual + Down, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(actual+Down, worker_id)) posicions.push(actual + Down);
          Visitades[f+1][c] = true;
          Direccions[f+1][c] =  Direccions[actual.i][actual.j];
          if (cell(actual + Down).bonus != None) return Direccions[f+1][c];
        }

        if (pos_ok(actual + Up) and not Visitades[f-1][c] and cell(actual+Up).type != Water and cell(actual + Up).id == -1) {
          if (posicio_perillosa(actual + Up, worker_id,NoSuicidis) == false and not posicio_perillosa_enemics(actual + Up, worker_id)) posicions.push(actual + Up);
          Visitades[f-1][c] = true;
          Direccions[f-1][c] =  Direccions[actual.i][actual.j];
          if (cell(actual + Up).bonus != None) return Direccions[f-1][c];
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

  bool prim = true;

  while (not posicions.empty()) {
    Pos actual = posicions.front();
    posicions.pop();

    if (cell(actual).bonus != None)return Direccions[actual.i][actual.j];
    Pos aux;
    for(int i = 0; i < 4; ++i){
      aux = actual + Dir(i);
       if (pos_ok(aux) and cell(aux).type != Water and not Visitades[aux.i][aux.j]) {
        if (prim) Direccions[aux.i][aux.j] = Dir(i);
        else Direccions[aux.i][aux.j] = Direccions[actual.i][actual.j];
        if (posicio_perillosa(aux, queen_id, NoSuicidis) == false) posicions.push(aux);
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
  if (cell(aux).id != -1 and ant(cell(aux).id).player != me() and ant(cell(aux).id).type != Queen) {
    ha_matado = true;
    move(queen_id, Dir(i));
    No_Suicidis_plz(NoSuicidis, Dir(i), p);
    }
  }
}

virtual void play () {
    // Command my workers in random order.
    vector<int> my_worker_ids = workers(me()); //vector con ids de trabajadores
    vector<int> perm = random_permutation(my_worker_ids.size());
    vector<int> my_queen_ids = queens(me());
    vector<int> my_soldier_ids = soldiers(me());
    NoSuicidisPlz V (board_rows(), vector<bool>(board_cols(), false));

            //WORKERS
    for (int k = 0; k < int(perm.size()); ++k) {
      int worker_id = my_worker_ids[perm[k]];
      Ant worker = ant(worker_id);
      Pos p = worker.pos;
      Cell c = cell(p);
      if (c.bonus != None) {
        if (valid_position_closetoQueen(p)) {
          Dir d = bfs_workers_for_food(worker_id, p, V);
          move(worker_id, d);
          No_Suicidis_plz(V,d,p);
        }
        else if (worker.bonus != None) {
          Dir d = bfs_food_for_Queen(worker_id, p, V);
          move (worker_id, d);
          No_Suicidis_plz(V,d,p);
        }
        else {
         take(worker_id);
       }
     }
      else if (worker.bonus != None) {
        Dir d = bfs_food_for_Queen(worker_id, p, V);
        move (worker_id, d);
        No_Suicidis_plz(V,d,p);
      }

      else {
      Dir d = bfs_workers_for_food(worker_id, p, V);
      move(worker_id, d);
      No_Suicidis_plz(V, d, p);
      }
    }
          //QUEEN
    int queen_id = my_queen_ids[0];
    Pos p_Queen = ant(queen_id).pos;
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
      }
    }
  }
          //SOLDIERS
    vector<int> perm_Sldr = random_permutation(my_soldier_ids.size());
    for (int k = 0; k < int(perm_Sldr.size()); ++k) {
      int soldier_id = my_soldier_ids[perm_Sldr[k]];
      Ant soldier = ant(soldier_id);
      Pos p_soldier = soldier.pos;
      Dir d_soldier = bfs_soldiers(soldier_id, p_soldier,V);
      move(soldier_id, d_soldier);
      No_Suicidis_plz(V, d_soldier, p_soldier);
    }
  };
};




/**
 * Do not modify the following line.
 */
RegisterPlayer(PLAYER_NAME);
