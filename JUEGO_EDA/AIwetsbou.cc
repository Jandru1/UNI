#include "Player.hh"


/**
 * Write the name of your player and save this file
 * with the same name and .cc extension.
 */
#define PLAYER_NAME wetsbou

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


  /**
   * Types and attributes for your player can be defined here.
   */

   const vector<NutrientType> nutrients = { Carbohydrate, Protein, Lipid };


  // Default direction to be used during all match.
   Dir default_dir;


  // Returns true if winning.
   bool winning() {
      for (int pl = 0; pl < num_players(); ++pl)
         if (pl != me() and score(me()) <= score(pl))
         return false;
      return true;
   }



//Se que he de tenir la posicio actual per saber quines direccions agafar
//Falta una cua/pila/matriu per guardar les posicions del tauler on he estat per tal de no repetir posicions
//La worker ha de fer: agafar menjar. Com s'agafa menjar?
//  Utilitzant les posicions lliures. Miro totes les posicions que puc agafar i em guardo on he estat.
// M'he de mirar l'estructura d'un bfs per saber com va

//Tema posicio: s'ha de restar -1 per tal de saber on estas tambe?
//Caldria saber la distancia respecte el punt d'origen?  NO

//Estr bfs;
//Cua: S'afegeix la posicio on estas
//Matriu_bool: true a la casella on estas
//dins d'un bucle anar mirant fins que la cua estigui buida

   //typedef vector< vector<Dir> > Matrix; ---> inutil?
   typedef vector< vector<bool> > Matrix_bool; //---> no se com crear una estructura boolenaa que guardi les posicions en les que he estat.
   typedef queue <Dir> Cua_Direccions;
   typedef pair<Pos, Dir> Pair_pos_dir;


   //retorna true si la meva reina està a prop de la posicio p
   bool radar(Pos p, int my_queen) {
      vector<Pos> adjacents = { p+Up, p+Up+Right, p+Right, p+Right+Down, p+Down, p+Down+Left, p+Left, p+Left+Up, p+Up+Up, p+Up+Up+Right, p+Up+Up+Right+Right, p+Right+Right+Up, p+Right+Right, p+Right+Right+Down, p+Right+Right+Down+Down, p+Down+Down+Right, p+Down+Down, p+Down+Down+Left, p+Down+Down+Left+Left, p+Left+Left+Down, p+Left+Left, p+Left+Left+Up, p+Left+Left+Up+Up, p+Up+Up+Left}; //TODO: Afegir mes posicions
      for (int i = 0; i < adjacents.size(); ++i) {
         if (pos_ok(adjacents[i])
             and cell(adjacents[i]).id != -1
             and ant(cell(adjacents[i]).id).type == Queen
             and ant(cell(adjacents[i]).id).player == me()) return true;
      }
      return false;
   }
   bool radar_enemic(Pos p){
      vector<Pos> adjacents = { p+Up, p+Up+Right, p+Right, p+Right+Down, p+Down, p+Down+Left, p+Left, p+Left+Up, p+Up+Up, p+Up+Up+Right, p+Up+Up+Right+Right, p+Right+Right+Up, p+Right+Right, p+Right+Right+Down, p+Right+Right+Down+Down, p+Down+Down+Right, p+Down+Down, p+Down+Down+Left, p+Down+Down+Left+Left, p+Left+Left+Down, p+Left+Left, p+Left+Left+Up, p+Left+Left+Up+Up, p+Up+Up+Left}; //TODO: Afegir mes posicions
      for (int i = 0; i < adjacents.size(); ++i) {
         if (pos_ok(adjacents[i])
             and cell(adjacents[i]).id != -1
             and ant(cell(adjacents[i]).id).type == Queen
             and ant(cell(adjacents[i]).id).player != me()) return true;
      }
      return false;
   }

   Dir bfs_worker_to_food(Pos &p, bool &found, Matrix_bool &mat_menjar_localitzat, Matrix_bool &mat_pos_actual, int queen_id){
      Matrix_bool mat_bool_w(board_rows(), vector<bool>(board_cols(), false));
      queue<Pair_pos_dir> cua_direccions_posicions;
      Pair_pos_dir pos_dir_ini;
      Pos pos_inicial = p;
      Dir dir_inicial;
      for(int i = 0; i < 4; ++i) {
         Pos pos_actual = p + Dir(i);

         if (pos_ok(pos_actual) and
            cell(pos_actual).type != Water and
            cell(pos_actual).id == -1 and
            not mat_pos_actual[pos_actual.i][pos_actual.j]){
               dir_inicial = Dir(i);
               pos_dir_ini.first = pos_actual;
               pos_dir_ini.second = dir_inicial;
               cua_direccions_posicions.push(pos_dir_ini);
         }
      }
      mat_bool_w[pos_inicial.i][pos_inicial.j] = true;

      while(!cua_direccions_posicions.empty()){
         Pos pos_act = cua_direccions_posicions.front().first;
         Dir dir_aux = cua_direccions_posicions.front().second;
         cua_direccions_posicions.pop();

         if (cell(pos_act).bonus != None and not radar(pos_act, queen_id)){
            found = true;
            mat_menjar_localitzat[pos_act.i][pos_act.j] = true;
            return dir_aux;
         }
         Pos pos_seg;

         for(int i = 0; i < 4; ++i){
            pos_seg = pos_act + Dir(i);

            if (pos_ok(pos_seg) and
               cell(pos_seg).type != Water and
               not mat_bool_w [pos_seg.i][pos_seg.j] and
               not mat_menjar_localitzat[pos_seg.i][pos_seg.j] and
               not mat_pos_actual[pos_seg.i][pos_seg.j]) {
                  Pair_pos_dir pos_dir_seg;
                  pos_dir_seg.first = pos_seg;
                  pos_dir_seg.second = dir_aux;
                  cua_direccions_posicions.push(pos_dir_seg);
                  mat_bool_w[pos_seg.i][pos_seg.j] = true;
            }
         }
      }
      return Up;
   }


   Dir bfs_worker_to_queen(Pos &p, bool &found, Matrix_bool &mat_pos_actual){
      vector<int> my_queens_ids = queens(me());
      int queen_id = my_queens_ids[0];
      Matrix_bool mat_bool_w_q(board_rows(), vector<bool>(board_cols(), false));
      queue<Pair_pos_dir> cua_direccions_posicions;
      Pair_pos_dir pos_dir_ini;
      Pos pos_inicial = p;
      Dir dir_inicial;
      for(int i = 0; i < 4; ++i) {
         Pos pos_actual = p + Dir(i);

         if (pos_ok(pos_actual) and
            cell(pos_actual).type != Water and
            cell(pos_actual).id == -1 and
            not mat_pos_actual[pos_actual.i][pos_actual.j]){
               dir_inicial = Dir(i);
               pos_dir_ini.first = pos_actual;
               pos_dir_ini.second = dir_inicial;
               cua_direccions_posicions.push(pos_dir_ini);
         }
      }
      mat_bool_w_q[pos_inicial.i][pos_inicial.j] = true;

      while(!cua_direccions_posicions.empty()){
         Pos pos_act = cua_direccions_posicions.front().first;
         Dir dir_aux = cua_direccions_posicions.front().second;
         cua_direccions_posicions.pop();


         if (cell(pos_act).id == queen_id){
            found = true;
            return dir_aux;
         }
         Pos pos_seg;

         for(int i = 0; i < 4; ++i){
            pos_seg = pos_act + Dir(i);

            if (pos_ok(pos_seg) and cell(pos_seg).type != Water and  not mat_bool_w_q [pos_seg.i][pos_seg.j]) {
               //if (cell(pos_seg).id == -1){
                  Pair_pos_dir pos_dir_seg;
                  pos_dir_seg.first = pos_seg;
                  pos_dir_seg.second = dir_aux;
                  cua_direccions_posicions.push(pos_dir_seg);
                  mat_bool_w_q[pos_seg.i][pos_seg.j] = true;
               //}
            }
         }
      }
      return Up;
   }


   Dir bfs_queen(Pos &p, bool &found, Matrix_bool &mat_pos_actual){
      vector<int> my_queens_ids = queens(me());
      int queen_id = my_queens_ids[0];
      Matrix_bool mat_bool_w_q(board_rows(), vector<bool>(board_cols(), false));
      queue<Pair_pos_dir> cua_direccions_posicions;
      Pair_pos_dir pos_dir_ini;
      Pos pos_inicial = p;
      Dir dir_inicial;
      for(int i = 0; i < 4; ++i) {
         Pos pos_actual = p + Dir(i);

         if (pos_ok(pos_actual) and
            cell(pos_actual).type != Water and
            cell(pos_actual).id == -1 and
            not mat_pos_actual[pos_actual.i][pos_actual.j]){
               dir_inicial = Dir(i);
               pos_dir_ini.first = pos_actual;
               pos_dir_ini.second = dir_inicial;
               cua_direccions_posicions.push(pos_dir_ini);
         }
      }
      mat_bool_w_q[pos_inicial.i][pos_inicial.j] = true;

      while(!cua_direccions_posicions.empty()){
         Pos pos_act = cua_direccions_posicions.front().first;
         Dir dir_aux = cua_direccions_posicions.front().second;
         cua_direccions_posicions.pop();
         //cout <<"La id de la meva queen es: "<<queen_id<< endl;


         if (cell(pos_act).bonus != None and not radar_enemic(pos_act)){
            found = true;
            return dir_aux;
         }
         Pos pos_seg;

         for(int i = 0; i < 4; ++i){
            pos_seg = pos_act + Dir(i);

            if (pos_ok(pos_seg) and cell(pos_seg).type != Water and not mat_bool_w_q [pos_seg.i][pos_seg.j]) {
               //if (cell(pos_seg).id == -1){
                  Pair_pos_dir pos_dir_seg;
                  pos_dir_seg.first = pos_seg;
                  pos_dir_seg.second = dir_aux;
                  cua_direccions_posicions.push(pos_dir_seg);
                  mat_bool_w_q[pos_seg.i][pos_seg.j] = true;
               //}
            }
         }
      }
      return Up;
   }



   Dir bfs_sold(Pos &p, bool &found, Matrix_bool &mat_pos_actual){
      Matrix_bool mat_bool_w_q(board_rows(), vector<bool>(board_cols(), false));
      queue<Pair_pos_dir> cua_direccions_posicions;
      Pair_pos_dir pos_dir_ini;
      Pos pos_inicial = p;
      Dir dir_inicial;
      for(int i = 0; i < 4; ++i) {
         Pos pos_actual = p + Dir(i);

         if (pos_ok(pos_actual) and
            cell(pos_actual).type != Water and
            cell(pos_actual).id != -1 and
            ant(cell(pos_actual).id).type == Worker and
            ant(cell(pos_actual).id).player != me() and
            not mat_pos_actual[pos_actual.i][pos_actual.j]){
               dir_inicial = Dir(i);
               pos_dir_ini.first = pos_actual;
               pos_dir_ini.second = dir_inicial;
               cua_direccions_posicions.push(pos_dir_ini);
         }
         else if (pos_ok(pos_actual) and
            cell(pos_actual).type != Water and
            cell(pos_actual).id == -1 and
            ant(cell(pos_actual).id).player != me() and
            not mat_pos_actual[pos_actual.i][pos_actual.j]){
               dir_inicial = Dir(i);
               pos_dir_ini.first = pos_actual;
               pos_dir_ini.second = dir_inicial;
               cua_direccions_posicions.push(pos_dir_ini);
            }
      }
      mat_bool_w_q[pos_inicial.i][pos_inicial.j] = true;

      while(!cua_direccions_posicions.empty()){
         Pos pos_act = cua_direccions_posicions.front().first;
         Dir dir_aux = cua_direccions_posicions.front().second;
         cua_direccions_posicions.pop();
         //cout <<"La id de la meva queen es: "<<queen_id<< endl;

         if(cell(pos_act).id != -1){
            if (ant(cell(pos_act).id).type != Queen and ant(cell(pos_act).id).player != me()){
               found = true;
               return dir_aux;
            }
         }
         Pos pos_seg;

         for(int i = 0; i < 4; ++i){
            pos_seg = pos_act + Dir(i);

            if (pos_ok(pos_seg) and cell(pos_seg).type != Water and not mat_bool_w_q [pos_seg.i][pos_seg.j]) {
               //if (cell(pos_seg).id == -1){
                  Pair_pos_dir pos_dir_seg;
                  pos_dir_seg.first = pos_seg;
                  pos_dir_seg.second = dir_aux;
                  cua_direccions_posicions.push(pos_dir_seg);
                  mat_bool_w_q[pos_seg.i][pos_seg.j] = true;
               //}
            }
         }
      }
      return Up;
   }

  /**
   * Play method, invoked once per each round.
   */
   virtual void play () {
      Matrix_bool mat_pos_actual(board_rows(), vector<bool>(board_cols(), false));//Matriu per saber quines posicions tinc ocupades a la mateixa ronda
      vector<int> my_workers_ids = workers(me());
      vector<int> perm_work = random_permutation(my_workers_ids.size());
      vector<int> my_queens_ids = queens(me());
      vector<int> perm_queens = random_permutation(my_queens_ids.size());
      vector<int> my_soldiers_ids = soldiers(me());
      vector<int> perm_sold = random_permutation(my_soldiers_ids.size());

   //Queens

      int queen_id = my_queens_ids[perm_queens[0]];
      Ant queen = ant(queen_id);
      Pos pos_queen = queen.pos;
      Cell c = cell(pos_queen);
      bool found_menjar = false;
      if (my_soldiers_ids.size() == 0){
         if(queen.reserve[0] >= 3 and queen.reserve[1] >= 3 and queen.reserve[2] >= 3){
            for(int i = 0; i< 4; ++i){
               if(pos_ok(pos_queen +Dir(i)) and cell(pos_queen + Dir(i)).type != Water and cell(pos_queen + Dir(i)).id == -1){
                  lay(queen_id, Dir(i), Soldier);
               }
            }
         }
      }
      else if(my_workers_ids.size() == 0){
         if(queen.reserve[0] >= 1 and queen.reserve[1] >= 1 and queen.reserve[2] >= 1){
            for(int i = 0; i< 4; ++i){
               if(pos_ok(pos_queen +Dir(i)) and cell(pos_queen + Dir(i)).type != Water and cell(pos_queen + Dir(i)).id == -1){
                  lay(queen_id, Dir(i), Worker);
               }
            }
         }
      }
      else if(my_soldiers_ids.size() > 0 ){
         if(queen.reserve[0] >= 1 and queen.reserve[1] >= 1 and queen.reserve[2] >= 1){
            for(int i = 0; i< 4; ++i){
               if(pos_ok(pos_queen +Dir(i)) and cell(pos_queen + Dir(i)).type != Water and cell(pos_queen + Dir(i)).id == -1){
                  lay(queen_id, Dir(i), Worker);
               }
            }
         }
      }

      Dir dir_queen = bfs_queen(pos_queen, found_menjar, mat_pos_actual);
      if (found_menjar){
         move(queen_id, dir_queen);
         mat_pos_actual[(queen.pos + dir_queen).i][(queen.pos + dir_queen).j] = true;
      }




//Workers

      Matrix_bool mat_menjar_localitzat(board_rows(), vector<bool>(board_cols(), false));
      for (int k = 0; k < int(perm_work.size()); ++k) {
         int worker_id = my_workers_ids[perm_work[k]];
         Ant worker = ant(worker_id);
         //Ant soldier = ant(worker_id);
         //Ant queen = ant(worker_id);
         Pos pos_work = worker.pos;
         Cell c = cell(pos_work);
         if (worker.bonus != None) {

            if (radar(pos_work, queen_id) and c.bonus == None) leave(worker_id);

            else {
               bool found_queen = false;
               //cout << "Eii ara tinc bonus"<<endl;
               Dir dir_w_queen = bfs_worker_to_queen(pos_work, found_queen, mat_pos_actual);
               if (found_queen){
                  move(worker_id, dir_w_queen);
                  mat_pos_actual[(worker.pos + dir_w_queen).i][(worker.pos + dir_w_queen).j] = true;
               }
               /*for(int i = 0; i < 4 ++i){
                  if(pos_work + Dir(i) == cell(pos_act).id == queen_id)

               }*/
            }
         }
         else if(worker.bonus == None) {
            bool found = false;
            Dir dir_w = bfs_worker_to_food(pos_work, found, mat_menjar_localitzat, mat_pos_actual, queen_id);
            if (c.bonus != None and not radar(pos_work, queen_id))
               take(worker_id);

            if (found){
               move(worker_id,dir_w);
               mat_pos_actual[(worker.pos + dir_w).i][(worker.pos + dir_w).j] = true;
            }

         }

      }
         //else if (worker.type == Soldier){ //La Ant es una Soldier

         //else {//La Ant es una queen
//Soldiers

     for (int k = 0; k < int(perm_sold.size()); ++k) {
         int soldier_id = my_soldiers_ids[perm_sold[k]];
         Ant soldier = ant(soldier_id);
         Pos pos_sold = soldier.pos;
         Cell c = cell(pos_sold);
         bool found_enemic = false;
         Dir dir_soldier = bfs_sold(pos_sold, found_enemic, mat_pos_actual);
         if (found_enemic){
            move(soldier_id, dir_soldier);
            mat_pos_actual[(soldier.pos + dir_soldier).i][(soldier.pos + dir_soldier).j] = true;
         }
      }




     // move(worker_id, dir_w);

         /*if           (c.bonus != None)  take(worker_id);     // More checks should be done here...
         else if (worker.bonus != None) leave(worker_id);     // More checks should be done here...
         else {
         Pos q = p + Up;
         if (pos_ok(q) and cell(q).type != Water and cell(q).id == -1)
            move(worker_id, bfs(p, )); // Move up if not water and no ant is there.
         }
      }
   } */
   }

};


/**
 * Do not modify the following line.
 */
RegisterPlayer(PLAYER_NAME);
