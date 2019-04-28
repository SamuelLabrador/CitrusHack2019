//class Food {
//  String name;
//  String calories;
//
//  Food(this.name, this.calories);
//
//  Food.fromSnapshot(DataSnapshot snapshot) :
//      name = snapshot.name,
//      calories = snapshot.value["calories"];
//
//  toJSON() {
//    return {
//      "name": name,
//      "calories" : calories,
//    };
//  }
//
//}