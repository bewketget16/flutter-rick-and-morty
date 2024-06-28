import 'package:flutter/material.dart';
import 'package:rick_and_morty/app/model/character.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(character.image),
            ),
            const SizedBox(height: 16),
            Text(
              'Name: ${character.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${character.status}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Species: ${character.species}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Gender: ${character.gender}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (character.type.isNotEmpty)
              Text(
                'Type: ${character.type}',
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 8),
            Text(
              'Location: ${character.location}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
