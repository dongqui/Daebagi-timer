import 'package:catodo/core/db.dart';
import 'package:catodo/features/data/models/character.dart';
import 'package:catodo/features/data/repositories/character_repository.dart';
import 'package:catodo/features/data/repositories/planet_repository.dart';
import 'package:catodo/features/data/repositories/selected_character_repository.dart';
// import 'package:firebase_core/firebase_core.dart';

Future<void> initDB() async {
  await DatabaseService.instance.setUpDB();

  await Future.wait([
    initCharacter(),
    PlanetRepository.instance.addDefaultPlanetsIfEmpty(),
  ]);

  // await Firebase.initializeApp(); // Firebase 초기화
}

Future<void> initCharacter() async {
  await CharacterRepository.instance.initializeDefaultCharacters();
  await SelectedCharacterRepository.instance
      .initSelectedCharacter(defaultCharacters[0].name);
}
